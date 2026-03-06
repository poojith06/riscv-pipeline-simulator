`timescale 1ns/1ps
`include "alu.v"

module alu_64_bit_tb;
    reg [63:0] a, b;
    reg [3:0] opcode;
    wire [63:0] result;
    wire zero_flag;
    integer pass_count = 0, total_tests = 31;
    
    // Control codes
    localparam  ADD_Oper  = 4'b0010,
                OR_Oper   = 4'b0001,
                AND_Oper  = 4'b0000,
                SUB_Oper  = 4'b0110;
    
    // Instantiate the ALU
    alu_64_bit uut(
        .a(a),
        .b(b),
        .opcode(opcode),
        .result(result),
        .zero_flag(zero_flag)
    );

    task run_test;
        input [7:0] test_number;
        input [63:0] test_a, test_b, expected_result;
        input [3:0] test_opcode;
        input exp_zero;
        begin
            a = test_a;
            b = test_b;
            opcode = test_opcode;
            #10;
            $display("Test %0d:", test_number);
            $display("  A: %016h  B: %016h  Opcode: %b", a, b, test_opcode);
            $display("  Result: %016h  Flags: Z=%b", result, zero_flag);
            
            if (result === expected_result && zero_flag === exp_zero) begin
                pass_count = pass_count + 1;
                $fdisplay(file_handle, "Test %0d, Status: PASS", test_number);
            end else begin
                $fdisplay(file_handle, "Test %0d, Status: FAIL", test_number);
                $display("  FAIL! Expected: result=%016h, zero=%b", expected_result, exp_zero);
                $display("         Got:     result=%016h, zero=%b", result, zero_flag);
            end
        end
    endtask

    integer file_handle;

    initial begin
        file_handle = $fopen("alu_results.txt", "w");
        if (file_handle == 0) begin
            $display("Error: Could not open file for writing.");
            $finish;
        end
        $dumpfile("alu_tb.vcd");
        $dumpvars(0, alu_64_bit_tb);
        pass_count = 0;

        // ======================== ADD (opcode 0010) ========================

        // Baseline: 0 + 0 = 0, zero flag set
        run_test(1, 64'h0000000000000000, 64'h0000000000000000, 64'h0000000000000000, ADD_Oper, 1);

        // Positive overflow: MAX_POS + 1 wraps to MIN_NEG
        run_test(2, 64'h7FFFFFFFFFFFFFFF, 64'h0000000000000001, 64'h8000000000000000, ADD_Oper, 0);

        // Simultaneous carry + overflow + zero: MIN_NEG + MIN_NEG
        run_test(3, 64'h8000000000000000, 64'h8000000000000000, 64'h0000000000000000, ADD_Oper, 1);

        // Unsigned wrap to zero: 0xFFF...F + 1, carry without overflow
        run_test(4, 64'hFFFFFFFFFFFFFFFF, 64'h0000000000000001, 64'h0000000000000000, ADD_Oper, 1);

        // Two negatives with carry, no overflow: (-1) + (-1) = -2
        run_test(5, 64'hFFFFFFFFFFFFFFFF, 64'hFFFFFFFFFFFFFFFF, 64'hFFFFFFFFFFFFFFFE, ADD_Oper, 0);

        // Two MAX_POS overflow to negative, no carry
        run_test(6, 64'h7FFFFFFFFFFFFFFF, 64'h7FFFFFFFFFFFFFFF, 64'hFFFFFFFFFFFFFFFE, ADD_Oper, 0);

        // Negative overflow with carry: MIN_NEG + (-1) = MAX_POS
        run_test(7, 64'h8000000000000000, 64'hFFFFFFFFFFFFFFFF, 64'h7FFFFFFFFFFFFFFF, ADD_Oper, 0);

        // Cancellation to zero with carry: 1 + (-1) = 0
        run_test(8, 64'h0000000000000001, 64'hFFFFFFFFFFFFFFFF, 64'h0000000000000000, ADD_Oper, 1);

        // Carry propagation across 32-bit boundary
        run_test(9, 64'h00000000FFFFFFFF, 64'h0000000000000001, 64'h0000000100000000, ADD_Oper, 0);

        // Random positive + positive, no overflow
        run_test(10, 64'h06EAE7CD9408D55F, 64'h0000000AA221D37B, 64'h06EAE7D8362AA8DA, ADD_Oper, 0);

        // Random positive + negative, no overflow
        run_test(11, 64'h0023185DDFBF101B, 64'hFFFD288475FDE3B9, 64'h002040E255BCF3D4, ADD_Oper, 0);

        // Mid-word carry chain: upper + lower cancel to zero
        run_test(12, 64'h0000000100000000, 64'hFFFFFFFF00000000, 64'h0000000000000000, ADD_Oper, 1);
        // ======================== SUB (opcode 0110) ========================

        // Baseline: 0 - 0 = 0
        run_test(13, 64'h0000000000000000, 64'h0000000000000000, 64'h0000000000000000, SUB_Oper, 1);

        // Equal operands cancel: 1 - 1 = 0
        run_test(14, 64'h0000000000000001, 64'h0000000000000001, 64'h0000000000000000, SUB_Oper, 1);

        // Unsigned borrow: 0 - 1 wraps to all-ones
        run_test(15, 64'h0000000000000000, 64'h0000000000000001, 64'hFFFFFFFFFFFFFFFF, SUB_Oper, 0);

        // Signed underflow: MIN_NEG - 1 = MAX_POS, overflow
        run_test(16, 64'h8000000000000000, 64'h0000000000000001, 64'h7FFFFFFFFFFFFFFF, SUB_Oper, 0);

        // Signed overflow: MAX_POS - (-1) wraps to MIN_NEG
        run_test(17, 64'h7FFFFFFFFFFFFFFF, 64'hFFFFFFFFFFFFFFFF, 64'h8000000000000000, SUB_Oper, 0);

        // Overflow: 0 - MIN_NEG wraps back to MIN_NEG
        run_test(18, 64'h0000000000000000, 64'h8000000000000000, 64'h8000000000000000, SUB_Oper, 0);

        // Negative cancel: (-1) - (-1) = 0
        run_test(19, 64'hFFFFFFFFFFFFFFFF, 64'hFFFFFFFFFFFFFFFF, 64'h0000000000000000, SUB_Oper, 1);

        // Random positive subtraction, no overflow
        run_test(20, 64'h06EAE7CD9408D55F, 64'h0000000AA221D37B, 64'h06EAE7C2F1E701E4, SUB_Oper, 0);

        // Random positive minus negative
        run_test(21, 64'h0023185DDFBF101B, 64'hFFFD288475FDE3B9, 64'h0025EFD969C12C62, SUB_Oper, 0);

        // Large minus small: all-ones - 1
        run_test(22, 64'hFFFFFFFFFFFFFFFF, 64'h0000000000000001, 64'hFFFFFFFFFFFFFFFE, SUB_Oper, 0);

        // Small minus large: 1 - all-ones = 2
        run_test(23, 64'h0000000000000001, 64'hFFFFFFFFFFFFFFFF, 64'h0000000000000002, SUB_Oper, 0);

        // ======================== AND (opcode 0000) ========================

        // Masking with zero: all-ones AND 0 = 0
        run_test(24, 64'hFFFFFFFFFFFFFFFF, 64'h0000000000000000, 64'h0000000000000000, AND_Oper, 1);

        // Random AND with non-zero result
        run_test(25, 64'h00002C84C4D54177, 64'h011C2D636E06D380, 64'h00002C0044044100, AND_Oper, 0);

        // Complementary patterns produce zero: 0x555... & 0xAAA... = 0
        run_test(26, 64'h5555555555555555, 64'hAAAAAAAAAAAAAAAA, 64'h0000000000000000, AND_Oper, 1);

        // Upper 32-bit mask extraction
        run_test(27, 64'h123456789ABCDEF0, 64'hFFFFFFFF00000000, 64'h1234567800000000, AND_Oper, 0);

        // ======================== OR (opcode 0001) ========================

        // Baseline: 0 OR 0 = 0
        run_test(28, 64'h0000000000000000, 64'h0000000000000000, 64'h0000000000000000, OR_Oper, 1);

        // Identity: all-ones OR 1 = all-ones
        run_test(29, 64'hFFFFFFFFFFFFFFFF, 64'hFFFFFFFFFFFFFFFF, 64'hFFFFFFFFFFFFFFFF, OR_Oper, 0);

        // Complementary pattern OR
        run_test(30, 64'h5555555555555555, 64'hAAAAAAAAAAAAAAAA, 64'hFFFFFFFFFFFFFFFF, OR_Oper, 0);

        // Random OR pattern
        run_test(31, 64'h00002C84C4D54177, 64'h011C2D636E06D380, 64'h011C2DE7EED7D3F7, OR_Oper, 0);


        // ======================== FINAL SUMMARY ========================
        $display("\n========================================");
        $display("  FINAL RESULT: Passed %0d/%0d tests", pass_count, total_tests);
        $display("========================================\n");
        $fdisplay(file_handle, "Passed %0d/%0d tests", pass_count, total_tests);
        $fclose(file_handle);
        #10 $finish;
    end
endmodule

