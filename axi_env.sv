//============================================================
//  AXI Environment
//  Run time: 20 transactions x ~120ns + margin = 8000ns
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

  task build();
    mon2sb = new();
    drv = new(axi_vif); mon = new(axi_vif, mon2sb);
    sb  = new(mon2sb);  seq = new();
    cov = new(axi_vif); cov.build();
    mon.cov = cov;

    sb.write_expected( 0, 32'hAAAD0000);  // 0x00: DEAD0000 -> byte3=AA
    sb.write_expected( 1, 32'hDEBB0001);  // 0x04: DEAD0001 -> byte2=BB
    sb.write_expected( 2, 32'h00000000);  // 0x08: overwritten to all-zeros
    sb.write_expected( 3, 32'hFFFFFFFF);  // 0x0C: overwritten to all-ones
    sb.write_expected( 4, 32'hAABB5678);  // 0x10: 12345678 -> bytes[3:2]=AABB
    sb.write_expected( 5, 32'h12343344);  // 0x14: 12345679 -> bytes[1:0]=3344
    sb.write_expected( 6, 32'h1234CC7A);  // 0x18: 1234567A -> byte1=CC
    sb.write_expected( 7, 32'h123456DD);  // 0x1C: 1234567B -> byte0=DD
    sb.write_expected( 8, 32'hAABBF00D);  // 0x20: CAFEF00D -> bytes[3:2]=AABB
    sb.write_expected( 9, 32'hAABB3344);  // 0x24: AABB0000 -> bytes[1:0]=3344

    $display("[%0t] ENV: Build phase complete", $time);
  endtask

  task run();
    $display("[%0t] ENV: Starting all components", $time);
    seq.start();
    fork
      drv.run(seq);
      mon.run();
      sb.run();
    join_none
    // 20 transactions x ~120ns = ~2400ns active + generous margin
    #8000;
    $display("[%0t] ENV: Test time expired", $time);
    cov.report();
  endtask
endclass
