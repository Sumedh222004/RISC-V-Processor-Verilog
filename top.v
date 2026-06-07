module top(
    input  clk, reset,
    output [31:0] pc,
    output [31:0] instr,
    output [31:0] aluresult,
    output [31:0] writedata,
    output [31:0] readdata,
    output [31:0] cycle_count,
    output [31:0] instr_count,
    output [31:0] stall_count,
    output [31:0] cpi_x100
);

wire        regwrite, alusrc, memwrite, branch, jump;
wire [1:0]  resultsrc, aluop, immsrc;
wire [2:0]  alucontrol;
wire        zero, pcsrce;
wire [1:0]  forwardae, forwardbe;
wire        stalld, stalle, flushd, flushe;
wire [4:0]  rs1e, rs2e, rde, rdm, rdw;
wire        regwritem, regwritew;
wire [1:0]  resultsrcm;

// instruction is valid when it is not a NOP and not flushed
wire instr_valid = (instr != 32'b0) && !flushd;

controller ctrl(
    .op(instr[6:0]),
    .funct3(instr[14:12]),
    .funct7b5(instr[30]),
    .zero(zero),
    .opb5(instr[5]),
    .regwrite(regwrite),
    .alusrc(alusrc),
    .memwrite(memwrite),
    .branch(branch),
    .jump(jump),
    .resultsrc(resultsrc),
    .aluop(aluop),
    .immsrc(immsrc),
    .alucontrol(alucontrol)
);

datapath dp(
    .clk(clk), .reset(reset),
    .forwardae(forwardae), .forwardbe(forwardbe),
    .stalld(stalld), .stalle(stalle),
    .flushd(flushd), .flushe(flushe),
    .regwrite(regwrite), .alusrc(alusrc),
    .memwrite(memwrite), .branch(branch), .jump(jump),
    .resultsrc(resultsrc), .aluop(aluop), .immsrc(immsrc),
    .alucontrol(alucontrol),
    .pc(pc), .instr(instr), .zero(zero),
    .aluresult(aluresult), .writedata(writedata), .readdata(readdata),
    .pcsrce(pcsrce),
    .rs1e_out(rs1e), .rs2e_out(rs2e), .rde_out(rde),
    .rdm_out(rdm), .rdw_out(rdw),
    .regwritem_out(regwritem), .regwritew_out(regwritew),
    .resultsrcm_out(resultsrcm)
);

hazard_unit hu(
    .rs1d(instr[19:15]), .rs2d(instr[24:20]),
    .rs1e(rs1e), .rs2e(rs2e), .rde(rde),
    .rdm(rdm), .rdw(rdw),
    .regwritem(regwritem), .regwritew(regwritew),
    .resultsrcm(resultsrcm),
    .pcsrce(pcsrce),
    .forwardae(forwardae), .forwardbe(forwardbe),
    .stalld(stalld), .stalle(stalle),
    .flushd(flushd), .flushe(flushe)
);

perf_counter pc_unit(
    .clk(clk), .reset(reset),
    .instr_valid(instr_valid),
    .stall(stalld),
    .cycle_count(cycle_count),
    .instr_count(instr_count),
    .stall_count(stall_count),
    .cpi_x100(cpi_x100)
);

endmodule