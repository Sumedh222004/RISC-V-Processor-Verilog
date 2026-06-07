module perf_counter(
    input         clk, reset,
    input         instr_valid,
    input         stall,
    output reg [31:0] cycle_count,
    output reg [31:0] instr_count,
    output reg [31:0] stall_count,
    output reg [31:0] cpi_x100
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        cycle_count <= 32'b0;
        instr_count <= 32'b0;
        stall_count <= 32'b0;
        cpi_x100    <= 32'b0;
    end else begin
        // count every cycle
        cycle_count <= cycle_count + 1;

        // count valid instructions that are not stalled
        if (instr_valid && !stall)
            instr_count <= instr_count + 1;

        // count stall cycles
        if (stall)
            stall_count <= stall_count + 1;

        // CPI x100 to avoid decimals
        // CPI = cycle_count / instr_count
        if (instr_count > 0)
            cpi_x100 <= (cycle_count * 100) / instr_count;
    end
end

endmodule