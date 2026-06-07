module datapath(
    input         clk, reset,
    input  [1:0]  forwardae, forwardbe,
    input         stalld, stalle, flushd, flushe,
    input         regwrite, alusrc, memwrite, branch, jump,
    input  [1:0]  resultsrc, aluop, immsrc,
    input  [2:0]  alucontrol,
    output [31:0] pc,
    output [31:0] instr,
    output        zero,
    output [31:0] aluresult, writedata, readdata,
    output        pcsrce,
    output [4:0]  rs1e_out, rs2e_out, rde_out, rdm_out, rdw_out,
    output        regwritem_out, regwritew_out,
    output [1:0]  resultsrcm_out
);

// ---- PC stage ----
reg  [31:0] pcreg;
wire [31:0] pcplus4f, pctargetm, pcnext;

assign pcplus4f  = pcreg + 4;
assign pcnext    = (pcsrce === 1'b1) ? pctargetm : pcplus4f;  // FIX: case-equality to block X
assign pc        = pcreg;

always @(posedge clk or posedge reset) begin
    if (reset)        pcreg <= 32'b0;
    else if (!stalld) pcreg <= pcnext;
end

// ---- Fetch ----
wire [31:0] instrF;
imem imem1(.a(pcreg), .rd(instrF));

// ---- IF/ID register ----
wire [31:0] pcD, instrD;
if_id if_id1(
    .clk(clk), .reset(reset | flushd), .enable(!stalld),
    .pc_in(pcreg), .instr_in(instrF),
    .pc_out(pcD), .instr_out(instrD)
);
assign instr = instrD;

// ---- Decode stage ----
wire [4:0]  rs1D, rs2D, rdD;
assign rs1D = instrD[19:15];
assign rs2D = instrD[24:20];
assign rdD  = instrD[11:7];

wire [31:0] rd1D, rd2D, immextD;
wire [31:0] resultW;
wire [4:0]  rdW;
wire        regwriteW;

regfile rf(
    .clk(clk), .we3(regwriteW),
    .a1(rs1D), .a2(rs2D), .a3(rdW),
    .wd3(resultW),
    .rd1(rd1D), .rd2(rd2D)
);

extend ext(
    .instr(instrD[31:7]),
    .immsrc(immsrc),
    .immext(immextD)
);

// ---- ID/IEx register ----
wire [31:0] pcE, rd1E, rd2E, immextE, pcplus4E;
wire [4:0]  rs1E, rs2E, rdE;
wire [2:0]  funct3E;
wire        regwriteE, memwriteE, alusrcE, branchE, jumpE;
wire [1:0]  resultsrcE, aluopE;

id_iex id_iex1(
    .clk(clk), .reset(reset | flushe),
    .pc_in(pcD), .rd1_in(rd1D), .rd2_in(rd2D), .immext_in(immextD),
    .rs1_in(rs1D), .rs2_in(rs2D), .rd_in(rdD),
    .funct3_in(instrD[14:12]),
    .regwrite_in(regwrite), .memwrite_in(memwrite),
    .alusrc_in(alusrc), .resultsrc_in(resultsrc),
    .aluop_in(aluop), .branch_in(branch), .jump_in(jump),
    .pc_out(pcE), .rd1_out(rd1E), .rd2_out(rd2E), .immext_out(immextE),
    .rs1_out(rs1E), .rs2_out(rs2E), .rd_out(rdE),
    .funct3_out(funct3E),
    .regwrite_out(regwriteE), .memwrite_out(memwriteE),
    .alusrc_out(alusrcE), .resultsrc_out(resultsrcE),
    .aluop_out(aluopE), .branch_out(branchE), .jump_out(jumpE)
);

assign pcplus4E   = pcE + 4;
assign rs1e_out   = rs1E;
assign rs2e_out   = rs2E;
assign rde_out    = rdE;

// ---- Execute stage ----
wire [31:0] aluresultE, srcbE_pre, srcaE, srcbE;
wire        zeroE;

// forwarding muxes
assign srcaE     = (forwardae == 2'b10) ? aluresultM :
                   (forwardae == 2'b01) ? resultW    : rd1E;

assign srcbE_pre = (forwardbe == 2'b10) ? aluresultM :
                   (forwardbe == 2'b01) ? resultW    : rd2E;

assign srcbE     = alusrcE ? immextE : srcbE_pre;
assign writedata = srcbE_pre;

alu alu1(
    .a(srcaE), .b(srcbE),
    .alucontrol(alucontrol),
    .result(aluresultE), .zero(zeroE)
);

// branch target computed in execute
wire [31:0] pctargetE;
assign pctargetE = pcE + immextE;

// ---- IEx/IMem register ----
wire [31:0] aluresultM, writedataM, pcplus4M, pctargetM_reg;
wire [4:0]  rdM;
wire        regwriteM, memwriteM, branchM, jumpM, zeroM;
wire [1:0]  resultsrcM;

iex_imem iex_imem1(
    .clk(clk), .reset(reset),
    .pc_in(pctargetE),
    .aluresult_in(aluresultE),
    .writedata_in(srcbE_pre),
    .pcplus4_in(pcplus4E),
    .rd_in(rdE),
    .regwrite_in(regwriteE), .memwrite_in(memwriteE),
    .resultsrc_in(resultsrcE),
    .branch_in(branchE), .jump_in(jumpE), .zero_in(zeroE),
    .pc_out(pctargetM_reg),
    .aluresult_out(aluresultM),
    .writedata_out(writedataM),
    .pcplus4_out(pcplus4M),
    .rd_out(rdM),
    .regwrite_out(regwriteM), .memwrite_out(memwriteM),
    .resultsrc_out(resultsrcM),
    .branch_out(branchM), .jump_out(jumpM), .zero_out(zeroM)
);

assign pctargetm      = pctargetM_reg;
assign pcsrce         = ((branchM === 1'b1) & (zeroM === 1'b1)) | (jumpM === 1'b1);  // FIX: case-equality to block X
assign aluresult      = aluresultM;
assign rdm_out        = rdM;
assign regwritem_out  = regwriteM;
assign resultsrcm_out = resultsrcM;

// ---- Memory stage ----
wire [31:0] readdataM;
dmem dmem1(
    .clk(clk), .we(memwriteM),
    .a(aluresultM), .wd(writedataM),
    .rd(readdataM)
);

// ---- IMem/IW register ----
wire [31:0] aluresultW, readdataW, pcplus4W;
wire [1:0]  resultsrcW;

imem_iw imem_iw1(
    .clk(clk), .reset(reset),
    .aluresult_in(aluresultM),
    .readdata_in(readdataM),
    .pcplus4_in(pcplus4M),
    .rd_in(rdM),
    .regwrite_in(regwriteM),
    .resultsrc_in(resultsrcM),
    .aluresult_out(aluresultW),
    .readdata_out(readdataW),
    .pcplus4_out(pcplus4W),
    .rd_out(rdW),
    .regwrite_out(regwriteW),
    .resultsrc_out(resultsrcW)
);

assign rdw_out      = rdW;
assign regwritew_out = regwriteW;

// ---- Writeback mux ----
assign resultW  = (resultsrcW == 2'b00) ? aluresultW :
                  (resultsrcW == 2'b01) ? readdataW  : pcplus4W;

assign readdata = readdataW;
assign zero     = zeroE;

endmodule