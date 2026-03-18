module full_adder(input a,b,c_in, output sum,carry);
    wire axb, a_and_b, axb_and_cin;
    xor(axb,a,b);
    xor(sum,axb,c_in);
    and(a_and_b,a,b);
    and(axb_and_cin,axb,c_in);
    or(carry,a_and_b,axb_and_cin);
endmodule


module add64(input [63:0] a,b, output [63:0]sum, output zero);
    wire [64:0]c;
    assign c[0] = 1'b0;
    genvar i;
    generate
        for (i=0; i<64; i=i+1) begin
            full_adder inst (.a(a[i]),.b(b[i]),.c_in(c[i]),.sum(sum[i]),.carry(c[i+1]));
        end
    endgenerate
    assign zero = (sum == 64'b0);
endmodule


module sub64(input [63:0] a,b, output [63:0]sum, output zero);
    wire [64:0]c;
    wire [63:0]b_inv;
    genvar j;
    generate
        for(j=0; j< 64;j=j+1) begin
            xor x1(b_inv[j], b[j], 1'b1);
        end
    endgenerate
    assign c[0] = 1'b1;
    genvar i;
    generate
        for (i=0; i<64; i=i+1) begin
            full_adder inst (.a(a[i]),.b(b_inv[i]),.c_in(c[i]),.sum(sum[i]),.carry(c[i+1]));
        end
    endgenerate
    assign zero = (sum == 64'b0);
endmodule


module or64(input [63:0]a, b, output [63:0]out, output zero);
    genvar i;
    generate
        for (i=0;i<64;i=i+1) begin
            or(out[i],a[i],b[i]);
        end
    endgenerate
    assign zero=(out==64'b0);
endmodule


module and64(input [63:0]a, b, output [63:0]out, output zero);
    genvar i;
    generate
        for (i=0;i<64;i=i+1) begin
            and(out[i],a[i],b[i]);
        end
    endgenerate
    assign zero=(out==64'b0);
endmodule


module alu_64_bit(input [63:0]a,b, input [3:0]opcode, output [63:0]result, output zero_flag);

    localparam  ADD_Oper  = 4'b0010,
                OR_Oper   = 4'b0001,
                AND_Oper  = 4'b0000,
                SUB_Oper  = 4'b0110;

    wire [63:0] add_out, sub_out, and_out, or_out;
    wire add_z, sub_z, and_z, or_z;


    add64 add_u(.a(a), .b(b), .sum(add_out), .zero(add_z));
    sub64 sub_u(.a(a), .b(b), .sum(sub_out), .zero(sub_z));
    and64 and_u(.a(a), .b(b), .out(and_out), .zero(and_z));
    or64  or_u (.a(a), .b(b), .out(or_out),  .zero(or_z));

    reg [63:0] res_sel;
    reg        z_sel;

    always @(*) begin

        case(opcode)

            ADD_Oper: begin
                res_sel = add_out;
                z_sel   = add_z;
            end

            SUB_Oper: begin
                res_sel = sub_out;
                z_sel   = sub_z;
            end

            AND_Oper: begin
                res_sel = and_out;
                z_sel   = and_z;
            end

            OR_Oper: begin
                res_sel = or_out;
                z_sel   = or_z;
            end

            default: begin
                res_sel = 64'b0;
                z_sel   = 1'b1;
            end

        endcase
    end

    assign result        = res_sel;
    assign zero_flag     = z_sel;

endmodule