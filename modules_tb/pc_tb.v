`timescale 1ns/1ps
`include "pc.v"

module pc_tb;
    reg clk;
    reg reset;
    reg [63:0] pc_in;
    wire [63:0] pc_out;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    pc uut(
        .clk(clk),
        .reset(reset),
        .pc_in(pc_in),
        .pc_out(pc_out)
    );
    
    task run_test;
        input [7:0] test_number;
        input [63:0] test_pc_in;
        input test_reset;
        input [63:0] expected_pc_out;
        begin
            pc_in = test_pc_in;
            reset = test_reset;
            
            @(posedge clk);
            #2;
            
            $display("Test %0d: pc_in = %h, reset = %b, pc_out = %h", test_number, pc_in, reset, pc_out);

            if (pc_out === expected_pc_out)
                $display("PASS\n");
            else begin 
                $display("FAIL");
                $display("  Expected pc_out = %h\n", expected_pc_out);
            end
        end
    endtask
    
    initial begin
        $dumpfile("pc_tb.vcd");
        $dumpvars(0, pc_tb);
        
        run_test(1, 64'h00ADB12FDEADBEEF, 1, 64'h0);
        run_test(2, 64'h000000000ABCDEF4, 0, 64'h000000000ABCDEF4);
        
        #20
        $finish;
    end
endmodule