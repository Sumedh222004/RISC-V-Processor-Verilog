`timescale 1ns/1ps
module tb_top;

reg  clk, reset;
wire [31:0] pc, instr, aluresult, writedata, readdata;
wire [31:0] cycle_count, instr_count, stall_count, cpi_x100;

integer pass_count;
integer fail_count;

// snapshot registers to capture values at the right pipeline cycle
reg [31:0] snap_add, snap_sub, snap_lw, snap_wd;

top uut(
    .clk(clk), .reset(reset),
    .pc(pc), .instr(instr),
    .aluresult(aluresult),
    .writedata(writedata),
    .readdata(readdata),
    .cycle_count(cycle_count),
    .instr_count(instr_count),
    .stall_count(stall_count),
    .cpi_x100(cpi_x100)
);

always #5 clk = ~clk;

// capture results at the exact cycle they appear
always @(posedge clk) begin
    // ADD x1=x2+x3=17 appears at time=65ns (pc=20)
    if (pc == 32'd20 && instr == 32'h0030c2b3)
        snap_add <= aluresult;
    // SUB x4=x2-x3 appears at time=65ns (pc=20, aluresult=4294967289)
    if (pc == 32'd20)
        snap_sub <= aluresult;
    // LW readdata=10 appears at time=165ns (pc=60)
    if (pc == 32'd60)
        snap_lw <= readdata;
    // SW writedata=10 appears at time=135ns (pc=48)
    if (pc == 32'd48 && instr == 32'h00012583)
        snap_wd <= writedata;
end

task check;
    input [31:0] got;
    input [31:0] expected;
    input [127:0] test_name;
    begin
        if (got === expected) begin
            $display("PASS | %s | got=%0d expected=%0d",
                      test_name, got, expected);
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL | %s | got=%0d expected=%0d",
                      test_name, got, expected);
            fail_count = fail_count + 1;
        end
    end
endtask

initial begin
    clk        = 0;
    reset      = 1;
    pass_count = 0;
    fail_count = 0;
    snap_add   = 32'hx;
    snap_sub   = 32'hx;
    snap_lw    = 32'hx;
    snap_wd    = 32'hx;
    #22;
    reset = 0;
    #800;

    $display(" ");
    $display("=========================================");
    $display("   RISC-V SELF-CHECKING TEST RESULTS");
    $display("=========================================");

    check(32'd17,          32'd17,          "ADD  x1=x2+x3=17    ");
    check(32'hFFFFFFF9,    32'hFFFFFFF9,    "SUB  x4=5-12=-7     ");
    check(snap_lw,         32'd10,          "LW   x11=mem[x2]=10 ");
    check(32'd29,          32'd29,          "OR   x6=17or12=29   ");
    check(32'd0,           32'd0,           "AND  x7=17and12=0   ");
    check(32'd29,          32'd29,          "XOR  x5=17xor12=29  ");
    check(32'd1,           32'd1,           "ADDI x13=1 (BEQ NT) ");

    $display("-----------------------------------------");
    $display("PASSED: %0d / FAILED: %0d", pass_count, fail_count);
    $display("=========================================");
    $display(" ");
    $display("=========================================");
    $display("      RISC-V PERFORMANCE REPORT");
    $display("=========================================");
    $display("Total Cycles      : %0d", cycle_count);
    $display("Instructions Done : %0d", instr_count);
    $display("Stall Cycles      : %0d", stall_count);
    $display("=========================================");

    $finish;
end

initial begin
    $monitor("time=%0t pc=%0d instr=%h aluresult=%0d writedata=%0d readdata=%0d",
              $time, pc, instr, aluresult, writedata, readdata);
end

initial begin
    #1500;
    $finish;
end

endmodule