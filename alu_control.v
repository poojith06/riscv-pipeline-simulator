module alu_control(input[1:0] ALUOp, input[3:0] Ins , output[3:0] ALUControl);

    reg[3:0] ALUControl_reg;
    wire[2:0] funct3;
    wire funct7_5;
    assign funct3 = Ins[2:0];
    assign funct7_5 = Ins[3];

always @(*) begin
    case (ALUOp)

        2'b00: ALUControl_reg = 4'b0010; // ADD for Ld and Sd
        2'b01: ALUControl_reg = 4'b0110; // SUB for BEQ
        2'b10: begin                 // R-type instructions
            case (funct3)

                3'b000: begin
                    if (funct7_5 == 1'b1)
                        ALUControl_reg = 4'b0110; // SUB
                    else
                        ALUControl_reg  = 4'b0010; // ADD
                end
                3'b111: ALUControl_reg = 4'b0000; // AND
                3'b110: ALUControl_reg = 4'b0001; // OR

                default: ALUControl_reg = 4'b0010;
            endcase
        end
        default: ALUControl_reg = 4'b0010;
    endcase
end
assign ALUControl = ALUControl_reg;
endmodule