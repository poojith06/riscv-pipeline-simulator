`timescale 1ns / 1ps

`include "pipe.v"

module pipe_tb;

    reg clk, reset;

    pipe uut(.clk(clk), .reset(reset));

    // 10ns clock
    initial begin clk = 0; forever #5 clk = ~clk; end

    integer i, fd;
    integer instr_count;
    integer nop_count;

    // Count every posedge where reset==0 (same convention as seq_tb)
    initial begin
        instr_count = 0;
        nop_count   = 0;
    end

    always @(posedge clk) begin
        if (!reset)
            instr_count = instr_count + 1;
    end

    initial begin
        $dumpfile("pipe_tb.vcd");
        $dumpvars(0, uut);

        // Same reset timing as seq_tb: hold reset for #11
        reset = 1;
        #11;
        reset = 0;

        // Wait until 4 consecutive NOPs (add x0,x0,x0 = 32'h00000033) seen in IF
        // then wait 1 more cycle so instr_count is correct (matches seq convention)
        @(posedge clk); // align to clock

        while (nop_count < 4) begin
            @(posedge clk);
            if (uut.instr == 32'h00000033)
                nop_count = nop_count + 1;
            else
                nop_count = 0;
        end

        // 1 extra cycle after 4th NOP detected (matches expected cycle count)
        @(posedge clk);
        #1

        // Write register_file.txt
        fd = $fopen("register_file.txt", "w");
        for (i = 0; i < 32; i = i + 1)
            $fdisplay(fd, "%h", uut.RF.registers[i]);
        $fdisplay(fd, "%0d", instr_count);
        $fclose(fd);

        $display("Total cycles: %0d", instr_count);
        for (i = 0; i < 32; i = i + 1)
            $display("x%0d: %h", i, uut.RF.registers[i]);

        $finish;
    end

endmodule
