//============================================================
//  AXI Environment
//============================================================
class axi_env;
  axi_driver     drv;
  axi_monitor    mon;
  axi_scoreboard sb;
  axi_sequencer  seq;
  axi_coverage   cov;
  virtual axi_if axi_vif;

  mailbox mon2sb;

  function new(virtual axi_if axi_vif);
    this.axi_vif = axi_vif;
  endfunction

  function void build();
    mon2sb = new();
    drv    = new(axi_vif);
    mon    = new(axi_vif, mon2sb);
    sb     = new(mon2sb);
    seq    = new();
    cov    = new(axi_vif);
    cov.build();
    mon.cov = cov;

    // Group A: mid-region (index = addr>>2)
    sb.write_expected(4,  32'h12345678);
    sb.write_expected(5,  32'h12345679);
    sb.write_expected(6,  32'h1234567a);
    sb.write_expected(7,  32'h1234567b);
    // Group B: low-region
    sb.write_expected(0,  32'hDEAD0000);
    sb.write_expected(1,  32'hDEAD0001);
    sb.write_expected(2,  32'hDEAD0002);
    sb.write_expected(3,  32'hDEAD0003);
    // Group C: high-region (0x20 >> 2 = 8, mod 16 = 8)
    sb.write_expected(8,  32'hCAFEF00D);
    // Group D: edge-case data (addr 0x08->idx2, 0x0C->idx3, overwrite B)
    sb.write_expected(2,  32'h00000000);  // all-zeros overwrites idx2
    sb.write_expected(3,  32'hFFFFFFFF);  // all-ones  overwrites idx3
    // Group E: partial strobes at 0x24(idx9), 0x28(idx10)
    // strb=4'hC writes only bytes[3:2], strb=4'h3 writes only bytes[1:0]
    sb.write_expected(9,  32'hAABB0000);  // upper 2 bytes only (strb=4'hC)
    sb.write_expected(10, 32'h00003344);  // lower 2 bytes only (strb=4'h3)

    $display("[%0t] ENV: Build phase complete", $time);
  endfunction

  task run();
    $display("[%0t] ENV: Starting all components", $time);
    seq.start();

    fork
      drv.run(seq);
      mon.run();
      sb.run();
    join_none


    #4000;
    $display("[%0t] ENV: Test time expired", $time);
    cov.report();
  endtask
endclass
