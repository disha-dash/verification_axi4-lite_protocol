// Base infrastructure first
`include "axi_if.sv"
`include "axi_slave.sv"

// Transaction and verification components
`include "axi_transaction.sv"
`include "axi_sequencer.sv"
`include "axi_driver.sv"
`include "axi_monitor.sv"
`include "axi_scoreboard.sv"

// Higher-level components
`include "axi_env.sv"
`include "axi_test.sv"

// Assertions and testbench top last
`include "axi_assertions.sv"
`include "tb_top.sv"
