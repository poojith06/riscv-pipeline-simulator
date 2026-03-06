module Immediate_Generation(input[31:0] instr, output[63:0] imm);

    wire [6:0] opcode = instr[6:0];
    reg[63:0] imm_reg;
    localparam I_type = 7'b0010011;
    localparam S_type = 7'b0100011;
    localparam load_type = 7'b0000011;
    localparam B_type = 7'b1100011;

    always @(*) begin
        case (opcode)

            I_type, load_type:
            begin
                imm_reg = {{52{instr[31]}},instr[31:20]};
            end

            S_type:
            begin
                imm_reg = {{52{instr[31]}},instr[31:25],instr[11:7]};
            end

            B_type:
            begin
                imm_reg = {{52{instr[31]}},instr[31],instr[7],instr[30:25],instr[11:8]};
            end

            default:
                imm_reg = 64'b0;
        endcase
    end
    assign imm = imm_reg;
endmodule