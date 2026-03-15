# verification_axi4-lite_protocol

This project verifies an AXI4-Lite slave interface using a SystemVerilog layered testbench
The testbench master drives read/write transactions and checks protocol compliance and data integrity

---

# What is AXI4-lite

 It is a simplified version of the AXI bus protocol used for low-bandwidth memory-mapped communication between processors and peripherals.
 It supports single read and write transactions using VALID-READY handshakes across five independent channels

---

# 5 Channels of AXI4-Lite

 ##Write Address Channel (AW)
 
  *Carries the address of the write operation
  
 ##Write Data Channel (W)
 
  *Carries the data to be written
  
 ##Write Response Channel (B)
 
  *Slave sends the status of the write transaction
  
 ##Read Address Channel (AR)
 
  *Carries the address of the read operation
  
 ##Read Data Channel (R)
 
  *Carries the data to be read
  

---

#VALID-READY Handshake

AXI uses a 2-signal handshake which commuhnicates safe communication without data loss.
Transaction occurs when both VALID and READY signals are 1.

 **Master**: AWVALID, WVALID, BVALID, ARVALID, RVALID
 
 **Slave**: AWREADY, WREADY, BREADY, ARREADY, RREADY

---

# Technologies Used

## Language 

*SystemVerilog*

### Tools/Simulators 

*Siemens Questa 2025.2

### Simulation Platform

*EDA PLayground - used to run the verification environment with the Questa simulator

Playground link: https://www.edaplayground.com/x/H8Yf

---

# Project Architecture

```
axi_verification
│
├── axi_if.sv
│
├── axi_transaction.sv
│
├── axi_sequencer.sv
│
├── axi_driver.sv
│
├── axi_monitor.sv
│
├── axi_scoreboard.sv
│
├── axi_env.sv
│
├── axi_test.sv
│
├── axi_assertions.sv
│
├── axi_slave.sv
│
└── tb_top.sv
```

### Files Description

**axi_if.sv**

* Contains all HTML pages used in the application.

**axi_transaction.sv**

* Defines the AXI4-Lite interface and modports connecting the testbench and DUT.

**axi_sequencer.sv**

* Defines the transaction object containing address, data, and operation type.
  
**axi_driver.sv**

* Generates AXI read/write transactions and sends them to the driver.

**axi_monitor.sv**

* Observes AXI bus activity and captures DUT responses.

**axi_scoreboard.sv**

* Compares expected and actual data to verify correctness.

**axi_env.sv**

* Connects and manages all verification components in the environment.

**axi_test.sv**

* Defines the test scenario and starts the verification process.

**axi_assertions.sv**

* Defines the test scenario and starts the verification process.

**axi_slave.sv**

* Contains SystemVerilog assertions to check AXI protocol rules.
  
**tb_top.sv**

* Top-level testbench that instantiates the DUT, interface, and test environment.
* 
---
