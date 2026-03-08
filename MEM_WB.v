module MEM_WB(
    input clk,reset,mem_to_reg,reg_write_en,
    input[63:0] data,alu_out,
    input[4:0] rd,
    output mem_to_reg_out,reg_write_en_out,
    output[63:0] data_out,alu_out_out,
    output[4:0] rd_out
);

    reg [63:0] alu_out_out_reg;
    reg [63:0] data_out_reg;
    reg [4:0] rd_out_reg;
    reg mem_to_reg_out_reg;
    reg reg_write_en_out_reg;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            alu_out_out_reg <= 64'b0;
            data_out_reg <= 64'b0;
            rd_out_reg <= 5'b0;
            mem_to_reg_out_reg <= 1'b0;
            reg_write_en_out_reg <= 1'b0;
        end else begin
            alu_out_out_reg <= alu_out;
            data_out_reg <= data;
            rd_out_reg <= rd;
            mem_to_reg_out_reg <= mem_to_reg;
            reg_write_en_out_reg <= reg_write_en;
        end
    end

    assign alu_out_out = alu_out_out_reg;
    assign data_out = data_out_reg;
    assign rd_out = rd_out_reg;
    assign mem_to_reg_out = mem_to_reg_out_reg;
    assign reg_write_en_out = reg_write_en_out_reg;
    
endmodule