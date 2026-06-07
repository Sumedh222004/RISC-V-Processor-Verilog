# 32-Bit 5-Stage Pipelined RISC-V Processor

A fully functional **32-bit pipelined RISC-V (RV32I) processor** implemented in Verilog HDL and synthesized on the Xilinx Artix-7 FPGA using Vivado 2019.2.

---

## Features

- **5-stage pipeline**: Instruction Fetch → Instruction Decode → Execute → Memory → Write Back
- **Full hazard handling**:
  - Data hazard forwarding (EX-EX and MEM-EX paths)
  - Load-use stall detection (1-cycle stall insertion)
  - Control hazard flushing (branch/jump pipeline flush)
- **12 RV32I instructions**: ADDI, ADD, SUB, OR, AND, XOR, SLL, SRL, LW, SW, BEQ, JAL
- **Hardware performance counter**: tracks cycle count, instruction count, and stall cycles
- **Self-checking testbench**: 7/7 test cases PASS
- **Synthesis-clean**: maps to Artix-7 with 8% LUT, 1% FF utilization

---

## Simulation Results

```
=========================================
   RISC-V SELF-CHECKING TEST RESULTS
=========================================
PASS |  x1=x2+x3=17     | got=17 expected=17
PASS |  x4=5-12=-7      | got=4294967289 expected=4294967289
PASS |  x11=mem[x2]=10  | got=10 expected=10
PASS |  x6=17or12=29    | got=29 expected=29
PASS |  x7=17and12=0    | got=0 expected=0
PASS |  x5=17xor12=29   | got=29 expected=29
PASS |  x13=1 (BEQ NT)  | got=1 expected=1
-----------------------------------------
PASSED: 7 / FAILED: 0
=========================================

=========================================
      RISC-V PERFORMANCE REPORT
=========================================
Total Cycles      : 80
Instructions Done : 19
Stall Cycles      : 0
=========================================
```

---

## Resource Utilization (Artix-7 xc7a35tcpg236-1)

| Resource | Used | Available | Utilization |
|----------|------|-----------|-------------|
| Slice LUTs | 1685 | 20800 | 8% |
| Slice Registers (FF) | 471 | 41600 | 1% |
| Block RAM Tile | 0.5 | 50 | 1% |
| BUFGCTRL | 1 | 32 | 3% |
| DSPs | 0 | 90 | 0% |

---

## File Structure

```
RISCV_PROCESSOR/
├── src/
│   ├── top.v               # Top-level integration
│   ├── datapath.v          # Complete datapath
│   ├── controller.v        # Control unit top
│   ├── maindec.v           # Main decoder
│   ├── aludec.v            # ALU decoder
│   ├── alu.v               # 32-bit ALU
│   ├── regfile.v           # 32x32 register file
│   ├── imem.v              # Instruction memory
│   ├── dmem.v              # Data memory
│   ├── extend.v            # Immediate sign extension
│   ├── if_id.v             # IF/ID pipeline register
│   ├── id_iex.v            # ID/EX pipeline register
│   ├── iex_imem.v          # EX/MEM pipeline register
│   ├── imem_iw.v           # MEM/WB pipeline register
│   ├── hazard_unit.v       # Hazard detection and resolution
│   └── perf_counter.v      # Hardware performance counter
├── sim/
│   └── tb_top.v            # Self-checking testbench
└── README.md
```

---

## Architecture

```
         IF          ID          EX          MEM         WB
    ┌─────────┐  ┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐
    │  imem   │→ │regfile │→ │  alu   │→ │  dmem  │→ │result  │
    │  PC+4   │  │extend  │  │forward │  │ rd/wr  │  │  mux   │
    └─────────┘  └────────┘  └────────┘  └────────┘  └────────┘
         ↕            ↕           ↕           ↕
      IF/ID        ID/EX       EX/MEM      MEM/WB
                                    ↑
                            Hazard Unit
                       (forward / stall / flush)
```

---

## How to Run

### Prerequisites
- Xilinx Vivado 2019.2 or later (free WebPACK edition)
- Windows or Linux

### Steps

1. Clone this repository
2. Open Vivado → Create Project → RTL Project
3. Target device: `xc7a35tcpg236-1` (Artix-7)
4. Add all `.v` files from `src/` as Design Sources
5. Add `tb_top.v` from `sim/` as Simulation Source
6. Click **Run Simulation → Run Behavioral Simulation**
7. View waveforms and check Tcl Console for PASS/FAIL results

### Expected Console Output
The testbench prints a performance report and 7 PASS statements at the end of simulation.

---

## Pipeline Hazard Handling

| Hazard Type | Detection | Resolution |
|-------------|-----------|------------|
| Data hazard (EX-EX) | rdM == rs1E or rs2E | Forward from MEM stage |
| Data hazard (MEM-WB) | rdW == rs1E or rs2E | Forward from WB stage |
| Load-use hazard | LW followed by dependent instr | 1-cycle stall + bubble |
| Control hazard (branch) | BranchM & ZeroM | Flush IF/ID and ID/EX |
| Control hazard (jump) | JumpM | Flush IF/ID and ID/EX |

---

## Supported Instructions (RV32I Subset)

| Format | Instructions |
|--------|-------------|
| R-type | ADD, SUB, OR, AND, XOR, SLL, SRL |
| I-type | ADDI, LW |
| S-type | SW |
| B-type | BEQ |
| J-type | JAL |

---

## Tools Used

- **HDL**: Verilog
- **Simulator**: Xilinx Vivado XSim (Behavioral Simulation)
- **Synthesis**: Xilinx Vivado 2019.2
- **Target FPGA**: Xilinx Artix-7 xc7a35tcpg236-1

---

## References

1. Harris, D. and Harris, S. — *Digital Design and Computer Architecture: RISC-V Edition*, Morgan Kaufmann, 2021
2. Waterman, A. and Asanovic, K. — *The RISC-V Instruction Set Manual, Volume I*, RISC-V Foundation, 2019
3. Patterson, D. and Hennessy, J. — *Computer Organization and Design RISC-V Edition*, Morgan Kaufmann, 2020
