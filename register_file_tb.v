`timescale 1ns/1ps
`include "register_file.v"

module register_file_tb;
    reg clk;
    reg reset;
    reg reg_write_en;
    reg [4:0] read_reg1, read_reg2, write_reg;
    reg [63:0] write_data;
    wire [63:0] read_data1, read_data2;

    register_file uut(
        .clk(clk),
        .reset(reset),
        .reg_write_en(reg_write_en),
        .read_reg1(read_reg1),
        .read_reg2(read_reg2),
        .write_reg(write_reg),
        .write_data(write_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    task run_test;
        input [4:0] tno;
        input t_reset;
        input t_reg_write_en;
        input [4:0] t_read_reg1;
        input [4:0] t_read_reg2;
        input [4:0] t_write_reg;
        input [63:0] t_write_data;
        input [63:0] expected1;
        input [63:0] expected2;
        begin

            @(negedge clk);
            reset = t_reset;
            reg_write_en = t_reg_write_en;
            read_reg1 = t_read_reg1;
            read_reg2 = t_read_reg2;
            write_reg = t_write_reg;
            write_data = t_write_data;

            @(posedge clk);
            #2;

            $display("Test %0d", tno);
            $display("Reset=%b WE=%b WR=%d WD=%h", reset, reg_write_en, write_reg, write_data);
            $display("RR1=%d RD1=%h", read_reg1, read_data1);
            $display("RR2=%d RD2=%h", read_reg2, read_data2);

            if (read_data1 === expected1 && read_data2 === expected2)
                $display("PASS\n");
            else begin
                $display("FAIL");
                $display("Expected RD1=%h  RD2=%h", expected1, expected2);
                $display("Output   RD1=%h  RD2=%h\n", read_data1, read_data2);
            end
        end
    endtask

    initial begin
        $dumpfile("register_file_tb.vcd");
        $dumpvars(0, register_file_tb);

        run_test(1, 0, 1, 0, 0, 0, 64'hFFFFFFFFFFFFFFFF, 64'h0, 64'h0);
        run_test(2, 0, 1, 1, 0, 1, 64'hDEADBEEFDEADBEEF, 64'hDEADBEEFDEADBEEF, 64'h0);
        run_test(3, 0, 1, 1, 2, 2, 64'hCAFEBABECAFEBABE, 64'hDEADBEEFDEADBEEF, 64'hCAFEBABECAFEBABE);
        run_test(4, 0, 0, 1, 2, 1, 64'h1111111111111111, 64'hDEADBEEFDEADBEEF, 64'hCAFEBABECAFEBABE);
        run_test(5, 0, 1, 0, 1, 0, 64'hFFFFFFFFFFFFFFFF, 64'h0, 64'hDEADBEEFDEADBEEF);
        run_test(6, 0, 1, 31, 0, 31, 64'h1234567890ABCDEF, 64'h1234567890ABCDEF, 64'h0);
        run_test(7, 0, 0, 2, 2, 0, 64'h0, 64'hCAFEBABECAFEBABE, 64'hCAFEBABECAFEBABE);

        #20 $finish;
    end
endmodule