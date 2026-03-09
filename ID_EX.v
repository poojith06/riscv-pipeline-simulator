module ID_EX(
    input clk,reset,flush,mem_to_reg,reg_write_en,mem_read,mem_write,Branch,ALUSrc,
    input[3:0] ALUControl,
    input[63:0] ID_EX_pc_in,data_in_1,data_in_2,imm_gen,
    input[4:0] ID_EX_rs1,ID_EX_rs2,ID_EX_rd,
    output mem_to_reg_out,reg_write_en_out,mem_read_out,mem_write_out,Branch_out,ALUSrc_out,
    output[3:0] ALUControl_out,
    output[63:0] ID_EX_pc_out,read_data1,read_data2,imm_gen_out,
    output[4:0] ID_EX_rs1_out,ID_EX_rs2_out,ID_EX_rd_out
);

    reg [63:0] read_data1_reg;
    reg [63:0] read_data2_reg;
    reg [4:0] ID_EX_rs1_out_reg;
    reg [4:0] ID_EX_rs2_out_reg;
    reg [4:0] ID_EX_rd_out_reg;
    reg mem_read_out_reg;
    reg mem_to_reg_out_reg;
    reg reg_write_en_out_reg;
    reg [3:0] ALUControl_out_reg;
    reg mem_write_out_reg;
    reg ALUSrc_out_reg;
    reg Branch_out_reg;
    reg [63:0] imm_gen_out_reg;
    reg [63:0] ID_EX_pc_out_reg;

    always @(posedge clk or posedge reset) begin
        if (reset || flush) begin
            read_data1_reg <= 64'b0;
            read_data2_reg <= 64'b0;
            ID_EX_rs1_out_reg <= 5'b0;
            ID_EX_rs2_out_reg <= 5'b0;
            ID_EX_rd_out_reg <= 5'b0;
            mem_read_out_reg <= 1'b0;
            mem_to_reg_out_reg <= 1'b0;
            reg_write_en_out_reg <= 1'b0;
            ALUControl_out_reg <= 4'b0;
            mem_write_out_reg <= 1'b0;
            ALUSrc_out_reg <= 1'b0;
            Branch_out_reg <= 1'b0;
            imm_gen_out_reg <= 64'b0;
            ID_EX_pc_out_reg <= 64'b0;
        end 
        else begin
            read_data1_reg <= data_in_1;
            read_data2_reg <= data_in_2;
            ID_EX_rs1_out_reg <= ID_EX_rs1;
            ID_EX_rs2_out_reg <= ID_EX_rs2;
            ID_EX_rd_out_reg <= ID_EX_rd;
            mem_read_out_reg <= mem_read;
            mem_to_reg_out_reg <= mem_to_reg;
            reg_write_en_out_reg <= reg_write_en;
            ALUControl_out_reg <= ALUControl;
            mem_write_out_reg <= mem_write;
            ALUSrc_out_reg <= ALUSrc;
            Branch_out_reg <= Branch;
            imm_gen_out_reg <= imm_gen;
            ID_EX_pc_out_reg <= ID_EX_pc_in;
        end
    end

    assign read_data1 = read_data1_reg;
    assign read_data2 = read_data2_reg;
    assign ID_EX_rs1_out = ID_EX_rs1_out_reg;
    assign ID_EX_rs2_out = ID_EX_rs2_out_reg;
    assign ID_EX_rd_out = ID_EX_rd_out_reg;
    assign mem_read_out = mem_read_out_reg;
    assign mem_to_reg_out = mem_to_reg_out_reg;
    assign reg_write_en_out = reg_write_en_out_reg;
    assign ALUControl_out = ALUControl_out_reg;
    assign mem_write_out = mem_write_out_reg;
    assign ALUSrc_out = ALUSrc_out_reg;
    assign Branch_out = Branch_out_reg;
    assign imm_gen_out = imm_gen_out_reg;
    assign ID_EX_pc_out = ID_EX_pc_out_reg;

endmodule