# 🚀 MIPS-Based Pipelined SoC with AHB/APB Peripherals

This project implements a 32-bit pipelined MIPS processor with full MIPS-I instruction set support, integrated in a system-on-chip (SoC) environment. The design features a multi-stage pipeline, exception handling via CP0, and memory-mapped AHB/APB peripherals such as UART, GPIO, SPI, and timer.

## 🧠 Features

- ✅ **MIPS-I 32-bit Pipelined Processor**  
- ✅ **Multi-Stage Pipeline**: Fetch, Decode, Execute, Memory, Write-back  
- ✅ **CP0 Co-processor**: For exception and interrupt management  
- ✅ **Branch Prediction & Hazard Unit**: To improve pipeline efficiency  
- ✅ **AHB/APB Bridge**: Memory and peripheral interconnect  
- ✅ **Integrated Peripherals**:  
  - 16550-style UART  
  - GPIO (AHB and I/O variants)  
  - SPI controller  
  - Timer module  
- ✅ **Booth Multiplier and Divider**: For arithmetic acceleration  
- ✅ **AHB Decoder & Default Slave**: For robust bus arbitration  
- ✅ **Instruction/Data Memory with DDR BRAM**

## 📁 File Structure

```
.
├── CPU Core
│   ├── MIPS_PIPE.v           # Top-level pipelined processor module
│   ├── FETCH_DECODE.v
│   ├── DECODE_EXCUTE.v
│   ├── EXCUTE_MEMORY.v
│   ├── MEMORY_WB.v
│   ├── ALU.v
│   ├── Control_ALU.v
│   ├── Register_File.v
│   ├── Sign_Extend.v
│   ├── CP0.v
│   ├── Branch_Unit.v
│   ├── Branch_Prediction.v
│   ├── hazard_unit.v
│   ├── hi_lo_reg.v
│   ├── mux_4x1.v
│   ├── booth_multiplier.v
│   ├── division.v
│   └── MIPS_PIPE_tb.v        # Testbench
│
├── Memory
│   ├── Instruction_Memory.v
│   ├── Data_Memory.v
│   └── DDR_BRAM.v
│
├── Interconnect & Bus
│   ├── AHB_APB_BRIDGE.v
│   ├── AHB_Decoder.v
│   ├── Default_Slave.v
│
├── Peripherals
│   ├── UART.v
│   ├── SPI.v
│   ├── TIMER.v
│   ├── cmsdk_ahb_gpio.v
│   ├── cmsdk_iop_gpio.v
│   ├── cmsdk_apb_timer.v
│   └── cmsdk_ahb_to_iop.v
│
├── Misc
│   ├── do.txt
│   ├── sourcefile.txt
│   ├── filenames.txt
│   ├── test1.txt ~ test5.txt
│
└── CACHE/                   # Placeholder or implementation of cache logic
```

## 🛠️ How to Use

1. **Simulation**:  
   Use any Verilog simulation tool like ModelSim or Vivado. Run `MIPS_PIPE_tb.v` to verify processor functionality.

2. **Synthesis**:  
   The project is FPGA-ready and designed with synthesizability in mind. Use Vivado or Quartus with proper memory and peripheral mapping.

3. **Test Files**:  
   The `test*.txt` files may include test programs or memory initializations.

## 📦 Dependencies

- Verilog 2001+
- Simulation tools: ModelSim, Vivado Simulator
- Optional: Xilinx IPs for DDR or peripherals if targeting Xilinx FPGAs

## 📃 License

MIT License (or add your preferred license)
