`timescale 1ns/1ps

//============================================================
//  AXI Layered Verification Testbench Top
//============================================================
module tb_top;
  localparam CLK_PERIOD = 10;
  bit clk  = 0;
  bit rstn = 0;

  // -------------------------------
  // Clock generation
  // -------------------------------
  always #(CLK_PERIOD/2) clk = ~clk;

  // -------------------------------
  // Instantiate AXI interface
  // -------------------------------
  axi_if axi_if_i();

  // Connect clock and reset
  assign axi_if_i.aclk = clk;
  assign axi_if_i.aresetn = rstn;

  // -------------------------------
  // DUT instantiation
  // -------------------------------
  axi_slave dut (
    .aclk     (axi_if_i.aclk),
    .aresetn  (axi_if_i.aresetn),

    .s_awvalid(axi_if_i.awvalid),
    .s_awready(axi_if_i.awready),
    .s_awaddr (axi_if_i.awaddr),

    .s_wvalid (axi_if_i.wvalid),
    .s_wready (axi_if_i.wready),
    .s_wdata  (axi_if_i.wdata),
    .s_wstrb  (axi_if_i.wstrb),

    .s_bvalid (axi_if_i.bvalid),
    .s_bready (axi_if_i.bready),
    .s_bresp  (axi_if_i.bresp),

    .s_arvalid(axi_if_i.arvalid),
    .s_arready(axi_if_i.arready),
    .s_araddr (axi_if_i.araddr),

    .s_rvalid (axi_if_i.rvalid),
    .s_rready (axi_if_i.rready),
    .s_rdata  (axi_if_i.rdata),
    .s_rresp  (axi_if_i.rresp)
  );


  // -------------------------------
  // Reset sequence
  // -------------------------------
  initial begin
    rstn = 0;
    repeat (3) @(posedge clk);
    rstn = 1;
    $display("[%0t] Reset deasserted", $time);
  end
  
  // -------------------------------
  // Declare test handle
  // -------------------------------
  axi_test test; 

  // -------------------------------
  // Create and run layered test
  // -------------------------------
  initial begin
    @(posedge rstn);
    $display("[%0t] Creating AXI test environment", $time);

    test = new(axi_if_i);      // Pass virtual interface
    test.build();
    test.run();

    #2000;
    $display("[%0t] Simulation completed", $time);
    $finish;
  end


  // -------------------------------
  // Optional waveform dump
  // -------------------------------
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_top);
  end

endmodule
