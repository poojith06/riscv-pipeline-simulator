module control_hazard(input branch_zero, output reg flush_if,output reg flush_id);
wire branch_taken; 
assign branch_taken=1'b0;
always @(*) begin
    if(branch_taken == brach_zero) begin
        flush_if = 1'b1;
        flush_id = 1'b1;
    end
    else begin
        flush_if = 1'b0;
        flush_id = 1'b0;
    end
end

endmodule
