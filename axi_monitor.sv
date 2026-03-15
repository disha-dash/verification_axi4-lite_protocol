//==============================================================
// AXI Monitor - Observes Read Transactions
//==============================================================
class axi_monitor;
  virtual axi_if.TB vif;
  mailbox mon2sb;

  function new(virtual axi_if.TB vif, mailbox mon2sb);
    this.vif = vif;
    this.mon2sb = mon2sb;
  endfunction

  task run();
    forever begin
      @(posedge vif.aclk);
      if (vif.rvalid && vif.rready) begin
        mon2sb.put({vif.araddr, vif.rdata});
        $display("[%0t] MON: addr=0x%08h data=0x%08h",
                 $time, vif.araddr, vif.rdata);
      end
    end
  endtask
endclass
