module MEM_WB(
    input clk,reset,MEM_WB_mem_to_reg,MEM_WB_reg_write_en,
    input[63:0] MEM_WB_data,MEM_WB_alu_out,
    input[4:0] MEM_WB_rd,
    output MEM_WB_mem_to_reg_out,MEM_WB_reg_write_en_out,
    output[63:0] MEM_WB_data_out,MEM_WB_alu_out_out,
    output[4:0] MEM_WB_rd_out
);

    reg [63:0] MEM_WB_alu_out_out_reg;
    reg [63:0] MEM_WB_data_out_reg;
    reg [4:0] MEM_WB_rd_out_reg;
    reg MEM_WB_mem_to_reg_out_reg;
    reg MEM_WB_reg_write_en_out_reg;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            MEM_WB_alu_out_out_reg <= 64'b0;
            MEM_WB_data_out_reg <= 64'b0;
            MEM_WB_rd_out_reg <= 5'b0;
            MEM_WB_mem_to_reg_out_reg <= 1'b0;
            MEM_WB_reg_write_en_out_reg <= 1'b0;
        end else begin
            MEM_WB_alu_out_out_reg <= MEM_WB_alu_out;
            MEM_WB_data_out_reg <= MEM_WB_data;
            MEM_WB_rd_out_reg <= MEM_WB_rd;
            MEM_WB_mem_to_reg_out_reg <= MEM_WB_mem_to_reg;
            MEM_WB_reg_write_en_out_reg <= MEM_WB_reg_write_en;
        end
    end

    assign MEM_WB_alu_out_out = MEM_WB_alu_out_out_reg;
    assign MEM_WB_data_out = MEM_WB_data_out_reg;
    assign MEM_WB_rd_out = MEM_WB_rd_out_reg;
    assign MEM_WB_mem_to_reg_out = MEM_WB_mem_to_reg_out_reg;
    assign MEM_WB_reg_write_en_out = MEM_WB_reg_write_en_out_reg;

endmodule