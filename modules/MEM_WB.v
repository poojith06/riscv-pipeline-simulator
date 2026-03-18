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