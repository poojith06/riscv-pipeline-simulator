module control(input[6:0] opcode, output Branch,MemRead,MemToReg, output[1:0] ALUOp, output MemWrite,ALUSrc,reg_write_en);
    
    localparam R_type = 7'b0110011;
    localparam I_type = 7'b0010011;
    localparam S_type = 7'b0100011;
    localparam load_type = 7'b0000011;
    localparam B_type = 7'b1100011;

    reg Branch_reg,  MemRead_reg, MemToReg_reg,  MemWrite_reg, ALUSrc_reg, reg_write_en_reg;
    reg [1:0] ALUOp_reg;


    always @(*) begin
        case(opcode)
            R_type: begin
                Branch_reg = 1'b0;
                MemRead_reg = 1'b0;
                MemToReg_reg = 1'b0;
                ALUOp_reg = 2'b10;
                MemWrite_reg = 1'b0;
                ALUSrc_reg = 1'b0;
                reg_write_en_reg = 1'b1;
            end
            I_type: begin
                Branch_reg = 1'b0;
                MemRead_reg = 1'b0;
                MemToReg_reg = 1'b0;
                ALUOp_reg = 2'b00;
                MemWrite_reg = 1'b0;
                ALUSrc_reg = 1'b1;
                reg_write_en_reg = 1'b1;
            end
            load_type: begin
                Branch_reg = 1'b0;
                MemRead_reg = 1'b1;
                MemToReg_reg = 1'b1;
                ALUOp_reg = 2'b00;
                MemWrite_reg = 1'b0;
                ALUSrc_reg = 1'b1;
                reg_write_en_reg = 1'b1;
            end
            S_type: begin
                Branch_reg = 1'b0;
                MemRead_reg = 1'b0;
                MemToReg_reg = 1'b0;
                ALUOp_reg = 2'b00;
                MemWrite_reg = 1'b1;
                ALUSrc_reg = 1'b1;
                reg_write_en_reg = 1'b0;
            end
            B_type: begin
                Branch_reg = 1'b1;
                MemRead_reg = 1'b0;
                MemToReg_reg = 1'b0;
                ALUOp_reg = 2'b01;
                MemWrite_reg = 1'b0;
                ALUSrc_reg = 1'b0;
                reg_write_en_reg = 1'b0;
            end
            default: begin
                Branch_reg = 1'b0;
                MemRead_reg = 1'b0;
                MemToReg_reg = 1'b0;
                ALUOp_reg = 2'b00;
                MemWrite_reg = 1'b0;
                ALUSrc_reg = 1'b0;
                reg_write_en_reg = 1'b0;
            end
        endcase
    end
    assign Branch = Branch_reg;
    assign MemRead = MemRead_reg;
    assign MemToReg = MemToReg_reg;
    assign ALUOp = ALUOp_reg;
    assign MemWrite = MemWrite_reg;
    assign ALUSrc = ALUSrc_reg;
    assign reg_write_en = reg_write_en_reg;
endmodule