
module hazard_detection_unit(
    input clk, reset,
    input  ex_mem_read, cur_mem_write, cur_mem_read,
    input  branch_taken,
    input  branch_instr,
    input  [63:0] branch_pc,
    input  [4:0] if_id_rs1, if_id_rs2, ex_rd,
    output pc_write, if_id_write, bubble_sel, flush,
    output predicted_taken
);

    // predicted_taken unused for PC redirect — pc_mux handles that directly
    // Keep BHT for future use but don't use prediction to gate flush
    reg [1:0] bht [0:15];
    integer idx;
    wire [3:0] bht_index = branch_pc[5:2];
    assign predicted_taken = bht[bht_index][1];

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (idx = 0; idx < 16; idx = idx + 1)
                bht[idx] <= 2'b01;
        end else if (branch_instr) begin
            case (bht[bht_index])
                2'b00: bht[bht_index] <= branch_taken ? 2'b01 : 2'b00;
                2'b01: bht[bht_index] <= branch_taken ? 2'b10 : 2'b00;
                2'b10: bht[bht_index] <= branch_taken ? 2'b11 : 2'b01;
                2'b11: bht[bht_index] <= branch_taken ? 2'b11 : 2'b10;
            endcase
        end
    end

    reg r_pcw, r_ifw, r_bub, r_flush;

    always @(*) begin
        r_pcw  = 1;
        r_ifw  = 1;
        r_bub  = 0;
        r_flush = 0;

        if (branch_instr && branch_taken) begin
            r_flush = 1;
        end

        // Load-use hazard (unchanged)
        if (ex_mem_read && (ex_rd != 5'b0) &&
            ((ex_rd == if_id_rs1) ||
             (ex_rd == if_id_rs2 && !(cur_mem_read || cur_mem_write)))) begin
            r_pcw = 0;
            r_ifw = 0;
            r_bub = 1;
        end
    end

    assign pc_write    = r_pcw;
    assign if_id_write = r_ifw;
    assign bubble_sel  = r_bub;
    assign flush       = r_flush;

endmodule