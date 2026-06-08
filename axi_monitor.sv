//==============================================================
// AXI Monitor - Observes Read Transactions + drives coverage
//==============================================================
class axi_monitor;
  virtual axi_if.TB vif;
  mailbox mon2sb;
  axi_coverage cov;  // handle set by env after build()

  function new(virtual axi_if.TB vif, mailbox mon2sb);
    this.vif   = vif;
    this.mon2sb = mon2sb;
  endfunction

  task run();
    forever begin
      @(posedge vif.aclk);

      // Sample coverage every clock edge
      if (cov != null) cov.sample();

      // Capture completed read beats for scoreboard
      if (vif.rvalid && vif.rready) begin
        mon2sb.put({vif.araddr, vif.rdata});
        $display("[%0t] MON: addr=0x%08h data=0x%08h",
                 $time, vif.araddr, vif.rdata);
      end
    end
  endtask
endclass
