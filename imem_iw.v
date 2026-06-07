module imem_iw(
    input         clk, reset,
    input  [31:0] aluresult_in, readdata_in, pcplus4_in,
    input  [4:0]  rd_in,
    input         regwrite_in,
    input  [1:0]  resultsrc_in,
    output reg [31:0] aluresult_out, readdata_out, pcplus4_out,
    output reg [4:0]  rd_out,
    output reg        regwrite_out,
    output reg [1:0]  resultsrc_out
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        aluresult_out <= 0;
        readdata_out  <= 0;
        pcplus4_out   <= 0;
        rd_out        <= 0;
        regwrite_out  <= 0;
        resultsrc_out <= 0;
    end else begin
        aluresult_out <= aluresult_in;
        readdata_out  <= readdata_in;
        pcplus4_out   <= pcplus4_in;
        rd_out        <= rd_in;
        regwrite_out  <= regwrite_in;
        resultsrc_out <= resultsrc_in;
    end
end

endmodule