module controller(
    input  [6:0] op,
    input  [2:0] funct3,
    input        funct7b5,
    input        zero,
    input        opb5,
    output       regwrite, alusrc, memwrite, branch, jump,
    output [1:0] resultsrc, aluop, immsrc,
    output [2:0] alucontrol
);

wire [1:0] aluop_w;

maindec md(
    .op(op), .regwrite(regwrite),
    .memwrite(memwrite), .resultsrc(resultsrc),
    .branch(branch), .aluop(aluop_w),
    .jump(jump), .alusrc(alusrc),
    .immsrc(immsrc)
);

assign aluop = aluop_w;

aludec ad(
    .aluop(aluop_w), .funct3(funct3),
    .funct7b5(funct7b5), .opb5(opb5),
    .alucontrol(alucontrol)
);

endmodule