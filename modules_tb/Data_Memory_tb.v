`timescale 1ns/1ps
`include "Data_Memory.v"

module Data_Memory_tb;

    reg clk;
    reg reset;
    reg MemRead;
    reg MemWrite;
    reg [9:0] address;
    reg [63:0] write_data;
    wire [63:0] read_data;

    Data_Memory uut(
        .clk(clk),
        .reset(reset),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .address(address),
        .write_data(write_data),
        .read_data(read_data)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    task run_test;
        input [4:0] tno;
        input t_reset;
        input t_MemWrite;
        input t_MemRead;
        input [9:0] t_address;
        input [63:0] t_write_data;
        input [63:0] expected;
        begin
            @(negedge clk);
            reset      = t_reset;
            MemWrite   = t_MemWrite;
            MemRead    = t_MemRead;
            address    = t_address;
            write_data = t_write_data;

            @(posedge clk);
            #2;

            $display("Test %0d", tno);
            $display("Reset=%b MemWrite=%b MemRead=%b Addr=%0d",reset, MemWrite, MemRead, address);
            $display("WriteData=%h", write_data);
            $display("ReadData =%h", read_data);

            if (read_data === expected)
                $display("PASS\n");
            else begin
                $display("FAIL");
                $display("Expected = %h\n", expected);
            end
        end
    endtask

    initial begin
        $dumpfile("Data_Memory_tb.vcd");
        $dumpvars(0, Data_Memory_tb);

        run_test(1, 1'b0, 1'b1, 1'b1,10'd8,64'hDEADBEEFCAFEBABE,64'hDEADBEEFCAFEBABE);
        run_test(2, 1'b0, 1'b0, 1'b1,10'd8,64'h1234567890ABCDEF,64'hDEADBEEFCAFEBABE);
        run_test(3, 1'b0, 1'b0, 1'b0,10'd16,64'd0,64'd0);

        #20 $finish;
    end
endmodule