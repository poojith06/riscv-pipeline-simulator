module hazard_detection_unit(input idex_memread,input[4:0] idex_reg_rd,input[31:0] ifid_instruction,output reg pc_write,output reg ifid_write,output reg idex_flush)

wire[4:0] rs1=ifid_instruction[19:15];
wire[4:0] rs2=ifid_instruction[24:20];

always @(*) begin
pc_write=1'b1;
ifid_write=1'b1;
idex_flush=1'b0;

if(idex_memread && ((idex_reg_rd ==rs1)||(idex_reg_rd ==rs2)) && (idex_reg_rd != 5'd0))
begin
pc_write=1'b0;
ifid_write=1'b0;
idex_flush=1'b1;
end
end
endmodule

