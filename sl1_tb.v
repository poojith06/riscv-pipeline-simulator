`timescale 1ns/1ps
`include "sl1.v"

module sl1_tb;

    reg  [63:0] in;
    wire [63:0] out;

    sl1 uut (.in(in), .out(out));

    initial begin
        $dumpfile("sl1_tb.vcd");
        $dumpvars(0, sl1_tb);

        in = 64'h0000000000000001; #10;
        in = 64'h000000000000000F; #10;
        in = 64'h8000000000000000; #10;

        $finish;
    end

endmodule