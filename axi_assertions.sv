//==============================================================
// AXI4-Lite SVA Assertions
//==============================================================
module axi_assertions (axi_if axi);

  wire rst = ~axi.aresetn;

  //============================================================
  // 1. WRITE ADDRESS CHANNEL (AW)
  //============================================================

  // 1a. AWVALID must be LOW (not X/Z) during reset
  property aw_valid_during_reset;
    @(posedge axi.aclk)
      (!axi.aresetn && !$isunknown(axi.awvalid)) |-> !axi.awvalid;
  endproperty
  assert property (aw_valid_during_reset)
    else $error("[SVA-AW01] AWVALID must be LOW during reset");
  cover property (aw_valid_during_reset);

  // 1b. AWVALID must stay high until AWREADY
  property aw_valid_stable;
    @(posedge axi.aclk) disable iff (rst || $isunknown(axi.awvalid))
      (axi.awvalid && !axi.awready) |=> axi.awvalid;
  endproperty
  assert property (aw_valid_stable)
    else $error("[SVA-AW02] AWVALID dropped before AWREADY");

  // 1c. AWADDR stable while AWVALID high and AWREADY low
  property aw_addr_stable;
    @(posedge axi.aclk) disable iff (rst || $isunknown(axi.awvalid))
      (axi.awvalid && !axi.awready) |=> $stable(axi.awaddr);
  endproperty
  assert property (aw_addr_stable)
    else $error("[SVA-AW03] AWADDR changed before handshake");

  // 1d. AWREADY arrives within 8 cycles
  property aw_handshake_timeout;
    @(posedge axi.aclk) disable iff (rst)
      $rose(axi.awvalid) |-> ##[1:8] axi.awready;
  endproperty
  assert property (aw_handshake_timeout)
    else $error("[SVA-AW04] AWREADY not seen within 8 cycles of AWVALID");
  cover property (@(posedge axi.aclk) disable iff (rst)
    axi.awvalid && axi.awready);

  //============================================================
  // 2. WRITE DATA CHANNEL (W)
  //============================================================

  // 2a. WVALID must be LOW (not X) during reset
  property w_valid_during_reset;
    @(posedge axi.aclk)
      (!axi.aresetn && !$isunknown(axi.wvalid)) |-> !axi.wvalid;
  endproperty
  assert property (w_valid_during_reset)
    else $error("[SVA-W01] WVALID must be LOW during reset");

  // 2b. WVALID must stay high until WREADY
  property w_valid_stable;
    @(posedge axi.aclk) disable iff (rst || $isunknown(axi.wvalid))
      (axi.wvalid && !axi.wready) |=> axi.wvalid;
  endproperty
  assert property (w_valid_stable)
    else $error("[SVA-W02] WVALID dropped before WREADY");

  // 2c. WDATA stable while WVALID high and WREADY low
  property w_data_stable;
    @(posedge axi.aclk) disable iff (rst || $isunknown(axi.wvalid))
      (axi.wvalid && !axi.wready) |=> $stable(axi.wdata);
  endproperty
  assert property (w_data_stable)
    else $error("[SVA-W03] WDATA changed before handshake");

  // 2d. WSTRB stable while WVALID high and WREADY low
  property w_strb_stable;
    @(posedge axi.aclk) disable iff (rst || $isunknown(axi.wvalid))
      (axi.wvalid && !axi.wready) |=> $stable(axi.wstrb);
  endproperty
  assert property (w_strb_stable)
    else $error("[SVA-W04] WSTRB changed before handshake");

  // 2e. WREADY within 8 cycles of WVALID
  property w_handshake_timeout;
    @(posedge axi.aclk) disable iff (rst)
      $rose(axi.wvalid) |-> ##[1:8] axi.wready;
  endproperty
  assert property (w_handshake_timeout)
    else $error("[SVA-W05] WREADY not seen within 8 cycles of WVALID");
  cover property (@(posedge axi.aclk) disable iff (rst)
    axi.wvalid && axi.wready);

  //============================================================
  // 3. WRITE RESPONSE CHANNEL (B)
  //============================================================

  // 3a. BVALID must be LOW during reset
  property b_valid_during_reset;
    @(posedge axi.aclk)
      (!axi.aresetn && !$isunknown(axi.bvalid)) |-> !axi.bvalid;
  endproperty
  assert property (b_valid_during_reset)
    else $error("[SVA-B01] BVALID must be LOW during reset");

  // 3b. BVALID must stay high until BREADY
  property b_valid_stable;
    @(posedge axi.aclk) disable iff (rst)
      (axi.bvalid && !axi.bready) |=> axi.bvalid;
  endproperty
  assert property (b_valid_stable)
    else $error("[SVA-B02] BVALID dropped before BREADY");

  // 3c. BRESP must be OKAY
  property bresp_okay;
    @(posedge axi.aclk) disable iff (rst)
      axi.bvalid |-> (axi.bresp == 2'b00);
  endproperty
  assert property (bresp_okay)
    else $error("[SVA-B03] BRESP not OKAY (got 0x%0h)", axi.bresp);

  // 3d. BVALID follows W handshake within 4 cycles
  property bvalid_after_whandshake;
    @(posedge axi.aclk) disable iff (rst)
      (axi.wvalid && axi.wready) |-> ##[1:4] axi.bvalid;
  endproperty
  assert property (bvalid_after_whandshake)
    else $error("[SVA-B04] BVALID did not appear within 4 cycles of W handshake");
  cover property (@(posedge axi.aclk) disable iff (rst)
    axi.bvalid && axi.bready);

  //============================================================
  // 4. READ ADDRESS CHANNEL (AR)
  //============================================================

  // 4a. ARVALID must be LOW (not X) during reset
  property ar_valid_during_reset;
    @(posedge axi.aclk)
      (!axi.aresetn && !$isunknown(axi.arvalid)) |-> !axi.arvalid;
  endproperty
  assert property (ar_valid_during_reset)
    else $error("[SVA-AR01] ARVALID must be LOW during reset");

  // 4b. ARVALID must stay high until ARREADY
  property ar_valid_stable;
    @(posedge axi.aclk) disable iff (rst || $isunknown(axi.arvalid))
      (axi.arvalid && !axi.arready) |=> axi.arvalid;
  endproperty
  assert property (ar_valid_stable)
    else $error("[SVA-AR02] ARVALID dropped before ARREADY");

  // 4c. ARADDR stable while ARVALID high and ARREADY low
  property ar_addr_stable;
    @(posedge axi.aclk) disable iff (rst || $isunknown(axi.arvalid))
      (axi.arvalid && !axi.arready) |=> $stable(axi.araddr);
  endproperty
  assert property (ar_addr_stable)
    else $error("[SVA-AR03] ARADDR changed before handshake");

  // 4d. ARREADY within 8 cycles of ARVALID
  property ar_handshake_timeout;
    @(posedge axi.aclk) disable iff (rst)
      $rose(axi.arvalid) |-> ##[1:8] axi.arready;
  endproperty
  assert property (ar_handshake_timeout)
    else $error("[SVA-AR04] ARREADY not seen within 8 cycles of ARVALID");
  cover property (@(posedge axi.aclk) disable iff (rst)
    axi.arvalid && axi.arready);

  //============================================================
  // 5. READ DATA CHANNEL (R)
  //============================================================

  // 5a. RVALID must be LOW during reset
  property r_valid_during_reset;
    @(posedge axi.aclk)
      (!axi.aresetn && !$isunknown(axi.rvalid)) |-> !axi.rvalid;
  endproperty
  assert property (r_valid_during_reset)
    else $error("[SVA-R01] RVALID must be LOW during reset");

  // 5b. RVALID must stay high until RREADY
  property r_valid_stable;
    @(posedge axi.aclk) disable iff (rst)
      (axi.rvalid && !axi.rready) |=> axi.rvalid;
  endproperty
  assert property (r_valid_stable)
    else $error("[SVA-R02] RVALID dropped before RREADY");

  // 5c. RDATA stable while RVALID high and RREADY low
  property r_data_stable;
    @(posedge axi.aclk) disable iff (rst)
      (axi.rvalid && !axi.rready) |=> $stable(axi.rdata);
  endproperty
  assert property (r_data_stable)
    else $error("[SVA-R03] RDATA changed before handshake");

  // 5d. RRESP must be OKAY
  property rresp_okay;
    @(posedge axi.aclk) disable iff (rst)
      axi.rvalid |-> (axi.rresp == 2'b00);
  endproperty
  assert property (rresp_okay)
    else $error("[SVA-R04] RRESP not OKAY (got 0x%0h)", axi.rresp);

  // 5e. RVALID within 8 cycles of AR handshake.
  //     ##[0:8] is required because this slave asserts RVALID on the SAME
  //     clock edge as ARREADY (both are set in the same always_ff block),
  //     so the concurrent cycle (##0) must be included in the window.
  property rvalid_after_arhandshake;
    @(posedge axi.aclk) disable iff (rst)
      (axi.arvalid && axi.arready) |-> ##[0:8] axi.rvalid;
  endproperty
  assert property (rvalid_after_arhandshake)
    else $error("[SVA-R05] RVALID did not appear within 8 cycles of AR handshake");
  cover property (@(posedge axi.aclk) disable iff (rst)
    axi.rvalid && axi.rready);

  //============================================================
  // 6. CROSS-CHANNEL CHECKS
  //============================================================

  // 6a. Track whether a write address was accepted and response not yet sent.
  //     A simple flag: set on AW handshake, clear on B handshake.
  //     BVALID is only legal while this flag is set.
  logic aw_pending;
  always_ff @(posedge axi.aclk or negedge axi.aresetn) begin
    if (!axi.aresetn)
      aw_pending <= 1'b0;
    else begin
      // Set when AW handshake completes, clear when B handshake completes
      if (axi.awvalid && axi.awready && !(axi.bvalid && axi.bready))
        aw_pending <= 1'b1;
      else if (axi.bvalid && axi.bready)
        aw_pending <= 1'b0;
    end
  end

  // BVALID must not appear without a pending write transaction
  property no_spurious_bvalid;
    @(posedge axi.aclk) disable iff (rst)
      $rose(axi.bvalid) |-> aw_pending;
  endproperty
  assert property (no_spurious_bvalid)
    else $error("[SVA-X01] BVALID asserted with no pending write transaction");

  // 6b. No overlapping write address while a response is outstanding
  property no_overlapping_writes;
    @(posedge axi.aclk) disable iff (rst)
      (axi.bvalid && !axi.bready) |-> !axi.awvalid;
  endproperty
  assert property (no_overlapping_writes)
    else $warning("[SVA-X02] AWVALID asserted while BVALID still pending");

  // 6c. Cover: complete write sequence AW -> W -> B
  cover property (@(posedge axi.aclk) disable iff (rst)
    (axi.awvalid && axi.awready) ##[1:6]
    (axi.wvalid  && axi.wready)  ##[1:6]
    (axi.bvalid  && axi.bready));

  // 6d. Cover: complete read sequence AR -> R
  cover property (@(posedge axi.aclk) disable iff (rst)
    (axi.arvalid && axi.arready) ##[0:8]
    (axi.rvalid  && axi.rready));

endmodule
