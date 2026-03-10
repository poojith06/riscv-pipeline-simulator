`timescale 1ns / 1ps

`include "pipe.v"

module pipe_tb;

    reg clk, reset;

    pipe uut(.clk(clk), .reset(reset));

    // 10ns clock
    initial begin clk = 0; forever #5 clk = ~clk; end

    integer i, fd;
    integer instr_count;

    initial begin
        instr_count = 0;
    end

    always @(posedge clk) begin
        if (!reset)
            instr_count = instr_count + 1;
    end

    initial begin
        $dumpfile("pipe_tb.vcd");
        $dumpvars(0, uut);

        reset = 1;
        #11;
        reset = 0;
    end

    // Stop when instruction memory output becomes 32'h00000000
    // (past end of program). Sampled at negedge so combinational
    // paths have settled. Guard pc != 0 to avoid false trigger.
    initial begin
        @(negedge reset);
        forever begin
            @(negedge clk);
            if (uut.instr === 32'h00000000
                && uut.pc_out !== 64'h0) begin

                // Write register_file.txt
                fd = $fopen("register_file.txt", "w");
                for (i = 0; i < 32; i = i + 1)
                    $fdisplay(fd, "%h", uut.RF.registers[i]);
                $fdisplay(fd, "%0d", instr_count + 1);
                $fclose(fd);

                $display("Total cycles: %0d", instr_count + 1);
                for (i = 0; i < 32; i = i + 1)
                    $display("x%0d: %h", i, uut.RF.registers[i]);

                $finish;
            end
        end
    end

endmodule