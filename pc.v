module pc(input clk,reset, input [63:0]pc_in, output [63:0]pc_out);
    reg [63:0] pc_reg;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc_reg <= 64'b0;
        end else begin
            pc_reg <= pc_in;
        end
    end 
    assign pc_out = pc_reg;
endmodule