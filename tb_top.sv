`timescale 1ns/1ps
module tb_top;
  localparam CLK_PERIOD = 10;
  bit clk  = 0;
  bit rstn = 0;

 
  always #(CLK_PERIOD/2) clk = ~clk;

  axi_if axi_if_i();
  assign axi_if_i.aclk    = clk;
  assign axi_if_i.aresetn = rstn;

  axi_slave dut (
    .aclk     (axi_if_i.aclk),    .aresetn  (axi_if_i.aresetn),
    .s_awvalid(axi_if_i.awvalid), .s_awready(axi_if_i.awready),
    .s_awaddr (axi_if_i.awaddr),
    .s_wvalid (axi_if_i.wvalid),  .s_wready (axi_if_i.wready),
    .s_wdata  (axi_if_i.wdata),   .s_wstrb  (axi_if_i.wstrb),
    .s_bvalid (axi_if_i.bvalid),  .s_bready (axi_if_i.bready),
    .s_bresp  (axi_if_i.bresp),
    .s_arvalid(axi_if_i.arvalid), .s_arready(axi_if_i.arready),
    .s_araddr (axi_if_i.araddr),
    .s_rvalid (axi_if_i.rvalid),  .s_rready (axi_if_i.rready),
    .s_rdata  (axi_if_i.rdata),   .s_rresp  (axi_if_i.rresp)
  );

  axi_assertions u_assertions (.axi(axi_if_i));

  // ── Early coverage sampler ────────────────────────────────
  // tb_cov is built at time 0 in the FIRST initial block.
  // Multiple initial blocks in SV all start at time 0 but
  // their ordering is simulator-dependent, so we use a SINGLE
  // initial block that builds tb_cov, THEN starts the reset
  // sequence, ensuring samples are taken during reset.
  axi_coverage tb_cov;
  axi_test     test;

  initial begin
    // Step 1: drive all master-side signals to known 0 at time 0.
    // This ensures {awvalid,wvalid,arvalid}=3'b000 during reset so the
    // cp_valids_in_reset coverage bin is hit cleanly (not blocked by X).
    axi_if_i.awvalid = 0; axi_if_i.awaddr  = 0;
    axi_if_i.wvalid  = 0; axi_if_i.wdata   = 0; axi_if_i.wstrb  = 0;
    axi_if_i.bready  = 0;
    axi_if_i.arvalid = 0; axi_if_i.araddr  = 0;
    axi_if_i.rready  = 0;

    // Step 2: build coverage at time 0 before any clock edge
    tb_cov = new(axi_if_i);
    tb_cov.build();

    // Step 3: hold reset for 8 cycles (plenty of in_reset samples)
    rstn = 0;
    repeat (8) @(posedge clk);
    rstn = 1;
    $display("[%0t] Reset deasserted", $time);

    // Step 3: build and run test
    $display("[%0t] Creating AXI test environment", $time);
    test = new(axi_if_i);
    test.build();
    test.run();

    #2000;
    $display("[%0t] Simulation completed", $time);
    $display("=== TB-level coverage (includes reset window) ===");
    tb_cov.report();
    $finish;
  end

  always @(posedge clk) begin
    if (tb_cov != null) tb_cov.sample();
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_top);  
  end
endmodule
