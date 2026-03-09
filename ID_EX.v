module ID_EX(
    input clk,reset,flush,ID_EX_mem_to_reg,ID_EX_reg_write_en,ID_EX_mem_read,ID_EX_mem_write,ID_EX_Branch,ID_EX_ALUSrc,
    input[3:0] ID_EX_ALUControl,
    input[63:0] ID_EX_pc_in,ID_EX_data_in_1,ID_EX_data_in_2,ID_EX_imm_gen,
    input[4:0] ID_EX_rs1,ID_EX_rs2,ID_EX_rd,
    output ID_EX_mem_to_reg_out,ID_EX_reg_write_en_out,ID_EX_mem_read_out,ID_EX_mem_write_out,ID_EX_Branch_out,ID_EX_ALUSrc_out,
    output[3:0] ID_EX_ALUControl_out,
    output[63:0] ID_EX_pc_out,ID_EX_read_data1,ID_EX_read_data2,ID_EX_imm_gen_out,
    output[4:0] ID_EX_rs1_out,ID_EX_rs2_out,ID_EX_rd_out
);

    reg [63:0] ID_EX_read_data1_reg;
    reg [63:0] ID_EX_read_data2_reg;
    reg [4:0] ID_EX_rs1_out_reg;
    reg [4:0] ID_EX_rs2_out_reg;
    reg [4:0] ID_EX_rd_out_reg;
    reg ID_EX_mem_read_out_reg;
    reg ID_EX_mem_to_reg_out_reg;
    reg ID_EX_reg_write_en_out_reg;
    reg [3:0] ID_EX_ALUControl_out_reg;
    reg ID_EX_mem_write_out_reg;
    reg ID_EX_ALUSrc_out_reg;
    reg ID_EX_Branch_out_reg;
    reg [63:0] ID_EX_imm_gen_out_reg;
    reg [63:0] ID_EX_pc_out_reg;

    always @(posedge clk or posedge reset) begin
        if (reset || flush) begin
            ID_EX_read_data1_reg <= 64'b0;
            ID_EX_read_data2_reg <= 64'b0;
            ID_EX_rs1_out_reg <= 5'b0;
            ID_EX_rs2_out_reg <= 5'b0;
            ID_EX_rd_out_reg <= 5'b0;
            ID_EX_mem_read_out_reg <= 1'b0;
            ID_EX_mem_to_reg_out_reg <= 1'b0;
            ID_EX_reg_write_en_out_reg <= 1'b0;
            ID_EX_ALUControl_out_reg <= 4'b0;
            ID_EX_mem_write_out_reg <= 1'b0;
            ID_EX_ALUSrc_out_reg <= 1'b0;
            ID_EX_Branch_out_reg <= 1'b0;
            ID_EX_imm_gen_out_reg <= 64'b0;
            ID_EX_pc_out_reg <= 64'b0;
        end 
        else begin
            ID_EX_read_data1_reg <= ID_EX_data_in_1;
            ID_EX_read_data2_reg <= ID_EX_data_in_2;
            ID_EX_rs1_out_reg <= ID_EX_rs1;
            ID_EX_rs2_out_reg <= ID_EX_rs2;
            ID_EX_rd_out_reg <= ID_EX_rd;
            ID_EX_mem_read_out_reg <= ID_EX_mem_read;
            ID_EX_mem_to_reg_out_reg <= ID_EX_mem_to_reg;
            ID_EX_reg_write_en_out_reg <= ID_EX_reg_write_en;
            ID_EX_ALUControl_out_reg <= ID_EX_ALUControl;
            ID_EX_mem_write_out_reg <= ID_EX_mem_write;
            ID_EX_ALUSrc_out_reg <= ID_EX_ALUSrc;
            ID_EX_Branch_out_reg <= ID_EX_Branch;
            ID_EX_imm_gen_out_reg <= ID_EX_imm_gen;
            ID_EX_pc_out_reg <= ID_EX_pc_in;
        end
    end

    assign ID_EX_read_data1 = ID_EX_read_data1_reg;
    assign ID_EX_read_data2 = ID_EX_read_data2_reg;
    assign ID_EX_rs1_out = ID_EX_rs1_out_reg;
    assign ID_EX_rs2_out = ID_EX_rs2_out_reg;
    assign ID_EX_rd_out = ID_EX_rd_out_reg;
    assign ID_EX_mem_read_out = ID_EX_mem_read_out_reg;
    assign ID_EX_mem_to_reg_out = ID_EX_mem_to_reg_out_reg;
    assign ID_EX_reg_write_en_out = ID_EX_reg_write_en_out_reg;
    assign ID_EX_ALUControl_out = ID_EX_ALUControl_out_reg;
    assign ID_EX_mem_write_out = ID_EX_mem_write_out_reg;
    assign ID_EX_ALUSrc_out = ID_EX_ALUSrc_out_reg;
    assign ID_EX_Branch_out = ID_EX_Branch_out_reg;
    assign ID_EX_imm_gen_out = ID_EX_imm_gen_out_reg;
    assign ID_EX_pc_out = ID_EX_pc_out_reg;

endmodule