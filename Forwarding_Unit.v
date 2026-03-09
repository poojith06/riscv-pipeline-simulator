module Forwarding_unit (
    input[4:0] ID_EX_rs1,ID_EX_rs2,EX_MEM_rd,MEM_WB_rd,
    input EX_MEM_Regwrite,MEM_WB_Regwrite,
    output[1:0] ForwardA,ForwardB
);
    reg[1:0] ForwardA_reg,ForwardB_reg;
    always @(*) begin
        ForwardA_reg = 2'b00;
        ForwardB_reg = 2'b00;

        if (EX_MEM_Regwrite && (EX_MEM_rd != 5'b0) && (EX_MEM_rd == ID_EX_rs1))
            ForwardA_reg = 2'b10;
        else if (MEM_WB_Regwrite && (MEM_WB_rd != 5'b0) && (MEM_WB_rd == ID_EX_rs1) &&
                 !(EX_MEM_Regwrite && (EX_MEM_rd == ID_EX_rs1)))
            ForwardA_reg = 2'b01;

        if (EX_MEM_Regwrite && (EX_MEM_rd != 5'b0) && (EX_MEM_rd == ID_EX_rs2))
            ForwardB_reg = 2'b10;
        else if (MEM_WB_Regwrite && (MEM_WB_rd != 5'b0) && (MEM_WB_rd == ID_EX_rs2) &&
                 !(EX_MEM_Regwrite && (EX_MEM_rd == ID_EX_rs2)))
            ForwardB_reg = 2'b01;

    end
    assign ForwardA = ForwardA_reg;
    assign ForwardB = ForwardB_reg;
endmodule