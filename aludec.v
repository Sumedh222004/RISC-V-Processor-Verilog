module aludec(
    input      [1:0] aluop,
    input      [2:0] funct3,
    input            funct7b5,
    input            opb5,
    output reg [2:0] alucontrol
);

wire rtypesub;
assign rtypesub = funct7b5 & opb5;

always @(*) begin
    case(aluop)
        2'b00: alucontrol = 3'b000; // ADD (load/store)
        2'b01: alucontrol = 3'b001; // SUB (branch)
        2'b10: begin
            case(funct3)
                3'b000: alucontrol = rtypesub ? 3'b001 : 3'b000; // SUB or ADD
                3'b010: alucontrol = 3'b001; // SLT (use SUB)
                3'b100: alucontrol = 3'b100; // XOR
                3'b110: alucontrol = 3'b011; // OR
                3'b111: alucontrol = 3'b010; // AND
                3'b001: alucontrol = 3'b101; // SHL
                3'b101: alucontrol = 3'b110; // SHR
                default: alucontrol = 3'b000;
            endcase
        end
        default: alucontrol = 3'b000;
    endcase
end

endmodule