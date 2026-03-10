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