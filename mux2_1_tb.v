`timescale 1ns/1ps
`include "mux2_1.v"

module mux2_1_tb;

    reg [63:0] a, b;
    reg sel;
    wire [63:0] out;

    mux2_1 uut(
        .a(a),
        .b(b),
        .sel(sel),
        .out(out)
    );

    task run_test;
        input [4:0] tno;
        input [63:0] t_a;
        input [63:0] t_b;
        input t_sel;
        input [63:0] expected;
        begin
            a = t_a;
            b = t_b;
            sel = t_sel;
            #5;

            $display("Test %0d", tno);
            $display("a=%h b=%h sel=%b → out=%h", a, b, sel, out);

            if (out === expected)
                $display("PASS\n");
            else begin
                $display("FAIL");
                $display("Expected = %h\n", expected);
            end
        end
    endtask

    initial begin
        $dumpfile("mux2_1_tb.vcd");
        $dumpvars(0, mux2_1_tb);

        run_test(1, 64'hAAAA, 64'hBBBB, 0, 64'hAAAA);
        run_test(2, 64'h123456789ABCDEF0, 64'h0, 0, 64'h123456789ABCDEF0);

        #20 $finish;
    end
endmodule