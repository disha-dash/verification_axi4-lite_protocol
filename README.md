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

## AXI4-Lite Handshake Signals

### Master Signals (Master → Slave)

- `AWVALID` – Indicates the write address on the AW channel is valid  
- `WVALID` – Indicates the write data on the W channel is valid  
- `BREADY` – Master is ready to accept the write response  
- `ARVALID` – Indicates the read address on the AR channel is valid  
- `RREADY` – Master is ready to accept the read data  

### Slave Signals (Slave → Master)

- `AWREADY` – Slave is ready to accept the write address  
- `WREADY` – Slave is ready to accept the write data  
- `BVALID` – Write response from the slave is valid  
- `ARREADY` – Slave is ready to accept the read address  
- `RVALID` – Read data from the slave is valid
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

```
axi_verification
│
├── tb_top.sv
│ ├── axi_if.sv
│ ├── axi_slave.sv
│ ├── axi_assertions.sv
│ └── axi_test.sv
│
├── axi_test.sv
│ ├── axi_env.sv
│ │ ├── axi_driver.sv
│ │ ├── axi_monitor.sv
│ │ ├── axi_scoreboard.sv
│ │ └── mailbox (monitor → scoreboard communication)
│ │
│ └── axi_sequencer.sv
│ └── axi_transaction.sv
```


---

# File Descriptions

**axi_if.sv**  
Defines the AXI4-Lite interface and modports connecting the testbench and DUT.

**axi_transaction.sv**  
Defines the transaction object containing address, data, and operation type.

**axi_sequencer.sv**  
Generates AXI read/write transactions and sends them to the driver.

**axi_driver.sv**  
Drives AXI interface signals based on transactions from the sequencer.

**axi_monitor.sv**  
Observes AXI bus activity and captures DUT responses.

**axi_scoreboard.sv**  
Compares expected and actual data to verify correctness.

**axi_env.sv**  
Connects and manages all verification components in the environment.

**axi_test.sv**  
Defines the test scenario and starts the verification process.

**axi_assertions.sv**  
Contains SystemVerilog assertions to check AXI protocol rules.

**axi_slave.sv**  
Implements the AXI4-Lite slave design under test (DUT).

**tb_top.sv**  
Top-level testbench that instantiates the DUT, interface, and verification environment.

---
