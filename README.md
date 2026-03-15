# Verification of AXI4-Lite Protocol

This project verifies an **AXI4-Lite slave interface** using a **SystemVerilog layered testbench**.  
The testbench master drives read and write transactions and checks **protocol compliance and data integrity** through monitoring and scoreboard verification.

---

# What is AXI4-Lite

AXI4-Lite is a simplified version of the AXI bus protocol used for **low-bandwidth memory-mapped communication** between processors and peripherals.  

It supports **single read and write transactions** using a **VALID–READY handshake mechanism** across five independent channels.

---

# Five Channels of AXI4-Lite

## Write Address Channel (AW)
Carries the **address of the write operation**.

## Write Data Channel (W)
Carries the **data to be written**.

## Write Response Channel (B)
The slave sends the **status of the write transaction**.

## Read Address Channel (AR)
Carries the **address of the read operation**.

## Read Data Channel (R)
Carries the **data returned from the slave**.

---

# VALID–READY Handshake

AXI uses a **two-signal handshake mechanism** that ensures safe data transfer without data loss.

A transaction occurs when **both VALID and READY signals are high (1).**

**Master signals**
- `AWVALID`
- `WVALID`
- `BREADY`
- `ARVALID`
- `RREADY`

**Slave signals**
- `AWREADY`
- `WREADY`
- `BVALID`
- `ARREADY`
- `RVALID`

---

# Technologies Used

## Language
- SystemVerilog

## Tools / Simulators
- Siemens QuestaSim 2025.2

## Simulation Platform
- **EDA Playground** – used to run the verification environment with the Questa simulator

Playground link:  
https://www.edaplayground.com/x/H8Yf

---

# Project Architecture
