module EX_MEM(
    input clk,reset,EX_MEM_mem_to_reg,EX_MEM_reg_write_en,EX_MEM_mem_read,EX_MEM_mem_write,
    input[63:0] EX_MEM_alu_out,EX_MEM_data,
    input[4:0] EX_MEM_rs2_ID_EX,EX_MEM_rd,
    output EX_MEM_mem_to_reg_out,EX_MEM_reg_write_en_out,EX_MEM_mem_read_out,EX_MEM_mem_write_out,
    output[63:0] EX_MEM_alu_out_out,EX_MEM_data_out,
    output[4:0] EX_MEM_rs2_ID_EX_out,EX_MEM_rd_out
);

    reg [63:0] EX_MEM_alu_out_out_reg;
    reg [63:0] EX_MEM_data_out_reg;
    reg [4:0] EX_MEM_rd_out_reg;
    reg EX_MEM_mem_read_out_reg;
    reg EX_MEM_mem_to_reg_out_reg;
    reg EX_MEM_reg_write_en_out_reg;
    reg EX_MEM_mem_write_out_reg;
    reg [4:0] EX_MEM_rs2_ID_EX_out_reg;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            EX_MEM_alu_out_out_reg <= 64'b0;
            EX_MEM_data_out_reg <= 64'b0;
            EX_MEM_rd_out_reg <= 5'b0;
            EX_MEM_mem_read_out_reg <= 1'b0;
            EX_MEM_mem_to_reg_out_reg <= 1'b0;
            EX_MEM_reg_write_en_out_reg <= 1'b0;
            EX_MEM_mem_write_out_reg <= 1'b0;
            EX_MEM_rs2_ID_EX_out_reg <= 5'b0;
        end else begin
            EX_MEM_alu_out_out_reg <= EX_MEM_alu_out;
            EX_MEM_data_out_reg <= EX_MEM_data;
            EX_MEM_rd_out_reg <= EX_MEM_rd;
            EX_MEM_mem_read_out_reg <= EX_MEM_mem_read;
            EX_MEM_mem_to_reg_out_reg <= EX_MEM_mem_to_reg;
            EX_MEM_reg_write_en_out_reg <= EX_MEM_reg_write_en;
            EX_MEM_mem_write_out_reg <= EX_MEM_mem_write;
            EX_MEM_rs2_ID_EX_out_reg <= EX_MEM_rs2_ID_EX;
        end
    end

    assign EX_MEM_alu_out_out = EX_MEM_alu_out_out_reg;
    assign EX_MEM_data_out = EX_MEM_data_out_reg;
    assign EX_MEM_rd_out = EX_MEM_rd_out_reg;
    assign EX_MEM_mem_read_out = EX_MEM_mem_read_out_reg;
    assign EX_MEM_mem_to_reg_out = EX_MEM_mem_to_reg_out_reg;
    assign EX_MEM_reg_write_en_out = EX_MEM_reg_write_en_out_reg;
    assign EX_MEM_mem_write_out = EX_MEM_mem_write_out_reg;
    assign EX_MEM_rs2_ID_EX_out = EX_MEM_rs2_ID_EX_out_reg;

endmodule