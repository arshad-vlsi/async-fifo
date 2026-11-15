# ⚡ Asynchronous FIFO (Dual-Clock, CDC) using Verilog

![Verilog](https://img.shields.io/badge/Verilog%20HDL-8957e5?style=flat-square)
![SystemVerilog](https://img.shields.io/badge/SystemVerilog-8957e5?style=flat-square)
![Cadence Xcelium](https://img.shields.io/badge/Cadence%20Xcelium-e36209?style=flat-square)
![Cadence Genus](https://img.shields.io/badge/Cadence%20Genus-e36209?style=flat-square)
![SDC](https://img.shields.io/badge/SDC%20Constraints-0075ca?style=flat-square)
![STA](https://img.shields.io/badge/STA-0075ca?style=flat-square)
![CDC](https://img.shields.io/badge/CDC%20Design-0075ca?style=flat-square)
![Gray Code](https://img.shields.io/badge/Gray%20Code-e36209?style=flat-square)

---

## 📌 Project Overview

This project implements a fully functional **asynchronous FIFO** in Verilog HDL with parameterized **data width (DSIZE = 8)** and **address size (ASIZE = 4)**, giving a FIFO depth of **16 locations**. It safely transfers data between two independent clock domains using **Gray-coded pointer synchronization** to prevent metastability — based on the architecture described by Clifford Cummings ("Simulation and Synthesis Techniques for Asynchronous FIFO Design"), a standard reference technique used in modern SoC and VLSI design.

The design was carried from RTL through **functional verification, SDC constraint writing, and logic synthesis in Cadence Genus**, with results cross-checked against the simulation waveform at each stage.

---

## 🗂 Module Architecture

| Module | Description |
|--------|-------------|
| `FIFO.v` | Top-level module — instantiates all submodules |
| `FIFO_memory.v` | Flop-based memory array — synchronous write (gated by `wfull`), combinational read |
| `wptr_full.v` | Write pointer (binary + Gray) and `wfull` flag generation |
| `rptr_empty.v` | Read pointer (binary + Gray) and `rempty` flag generation |
| `sync_w2r.v` | Write→Read clock domain pointer synchronizer (2-flop) |
| `sync_r2w.v` | Read→Write clock domain pointer synchronizer (2-flop) |
| `async_fifo_tb.v` | Self-checking Verilog testbench (scoreboard-based) |
| `async_fifo_tb_layered.sv` | Class-based SystemVerilog testbench (transaction / generator / driver / monitor / scoreboard) |

> **Note:** an earlier revision of `sync_w2r.v` / `sync_r2w.v` had a port-width mismatch (`WIDTH` instantiated as `ASIZE+1` against ports sized `[WIDTH:0]`) and used `WIDTH` before declaring it in the module header. Both were fixed — ports now size correctly against the top-level pointer wires, and `WIDTH` is declared as an ANSI-style parameter.

---

## 🔌 Top-Level Port Description

| Port | Direction | Width | Description |
|------|-----------|-------|-------------|
| wclk | Input | 1-bit | Write clock domain |
| rclk | Input | 1-bit | Read clock domain |
| wrst_n | Input | 1-bit | Active-low write reset |
| rrst_n | Input | 1-bit | Active-low read reset |
| winc | Input | 1-bit | Write increment (enable) |
| rinc | Input | 1-bit | Read increment (enable) |
| wdata | Input | DSIZE | Write data input |
| rdata | Output | DSIZE | Read data output |
| wfull | Output | 1-bit | FIFO full flag |
| rempty | Output | 1-bit | FIFO empty flag |

---

## ✨ Features

- ✅ Parameterized: DSIZE = 8 bits, ASIZE = 4 → depth of 16 locations
- ✅ Dual independent clock domains (`wclk` & `rclk`), declared asynchronous to each other in the SDC
- ✅ Gray-coded pointers (with one extra MSB) to distinguish full from empty across domains
- ✅ 2-flop synchronizers for metastability prevention
- ✅ Active-low reset for both clock domains
- ✅ `wfull` & `rempty` status flags, each registered and generated in its own clock domain
- ✅ Verified with two testbenches: a self-checking plain-Verilog testbench and a layered, class-based SystemVerilog testbench
- ✅ Simulated in **Cadence Xcelium**, waveforms analyzed in **SimVision**
- ✅ Synthesized in **Cadence Genus (90nm, slow corner)** with asynchronous clock-group SDC constraints

---

## 🧪 Verification

Two testbenches are included, both exercising the same five scenarios — reset state, basic write/read-back, overflow (write past full), underflow (read past empty), and concurrent pseudo-random read/write across both clocks:

- **`async_fifo_tb.v`** — plain Verilog, self-checking against a software scoreboard, prints `PASS`/`FAIL` per check and a final test verdict.
- **`async_fifo_tb_layered.sv`** — the same coverage restructured into transaction, generator, driver, monitor and scoreboard classes connected through mailboxes, for a more industry-style verification environment.

---

## 🛠 Synthesis (Cadence Genus)

Synthesized at nominal clocks (100 MHz write / 50 MHz read) against a 90nm standard-cell library, with the two clocks declared as an asynchronous clock group in the SDC:

| Metric | Value |
|---|---|
| Cell count | 380 (168 sequential, 212 combinational) |
| Total area | 4371.10 µm² |
| Total power | 313.43 µW |
| Setup slack — write clock (100 MHz) | +7.15 ns |
| Setup slack — read clock (50 MHz) | +17.78 ns |

Tighter SDC constraint sets were also explored to find the practical maximum frequency for each clock domain; see `sdc/iterations/` for those constraint files. Note that resynthesizing at a tighter period lets Genus swap in faster (higher-power) cells, so area/power at those tighter corners is **not** directly comparable to the nominal-clock numbers above.

---

## 📁 File Structure

```
async-fifo/
├── rtl/
│   ├── FIFO.v              ← Top-level module
│   ├── FIFO_memory.v       ← Flop-based memory array
│   ├── wptr_full.v         ← Write pointer & full flag
│   ├── rptr_empty.v        ← Read pointer & empty flag
│   ├── sync_w2r.v          ← Write-to-Read synchronizer
│   └── sync_r2w.v          ← Read-to-Write synchronizer
├── tb/
│   ├── async_fifo_tb.v            ← Self-checking Verilog testbench
├── sdc/
│   ├── async_fifo.sdc       ← Nominal constraints (100 MHz write / 50 MHz read)
├── docs/
│   ├── synthesis/
│   │   ├── area.rpt
│   │   ├── power.rpt
│   │   ├── gates.rpt
│   │   └── timing.rpt
│   └── waveform.png    ← SimVision capture of a write/read sequence
├── LICENSE
├── .gitignore
└── README.md
```

---

## 📊 Simulation Waveform

![Waveform](docs/waveform_simvision.png)

Waveform shows `wclk`, `rclk`, `winc`, `rinc`, `wdata`, `wptr`, `wfull`, `rinc`, `rptr`, `rempty` and `rdata`, captured in Cadence SimVision across a write-then-read sequence (writes `0x10`–`0x17`, read back in order, `rempty` falling after the first write and rising after the last read).

---

## 🎓 Learning Outcome

- Mastered Clock Domain Crossing (CDC) in digital design, including the full/empty-distinguishing extra-MSB pointer technique
- Implemented Gray-coded pointers with 2-flop synchronizers to avoid metastability
- Debugged real RTL issues: a port-width mismatch and a parameter-declaration-order issue in the synchronizer modules, and a missing-module (unresolved reference) issue during synthesis
- Wrote and compared two testbench styles — directed/self-checking Verilog and a class-based SystemVerilog verification environment
- Wrote SDC constraints (including asynchronous clock groups) and synthesized the design in Cadence Genus
- Explored the practical maximum operating frequency through iterative SDC constraint tightening

---

## 👨‍💻 Author

**Arshad Ansari**
M.Tech ECE (VLSI Design) — NIT Hamirpur
[![LinkedIn](https://img.shields.io/badge/LinkedIn-arshadansari04-0077B5?style=flat-square&logo=linkedin)](https://www.linkedin.com/in/arshadansari04/)
