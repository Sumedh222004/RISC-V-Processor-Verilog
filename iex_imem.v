module iex_imem(
    input         clk, reset,
    input  [31:0] pc_in, aluresult_in, writedata_in, pcplus4_in,
    input  [4:0]  rd_in,
    input         regwrite_in, memwrite_in,
    input  [1:0]  resultsrc_in,
    input         branch_in, jump_in, zero_in,
    output reg [31:0] pc_out, aluresult_out, writedata_out, pcplus4_out,
    output reg [4:0]  rd_out,
    output reg        regwrite_out, memwrite_out,
    output reg [1:0]  resultsrc_out,
    output reg        branch_out, jump_out, zero_out
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        pc_out        <= 0;
        aluresult_out <= 0;
        writedata_out <= 0;
        pcplus4_out   <= 0;
        rd_out        <= 0;
        regwrite_out  <= 0;
        memwrite_out  <= 0;
        resultsrc_out <= 0;
        branch_out    <= 0;
        jump_out      <= 0;
        zero_out      <= 0;
    end else begin
        pc_out        <= pc_in;
        aluresult_out <= aluresult_in;
        writedata_out <= writedata_in;
        pcplus4_out   <= pcplus4_in;
        rd_out        <= rd_in;
        regwrite_out  <= regwrite_in;
        memwrite_out  <= memwrite_in;
        resultsrc_out <= resultsrc_in;
        branch_out    <= branch_in;
        jump_out      <= jump_in;
        zero_out      <= zero_in;
    end
end

endmodule