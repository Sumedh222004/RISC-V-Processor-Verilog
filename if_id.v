module if_id(
    input         clk, reset, enable,
    input  [31:0] pc_in, instr_in,
    output reg [31:0] pc_out, instr_out
);

always @(posedge clk) begin
    if (reset) begin
        pc_out    <= 32'b0;
        instr_out <= 32'b0;
    end else if (enable) begin
        pc_out    <= pc_in;
        instr_out <= instr_in;
    end
end

endmodule