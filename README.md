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
https://www.edaplayground.com/x/WBmi

---

# Project Architecture

```
axi_verification
│
├── design.sv
├── testbench.sv
│
├── tb_top.sv
├── axi_if.sv
├── axi_slave.sv
├── axi_assertions.sv
│
├── axi_test.sv
│ ├── axi_env.sv
│ │ ├── axi_driver.sv
│ │ ├── axi_monitor.sv
│ │ ├── axi_coverage.sv
│ │ ├── axi_scoreboard.sv
│ │ └── mailbox (monitor → scoreboard communication)
│ │
│ ├── axi_sequencer.sv
│ └── axi_transaction.sv
│
└── tb_axi_slave.sv

```


---

# Verification Features

The verification environment is implemented using a layered SystemVerilog architecture and includes:

* Transaction-based stimulus generation
* Driver, Monitor and Scoreboard architecture
* Mailbox-based component communication
* SystemVerilog Assertions (SVA)
* Functional Coverage collection
* Cross Coverage analysis
* Directed testing
* Read-after-write data integrity verification
* Byte-enable (WSTRB) verification
* Reset scenario verification
---

# Key Achievements

* Developed a layered SystemVerilog verification environment from scratch
* Implemented Driver, Monitor, Scoreboard, Assertions, and Functional Coverage components
* Verified AXI4-Lite read and write transactions across multiple address regions
* Achieved 94.6% functional coverage with 100% coverage across all AXI4-Lite transaction channels
  and cross-coverage goals
* Implemented protocol checking using SystemVerilog Assertions (SVA)
* Verified byte-enable (WSTRB) functionality and partial-write behavior
* Automated data integrity checking using a scoreboard-based architecture

---

# SystemVerilog Assertions (SVA)

SystemVerilog Assertions were implemented to automatically detect AXI4-Lite protocol violations during simulation.

The assertions verify:

* VALID signal stability until handshake completion
* AW channel handshake correctness
* W channel handshake correctness
* AR channel handshake correctness
* Read response validity
* Write response validity
* Protocol sequencing requirements
* Reset behaviour and signal consistency

Assertions provide immediate detection of protocol violations and improve verification quality beyond traditional scoreboard-based checking.

---

# Functional Coverage

Functional coverage was implemented to measure verification completeness across AXI4-Lite transactions and protocol handshakes.

Coverage points include:

* Write Address Channel (AW)
* Write Data Channel (W)
* Write Response Channel (B)
* Read Address Channel (AR)
* Read Data Channel (R)
* Cross coverage between address and data channels
* Reset behaviour

## Coverage Results

| Coverage Item                 | Coverage  |
| ----------------------------- | --------- |
| AW Channel                    | 100.0%    |
| W Channel                     | 100.0%    |
| B Channel                     | 100.0%    |
| AR Channel                    | 100.0%    |
| R Channel                     | 100.0%    |
| AW × W Cross Coverage         | 100.0%    |
| Reset Coverage                | 62.5%     |
| **Total Functional Coverage** | **94.6%** |

The verification environment achieved complete coverage of all AXI4-Lite protocol channels and cross-coverage goals. The generated stimulus exercised full-word writes, partial-byte writes, address alignment scenarios, multiple address regions, protocol handshakes, read-after-write operations, response handling, and reset behavior.

The achieved 94.6% functional coverage demonstrates thorough verification of the AXI4-Lite slave interface and confirms that all planned protocol scenarios were successfully exercised during simulation.

---

# Verification Flow

```text
Transaction
     │
     ▼
 Sequencer
     │
     ▼
  Driver
     │
     ▼
 AXI DUT
     │
 ┌───┴──────────────┐
 ▼                  ▼
Monitor        Assertions
 │
 ▼
Scoreboard
 │
 ▼
Coverage Collection
```

The monitor captures DUT activity and forwards transactions to the scoreboard for checking. Assertions continuously verify protocol correctness, while functional coverage measures verification completeness.



# File Descriptions

**axi_if.sv**  
Defines the AXI4-Lite interface and modports connecting the testbench and DUT.

**axi_transaction.sv**  
Defines the transaction object containing address, data, and operation type.

**axi_sequencer.sv**  
Generates AXI read/write transactions and sends them to the driver.

**axi_driver.sv**  
Drives AXI interface signals based on transactions from the sequencer.

**axi_coverage.sv** 
Contains SystemVerilog functional coverage models that track AXI4-Lite channel activity, protocol handshakes, cross coverage, and reset scenarios.

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

**tb_axi_slave.sv**  
A basic standalone testbench that verifies the AXI4-Lite slave by manually driving read and write signals on the AXI interface.

**tb_top.sv**  
Top-level testbench that instantiates the DUT, interface, and verification environment.

**testbench.sv**  
Initial testbench structure with includes.

---
