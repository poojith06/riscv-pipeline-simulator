import re
import argparse

# RISC-V opcodes for the requested instructions
OPCODES = {
    "add":  0b0110011,  # From the image
    "sub":  0b0110011,  # From the image
    "and":  0b0110011,  # From the image
    "or":   0b0110011,  # From the image
    "addi": 0b0010011,  # From your additional info
    "ld":   0b0000011,  # From your additional info
    "sd":   0b0100011,  # From your additional info
    "beq":  0b1100011   # From your additional info
}

# RISC-V Function 3 codes
FUNCT3 = {
    "add":  0b000,  # From the image (0x0)
    "sub":  0b000,  # From the image (0x0)
    "and":  0b111,  # From the image (0x7)
    "or":   0b110,  # From the image (0x6)
    "addi": 0b000,  # From your additional info
    "ld":   0b011,  # From your additional info
    "sd":   0b011,  # From your additional info
    "beq":  0b000   # From your additional info
}

# RISC-V Function 7 codes
FUNCT7 = {
    "add": 0b0000000,  # From the image (0x00)
    "sub": 0b0100000,  # From the image (0x20)
    "and": 0b0000000,  # From the image (0x00)
    "or":  0b0000000   # From the image (0x00)
}

def parse_register(reg_str):
    """Parse register strings like x0, x1, etc."""
    if reg_str.startswith('x') or reg_str.startswith('X'):
        try:
            reg_num = int(reg_str[1:])
            if 0 <= reg_num <= 31:
                return reg_num
        except ValueError:
            pass
    
    # ABI register names
    reg_map = {
        "zero": 0, "ra": 1, "sp": 2, "gp": 3, "tp": 4,
        "t0": 5, "t1": 6, "t2": 7,
        "s0": 8, "fp": 8, "s1": 9,
        "a0": 10, "a1": 11, "a2": 12, "a3": 13, "a4": 14, "a5": 15, "a6": 16, "a7": 17,
        "s2": 18, "s3": 19, "s4": 20, "s5": 21, "s6": 22, "s7": 23, "s8": 24, "s9": 25, "s10": 26, "s11": 27,
        "t3": 28, "t4": 29, "t5": 30, "t6": 31
    }
    
    return reg_map.get(reg_str.lower(), -1)

def parse_immediate(imm_str):
    """Parse immediate values in various formats."""
    try:
        if imm_str.startswith('0x') or imm_str.startswith('0X'):
            return int(imm_str, 16)
        elif imm_str.startswith('0b') or imm_str.startswith('0B'):
            return int(imm_str, 2)
        else:
            return int(imm_str)
    except ValueError:
        return None

def parse_mem_offset(operand):
    """Parse memory offsets like 8(x5) into (offset, register)."""
    match = re.match(r'(-?\d+)\(([a-zA-Z][0-9a-zA-Z]*|[xX]\d+)\)', operand)
    if match:
        offset = int(match.group(1))
        reg = parse_register(match.group(2))
        return offset, reg
    return None, None

def encode_r_type(instr, rd, rs1, rs2):
    """Encode R-type instructions: add, sub, and, or."""
    opcode = OPCODES[instr]
    funct3 = FUNCT3[instr]
    funct7 = FUNCT7[instr]
    
    encoded = (funct7 << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode
    return encoded

def encode_i_type(instr, rd, rs1, imm):
    """Encode I-type instructions: addi, ld."""
    opcode = OPCODES[instr]
    funct3 = FUNCT3[instr]
    
    # For 12-bit immediate
    imm = imm & 0xFFF  # Ensure it's 12 bits
    
    encoded = (imm << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode
    return encoded

def encode_s_type(instr, rs1, rs2, imm):
    """Encode S-type instructions: sd."""
    opcode = OPCODES[instr]
    funct3 = FUNCT3[instr]
    
    imm = imm & 0xFFF  # 12-bit immediate
    imm_11_5 = (imm >> 5) & 0x7F  # Upper 7 bits
    imm_4_0 = imm & 0x1F  # Lower 5 bits
    
    encoded = (imm_11_5 << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | (imm_4_0 << 7) | opcode
    return encoded

def encode_b_type(instr, rs1, rs2, offset):
    """Encode B-type instructions: beq."""
    opcode = OPCODES[instr]
    funct3 = FUNCT3[instr]
    
    # B-type immediates are multiples of 2 (last bit is always 0)
    # Extract the bits according to the B-type format
    imm = offset & 0x1FFE  # 13-bit immediate (bit 0 is always 0)
    
    imm_12 = (offset >> 12) & 0x1      # bit 12
    imm_11 = (offset >> 11) & 0x1      # bit 11
    imm_10_5 = (offset >> 5) & 0x3F    # bits 10-5
    imm_4_1 = (offset >> 1) & 0xF      # bits 4-1
    
    encoded = (imm_12 << 31) | (imm_10_5 << 25) | (rs2 << 20) | (rs1 << 15) | \
              (funct3 << 12) | (imm_4_1 << 8) | (imm_11 << 7) | opcode
    return encoded

def parse_instruction(line):
    """Parse a RISC-V assembly instruction and return its components."""
    # Remove comments and trim whitespace
    line = re.sub(r'#.*$', '', line).strip()
    if not line:
        return None
    
    # Split into instruction and operands
    parts = re.split(r'\s+', line, 1)
    if len(parts) < 2:
        return parts[0], []
    
    instr = parts[0].lower()
    # Split operands and remove whitespace
    operands = [op.strip() for op in parts[1].split(',')]
    
    return instr, operands

def encode_instruction(instr, operands):
    """Encode a RISC-V instruction based on its mnemonic and operands."""
    if instr not in OPCODES:
        return None, f"Unsupported instruction: {instr}"
    
    # R-type: add rd, rs1, rs2
    if instr in ["add", "sub", "and", "or"]:
        if len(operands) != 3:
            return None, f"{instr} requires 3 operands: rd, rs1, rs2"
        
        rd = parse_register(operands[0])
        rs1 = parse_register(operands[1])
        rs2 = parse_register(operands[2])
        
        if -1 in [rd, rs1, rs2]:
            return None, f"Invalid register in: {instr} {', '.join(operands)}"
        
        return encode_r_type(instr, rd, rs1, rs2), None
    
    # I-type (immediate): addi rd, rs1, imm
    elif instr == "addi":
        if len(operands) != 3:
            return None, f"{instr} requires 3 operands: rd, rs1, imm"
        
        rd = parse_register(operands[0])
        rs1 = parse_register(operands[1])
        imm = parse_immediate(operands[2])
        
        if -1 in [rd, rs1] or imm is None:
            return None, f"Invalid operand in: {instr} {', '.join(operands)}"
        
        return encode_i_type(instr, rd, rs1, imm), None
    
    # I-type (load): ld rd, offset(rs1)
    elif instr == "ld":
        if len(operands) != 2:
            return None, f"{instr} requires 2 operands: rd, offset(rs1)"
        
        rd = parse_register(operands[0])
        offset, rs1 = parse_mem_offset(operands[1])
        
        if -1 in [rd, rs1] or offset is None:
            return None, f"Invalid operand in: {instr} {', '.join(operands)}"
        
        return encode_i_type(instr, rd, rs1, offset), None
    
    # S-type: sd rs2, offset(rs1)
    elif instr == "sd":
        if len(operands) != 2:
            return None, f"{instr} requires 2 operands: rs2, offset(rs1)"
        
        rs2 = parse_register(operands[0])
        offset, rs1 = parse_mem_offset(operands[1])
        
        if -1 in [rs1, rs2] or offset is None:
            return None, f"Invalid operand in: {instr} {', '.join(operands)}"
        
        return encode_s_type(instr, rs1, rs2, offset), None
    
    # B-type: beq rs1, rs2, offset
    elif instr == "beq":
        if len(operands) != 3:
            return None, f"{instr} requires 3 operands: rs1, rs2, offset"
        
        rs1 = parse_register(operands[0])
        rs2 = parse_register(operands[1])
        offset = parse_immediate(operands[2])
        
        if -1 in [rs1, rs2] or offset is None:
            return None, f"Invalid operand in: {instr} {', '.join(operands)}"
        
        return encode_b_type(instr, rs1, rs2, offset), None
    
    return None, f"Instruction encoding not implemented: {instr}"

def write_executable_format(encoded_instructions, output_file):
    """
    Write encoded instructions to a file in the executable format.
    Each line contains 2 hex digits (8 bits), with most significant byte first.
    """
    with open(output_file, 'w') as f:
        for instruction in encoded_instructions:
            # Extract each byte and write as 2 hex digits per line
            for byte_pos in range(3, -1, -1):  # From 3 to 0 (MSB to LSB)
                byte_val = (instruction >> (byte_pos * 8)) & 0xFF
                f.write(f"{byte_val:02x}\n")

def main():
    parser = argparse.ArgumentParser(description='Encode RISC-V instructions to hex')
    parser.add_argument('input_file', help='File with RISC-V assembly instructions')
    parser.add_argument('-o', '--output', default='hex_instructions.s', 
                        help='Output file (default: hex_instructions.s)')
    parser.add_argument('-e', '--executable', default='executable.s',
                        help='Executable output file (default: executable.s)')
    args = parser.parse_args()
    
    with open(args.input_file, 'r') as f:
        lines = f.readlines()
    
    results = []
    encoded_instructions = []
    
    for i, line in enumerate(lines, 1):
        parsed = parse_instruction(line)
        if parsed is None:
            continue
        
        instr, operands = parsed
        encoded, error = encode_instruction(instr, operands)
        
        if error:
            results.append(f"Line {i}: {error}")
        else:
            results.append(f"{line.strip():40} # 0x{encoded:08x}")
            encoded_instructions.append(encoded)
    
    output = '\n'.join(results)
    
    # Write the annotated output
    with open(args.output, 'w') as f:
        f.write(output)
        print(f"Output written to {args.output}")
    
    # Write the executable format
    write_executable_format(encoded_instructions, args.executable)
    print(f"Executable format written to {args.executable}")

if __name__ == "__main__":
    main()