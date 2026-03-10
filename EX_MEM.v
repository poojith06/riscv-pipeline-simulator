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