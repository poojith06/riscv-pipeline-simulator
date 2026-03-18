`timescale 1ns/1ps
`include "alu_control.v"

module alu_control_tb;

    reg [1:0] ALUOp;
    reg [3:0] Ins;
    wire [3:0] ALUControl;

    alu_control uut(
        .ALUOp(ALUOp),
        .Ins(Ins),
        .ALUControl(ALUControl)
    );

    task run_test;
        input [4:0] tno;
        input [1:0] t_ALUOp;
        input [3:0] t_Ins;
        input [3:0] expected;
        begin
            ALUOp = t_ALUOp;
            Ins   = t_Ins;
            #5;

            $display("Test %0d", tno);
            $display("ALUOp=%b Ins=%b → ALUControl=%b", ALUOp, Ins, ALUControl);

            if (ALUControl === expected)
                $display("PASS\n");
            else begin
                $display("FAIL");
                $display("Expected = %b\n", expected);
            end
        end
    endtask

    initial begin
        $dumpfile("alu_control_tb.vcd");
        $dumpvars(0, alu_control_tb);

        run_test(1, 2'b00, 4'b0000, 4'b0010);
        run_test(2, 2'b01, 4'b0000, 4'b0110);
        run_test(3, 2'b10, 4'b0000, 4'b0010);
        run_test(4, 2'b10, 4'b1000, 4'b0110);
        run_test(5, 2'b10, 4'b0111, 4'b0000);
        run_test(6, 2'b10, 4'b0110, 4'b0001);

        #20 $finish;
    end
endmodule