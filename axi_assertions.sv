//==============================================================
// AXI Assertions - Protocol Handshake Checks
//==============================================================
module axi_assertions (axi_if axi);

  // AWVALID / AWREADY handshake
  property aw_handshake;
    @(posedge axi.aclk) axi.awvalid |-> ##[1:3] axi.awready;
  endproperty
  assert property (aw_handshake)
    else $error("AWVALID not followed by AWREADY within 3 cycles");

  // WVALID / WREADY handshake
  property w_handshake;
    @(posedge axi.aclk) axi.wvalid |-> ##[1:3] axi.wready;
  endproperty
  assert property (w_handshake)
    else $error("WVALID not followed by WREADY within 3 cycles");

endmodule
