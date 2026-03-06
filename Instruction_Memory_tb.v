`timescale 1ns/1ps
`include "Instruction_Memory.v"

module Instruction_Memory_tb;

    reg [63:0] addr;
    wire [31:0] instr;

    Instruction_Memory uut(
        .addr(addr),
        .instr(instr)
    );


    task run_test;
        input [4:0]  tno;
        input [63:0] t_addr;
        input [31:0] expected;
        begin
            addr  = t_addr;
            #6;

            $display("Test %0d", tno);
            $display("Address     = %0d", addr);
            $display("Instruction = %h", instr);

            if (instr === expected)
                $display("PASS\n");
            else begin
                $display("FAIL");
                $display("Expected    = %h\n", expected);
            end
        end
    endtask

    initial begin
        $dumpfile("Instruction_Memory_tb.vcd");
        $dumpvars(0, Instruction_Memory_tb);

        run_test(1, 64'd0,  32'h00500113);
        run_test(2, 64'd4,  32'h00A00193);
        run_test(3, 64'd8,  32'h003100B3);
        run_test(4, 64'd12, 32'h40310133);

        #20 $finish;
    end
endmodule