`timescale 1ns/1ps
`include "seq.v"

module seq_tb;

    reg clk;
    reg reset;
    integer i;
    integer instr_count;
    integer outfile;

    seq uut (
        .clk(clk),
        .reset(reset)
    );

    initial begin
        instr_count = 0;
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
    reset = 1;     
    #11;
    reset = 0;
    end

    always @(posedge clk) begin
        if (!reset)
            instr_count = instr_count + 1;
    end

    // debug monitor 
    // always @(negedge clk) begin

    //     $display("PC=%d INSTR=%h opcode=%b RegWrite=%b WriteReg=%d WriteData=%h",
    //              uut.pc_out,
    //              uut.instr,
    //              uut.instr[6:0],
    //              uut.reg_write_en,
    //              uut.instr[11:7],
    //              uut.write_data);
    //     $display("INSTR=%h", uut.instr);
    //     $display("MemToReg=%b", uut.MemToReg);
    //     $display("imm_shifted=%b", uut.imm_shifted);
    //     $display("mux_pc_2=%b", uut.mux_pc_2);
    //     $display("Branch_and_zero=%b", uut.Branch_and_zero);
    //     $display("read1=%h read2=%h imm=%h alu_in2=%h alu_result=%h",
    //             uut.read_data1,
    //             uut.read_data2,
    //             uut.imm,
    //             uut.alu_in2,
    //             uut.alu_result);
    // end


    initial begin
        $dumpfile("seq_tb.vcd");
        $dumpvars(0, seq_tb);
        wait(uut.instr == 32'h00000000);
        @(posedge clk);
        #2

        // $display("\n==== REGISTER FILE CONTENTS ====");
        // for (i = 0; i < 32; i = i + 1)
        //     $display("x%0d = %016h", i, uut.register_file_inst.registers[i]);
        // $display("\nTotal instructions executed: %0d", instr_count);

        outfile = $fopen("register_file.txt", "w");

        for (i = 0; i < 32; i = i + 1)
            $fdisplay(outfile, "%016h", uut.register_file_inst.registers[i]);

        $fdisplay(outfile, "%0d", instr_count);

        $fclose(outfile);
        $finish;

    end
endmodule