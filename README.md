# CSEE 4840 Lab 1: Using the FPGA

Columbia University, Spring 2026.

This repository contains Lab 1 code for implementing and validating four SystemVerilog modules on the DE1-SoC board: `hex7seg`, `collatz`, `range`, and top-level `lab1`. The workflow uses Verilator for simulation, GTKWave for waveform inspection, and Quartus Prime 21.1 for FPGA compilation/programming.

## Repository Layout

All lab source files are in `lab1/`.

| Path                       | Purpose                                                         |
| -------------------------- | --------------------------------------------------------------- |
| `lab1/hex7seg.sv`          | Hex-to-seven-segment decoder (active-low outputs)               |
| `lab1/collatz.sv`          | Single-value Collatz sequence engine                            |
| `lab1/range.sv`            | Range-based Collatz count engine with RAM-backed results        |
| `lab1/lab1.sv`             | DE1-SoC top-level UI integration (switches, keys, HEX displays) |
| `lab1/hex7seg.cpp`         | Verilator testbench for `hex7seg`                               |
| `lab1/collatz.cpp`         | Verilator testbench for `collatz`                               |
| `lab1/range.cpp`           | Verilator testbench for `range`                                 |
| `lab1/collatz.gtkw`        | GTKWave save file for Collatz simulation                        |
| `lab1/range.gtkw`          | GTKWave save file for range simulation                          |
| `lab1/range-done.gtkw`     | GTKWave save file for range completion/readout view             |
| `lab1/Makefile`            | Main build, sim, lint, Quartus, and packaging targets           |
| `lab1/de1-soc-project.tcl` | Quartus project-generation script                               |

## Tooling and Prerequisites

- Verilator (for lint and C++ testbench simulation)
- GTKWave (for VCD waveform viewing)
- Quartus Prime Lite 21.1 (for DE1-SoC synthesis/programming)
- DE1-SoC board, power supply, and USB Blaster/JTAG connection

## Quickstart Commands

Run these from the repository root:

```bash
make -C lab1 lint
make -C lab1 hex7seg
make -C lab1 collatz.vcd
make -C lab1 range.vcd
gtkwave --save=lab1/collatz.gtkw lab1/collatz.vcd
gtkwave --save=lab1/range.gtkw lab1/range.vcd
```

## FPGA Build and Program Flow

```bash
make -C lab1 lab1.qpf
make -C lab1 output_files/lab1.sof
make -C lab1 program
```

Hardware checklist before `make program`:

- Set DE1-SoC mode switches to Active Serial mode.
- Connect board power and turn board on.
- Connect USB cable to the board USB Blaster port.
- Confirm JTAG visibility (`jtagconfig`) if programming fails.

## Current Verification Status (Repo Snapshot)

Observed from this repository snapshot on 2026-02-11:

- `collatz`: passing expected sequence behavior (e.g., start `7` produces `7 22 11 34 ... 2 1`).
- `hex7seg`: failing mapping for most inputs under provided testbench.
- `range`: failing strict Verilator flow (`make -C lab1 range.vcd`) due warning-as-error issues and incorrect count behavior.
- `lint`: currently failing (`make -C lab1 lint`).

## Known Issues and Next Fixes

1. Correct full hex-to-seven-segment truth table in `lab1/hex7seg.sv`.
2. Declare `cdout` with correct width and connect it correctly in `lab1/range.sv`.
3. Rework `range` count/write sequencing to align with `cdone` protocol requirements.
4. Resolve width/lint warnings in `lab1/lab1.sv` and `lab1/range.sv`.
5. Optional UI improvement: make top-level `go` edge-triggered instead of level-sensitive.

## Public Module Interfaces

No interface changes are planned. Current module interfaces:

```systemverilog
module hex7seg(
  input logic [3:0] a,
  output logic [6:0] y
);
```

```systemverilog
module collatz(
  input logic clk,
  input logic go,
  input logic [31:0] n,
  output logic [31:0] dout,
  output logic done
);
```

```systemverilog
module range #(
  parameter RAM_WORDS = 16,
  parameter RAM_ADDR_BITS = 4
)(
  input logic clk,
  input logic go,
  input logic [31:0] start,
  output logic done,
  output logic [15:0] count
);
```

```systemverilog
module lab1(
  input logic CLOCK_50,
  input logic [3:0] KEY,
  input logic [9:0] SW,
  output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5,
  output logic [9:0] LEDR
);
```

## Submission Checklist

1. Package deliverables:
   ```bash
   make -C lab1 lab1.tar.gz
   ```
2. Confirm `lint` and required simulations pass before submission.
3. Demonstrate board behavior to a TA (switch input, button interactions, HEX output, completion indication).
