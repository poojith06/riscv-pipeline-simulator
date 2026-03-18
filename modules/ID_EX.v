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