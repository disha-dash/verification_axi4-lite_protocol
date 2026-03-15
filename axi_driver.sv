//==============================================================
// AXI Driver - Drives transactions to DUT
//==============================================================
class axi_driver;
  virtual axi_if axi_vif;
  int transaction_count = 0;

  function new(virtual axi_if axi_vif);
    this.axi_vif = axi_vif;
  endfunction

  task run(axi_sequencer seq);
    axi_transaction tr;
    bit aw_done, w_done;
    
    $display("[%0t] DRV: Initializing signals", $time);
    
    // Initialize all signals to idle state
    axi_vif.awvalid = 0;
    axi_vif.awaddr  = 0;
    axi_vif.wvalid  = 0;
    axi_vif.wdata   = 0;
    axi_vif.wstrb   = 0;
    axi_vif.bready  = 0;
    axi_vif.arvalid = 0;
    axi_vif.araddr  = 0;
    axi_vif.rready  = 0;
    
    // Wait for reset to deassert
    wait(axi_vif.aresetn);
    repeat(2) @(posedge axi_vif.aclk);
    
    $display("[%0t] DRV: Starting transaction loop", $time);
    
    // Process transactions while available
    while (seq.seq_mb.num() > 0) begin
      // Get next transaction from sequencer
      seq.get_next_item(tr);
      transaction_count++;
      
      $display("[%0t] DRV: ========================================", $time);
      $display("[%0t] DRV: Transaction #%0d", $time, transaction_count);
      $display("[%0t] DRV: addr=0x%08h data=0x%08h", $time, tr.addr, tr.data);
      $display("[%0t] DRV: ========================================", $time);

      // ==========================================
      // WRITE TRANSACTION
      // ==========================================
      
      // Present address and data on same cycle
      @(posedge axi_vif.aclk);
      axi_vif.awaddr  <= tr.addr;
      axi_vif.awvalid <= 1;
      axi_vif.wdata   <= tr.data;
      axi_vif.wstrb   <= 4'hF;
      axi_vif.wvalid  <= 1;
      $display("[%0t] DRV: WRITE - Asserted AWVALID and WVALID", $time);
      
      // Wait for both handshakes
      aw_done = 0;
      w_done = 0;
      
      while (!aw_done || !w_done) begin
        @(posedge axi_vif.aclk);
        
        if (axi_vif.awready && !aw_done) begin
          axi_vif.awvalid <= 0;
          axi_vif.awaddr  <= 0;
          aw_done = 1;
          $display("[%0t] DRV: WRITE - AWREADY received", $time);
        end
        
        if (axi_vif.wready && !w_done) begin
          axi_vif.wvalid <= 0;
          axi_vif.wdata  <= 0;
          axi_vif.wstrb  <= 0;
          w_done = 1;
          $display("[%0t] DRV: WRITE - WREADY received", $time);
        end
      end

      // Wait for write response
      @(posedge axi_vif.aclk);
      axi_vif.bready <= 1;
      
      while (!axi_vif.bvalid) @(posedge axi_vif.aclk);
      $display("[%0t] DRV: WRITE - Response received (bresp=0x%0h)", $time, axi_vif.bresp);
      
      @(posedge axi_vif.aclk);
      axi_vif.bready <= 0;
      
      // Small delay between write and read
      repeat(2) @(posedge axi_vif.aclk);

      // ==========================================
      // READ TRANSACTION
      // ==========================================
      axi_vif.araddr  <= tr.addr;
      axi_vif.arvalid <= 1;
      axi_vif.rready  <= 1;
      $display("[%0t] DRV: READ - Asserted ARVALID", $time);
      
      // Wait for ARREADY
      @(posedge axi_vif.aclk);
      while (!axi_vif.arready) @(posedge axi_vif.aclk);
      
      axi_vif.arvalid <= 0;
      axi_vif.araddr  <= 0;
      $display("[%0t] DRV: READ - ARREADY received", $time);
      
      // Wait for read data
      while (!axi_vif.rvalid) @(posedge axi_vif.aclk);
      $display("[%0t] DRV: READ - Data received: 0x%08h (rresp=0x%0h)", 
               $time, axi_vif.rdata, axi_vif.rresp);
      
      @(posedge axi_vif.aclk);
      axi_vif.rready <= 0;

      // Notify sequencer that transaction is done
      seq.item_done(tr);
      
      $display("[%0t] DRV: Transaction #%0d COMPLETE\n", $time, transaction_count);
      
      // Small delay before next transaction
      repeat(2) @(posedge axi_vif.aclk);
    end
    
    $display("[%0t] DRV: All %0d transactions completed!", $time, transaction_count);
  endtask
endclass
