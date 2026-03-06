module Instruction_Memory(input[63:0] addr, output[31:0] instr);

    reg [7:0] memory[4095:0];
    integer i;

    initial begin
        for (i = 0; i < 4096; i = i + 1)
                memory[i] = 8'h00;
        $readmemh("instructions.txt", memory);    
        // $readmemh("../instructions.txt", memory); use this when your using some extention on vscode
    end

    assign instr = {memory[addr[11:0]],memory[addr[11:0]+1],memory[addr[11:0]+2],memory[addr[11:0]+3]};

endmodule