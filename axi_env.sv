//============================================================
//  AXI Environment
//============================================================
class axi_env;
  axi_driver drv;
  axi_monitor mon;
  axi_scoreboard sb;
  axi_sequencer seq;
  virtual axi_if axi_vif;

  // Mailbox between monitor and scoreboard
  mailbox mon2sb;

  // Constructor
  function new(virtual axi_if axi_vif);
    this.axi_vif = axi_vif;
  endfunction

  // Build phase
  function void build();
    mon2sb = new();               // create mailbox
    drv = new(axi_vif);
    mon = new(axi_vif, mon2sb);   // monitor takes interface and mailbox
    sb  = new(mon2sb);            // scoreboard takes mailbox
    seq = new();
    
    // Pre-populate scoreboard with expected values
    sb.write_expected(4, 32'h12345678);  // addr 0x10 -> index 4
    sb.write_expected(5, 32'h12345679);  // addr 0x14 -> index 5
    sb.write_expected(6, 32'h1234567a);  // addr 0x18 -> index 6
    sb.write_expected(7, 32'h1234567b);  // addr 0x1C -> index 7
    
    $display("[%0t] ENV: Build phase complete", $time);
  endfunction

  // Run phase
  task run();
    $display("[%0t] ENV: Starting all components", $time);
    
    // Start sequencer first to populate mailbox
    seq.start();
    
    // Then start other components
    fork
      begin
        drv.run(seq);               // driver drives from sequencer
      end
      begin
        mon.run();                  // monitor observes transactions
      end
      begin
        sb.run();                   // scoreboard checks data
      end
    join_none
    
    // Wait for completion
    #2000;
    $display("[%0t] ENV: Test time expired", $time);
  endtask
endclass
