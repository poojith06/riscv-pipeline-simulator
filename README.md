# RISC-V Pipelined Processor (RV64I)

A 5-stage pipelined RISC-V processor implemented in Verilog, based on the RV64I instruction set architecture, featuring a Hazard Detection Unit and Data Forwarding Unit.

## Table of Contents

- [Overview](#overview)
- [Datapath Architecture](#datapath-architecture)
- [Pipeline Stages](#pipeline-stages)
- [Hazard Handling](#hazard-handling)
- [Supported Instructions](#supported-instructions)
- [Module Descriptions](#module-descriptions)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Testing & Results](#testing--results)
- [Conclusion](#conclusion)

---

## Overview

This project presents the design and implementation of a **5-stage pipelined RISC-V processor** based on the RV64I instruction set. The processor is implemented in **Verilog** and simulated using **iVerilog**.

Key characteristics:

- Executes instructions across **5 pipeline stages**: IF, ID, EX, MEM, WB
- Features a **Hazard Detection Unit** to handle load-use data hazards via pipeline stalls
- Features a **Forwarding Unit** to resolve data hazards without unnecessary stalls wherever possible
- **Pipeline registers** (IF/ID, ID/EX, EX/MEM, MEM/WB) hold intermediate values between stages
- Fully modular design — each datapath component is an independent Verilog module
- All modules operate **synchronously** with the clock signal

---

## Datapath Architecture

The complete datapath of the pipelined processor is shown below:

![Datapath Architecture](Datapath_Architecture/Datapath_Architecture_pipe.png)

The datapath implements the classic 5-stage RISC-V pipeline:

1. **IF (Instruction Fetch)** — PC provides the address; Instruction Memory returns the 32-bit instruction; PC+4 is computed for the next cycle
2. **ID (Instruction Decode)** — Control Unit decodes the opcode; Register File reads source operands; Immediate Generator sign-extends the immediate field
3. **EX (Execute)** — ALU performs the required operation; Forwarding Unit selects the correct operands; branch target address is computed
4. **MEM (Memory Access)** — Data Memory performs load or store if required; branch decision is resolved
5. **WB (Write-Back)** — Result is written back to the destination register

---

## Pipeline Stages

| Stage | Register Used | Key Operations |
|-------|--------------|----------------|
| IF    | PC, IF/ID    | Instruction fetch, PC+4 |
| ID    | ID/EX        | Register read, control signal generation, immediate generation |
| EX    | EX/MEM       | ALU operation, forwarding selection, branch target computation |
| MEM   | MEM/WB       | Data memory read/write |
| WB    | —            | Write result to register file |

---

## Hazard Handling

### Data Hazards — Forwarding Unit

The **Forwarding Unit** detects when a register being read in the EX stage was written by an instruction still in the EX/MEM or MEM/WB pipeline stage. It forwards the correct value directly to the ALU inputs, eliminating most data hazard stalls.

Forwarding conditions:

| Condition | Source | Action |
|-----------|--------|--------|
| EX/MEM hazard | EX/MEM.RegisterRd == ID/EX.RegisterRs1/Rs2 | Forward from EX/MEM ALU result |
| MEM/WB hazard | MEM/WB.RegisterRd == ID/EX.RegisterRs1/Rs2 | Forward from MEM/WB result |

### Load-Use Hazard — Hazard Detection Unit

The **Hazard Detection Unit** detects load-use hazards, where a `ld` instruction is immediately followed by an instruction that uses the loaded value. In this case, the pipeline is stalled for one cycle by:

- Inserting a **bubble (NOP)** into the EX stage
- **Freezing** the PC and IF/ID pipeline register for one cycle

---

## Supported Instructions

| Format | Instructions |
|--------|-------------|
| R-type | `add`, `sub`, `and`, `or` |
| I-type | `addi` |
| Load   | `ld` |
| Store  | `sd` |
| Branch | `beq` |

---

## Module Descriptions

The processor is built from the following independently designed and verified modules:

### 1. Program Counter (`pc.v`)

- 64-bit register storing the address of the current instruction
- Updates on every rising clock edge, unless stalled by the Hazard Detection Unit
- Resets to `0x0000...0000` when the reset signal is asserted

### 2. Register File (`register_file.v`)

- 32 × 64-bit general-purpose registers (RV64I architecture)
- 2 combinational read ports, 1 synchronous write port
- Register `x0` is hardwired to zero and cannot be written

### 3. Instruction Memory (`Instruction_Memory.v`)

- Read-only memory, 4096 bytes, byte-addressed
- Loads instructions from `instructions.txt` at initialization
- Outputs a 32-bit instruction in **Big-Endian** format

### 4. Control Unit (`control.v`)

- Decodes the 7-bit opcode and generates all datapath control signals
- Combinational logic — outputs update immediately on opcode change
- Control signals are passed through pipeline registers (ID/EX → EX/MEM → MEM/WB)

| Instruction | ALUSrc | MemToReg | RegWrite | MemRead | MemWrite | Branch | ALUOp |
|-------------|--------|----------|----------|---------|----------|--------|-------|
| R-format    | 0      | 0        | 1        | 0       | 0        | 0      | 10    |
| `ld`        | 1      | 1        | 1        | 1       | 0        | 0      | 00    |
| `sd`        | 1      | X        | 0        | 0       | 1        | 0      | 00    |
| `beq`       | 0      | X        | 0        | 0       | 0        | 1      | 01    |

### 5. Immediate Generator (`Immediate_Generation.v`)

- Extracts and **sign-extends** immediate fields to 64 bits
- Supports I-type, load, S-type, and B-type instruction formats

### 6. ALU Control (`alu_control.v`)

- Generates a 4-bit control signal for the ALU based on `ALUOp` and `funct3`/`funct7` fields

| ALUOp | Operation | ALU Control |
|-------|-----------|-------------|
| 00    | ADD (for `ld`/`sd`) | 0010 |
| 01    | SUB (for `beq`)     | 0110 |
| 10    | R-type (`add`/`sub`/`and`/`or`) | see funct bits |

### 7. 64-bit ALU (`alu.v`)

- Performs ADD, SUB, AND, OR on 64-bit operands
- Outputs a **zero flag** used for branch decisions
- Receives operands via the Forwarding Unit's mux outputs

### 8. Data Memory (`Data_Memory.v`)

- 1024 bytes of byte-addressable storage
- Supports 64-bit load (`ld`) and store (`sd`) operations in **Big-Endian** format
- Synchronous writes on rising clock edge; combinational reads

### 9. Hazard Detection Unit (`hazard_detection.v`)

- Monitors the ID/EX pipeline register for load-use hazards
- When detected: asserts `PCWrite = 0`, `IF/IDWrite = 0`, and inserts a NOP bubble into ID/EX

### 10. Forwarding Unit (`forwarding_unit.v`)

- Compares destination registers in EX/MEM and MEM/WB stages with source registers in EX stage
- Generates `ForwardA` and `ForwardB` select signals for the ALU input muxes
- Handles double data hazards (MEM/WB forwarding takes lower priority than EX/MEM)

### 11. Pipeline Registers

Four sets of pipeline registers hold values between stages:

| Register | Holds |
|----------|-------|
| IF/ID    | Instruction, PC+4 |
| ID/EX    | Control signals, register values, immediate, register numbers |
| EX/MEM   | Control signals, ALU result, zero flag, write data, destination register |
| MEM/WB   | Control signals, read data, ALU result, destination register |

### 12. 2:1 Multiplexers (`mux2_1.v`)

- Selects between two 64-bit inputs based on a single control signal
- Used for ALU source, PC source, and write-back data selection

### 13. 3:1 Multiplexers (Forwarding Muxes)

- Select among three 64-bit inputs (register value, EX/MEM forward, MEM/WB forward)
- Used on ALU inputs A and B for data forwarding

### 14. 64-bit Adder (`adder64.v`)

- Combinational adder used for PC+4 increment and branch target computation

### 15. Shift Left by 1 (`sl1.v`)

- Performs a logical left shift by 1 bit on the 64-bit immediate value
- Used to align branch offsets to instruction boundaries (multiplies offset by 2)

---

## Project Structure

```
riscv-pipeline-simulator/
├── Datapath_Architecture/
│   └── Datapath_Architecture_pipe.png
├── PIPE_grading/
│   └── PIPE_grading/
├── Report/
│   └── IPA_Pipelined_Project_Report.pdf
├── modules/
│   ├── adder64.v
│   ├── alu.v
│   ├── alu_control.v
│   ├── control.v
│   ├── Data_Memory.v
│   ├── forwarding_unit.v
│   ├── hazard_detection.v
│   ├── Immediate_Generation.v
│   ├── Instruction_Memory.v
│   ├── mux2_1.v
│   ├── mux3_1.v
│   ├── pc.v
│   ├── register_file.v
│   └── sl1.v
├── modules_tb/
│   ├── adder64_tb.v
│   ├── alu_control_tb.v
│   ├── alu_tb.v
│   ├── control_tb.v
│   ├── Data_Memory_tb.v
│   ├── forwarding_unit_tb.v
│   ├── hazard_detection_tb.v
│   ├── Immediate_Generation_tb.v
│   ├── Instruction_Memory_tb.v
│   ├── mux2_1_tb.v
│   ├── pc_tb.v
│   └── register_file_tb.v
├── Fibonacci_ins.txt
├── Fibonacci_ins_exp.txt
├── Fibonacci_register_file.txt
├── IPA_Pipelined_Project_Doc.pdf
├── instructions.txt
├── instructions_exp.txt
├── pipe.v
├── pipe_tb.v
├── README.md
└── register_file.txt
```

---

## Getting Started

### Prerequisites

- [iVerilog](http://iverilog.icarus.com/) (Icarus Verilog)
- Any terminal / command prompt

### Running the Full Processor Simulation

```bash
# Compile
iverilog -o pipe_sim pipe_tb.v pipe.v modules/*.v

# Run
vvp pipe_sim
```

### Running Individual Module Testbenches

```bash
# Example: Hazard Detection Unit
iverilog -o hdu_sim modules_tb/hazard_detection_tb.v modules/hazard_detection.v
vvp hdu_sim

# Example: Forwarding Unit
iverilog -o fwd_sim modules_tb/forwarding_unit_tb.v modules/forwarding_unit.v
vvp fwd_sim
```

### Changing the Input Program

Edit `instructions.txt` with your RISC-V machine code (one byte per line, in hexadecimal). An expected output can be placed in `instructions_exp.txt` for comparison.

---

## Testing & Results

### Basic Functionality Test

A basic test program covering all supported instruction types was executed. The assembly program performed arithmetic, logical, load/store, and branch operations, verifying correct forwarding and hazard handling behaviour.

**Register File Output (after execution):**

```
x1  = 000000000000000f   (15)
x2  = fffffffffffffffb   (-5)
x3  = 000000000000000a   (10)
x4  = 000000000000000a   (10)
x5  = 000000000000000a   (10)
x6  = fffffffffffffffb   (-5)
x7  = fffffffffffffffb   (-5)
x10 = 000000000000000f   (15)
x11 = fffffffffffffffb   (-5)
x13 = 000000000000001e   (30)

Total clock cycles: 19
```

---

### Fibonacci Sequence Test

The processor was validated by computing the **10th Fibonacci number** using a loop and branch instructions, exercising forwarding across multiple iterations.

**Assembly Program:**

```asm
addi x1, x0, 10      # Initialize loop counter n = 10
addi x2, x0, 0       # a = 0
addi x3, x0, 1       # b = 1
addi x1, x1, -1      # n = n - 1
beq  x1, x0, 20      # If n == 0, exit loop
add  x4, x2, x3      # temp = a + b
addi x2, x3, 0       # a = b
addi x3, x4, 0       # b = temp
beq  x0, x0, -20     # Unconditional branch back to loop
```

**Register File Output (after execution):**

```
x0  = 0000000000000000   (0)
x1  = 0000000000000000   (0)   ← loop counter exhausted
x2  = 0000000000000022   (34)  ← 9th Fibonacci number
x3  = 0000000000000037   (55)  ← 10th Fibonacci number
x4  = 0000000000000037   (55)  ← last computed value
```

The result confirms correct pipelined execution with data forwarding resolving RAW hazards across all loop iterations.

---

## Conclusion

A 5-stage pipelined RISC-V processor (RV64I) was successfully designed, implemented in Verilog, and verified through simulation. The pipeline includes a fully functional Hazard Detection Unit for load-use stalls and a Forwarding Unit for resolving data hazards with minimal performance penalty. All datapath and hazard-handling modules were developed independently, tested with dedicated testbenches, and integrated into a complete working processor. The design correctly executes arithmetic, logical, memory, and branch instructions, as validated by both the basic functionality test and the Fibonacci benchmark.

---

> **Related Project:** [RISC-V Sequential Simulator](https://github.com/aneesh0424/riscv-sequential-simulator) — the non-pipelined single-cycle version of this processor.
