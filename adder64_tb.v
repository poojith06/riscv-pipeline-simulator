`timescale 1ns/1ps
`include "adder64.v"

module adder64_tb;

    reg [63:0] a, b;
    wire [63:0] sum;

    adder64 uut(
        .a(a),
        .b(b),
        .sum(sum)
    );

    task run_test;
        input [4:0] tno;
        input [63:0] ta;
        input [63:0] tb;
        input [63:0] expected;
        begin
            a = ta;
            b = tb;
            #5;

            $display("Test %0d", tno);
            $display("a=%h b=%h → sum=%h", a, b, sum);

            if (sum === expected)
                $display("PASS\n");
            else begin
                $display("FAIL");
                $display("Expected = %h\n", expected);
            end
        end
    endtask

    initial begin
        $dumpfile("adder64_tb.vcd");
        $dumpvars(0, adder64_tb);

        run_test(1, 64'd10, 64'd20, 64'd30);
        run_test(3, 64'hFFFFFFFFFFFFFFF0, 64'd16, 64'h0);

        #20 $finish;
    end
endmodule