// `timescale 1ns / 1ps

// `include "pipe.v"

// module pipe_tb;

//     reg clk, reset;

//     pipe uut(.clk(clk), .reset(reset));

//     // 10ns clock
//     initial begin clk = 0; forever #5 clk = ~clk; end

//     integer i, fd;
//     integer instr_count;
//     integer nop_count;

//     // Count every posedge where reset==0 (same convention as seq_tb)
//     initial begin
//         instr_count = 0;
//         nop_count   = 0;
//     end

//     always @(posedge clk) begin
//         if (!reset)
//             instr_count = instr_count + 1;
//     end

//     initial begin
//         $dumpfile("pipe_tb.vcd");
//         $dumpvars(0, uut);

//         // Same reset timing as seq_tb: hold reset for #11
//         reset = 1;
//         #11;
//         reset = 0;

//         // Wait until 4 consecutive NOPs (add x0,x0,x0 = 32'h00000033) seen in IF
//         // then wait 1 more cycle so instr_count is correct (matches seq convention)
//         @(posedge clk); // align to clock

//         while (nop_count < 4) begin
//             @(posedge clk);
//             if (uut.instr == 32'h00000033)
//                 nop_count = nop_count + 1;
//             else
//                 nop_count = 0;
//         end

//         // 1 extra cycle after 4th NOP detected (matches expected cycle count)
//         @(posedge clk);
//         #1

//         // Write register_file.txt
//         fd = $fopen("register_file.txt", "w");
//         for (i = 0; i < 32; i = i + 1)
//             $fdisplay(fd, "%h", uut.RF.registers[i]);
//         $fdisplay(fd, "%0d", instr_count);
//         $fclose(fd);

//         $display("Total cycles: %0d", instr_count);
//         for (i = 0; i < 32; i = i + 1)
//             $display("x%0d: %h", i, uut.RF.registers[i]);

//         $finish;
//     end

// endmodule


// Testbench for the 5-stage Pipelined RISC-V Processor
// NOPs are encoded as "add x0, x0, x0" = 32'h0000_0033.
// The program ends with 4 such NOPs to flush the pipeline.
// The instruction memory is combinational and zero-initialised beyond
// the program, so after NOP 4 is presented at IF the very next
// combinational fetch is 32'h0000_0000 (all zeroes).
// We watch instruction_IF (the raw combinational output of the
// instruction memory).  The moment it goes to 32'h0000_0000 we know
// NOP 4 has just been fetched into IF this cycle -- stop immediately.
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