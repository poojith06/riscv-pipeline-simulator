`timescale 1ns/1ps
`include "Immediate_Generation.v"

module Immediate_Generation_tb;

    reg  [31:0] instr;
    wire [63:0] imm;

    Immediate_Generation uut(
        .instr(instr),
        .imm(imm)
    );

    task run_test;
        input [4:0] tno;
        input [31:0] t_instr;
        input [63:0] expected;
        begin
            instr = t_instr;
            #5;

            $display("Test %0d", tno);
            $display("Instruction = %h", instr);
            $display("Immediate   = %h", imm);

            if (imm === expected)
                $display("PASS\n");
            else begin
                $display("FAIL");
                $display("Expected = %h\n", expected);
            end
        end
    endtask

    initial begin
        $dumpfile("Immediate_Generation_tb.vcd");
        $dumpvars(0, Immediate_Generation_tb);

        // I-type
        run_test(1,32'b000000000010_00010_000_00001_0010011,64'd2);
        // load-type
        run_test(2,32'b111111111111_00010_000_00001_0000011,64'hFFFFFFFFFFFFFFFF);
        // S-type
        run_test(3,32'b0000000_00010_00001_010_01000_0100011,64'd8);
        // B-type 
        run_test(4,32'b0000000_00010_00001_000_00100_1100011,64'd2);

        #20 $finish;
    end
endmodule