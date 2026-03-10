module Forwarding_unit(
    input [4:0] ex_rs1, ex_rs2, mem_rd, wb_rd,
    input mem_regwrite, wb_regwrite,
    output [1:0] ForwardA, ForwardB
);
    reg [1:0] fa, fb;
    always @(*) begin
        fa = 2'b00; fb = 2'b00;

        // ForwardA
        if (mem_regwrite && (mem_rd != 5'b0) && (mem_rd == ex_rs1))
            fa = 2'b10;
        else if (wb_regwrite && (wb_rd != 5'b0) && (wb_rd == ex_rs1) &&
                 !(mem_regwrite && mem_rd == ex_rs1))
            fa = 2'b01;

        // ForwardB
        if (mem_regwrite && (mem_rd != 5'b0) && (mem_rd == ex_rs2))
            fb = 2'b10;
        else if (wb_regwrite && (wb_rd != 5'b0) && (wb_rd == ex_rs2) &&
                 !(mem_regwrite && mem_rd == ex_rs2))
            fb = 2'b01;
    end
    assign ForwardA = fa;
    assign ForwardB = fb;
endmodule