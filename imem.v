module imem(
    input  [31:0] a,
    output [31:0] rd
);

reg [31:0] RAM[63:0];

initial begin
    // Test program covering full RV32I base instructions
    RAM[0]  = 32'h00500113; // addi  x2,  x0,  5    // x2  = 5
    RAM[1]  = 32'h00C00193; // addi  x3,  x0,  12   // x3  = 12
    RAM[2]  = 32'h003100B3; // add   x1,  x2,  x3   // x1  = 17
    RAM[3]  = 32'h40310233; // sub   x4,  x2,  x3   // x4  = -7
    RAM[4]  = 32'h0030C2B3; // xor   x5,  x1,  x3   // x5  = 17^12
    RAM[5]  = 32'h0030E333; // or    x6,  x1,  x3   // x6  = 17|12
    RAM[6]  = 32'h0030F3B3; // and   x7,  x1,  x3   // x7  = 17&12
    RAM[7]  = 32'h00209433; // sll   x8,  x1,  x2   // x8  = 17<<5
    RAM[8]  = 32'h0020D4B3; // srl   x9,  x1,  x2   // x9  = 17>>5
    RAM[9]  = 32'h00A00513; // addi  x10, x0,  10   // x10 = 10
    RAM[10] = 32'h00A12023; // sw    x10, 0(x2)     // mem[5] = 10
    RAM[11] = 32'h00012583; // lw    x11, 0(x2)     // x11 = mem[5] = 10
    RAM[12] = 32'h00B00613; // addi  x12, x0,  11   // x12 = 11
    RAM[13] = 32'h00C58663; // beq   x11, x12, skip // not taken
    RAM[14] = 32'h00100693; // addi  x13, x0,  1    // x13 = 1 (executed)
    RAM[15] = 32'h00000013; // nop
    RAM[16] = 32'h00000013; // nop
    RAM[17] = 32'h00000013; // nop
    RAM[18] = 32'h00000013; // nop
end

assign rd = RAM[a[31:2]];

endmodule