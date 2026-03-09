module ld_after_sd_forwarding(input[4:0] ld_rd,sd_rs2, input ld_sd_mem_to_reg,ld_sd_mem_write, output ld_sd_sel);
    
    reg ld_sd_sel_reg;

    always @(*) begin

        ld_sd_sel_reg = 1'b0;

        if (ld_sd_mem_to_reg && (ld_rd == sd_rs2) && (ld_rd != 5'b0) && ld_sd_mem_write) begin
            ld_sd_sel_reg = 1'b1;
        end
    end

assign ld_sd_sel = ld_sd_sel_reg;

endmodule