module EX_MEM(
    input clk,reset,mem_to_reg,reg_write_en,mem_read,mem_write,
    input[63:0] alu_out,data,
    input[4:0] rs2_ID_EX,rd,
    output mem_to_reg_out,reg_write_en_out,mem_read_out,mem_write_out,
    output[63:0] alu_out_out,data_out,
    output[4:0] rs2_ID_EX_out,rd_out
);

    reg [63:0] alu_out_out_reg;
    reg [63:0] data_out_reg;
    reg [4:0] rd_out_reg;
    reg mem_read_out_reg;
    reg mem_to_reg_out_reg;
    reg reg_write_en_out_reg;
    reg mem_write_out_reg;
    reg [4:0] rs2_ID_EX_out_reg;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            alu_out_out_reg <= 64'b0;
            data_out_reg <= 64'b0;
            rd_out_reg <= 5'b0;
            mem_read_out_reg <= 1'b0;
            mem_to_reg_out_reg <= 1'b0;
            reg_write_en_out_reg <= 1'b0;
            mem_write_out_reg <= 1'b0;
            rs2_ID_EX_out_reg <= 5'b0;
        end else begin
            alu_out_out_reg <= alu_out;
            data_out_reg <= data;
            rd_out_reg <= rd;
            mem_read_out_reg <= mem_read;
            mem_to_reg_out_reg <= mem_to_reg;
            reg_write_en_out_reg <= reg_write_en;
            mem_write_out_reg <= mem_write;
            rs2_ID_EX_out_reg <= rs2_ID_EX;
        end
    end

    assign alu_out_out = alu_out_out_reg;
    assign data_out = data_out_reg;
    assign rd_out = rd_out_reg;
    assign mem_read_out = mem_read_out_reg;
    assign mem_to_reg_out = mem_to_reg_out_reg;
    assign reg_write_en_out = reg_write_en_out_reg;
    assign mem_write_out = mem_write_out_reg;
    assign rs2_ID_EX_out = rs2_ID_EX_out_reg;

endmodule