module control_bubble(
    input Branch_bubble,mem_read_bubble,mem_to_reg_bubble,mem_write_bubble,alu_src_bubble,reg_write_en_bubble,control_bubble_sel,
    input[3:0] op_bubble,
    output branch_out_bubble,mem_read_out_bubble,mem_to_reg_out_bubble,mem_write_out_bubble,alu_src_out_bubble,reg_write_en_out_bubble,
    output[3:0] op_out_bubble
);

assign branch_out_bubble        = control_bubble_sel ? 1'b0 : Branch_bubble;
assign mem_read_out_bubble      = control_bubble_sel ? 1'b0 : mem_read_bubble;
assign mem_to_reg_out_bubble    = control_bubble_sel ? 1'b0 : mem_to_reg_bubble;
assign op_out_bubble            = control_bubble_sel ? 4'b0 : op_bubble;
assign mem_write_out_bubble     = control_bubble_sel ? 1'b0 : mem_write_bubble;
assign alu_src_out_bubble       = control_bubble_sel ? 1'b0 : alu_src_bubble;
assign reg_write_en_out_bubble  = control_bubble_sel ? 1'b0 : reg_write_en_bubble;

endmodule