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