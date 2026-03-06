module pc(input clk,reset, input [63:0]pc_in, output [63:0]pc_out);
    reg [63:0] pc_reg;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc_reg <= 64'b0;
        end else begin
            pc_reg <= pc_in;
        end
    end 
    assign pc_out = pc_reg;
endmodule


module register_file(input clk,reset,reg_write_en, input[4:0] read_reg1, read_reg2, write_reg, input[63:0] write_data, output[63:0] read_data1, read_data2);
    
    reg[63:0] registers[31:0];
    
    integer i;
    initial begin
        for (i = 0; i<32; i=i+1) begin
            registers[i] = 64'b0;
        end
    end

    assign read_data1 = registers[read_reg1];
    assign read_data2 = registers[read_reg2];
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i=0; i<32; i=i+1) begin
                registers[i]<=64'b0;
            end
        end
        else if (reg_write_en && write_reg != 5'b0) begin
            registers[write_reg]<=write_data;
        end    
    end
endmodule


module Instruction_Memory(input[63:0] addr, output[31:0] instr);

    reg [7:0] memory[4095:0];
    integer i;

    initial begin
        for (i = 0; i < 4096; i = i + 1)
                memory[i] = 8'h00;
        // $readmemh("../instructions.txt", memory);  (use this when your using some extension on vscode)
        $readmemh("instructions.txt", memory);
    end

    assign instr = {memory[addr[11:0]],memory[addr[11:0]+1],memory[addr[11:0]+2],memory[addr[11:0]+3]};

endmodule


module control(input[6:0] opcode, output Branch,MemRead,MemToReg, output[1:0] ALUOp, output MemWrite,ALUSrc,reg_write_en);
    
    localparam R_type = 7'b0110011;
    localparam I_type = 7'b0010011;
    localparam S_type = 7'b0100011;
    localparam load_type = 7'b0000011;
    localparam B_type = 7'b1100011;

    reg Branch_reg,  MemRead_reg, MemToReg_reg,  MemWrite_reg, ALUSrc_reg, reg_write_en_reg;
    reg [1:0] ALUOp_reg;


    always @(*) begin
        case(opcode)
            R_type: begin
                Branch_reg = 1'b0;
                MemRead_reg = 1'b0;
                MemToReg_reg = 1'b0;
                ALUOp_reg = 2'b10;
                MemWrite_reg = 1'b0;
                ALUSrc_reg = 1'b0;
                reg_write_en_reg = 1'b1;
            end
            I_type: begin
                Branch_reg = 1'b0;
                MemRead_reg = 1'b0;
                MemToReg_reg = 1'b0;
                ALUOp_reg = 2'b00;
                MemWrite_reg = 1'b0;
                ALUSrc_reg = 1'b1;
                reg_write_en_reg = 1'b1;
            end
            load_type: begin
                Branch_reg = 1'b0;
                MemRead_reg = 1'b1;
                MemToReg_reg = 1'b1;
                ALUOp_reg = 2'b00;
                MemWrite_reg = 1'b0;
                ALUSrc_reg = 1'b1;
                reg_write_en_reg = 1'b1;
            end
            S_type: begin
                Branch_reg = 1'b0;
                MemRead_reg = 1'b0;
                MemToReg_reg = 1'b0;
                ALUOp_reg = 2'b00;
                MemWrite_reg = 1'b1;
                ALUSrc_reg = 1'b1;
                reg_write_en_reg = 1'b0;
            end
            B_type: begin
                Branch_reg = 1'b1;
                MemRead_reg = 1'b0;
                MemToReg_reg = 1'b0;
                ALUOp_reg = 2'b01;
                MemWrite_reg = 1'b0;
                ALUSrc_reg = 1'b0;
                reg_write_en_reg = 1'b0;
            end
            default: begin
                Branch_reg = 1'b0;
                MemRead_reg = 1'b0;
                MemToReg_reg = 1'b0;
                ALUOp_reg = 2'b00;
                MemWrite_reg = 1'b0;
                ALUSrc_reg = 1'b0;
                reg_write_en_reg = 1'b0;
            end
        endcase
    end
    assign Branch = Branch_reg;
    assign MemRead = MemRead_reg;
    assign MemToReg = MemToReg_reg;
    assign ALUOp = ALUOp_reg;
    assign MemWrite = MemWrite_reg;
    assign ALUSrc = ALUSrc_reg;
    assign reg_write_en = reg_write_en_reg;
endmodule


module Immediate_Generation(input[31:0] instr, output[63:0] imm);

    wire [6:0] opcode = instr[6:0];
    reg[63:0] imm_reg;
    localparam I_type = 7'b0010011;
    localparam S_type = 7'b0100011;
    localparam load_type = 7'b0000011;
    localparam B_type = 7'b1100011;

    always @(*) begin
        case (opcode)

            I_type, load_type:
            begin
                imm_reg = {{52{instr[31]}},instr[31:20]};
            end

            S_type:
            begin
                imm_reg = {{52{instr[31]}},instr[31:25],instr[11:7]};
            end

            B_type:
            begin
                imm_reg = {{52{instr[31]}},instr[31],instr[7],instr[30:25],instr[11:8]};
            end

            default:
                imm_reg = 64'b0;
        endcase
    end
    assign imm = imm_reg;
endmodule


module alu_control(input[1:0] ALUOp, input[3:0] Ins , output[3:0] ALUControl);

    reg[3:0] ALUControl_reg;
    wire[2:0] funct3;
    wire funct7_5;
    assign funct3 = Ins[2:0];
    assign funct7_5 = Ins[3];

always @(*) begin
    case (ALUOp)

        2'b00: ALUControl_reg = 4'b0010; // ADD for Ld and Sd
        2'b01: ALUControl_reg = 4'b0110; // SUB for BEQ
        2'b10: begin                 // R-type instructions
            case (funct3)

                3'b000: begin
                    if (funct7_5 == 1'b1)
                        ALUControl_reg = 4'b0110; // SUB
                    else
                        ALUControl_reg  = 4'b0010; // ADD
                end
                3'b111: ALUControl_reg = 4'b0000; // AND
                3'b110: ALUControl_reg = 4'b0001; // OR

                default: ALUControl_reg = 4'b0010;
            endcase
        end
        default: ALUControl_reg = 4'b0010;
    endcase
end
assign ALUControl = ALUControl_reg;
endmodule



module full_adder(input a,b,c_in, output sum,carry);
    wire axb, a_and_b, axb_and_cin;
    xor(axb,a,b);
    xor(sum,axb,c_in);
    and(a_and_b,a,b);
    and(axb_and_cin,axb,c_in);
    or(carry,a_and_b,axb_and_cin);
endmodule


module add64(input [63:0] a,b, output [63:0]sum, output zero);
    wire [64:0]c;
    assign c[0] = 1'b0;
    genvar i;
    generate
        for (i=0; i<64; i=i+1) begin
            full_adder inst (.a(a[i]),.b(b[i]),.c_in(c[i]),.sum(sum[i]),.carry(c[i+1]));
        end
    endgenerate
    assign zero = (sum == 64'b0);
endmodule


module sub64(input [63:0] a,b, output [63:0]sum, output zero);
    wire [64:0]c;
    wire [63:0]b_inv;
    genvar j;
    generate
        for(j=0; j< 64;j=j+1) begin
            xor x1(b_inv[j], b[j], 1'b1);
        end
    endgenerate
    assign c[0] = 1'b1;
    genvar i;
    generate
        for (i=0; i<64; i=i+1) begin
            full_adder inst (.a(a[i]),.b(b_inv[i]),.c_in(c[i]),.sum(sum[i]),.carry(c[i+1]));
        end
    endgenerate
    assign zero = (sum == 64'b0);
endmodule


module or64(input [63:0]a, b, output [63:0]out, output zero);
    genvar i;
    generate
        for (i=0;i<64;i=i+1) begin
            or(out[i],a[i],b[i]);
        end
    endgenerate
    assign zero=(out==64'b0);
endmodule


module and64(input [63:0]a, b, output [63:0]out, output zero);
    genvar i;
    generate
        for (i=0;i<64;i=i+1) begin
            and(out[i],a[i],b[i]);
        end
    endgenerate
    assign zero=(out==64'b0);
endmodule


module alu_64_bit(input [63:0]a,b, input [3:0]opcode, output [63:0]result, output zero_flag);

    localparam  ADD_Oper  = 4'b0010,
                OR_Oper   = 4'b0001,
                AND_Oper  = 4'b0000,
                SUB_Oper  = 4'b0110;

    wire [63:0] add_out, sub_out, and_out, or_out;
    wire add_z, sub_z, and_z, or_z;


    add64 add_u(.a(a), .b(b), .sum(add_out), .zero(add_z));
    sub64 sub_u(.a(a), .b(b), .sum(sub_out), .zero(sub_z));
    and64 and_u(.a(a), .b(b), .out(and_out), .zero(and_z));
    or64  or_u (.a(a), .b(b), .out(or_out),  .zero(or_z));

    reg [63:0] res_sel;
    reg        z_sel;

    always @(*) begin

        case(opcode)

            ADD_Oper: begin
                res_sel = add_out;
                z_sel   = add_z;
            end

            SUB_Oper: begin
                res_sel = sub_out;
                z_sel   = sub_z;
            end

            AND_Oper: begin
                res_sel = and_out;
                z_sel   = and_z;
            end

            OR_Oper: begin
                res_sel = or_out;
                z_sel   = or_z;
            end

            default: begin
                res_sel = 64'b0;
                z_sel   = 1'b1;
            end

        endcase
    end

    assign result        = res_sel;
    assign zero_flag     = z_sel;

endmodule


module Data_Memory(input clk,reset,MemRead,MemWrite, input[9:0] address, input[63:0]write_data, output[63:0] read_data);

    reg[7:0] Dmemory[1023:0];
    integer k;

    initial begin
    for (k = 0; k < 1024; k = k + 1)
        Dmemory[k] = 8'h00;
    end

    always @(posedge clk) begin
        if (reset) begin
            for (k = 0; k < 1024; k = k + 1)
                Dmemory[k] <= 8'h0;
        end else begin
            if (MemWrite) begin
                Dmemory[address]     <= write_data[63:56];
                Dmemory[address + 1] <= write_data[55:48];
                Dmemory[address + 2] <= write_data[47:40];
                Dmemory[address + 3] <= write_data[39:32];
                Dmemory[address + 4] <= write_data[31:24];
                Dmemory[address + 5] <= write_data[23:16];
                Dmemory[address + 6] <= write_data[15:8];
                Dmemory[address + 7] <= write_data[7:0];
            end
        end
    end

    assign read_data = MemRead ? {Dmemory[address],Dmemory[address+1],Dmemory[address+2],Dmemory[address+3],Dmemory[address+4],Dmemory[address+5],Dmemory[address+6],Dmemory[address+7]} : 64'b0;

endmodule


module mux2_1(input[63:0] a,b, input sel, output[63:0] out);
    assign out = sel ? b : a;
endmodule


module adder64(input[63:0] a,b ,output [63:0] sum);
    assign sum=a+b;
endmodule

module sl1(input[63:0] in, output[63:0] out);
    assign out = {in[62:0], 1'b0};
endmodule

module and2 (input a, b, output out);
    and(out,a,b);
endmodule



module seq(input clk,reset);

    wire [63:0] pc_in,pc_out;
    wire reg_write_en;
    wire [4:0] read_reg1, read_reg2, write_reg;
    wire [63:0] write_data, read_data1, read_data2;
    wire [31:0] instr;
    wire Branch, MemRead, MemToReg, MemWrite, ALUSrc;
    wire [1:0] ALUOp;
    wire [3:0] ALUControl;
    wire [63:0] imm, imm_shifted;
    wire [3:0] Ins;
    wire [63:0] alu_in2, alu_result;
    wire zero_flag;
    wire [63:0] read_data_mem;
    wire [63:0] mux_pc_1, mux_pc_2;
    wire Branch_and_zero;



    pc pc_inst(.clk(clk), .reset(reset), .pc_in(pc_in), .pc_out(pc_out));
    Instruction_Memory Instruction_Memory_inst(.addr(pc_out), .instr(instr));
    control control_inst(.opcode(instr[6:0]), .Branch(Branch), .MemRead(MemRead), .MemToReg(MemToReg), .ALUOp(ALUOp), .MemWrite(MemWrite), .ALUSrc(ALUSrc), .reg_write_en(reg_write_en));
    register_file register_file_inst(.clk(clk), .reset(reset), .reg_write_en(reg_write_en), .read_reg1(instr[19:15]), .read_reg2(instr[24:20]), .write_reg(instr[11:7]), .write_data(write_data), .read_data1(read_data1), .read_data2(read_data2));
    Immediate_Generation immediate_generation_inst(.instr(instr), .imm(imm));
    alu_control alu_control_inst(.ALUOp(ALUOp), .Ins({instr[30], instr[14:12]}), .ALUControl(ALUControl));
    Data_Memory Data_Memory_inst(.clk(clk), .reset(reset), .MemRead(MemRead), .MemWrite(MemWrite), .address(alu_result[9:0]), .write_data(read_data2), .read_data(read_data_mem));
    adder64 adderpc_inst(.a(pc_out), .b(64'd4), .sum(mux_pc_1));
    sl1 sl1_inst(.in(imm), .out(imm_shifted));
    adder64 adderbranch_inst(.a(pc_out), .b(imm_shifted), .sum(mux_pc_2));
    and2 and_branch_inst(.a(Branch), .b(zero_flag), .out(Branch_and_zero));
    mux2_1 mux_pc_inst(.a(mux_pc_1), .b(mux_pc_2), .sel(Branch_and_zero), .out(pc_in));
    mux2_1 mux_alu_inst(.a(read_data2), .b(imm), .sel(ALUSrc), .out(alu_in2));
    mux2_1 mux_write_data_inst(.a(alu_result), .b(read_data_mem), .sel(MemToReg), .out(write_data));
    alu_64_bit alu_inst(.a(read_data1), .b(alu_in2), .opcode(ALUControl), .result(alu_result), .zero_flag(zero_flag));

endmodule

