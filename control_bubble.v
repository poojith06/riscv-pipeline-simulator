module control_bubble(
    input branch,mem_read,mem_to_reg,mem_write,alu_src,reg_write_en,control_bubble_sel,
    input[3:0] op,
    output branch_out,mem_read_out,mem_to_reg_out,mem_write_out,alu_src_out,reg_write_en_out,
    output[3:0] op_out
);

assign branch_out        = control_bubble_sel ? 1'b0 : branch;
assign mem_read_out      = control_bubble_sel ? 1'b0 : mem_read;
assign mem_to_reg_out    = control_bubble_sel ? 1'b0 : mem_to_reg;
assign op_out            = control_bubble_sel ? 4'b0 : op;
assign mem_write_out     = control_bubble_sel ? 1'b0 : mem_write;
assign alu_src_out       = control_bubble_sel ? 1'b0 : alu_src;
assign reg_write_en_out  = control_bubble_sel ? 1'b0 : reg_write_en;

endmodule