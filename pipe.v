// ============================================================
// PC Module
// ============================================================
module pc(input clk, reset, pc_write, input [63:0] pc_in, output [63:0] pc_out);
    reg [63:0] pc_out_reg;
    always @(posedge clk or posedge reset) begin
        if (reset)
            pc_out_reg <= 64'h0;
        else if (pc_write)
            pc_out_reg <= pc_in;
    end
    assign pc_out = pc_out_reg;
endmodule

// ============================================================
// Register File
// ============================================================
module register_file(input clk, reset, reg_write_en,
                     input [4:0] read_reg1, read_reg2, write_reg,
                     input [63:0] write_data,
                     output [63:0] read_data1, read_data2);
    reg [63:0] registers [31:0];
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1)
            registers[i] = 64'b0;
    end
    // Write-forwarding: if WB writes to the same register being read in ID
    // this cycle, forward the new value immediately (avoids 1-cycle stale read)
    assign read_data1 = (reg_write_en && write_reg != 5'b0 && write_reg == read_reg1)
                        ? write_data : registers[read_reg1];
    assign read_data2 = (reg_write_en && write_reg != 5'b0 && write_reg == read_reg2)
                        ? write_data : registers[read_reg2];
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1)
                registers[i] <= 64'b0;
        end else if (reg_write_en && write_reg != 5'b0) begin
            registers[write_reg] <= write_data;
        end
    end
endmodule

// ============================================================
// Instruction Memory
// ============================================================
module Instruction_Memory(input [63:0] addr, output [31:0] instr);
    reg [7:0] memory [4095:0];
    integer i;
    initial begin
        for (i = 0; i < 4096; i = i + 1)
            memory[i] = 8'h00;
        $readmemh("instructions.txt", memory);
        // $readmemh("../instructions.txt", memory);
    end
    assign instr = {memory[addr[11:0]], memory[addr[11:0]+1],
                    memory[addr[11:0]+2], memory[addr[11:0]+3]};
endmodule

// ============================================================
// Control Unit
// ============================================================

module control(input [6:0] opcode,
               output Branch, MemRead, MemToReg,
               output [1:0] ALUOp,
               output MemWrite, ALUSrc, reg_write_en);

    localparam R_type    = 7'b0110011;
    localparam I_type    = 7'b0010011;
    localparam S_type    = 7'b0100011;
    localparam load_type = 7'b0000011;
    localparam B_type    = 7'b1100011;

    reg Branch_reg, MemRead_reg, MemToReg_reg, MemWrite_reg, ALUSrc_reg, reg_write_en_reg;
    reg [1:0] Ao;

    always @(*) begin
        case (opcode)
            R_type:    begin Branch_reg=0; MemRead_reg=0; MemToReg_reg=0; Ao=2'b10; MemWrite_reg=0; ALUSrc_reg=0; reg_write_en_reg=1; end
            I_type:    begin Branch_reg=0; MemRead_reg=0; MemToReg_reg=0; Ao=2'b00; MemWrite_reg=0; ALUSrc_reg=1; reg_write_en_reg=1; end
            load_type: begin Branch_reg=0; MemRead_reg=1; MemToReg_reg=1; Ao=2'b00; MemWrite_reg=0; ALUSrc_reg=1; reg_write_en_reg=1; end
            S_type:    begin Branch_reg=0; MemRead_reg=0; MemToReg_reg=0; Ao=2'b00; MemWrite_reg=1; ALUSrc_reg=1; reg_write_en_reg=0; end
            B_type:    begin Branch_reg=1; MemRead_reg=0; MemToReg_reg=0; Ao=2'b01; MemWrite_reg=0; ALUSrc_reg=0; reg_write_en_reg=0; end
            default:   begin Branch_reg=0; MemRead_reg=0; MemToReg_reg=0; Ao=2'b00; MemWrite_reg=0; ALUSrc_reg=0; reg_write_en_reg=0; end
        endcase
    end
    assign Branch=Branch_reg; assign MemRead=MemRead_reg; assign MemToReg=MemToReg_reg;
    assign ALUOp=Ao;  assign MemWrite=MemWrite_reg; assign ALUSrc=ALUSrc_reg; assign reg_write_en=reg_write_en_reg;
endmodule



// ============================================================
// Immediate Generation
// NOTE: B-type immediate already encodes byte offset (LSB=0 appended).
//       Do NOT left-shift in the branch adder.
// ============================================================

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
                imm_reg = {{52{instr[31]}},instr[31],instr[7],instr[30:25],instr[11:8],1'b0};
            end

            default:
                imm_reg = 64'b0;
        endcase
    end
    assign imm = imm_reg;
endmodule

// ============================================================
// ALU Control
// ============================================================
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

// ============================================================
// 64-bit ALU (fully behavioral -- avoids gate elaboration bugs)
// ============================================================

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


// ============================================================
// Data Memory (byte-addressed, 64-bit big-endian read/write)
// ============================================================
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

// ============================================================
// Utility modules
// ============================================================
module mux2_1(input [63:0] a, b, input sel, output [63:0] out);
    assign out = sel ? b : a;
endmodule

module adder64(input [63:0] a, b, output [63:0] sum);
    assign sum = a + b;
endmodule

module and2(input a, b, output out);
    assign out = a & b;
endmodule

// ============================================================
// IF/ID Pipeline Register
// ============================================================
module IF_ID(input reset,clk,flush,IF_ID_write, input[63:0] IF_ID_pc_in, input[31:0] IF_ID_Ins_in, output[63:0] IF_ID_pc_out, output[31:0] IF_ID_Ins_out);

    reg [63:0] IF_ID_pc_out_reg;
    reg [31:0] IF_ID_Ins_out_reg;

    always @(posedge clk) begin
        if(reset || flush) begin
            IF_ID_pc_out_reg <= 64'b0;
            IF_ID_Ins_out_reg <= 32'b0;
        end
        else if(IF_ID_write) begin
            IF_ID_pc_out_reg <= IF_ID_pc_in;
            IF_ID_Ins_out_reg <= IF_ID_Ins_in;
        end
    end
    assign IF_ID_pc_out = IF_ID_pc_out_reg;
    assign IF_ID_Ins_out = IF_ID_Ins_out_reg;
endmodule

// ============================================================
// ID/EX Pipeline Register
// ============================================================
module ID_EX(
    input clk, reset, flush,
    input  id_mem_to_reg, id_reg_write_en, id_mem_read,
    input  id_mem_write, id_branch, id_alu_src,
    input  [3:0]  id_alu_ctrl,
    input  [63:0] id_pc, id_data1, id_data2, id_imm,
    input  [4:0]  id_rs1, id_rs2, id_rd,
    output ex_mem_to_reg, ex_reg_write_en, ex_mem_read,
    output ex_mem_write, ex_branch, ex_alu_src,
    output [3:0]  ex_alu_ctrl,
    output [63:0] ex_pc, ex_data1, ex_data2, ex_imm,
    output [4:0]  ex_rs1, ex_rs2, ex_rd
);
    reg r_mt,r_rw,r_mr,r_mw,r_br,r_as;
    reg [3:0]  r_ac;
    reg [63:0] r_pc,r_d1,r_d2,r_imm;
    reg [4:0]  r_rs1,r_rs2,r_rd;

    always @(posedge clk or posedge reset) begin
        if (reset || flush) begin
            r_mt<=0; r_rw<=0; r_mr<=0; r_mw<=0; r_br<=0; r_as<=0;
            r_ac<=0; r_pc<=0; r_d1<=0; r_d2<=0; r_imm<=0;
            r_rs1<=0; r_rs2<=0; r_rd<=0;
        end else begin
            r_mt<=id_mem_to_reg; r_rw<=id_reg_write_en; r_mr<=id_mem_read;
            r_mw<=id_mem_write;  r_br<=id_branch;       r_as<=id_alu_src;
            r_ac<=id_alu_ctrl;   r_pc<=id_pc;           r_d1<=id_data1;
            r_d2<=id_data2;      r_imm<=id_imm;
            r_rs1<=id_rs1; r_rs2<=id_rs2; r_rd<=id_rd;
        end
    end
    assign ex_mem_to_reg=r_mt; assign ex_reg_write_en=r_rw; assign ex_mem_read=r_mr;
    assign ex_mem_write=r_mw;  assign ex_branch=r_br;       assign ex_alu_src=r_as;
    assign ex_alu_ctrl=r_ac;   assign ex_pc=r_pc;           assign ex_data1=r_d1;
    assign ex_data2=r_d2;      assign ex_imm=r_imm;
    assign ex_rs1=r_rs1; assign ex_rs2=r_rs2; assign ex_rd=r_rd;
endmodule

// ============================================================
// EX/MEM Pipeline Register
// ============================================================
module EX_MEM(
    input clk, reset,
    input  ex_mem_to_reg, ex_reg_write_en, ex_mem_read, ex_mem_write,
    input  [63:0] ex_alu_out, ex_store_data,
    input  [4:0]  ex_rs2, ex_rd,
    output mem_mem_to_reg, mem_reg_write_en, mem_mem_read, mem_mem_write,
    output [63:0] mem_alu_out, mem_store_data,
    output [4:0]  mem_rs2, mem_rd
);
    reg r_mt,r_rw,r_mr,r_mw;
    reg [63:0] r_alu,r_sd;
    reg [4:0]  r_rs2,r_rd;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            r_mt<=0; r_rw<=0; r_mr<=0; r_mw<=0;
            r_alu<=0; r_sd<=0; r_rs2<=0; r_rd<=0;
        end else begin
            r_mt<=ex_mem_to_reg; r_rw<=ex_reg_write_en;
            r_mr<=ex_mem_read;   r_mw<=ex_mem_write;
            r_alu<=ex_alu_out;   r_sd<=ex_store_data;
            r_rs2<=ex_rs2;       r_rd<=ex_rd;
        end
    end
    assign mem_mem_to_reg=r_mt; assign mem_reg_write_en=r_rw;
    assign mem_mem_read=r_mr;   assign mem_mem_write=r_mw;
    assign mem_alu_out=r_alu;   assign mem_store_data=r_sd;
    assign mem_rs2=r_rs2;       assign mem_rd=r_rd;
endmodule

// ============================================================
// MEM/WB Pipeline Register
// ============================================================
module MEM_WB(
    input clk, reset,
    input  wb_mem_to_reg_in, wb_reg_write_en_in,
    input  [63:0] wb_mem_data_in, wb_alu_out_in,
    input  [4:0]  wb_rd_in,
    output wb_mem_to_reg, wb_reg_write_en,
    output [63:0] wb_mem_data, wb_alu_out,
    output [4:0]  wb_rd
);
    reg r_mt,r_rw;
    reg [63:0] r_md,r_alu;
    reg [4:0]  r_rd;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            r_mt<=0; r_rw<=0; r_md<=0; r_alu<=0; r_rd<=0;
        end else begin
            r_mt<=wb_mem_to_reg_in; r_rw<=wb_reg_write_en_in;
            r_md<=wb_mem_data_in;   r_alu<=wb_alu_out_in;
            r_rd<=wb_rd_in;
        end
    end
    assign wb_mem_to_reg=r_mt; assign wb_reg_write_en=r_rw;
    assign wb_mem_data=r_md;   assign wb_alu_out=r_alu;
    assign wb_rd=r_rd;
endmodule

// ============================================================
// Hazard Detection Unit
// ============================================================

module hazard_detection_unit(
    input clk, reset,
    input  ex_mem_read, cur_mem_write, cur_mem_read,
    input  branch_taken,
    input  branch_instr,
    input  [63:0] branch_pc,
    input  [4:0] if_id_rs1, if_id_rs2, ex_rd,
    output pc_write, if_id_write, bubble_sel, flush,
    output predicted_taken
);

    // predicted_taken unused for PC redirect — pc_mux handles that directly
    // Keep BHT for future use but don't use prediction to gate flush
    reg [1:0] bht [0:15];
    integer idx;
    wire [3:0] bht_index = branch_pc[5:2];
    assign predicted_taken = bht[bht_index][1];

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (idx = 0; idx < 16; idx = idx + 1)
                bht[idx] <= 2'b01;
        end else if (branch_instr) begin
            case (bht[bht_index])
                2'b00: bht[bht_index] <= branch_taken ? 2'b01 : 2'b00;
                2'b01: bht[bht_index] <= branch_taken ? 2'b10 : 2'b00;
                2'b10: bht[bht_index] <= branch_taken ? 2'b11 : 2'b01;
                2'b11: bht[bht_index] <= branch_taken ? 2'b11 : 2'b10;
            endcase
        end
    end

    reg r_pcw, r_ifw, r_bub, r_flush;

    always @(*) begin
        r_pcw  = 1;
        r_ifw  = 1;
        r_bub  = 0;
        r_flush = 0;

        if (branch_instr && branch_taken) begin
            r_flush = 1;
        end

        // Load-use hazard (unchanged)
        if (ex_mem_read && (ex_rd != 5'b0) &&
            ((ex_rd == if_id_rs1) ||
             (ex_rd == if_id_rs2 && !(cur_mem_read || cur_mem_write)))) begin
            r_pcw = 0;
            r_ifw = 0;
            r_bub = 1;
        end
    end

    assign pc_write    = r_pcw;
    assign if_id_write = r_ifw;
    assign bubble_sel  = r_bub;
    assign flush       = r_flush;

endmodule


// ============================================================
// Control Bubble (NOP mux)
// ============================================================
module control_bubble(
    input  branch_in, mem_read_in, mem_to_reg_in,
    input  mem_write_in, alu_src_in, reg_write_in,
    input  [3:0] alu_ctrl_in,
    input  sel,
    output branch_out, mem_read_out, mem_to_reg_out,
    output mem_write_out, alu_src_out, reg_write_out,
    output [3:0] alu_ctrl_out
);
    assign branch_out    = sel ? 1'b0 : branch_in;
    assign mem_read_out  = sel ? 1'b0 : mem_read_in;
    assign mem_to_reg_out= sel ? 1'b0 : mem_to_reg_in;
    assign mem_write_out = sel ? 1'b0 : mem_write_in;
    assign alu_src_out   = sel ? 1'b0 : alu_src_in;
    assign reg_write_out = sel ? 1'b0 : reg_write_in;
    assign alu_ctrl_out  = sel ? 4'b0 : alu_ctrl_in;
endmodule

// ============================================================
// Forwarding Unit
// ============================================================
module Forwarding_unit(
    input [4:0] ex_rs1, ex_rs2, mem_rd, wb_rd,
    input mem_regwrite, wb_regwrite,
    output [1:0] ForwardA, ForwardB
);
    reg [1:0] fa, fb;
    always @(*) begin
        fa = 2'b00; fb = 2'b00;

        // ForwardA
        if (mem_regwrite && (mem_rd != 5'b0) && (mem_rd == ex_rs1))
            fa = 2'b10;
        else if (wb_regwrite && (wb_rd != 5'b0) && (wb_rd == ex_rs1) &&
                 !(mem_regwrite && mem_rd == ex_rs1))
            fa = 2'b01;

        // ForwardB
        if (mem_regwrite && (mem_rd != 5'b0) && (mem_rd == ex_rs2))
            fb = 2'b10;
        else if (wb_regwrite && (wb_rd != 5'b0) && (wb_rd == ex_rs2) &&
                 !(mem_regwrite && mem_rd == ex_rs2))
            fb = 2'b01;
    end
    assign ForwardA = fa;
    assign ForwardB = fb;
endmodule

// ============================================================
// LD-after-SD Forwarding (BONUS: MEM/WB load -> EX/MEM store)
// ============================================================
module ld_after_sd_forwarding(input [4:0] ld_rd, sd_rs2,input ld_mem_to_reg, sd_mem_write,output ld_sd_sel);
    reg ld_sd_sel_reg;
    always @(*) begin
        ld_sd_sel_reg = 1'b0;
        if (ld_mem_to_reg && (ld_rd == sd_rs2) &&
            (ld_rd != 5'b0) && sd_mem_write) begin
            ld_sd_sel_reg = 1'b1;
        end
    end
    assign ld_sd_sel = ld_sd_sel_reg;
endmodule

// ============================================================
// PIPE -- 5-stage pipelined RISC-V processor (top-level)
// ============================================================
module pipe(input clk, reset);

    // IF
    wire [63:0] pc_out, pc_plus4, pc_branch, pc_next;
    wire [31:0] instr;
    wire        pc_write_en, flush_sig, if_id_write_en;

    // IF/ID
    wire [63:0] if_id_pc;
    wire [31:0] if_id_ins;

    // ID: control
    wire        branch, mem_read, mem_to_reg, mem_write, alu_src, reg_write;
    wire [1:0]  alu_op;
    wire [3:0]  alu_ctrl_raw;

    // ID: bubble outputs
    wire        bubble_sel;
    wire        b_branch, b_mem_read, b_mem_to_reg, b_mem_write, b_alu_src, b_reg_write;
    wire [3:0]  b_alu_ctrl;

    // ID: register file
    wire [63:0] rf_rdata1, rf_rdata2;
    wire [63:0] wb_write_data;
    wire [4:0]  wb_rd;
    wire        wb_reg_write;

    // ID: imm gen
    wire [63:0] imm;

    // ID/EX
    wire        ex_mem_to_reg, ex_reg_write, ex_mem_read, ex_mem_write;
    wire        ex_branch, ex_alu_src;
    wire [3:0]  ex_alu_ctrl;
    wire [63:0] ex_pc, ex_data1, ex_data2, ex_imm;
    wire [4:0]  ex_rs1, ex_rs2, ex_rd;

    // EX: forwarding
    wire [1:0]  fwd_a, fwd_b;
    wire [63:0] alu_a, alu_b_pre, alu_b;
    wire [63:0] alu_out;
    wire        alu_zero;
    wire        branch_taken;

    // EX/MEM
    wire        mem_mem_to_reg, mem_reg_write, mem_mem_read, mem_mem_write;
    wire [63:0] mem_alu_out, mem_store_data;
    wire [4:0]  mem_rs2, mem_rd;

    // MEM: ld-sd forwarding
    wire        ld_sd_sel;
    wire [63:0] mem_write_data_final;
    wire [63:0] mem_read_data;

    // MEM/WB
    wire        wb_mem_to_reg;
    wire [63:0] wb_mem_data, wb_alu_out;
    wire [4:0]  wb_rd_sig;
    wire        wb_reg_write_sig;

    // =========================================================
    // IF STAGE
    // =========================================================
    adder64 add4(.a(pc_out), .b(64'd4), .sum(pc_plus4));

    // Branch target = PC_in_EX + imm (B-type imm already byte offset, no extra shift)
    adder64 add_branch(.a(ex_pc), .b(ex_imm), .sum(pc_branch));

    and2 branch_and(.a(ex_branch), .b(alu_zero), .out(branch_taken));

    mux2_1 pc_mux(.a(pc_plus4), .b(pc_branch), .sel(branch_taken), .out(pc_next));

    pc PC(.clk(clk), .reset(reset), .pc_write(pc_write_en),
          .pc_in(pc_next), .pc_out(pc_out));

    Instruction_Memory IMEM(.addr(pc_out), .instr(instr));

    IF_ID IFID(.reset(reset), .clk(clk), .flush(flush_sig),
               .IF_ID_write(if_id_write_en),
               .IF_ID_pc_in(pc_out), .IF_ID_Ins_in(instr),
               .IF_ID_pc_out(if_id_pc), .IF_ID_Ins_out(if_id_ins));

    // =========================================================
    // ID STAGE
    // =========================================================
    control CTRL(
        .opcode(if_id_ins[6:0]),
        .Branch(branch), .MemRead(mem_read), .MemToReg(mem_to_reg),
        .ALUOp(alu_op), .MemWrite(mem_write), .ALUSrc(alu_src),
        .reg_write_en(reg_write)
    );

    alu_control ALUCTRL(
        .ALUOp(alu_op),
        .Ins({if_id_ins[30], if_id_ins[14:12]}),
        .ALUControl(alu_ctrl_raw)
    );

    control_bubble BUBBLE(
        .branch_in(branch), .mem_read_in(mem_read), .mem_to_reg_in(mem_to_reg),
        .mem_write_in(mem_write), .alu_src_in(alu_src), .reg_write_in(reg_write),
        .alu_ctrl_in(alu_ctrl_raw), .sel(bubble_sel),
        .branch_out(b_branch), .mem_read_out(b_mem_read),
        .mem_to_reg_out(b_mem_to_reg), .mem_write_out(b_mem_write),
        .alu_src_out(b_alu_src), .reg_write_out(b_reg_write),
        .alu_ctrl_out(b_alu_ctrl)
    );

    register_file RF(
        .clk(clk), .reset(reset), .reg_write_en(wb_reg_write),
        .read_reg1(if_id_ins[19:15]), .read_reg2(if_id_ins[24:20]),
        .write_reg(wb_rd), .write_data(wb_write_data),
        .read_data1(rf_rdata1), .read_data2(rf_rdata2)
    );

    Immediate_Generation IMMGEN(.instr(if_id_ins), .imm(imm));

    ID_EX IDEX(
        .clk(clk), .reset(reset), .flush(flush_sig),
        .id_mem_to_reg(b_mem_to_reg), .id_reg_write_en(b_reg_write),
        .id_mem_read(b_mem_read), .id_mem_write(b_mem_write),
        .id_branch(b_branch), .id_alu_src(b_alu_src), .id_alu_ctrl(b_alu_ctrl),
        .id_pc(if_id_pc), .id_data1(rf_rdata1), .id_data2(rf_rdata2), .id_imm(imm),
        .id_rs1(if_id_ins[19:15]), .id_rs2(if_id_ins[24:20]), .id_rd(if_id_ins[11:7]),
        .ex_mem_to_reg(ex_mem_to_reg), .ex_reg_write_en(ex_reg_write),
        .ex_mem_read(ex_mem_read), .ex_mem_write(ex_mem_write),
        .ex_branch(ex_branch), .ex_alu_src(ex_alu_src), .ex_alu_ctrl(ex_alu_ctrl),
        .ex_pc(ex_pc), .ex_data1(ex_data1), .ex_data2(ex_data2), .ex_imm(ex_imm),
        .ex_rs1(ex_rs1), .ex_rs2(ex_rs2), .ex_rd(ex_rd)
    );

    // =========================================================
    // EX STAGE
    // =========================================================
    Forwarding_unit FWD(
        .ex_rs1(ex_rs1), .ex_rs2(ex_rs2),
        .mem_rd(mem_rd), .wb_rd(wb_rd_sig),
        .mem_regwrite(mem_reg_write), .wb_regwrite(wb_reg_write_sig),
        .ForwardA(fwd_a), .ForwardB(fwd_b)
    );

    // 3-to-1 forwarding muxes
    assign alu_a     = (fwd_a == 2'b10) ? mem_alu_out :
                       (fwd_a == 2'b01) ? wb_write_data : ex_data1;

    assign alu_b_pre = (fwd_b == 2'b10) ? mem_alu_out :
                       (fwd_b == 2'b01) ? wb_write_data : ex_data2;

    // ALUSrc mux (imm vs register)
    mux2_1 alu_src_mux(.a(alu_b_pre), .b(ex_imm), .sel(ex_alu_src), .out(alu_b));

    alu_64_bit ALU(.a(alu_a), .b(alu_b), .opcode(ex_alu_ctrl),
                   .result(alu_out), .zero_flag(alu_zero));

    EX_MEM EXMEM(
        .clk(clk), .reset(reset),
        .ex_mem_to_reg(ex_mem_to_reg), .ex_reg_write_en(ex_reg_write),
        .ex_mem_read(ex_mem_read), .ex_mem_write(ex_mem_write),
        .ex_alu_out(alu_out), .ex_store_data(alu_b_pre),
        .ex_rs2(ex_rs2), .ex_rd(ex_rd),
        .mem_mem_to_reg(mem_mem_to_reg), .mem_reg_write_en(mem_reg_write),
        .mem_mem_read(mem_mem_read), .mem_mem_write(mem_mem_write),
        .mem_alu_out(mem_alu_out), .mem_store_data(mem_store_data),
        .mem_rs2(mem_rs2), .mem_rd(mem_rd)
    );

    // =========================================================
    // MEM STAGE
    // =========================================================
    ld_after_sd_forwarding LD_SD_FWD(
        .ld_rd(wb_rd_sig), .sd_rs2(mem_rs2),
        .ld_mem_to_reg(wb_mem_to_reg), .sd_mem_write(mem_mem_write),
        .ld_sd_sel(ld_sd_sel)
    );

    mux2_1 ld_sd_mux(.a(mem_store_data), .b(wb_write_data),
                     .sel(ld_sd_sel), .out(mem_write_data_final));

    Data_Memory DMEM(
        .clk(clk), .reset(reset),
        .MemRead(mem_mem_read), .MemWrite(mem_mem_write),
        .address(mem_alu_out[9:0]),
        .write_data(mem_write_data_final), .read_data(mem_read_data)
    );

    MEM_WB MEMWB(
        .clk(clk), .reset(reset),
        .wb_mem_to_reg_in(mem_mem_to_reg), .wb_reg_write_en_in(mem_reg_write),
        .wb_mem_data_in(mem_read_data), .wb_alu_out_in(mem_alu_out),
        .wb_rd_in(mem_rd),
        .wb_mem_to_reg(wb_mem_to_reg), .wb_reg_write_en(wb_reg_write_sig),
        .wb_mem_data(wb_mem_data), .wb_alu_out(wb_alu_out),
        .wb_rd(wb_rd_sig)
    );

    // =========================================================
    // WB STAGE
    // =========================================================
    mux2_1 wb_mux(.a(wb_alu_out), .b(wb_mem_data),
                  .sel(wb_mem_to_reg), .out(wb_write_data));

    assign wb_rd       = wb_rd_sig;
    assign wb_reg_write = wb_reg_write_sig;

    // =========================================================
    // HAZARD DETECTION UNIT
    // =========================================================
// =========================================================
    // HAZARD DETECTION UNIT
    // =========================================================
    wire predicted_taken;
    wire branch_instr;
    wire [63:0] branch_pc;

    // branch_instr: high when EX stage has a branch (ex_branch comes from ID/EX register)
    assign branch_instr = ex_branch;

    // branch_pc: PC stored in ID/EX register (ex_pc)
    assign branch_pc = ex_pc;

    hazard_detection_unit HDU(
        .clk(clk),
        .reset(reset),
        .ex_mem_read(ex_mem_read),
        .cur_mem_write(mem_write), .cur_mem_read(mem_read),
        .branch_taken(branch_taken),
        .branch_instr(branch_instr),
        .branch_pc(branch_pc),
        .if_id_rs1(if_id_ins[19:15]), .if_id_rs2(if_id_ins[24:20]),
        .ex_rd(ex_rd),
        .pc_write(pc_write_en), .if_id_write(if_id_write_en),
        .bubble_sel(bubble_sel), .flush(flush_sig),
        .predicted_taken(predicted_taken)
    );

endmodule
