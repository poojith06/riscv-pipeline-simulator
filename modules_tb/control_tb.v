`timescale 1ns/1ps
`include "control.v"

module control_tb;

    reg [6:0] opcode;
    wire Branch;
    wire MemRead;
    wire MemToReg;
    wire [1:0] ALUOp;
    wire MemWrite;
    wire ALUSrc;
    wire reg_write_en;

    control uut(
        .opcode(opcode),
        .Branch(Branch),
        .MemRead(MemRead),
        .MemToReg(MemToReg),
        .ALUOp(ALUOp),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .reg_write_en(reg_write_en)
    );

    task run_test;
        input [4:0] tno;
        input [6:0] t_opcode;
        input expBranch;
        input expMemRead;
        input expMemToReg;
        input [1:0] expALUOp;
        input expMemWrite;
        input expALUSrc;
        input expRegWrite;
        begin
            opcode = t_opcode;
            #5;

            $display("Test %0d", tno);
            $display("Opcode = %b", opcode);
            $display("Outputs: Branch=%b MemRead=%b MemToReg=%b ALUOp=%b MemWrite=%b ALUSrc=%b RegWrite=%b",
                     Branch, MemRead, MemToReg, ALUOp, MemWrite, ALUSrc, reg_write_en);

            if (Branch===expBranch &&
                MemRead===expMemRead &&
                MemToReg===expMemToReg &&
                ALUOp===expALUOp &&
                MemWrite===expMemWrite &&
                ALUSrc===expALUSrc &&
                reg_write_en===expRegWrite)
                $display("PASS\n");
            else begin
                $display("FAIL");
                $display("Expected: Branch=%b MemRead=%b MemToReg=%b ALUOp=%b MemWrite=%b ALUSrc=%b RegWrite=%b\n",
                         expBranch, expMemRead, expMemToReg, expALUOp, expMemWrite, expALUSrc, expRegWrite);
            end
        end
    endtask

    initial begin
        $dumpfile("control_tb.vcd");
        $dumpvars(0, control_tb);

        run_test(1, 7'b0110011, 0,0,0,2'b10,0,0,1);
        run_test(2, 7'b0010011, 0,0,0,2'b00,0,1,1);
        run_test(3, 7'b0000011, 0,1,1,2'b00,0,1,1);
        run_test(4, 7'b0100011, 0,0,0,2'b00,1,1,0);
        run_test(5, 7'b1100011, 1,0,0,2'b01,0,0,0);

        #20 $finish;
    end
endmodule