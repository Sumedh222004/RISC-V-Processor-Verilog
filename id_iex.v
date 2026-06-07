module id_iex(
    input         clk, reset,
    input  [31:0] pc_in, rd1_in, rd2_in, immext_in,
    input  [4:0]  rs1_in, rs2_in, rd_in,
    input  [2:0]  funct3_in,
    input         regwrite_in, memwrite_in, alusrc_in,
    input  [1:0]  resultsrc_in, aluop_in,
    input         branch_in, jump_in,
    output reg [31:0] pc_out, rd1_out, rd2_out, immext_out,
    output reg [4:0]  rs1_out, rs2_out, rd_out,
    output reg [2:0]  funct3_out,
    output reg        regwrite_out, memwrite_out, alusrc_out,
    output reg [1:0]  resultsrc_out, aluop_out,
    output reg        branch_out, jump_out
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        pc_out       <= 0; rd1_out      <= 0; rd2_out  <= 0;
        immext_out   <= 0; rs1_out      <= 0; rs2_out  <= 0;
        rd_out       <= 0; funct3_out   <= 0;
        regwrite_out <= 0; memwrite_out <= 0; alusrc_out   <= 0;
        resultsrc_out <= 0; aluop_out  <= 0;
        branch_out   <= 0; jump_out    <= 0;
    end else begin
        pc_out        <= pc_in;
        rd1_out       <= rd1_in;
        rd2_out       <= rd2_in;
        immext_out    <= immext_in;
        rs1_out       <= rs1_in;
        rs2_out       <= rs2_in;
        rd_out        <= rd_in;
        funct3_out    <= funct3_in;
        regwrite_out  <= regwrite_in;
        memwrite_out  <= memwrite_in;
        alusrc_out    <= alusrc_in;
        resultsrc_out <= resultsrc_in;
        aluop_out     <= aluop_in;
        branch_out    <= branch_in;
        jump_out      <= jump_in;
    end
end

endmodule