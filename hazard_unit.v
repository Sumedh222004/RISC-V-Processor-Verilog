module hazard_unit(
    input      [4:0] rs1d, rs2d,
    input      [4:0] rs1e, rs2e,
    input      [4:0] rde, rdm, rdw,
    input            regwritem, regwritew,
    input      [1:0] resultsrcm,
    input            pcsrce,
    output reg [1:0] forwardae, forwardbe,
    output           stalld, stalle,
    output           flushd, flushe
);

// ---- Forwarding logic ----
always @(*) begin
    // Forward A
    if (regwritem && rdm != 0 && rdm == rs1e)
        forwardae = 2'b10;
    else if (regwritew && rdw != 0 && rdw == rs1e)
        forwardae = 2'b01;
    else
        forwardae = 2'b00;

    // Forward B
    if (regwritem && rdm != 0 && rdm == rs2e)
        forwardbe = 2'b10;
    else if (regwritew && rdw != 0 && rdw == rs2e)
        forwardbe = 2'b01;
    else
        forwardbe = 2'b00;
end

// ---- Load-use hazard stall ----
// resultsrcm == 2'b01 means the MEM stage is a load (rd comes from memory)
// Stall if the load destination matches either source register in Decode
wire lwstall;
assign lwstall = (resultsrcm == 2'b01) &&
                 ((rde == rs1d) || (rde == rs2d));

assign stalld  = lwstall;
assign stalle  = lwstall;

// ---- Flush on branch/jump taken or load-use stall ----
// FIX: use case-equality (===) so an X on pcsrce never causes a spurious flush
assign flushd  = (pcsrce === 1'b1) ? 1'b1 : 1'b0;
assign flushe  = lwstall | ((pcsrce === 1'b1) ? 1'b1 : 1'b0);

endmodule