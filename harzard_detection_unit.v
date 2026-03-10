module hazard_detection_unit(
    input  ex_mem_read, cur_mem_write, cur_mem_read, branch_taken,
    input  [4:0] if_id_rs1, if_id_rs2, ex_rd,
    output pc_write, if_id_write, bubble_sel, flush
);
    reg r_pcw, r_ifw, r_bub, r_flush;
    always @(*) begin
        r_pcw=1; r_ifw=1; r_bub=0; r_flush=0;
        if (branch_taken) begin
            r_flush = 1;
        end else if (ex_mem_read && (ex_rd != 5'b0) &&
                     ((ex_rd == if_id_rs1) ||
                      (ex_rd == if_id_rs2 && !(cur_mem_read || cur_mem_write)))) begin
            r_pcw=0; r_ifw=0; r_bub=1;
        end
    end
    assign pc_write   = r_pcw;
    assign if_id_write = r_ifw;
    assign bubble_sel = r_bub;
    assign flush      = r_flush;
endmodule