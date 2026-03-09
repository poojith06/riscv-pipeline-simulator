module hazard_detection_unit(
    input ID_EX_mem_read,ld_sd_mem_write,ld_sd_mem_read,Branch_and_zero, 
    input[4:0] IF_ID_rs1,IF_ID_rs2,ID_EX_rd,            
    output pc_write,IF_ID_write,control_bubble_sel,flush         
);
    reg pc_write_reg, IF_ID_write_reg, control_bubble_sel_reg, flush_reg;

    always @(*) begin

        pc_write_reg = 1'b1;
        IF_ID_write_reg = 1'b1;
        control_bubble_sel_reg = 1'b0;
        flush_reg = 1'b0;
        
        if (Branch_and_zero) begin
            flush_reg = 1'b1;
        end


        else if (ID_EX_mem_read && ((ID_EX_rd == IF_ID_rs1) || (ID_EX_rd == IF_ID_rs2 && !(ld_sd_mem_read || ld_sd_mem_write))) && (ID_EX_rd != 5'b0)) begin
            
            pc_write_reg = 1'b0;
            IF_ID_write_reg = 1'b0;
            control_bubble_sel_reg = 1'b1;
            flush_reg = 1'b0;               
        end
    end

    assign pc_write = pc_write_reg;
    assign IF_ID_write = IF_ID_write_reg;
    assign control_bubble_sel = control_bubble_sel_reg;
    assign flush = flush_reg;

endmodule