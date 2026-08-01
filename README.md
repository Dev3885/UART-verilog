# Bi-Directional UART — Verilog

A from-scratch UART transmitter/receiver pair written in Verilog, simulated in a full-duplex loopback: two independent device instances exchange 8-bit frames with a start bit, parity bit, and stop bit, verified by a self-checking testbench.

## Features

- Full-duplex simulated communication between two UART devices over a shared serial line
- Configurable baud rate and clock frequency via module parameters (default: 9600 baud @ 50 MHz)
- 16x oversampling receiver with mid-bit sampling for reliable bit recovery
- Parity generation and checking, with a flag raised on mismatch
- Self-checking testbench that compares transmitted vs. received bytes in both directions and prints a pass/fail report

## Repository Structure

```
.
├── device_1.v     # Transmitter + receiver primitives for Device 1
├── device_2.v     # Transmitter + receiver primitives for Device 2
├── FSM1.v         # Top-level wrappers (fsm1, fsm2) wiring TX/RX blocks per device
├── testbench.v    # Bi-directional self-checking testbench
└── README.md
```

## Frame Format

11-bit frame, transmitted LSB-first:

```
[ start (0) | data[0:7] | parity | stop (1) ]
```

- Bit period = `clk_frequency / baud_rate` clock cycles
- The receiver detects the falling edge of the start bit, then uses 16x oversampling to sample each subsequent bit at its mid-point
- Parity is the XOR of the 8 data bits; a mismatch on receive sets `FLAG_state` / `FLAG_state1` and the received byte is discarded

## Module Map

| Module | Role |
|---|---|
| `counter` / `counter2` | Baud-rate tick generator for the transmitter |
| `register` / `register2` | Holds the byte to send, loaded on `RegEnable` |
| `shiftregisterPISO` / `shiftregisterPISO2` | Parallel-in/serial-out — frames and serializes the byte |
| `Rcounter` / `Rcounter2` | 16x oversampling clock + mid-bit sample-position counter |
| `shiftregisterSIPO` / `shiftregisterSIPO2` | Serial-in/parallel-out — start-bit detection, parity check, frame reconstruction |
| `Rregister` / `Rregister2` | Output holding register (`DISPLAY` / `DISPLAY1`) |
| `fsm1` / `fsm2` (in `FSM1.v`) | Top-level glue tying each device's TX and RX blocks together |

## Running the Simulation

Developed and tested in Vivado (XSIM), but any simulator supporting standard `always`/parameter syntax, `$display`, `$monitor`, and `$dumpfile`/`$dumpvars` should work.

1. Create a Vivado simulation project and add `device_1.v`, `device_2.v`, `FSM1.v`, and `testbench.v` as simulation sources.
2. Set `testbench` as the simulation top module.
3. Run behavioral simulation:
   ```
   run 5ms
   ```
4. The console prints a table of Sent / Expected / Received / Parity Flag / Status per frame, plus a final error count.

## Sample Output

```
===============================================================================================
                                 UART BI-DIRECTIONAL TESTBENCH
===============================================================================================
      Time (ns)         Direction          Sent (TX)      Expected      Received (RX)   Parity Flag         Status
-----------------------------------------------------------------------------------------------
          1150080000    Dev 1 -> Dev 2    8'b10101000    8'b1          8'b10101000         0        [   PASSED   ]
          2300100000    Dev 1 -> Dev 2    8'b11111001    8'b1          8'b11111001         0        [   PASSED   ]
          3450120000    Dev 2 -> Dev 1    8'b10101000    8'b1          8'b10101000         0        [   PASSED   ]
          4600140000    Dev 2 -> Dev 1    8'b11111001    8'b1          8'b11111001         0        [   PASSED   ]
===============================================================================================
[STATUS] Simulation completed with 0 errors. All UART frames matched!
===============================================================================================
```

## RTL Schematic

Generated in Vivado via RTL Analysis → Open Elaborated Design → Schematic.
![RTL Schematic](docs/img/schematicRTL.pdf)

## Waveform

Each run generates UART.vcd, viewable in Vivado's waveform viewer, GTKWave, or any VCD-compatible tool. in here Vivado is used.
![Simulation Waveform](docs/img/waveform.Vivado.png)

## Known Limitations / Next Steps

- Baud generator uses integer division (`clk_frequency / baud_rate`), so baud rates that don't divide the clock evenly will accumulate small timing error over a long transmission.
- Simulation-only so far — next step is synthesis and an on-FPGA loopback test against a physical UART bridge.
- Frame format is fixed at 8 data bits / 1 parity bit / 1 stop bit; not yet parameterized for other configurations.


## Author

Debmalya Das/Dev3885
