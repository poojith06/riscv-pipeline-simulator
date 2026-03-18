module control_hazard(input Branch_and_zero, output flush);
reg flush_reg;
    always @(*) begin
        if (Branch_and_zero) begin
            flush_reg = 1'b1;
        end
        else begin
            flush_reg = 1'b0;
        end
    end
    assign flush = flush_reg;
endmodule