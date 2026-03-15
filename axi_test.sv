class axi_test;
  axi_env env;
  virtual axi_if axi_vif;

  function new(virtual axi_if axi_vif);
    this.axi_vif = axi_vif;
  endfunction

  function void build();
    env = new(axi_vif);
    env.build();
  endfunction

  task run();
    $display("[%0t] Starting AXI layered test", $time);
    env.run();
    $display("[%0t] Test completed", $time);
  endtask
endclass
