module register_file(input clk,reset,reg_write_en, input[4:0] read_reg1, read_reg2, write_reg, input[63:0] write_data, output[63:0] read_data1, read_data2);
    
    reg[63:0] registers[31:0];
    
    integer i;
    initial begin
        for (i = 0; i<32; i=i+1) begin
            registers[i] = 64'b0;
        end
    end

    assign read_data1 = registers[read_reg1];
    assign read_data2 = registers[read_reg2];
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i=0; i<32; i=i+1) begin
                registers[i]<=64'b0;
            end
        end
        else if (reg_write_en && write_reg != 5'b0) begin
            registers[write_reg]<=write_data;
        end    
    end
endmodule