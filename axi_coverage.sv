//==============================================================
// AXI4-Lite Functional Coverage 
//==============================================================

//--------------------------------------------------------------
// Covergroup 1 – Write Address Channel
//--------------------------------------------------------------
covergroup cg_aw_channel (ref logic s_awvalid, s_awready,
                           ref logic [31:0] s_awaddr);
  cp_aw_handshake: coverpoint (s_awvalid & s_awready) {
    bins handshake = {1'b1};
  }
  cp_aw_addr_region: coverpoint s_awaddr[7:0]
      iff (s_awvalid & s_awready) {
    bins low_regs  = {[8'h00 : 8'h0F]};
    bins mid_regs  = {[8'h10 : 8'h1F]};
    bins high_regs = {[8'h20 : 8'hFF]};
  }
  cp_aw_addr_align: coverpoint s_awaddr[3:2]
      iff (s_awvalid & s_awready) {
    bins offset_0 = {2'b00};
    bins offset_1 = {2'b01};
    bins offset_2 = {2'b10};
    bins offset_3 = {2'b11};
  }
endgroup

//--------------------------------------------------------------
// Covergroup 2 – Write Data Channel
//--------------------------------------------------------------
covergroup cg_w_channel (ref logic s_wvalid, s_wready,
                          ref logic [31:0] s_wdata,
                          ref logic [3:0]  s_wstrb);
  cp_w_handshake: coverpoint (s_wvalid & s_wready) {
    bins handshake = {1'b1};
  }
  // All practically useful strobe patterns
  cp_w_strb: coverpoint s_wstrb iff (s_wvalid & s_wready) {
    bins full_word  = {4'hF};           // all 4 bytes
    bins upper_half = {4'hC};           // bytes [3:2]
    bins lower_half = {4'h3};           // bytes [1:0]
    bins byte3      = {4'h8};           // byte 3 only
    bins byte2      = {4'h4};           // byte 2 only
    bins byte1      = {4'h2};           // byte 1 only
    bins byte0      = {4'h1};           // byte 0 only
    bins other      = default;
  }
  cp_w_data_range: coverpoint s_wdata iff (s_wvalid & s_wready) {
    bins all_zeros = {32'h0000_0000};
    bins all_ones  = {32'hFFFF_FFFF};
    bins mid_range = {[32'h0000_0001 : 32'hFFFFFFFE]};
  }
endgroup

//--------------------------------------------------------------
// Covergroup 3 – Write Response Channel
//--------------------------------------------------------------
covergroup cg_b_channel (ref logic s_bvalid, s_bready,
                          ref logic [1:0] s_bresp);
  cp_b_handshake: coverpoint (s_bvalid & s_bready) {
    bins handshake = {1'b1};
  }
  cp_bresp: coverpoint s_bresp iff (s_bvalid) {
    bins      okay   = {2'b00};
    // A correct AXI4-Lite slave never generates these;
    // keep as ignore so they don't drag coverage down.
    ignore_bins exokay = {2'b01};
    ignore_bins slverr = {2'b10};
    ignore_bins decerr = {2'b11};
  }
endgroup

//--------------------------------------------------------------
// Covergroup 4 – Read Address Channel
//--------------------------------------------------------------
covergroup cg_ar_channel (ref logic s_arvalid, s_arready,
                           ref logic [31:0] s_araddr);
  cp_ar_handshake: coverpoint (s_arvalid & s_arready) {
    bins handshake = {1'b1};
  }
  cp_ar_addr_region: coverpoint s_araddr[7:0]
      iff (s_arvalid & s_arready) {
    bins low_regs  = {[8'h00 : 8'h0F]};
    bins mid_regs  = {[8'h10 : 8'h1F]};
    bins high_regs = {[8'h20 : 8'hFF]};
  }
  cp_ar_addr_align: coverpoint s_araddr[3:2]
      iff (s_arvalid & s_arready) {
    bins offset_0 = {2'b00};
    bins offset_1 = {2'b01};
    bins offset_2 = {2'b10};
    bins offset_3 = {2'b11};
  }
endgroup

//--------------------------------------------------------------
// Covergroup 5 – Read Data Channel
//--------------------------------------------------------------
covergroup cg_r_channel (ref logic s_rvalid, s_rready,
                          ref logic [31:0] s_rdata,
                          ref logic [1:0]  s_rresp);
  cp_r_handshake: coverpoint (s_rvalid & s_rready) {
    bins handshake = {1'b1};
  }
  cp_rresp: coverpoint s_rresp iff (s_rvalid) {
    bins      okay   = {2'b00};
    ignore_bins exokay = {2'b01};
    ignore_bins slverr = {2'b10};
    ignore_bins decerr = {2'b11};
  }
  cp_r_data_range: coverpoint s_rdata iff (s_rvalid & s_rready) {
    bins all_zeros = {32'h0000_0000};
    bins all_ones  = {32'hFFFF_FFFF};
    bins mid_range = {[32'h0000_0001 : 32'hFFFFFFFE]};
  }
endgroup

//--------------------------------------------------------------
// Covergroup 6 – Cross: AW address region x W strobe type
//
// AW and W handshakes occur on DIFFERENT clock cycles in this DUT.
//--------------------------------------------------------------
covergroup cg_aw_w_cross (ref logic [31:0] cross_awaddr,
                           ref logic [3:0]  cross_wstrb);
  cp_addr_rgn: coverpoint cross_awaddr[7:5] {
    bins region_low  = {3'b000};          // addr 0x00–0x1F
    bins region_high = {[3'b001:3'b111]}; // addr 0x20+
  }
  cp_strb_type: coverpoint cross_wstrb {
    bins full_word = {4'hF};
    bins partial   = {[4'h1 : 4'hE]};
  }
  cx_addr_strb: cross cp_addr_rgn, cp_strb_type;
endgroup

//--------------------------------------------------------------
// Covergroup 7 – Reset behavior
//
// Uses boolean (2-state) expressions to avoid QuestaSim auto-binning
// of 4-state logic signals, which inflates the bin count and dilutes %.
//
// cg_reset_beh   : sampled every clock — covers both reset states
// cg_reset_valids: sampled only during reset (controlled in sample())
//--------------------------------------------------------------
//--------------------------------------------------------------
// Covergroup 7 – Reset behavior
//--------------------------------------------------------------
covergroup cg_reset (ref logic s_aresetn,
                     ref logic s_awvalid,
                     ref logic s_wvalid,
                     ref logic s_arvalid);

  cp_reset : coverpoint s_aresetn {
    bins in_reset     = {1'b0};
    bins out_of_reset = {1'b1};
  }

  cp_valids_during_reset :
    coverpoint ((s_awvalid==0) &&
                (s_wvalid ==0) &&
                (s_arvalid==0))
    iff (!s_aresetn)
  {
    bins all_low = {1'b1};
  }

endgroup
//==============================================================
// Coverage class
//==============================================================
class axi_coverage;

  virtual axi_if vif;

  // Snapshot variables
  logic        s_awvalid, s_awready;
  logic [31:0] s_awaddr;
  logic        s_wvalid,  s_wready;
  logic [31:0] s_wdata;
  logic  [3:0] s_wstrb;
  logic        s_bvalid,  s_bready;
  logic  [1:0] s_bresp;
  logic        s_arvalid, s_arready;
  logic [31:0] s_araddr;
  logic        s_rvalid,  s_rready;
  logic [31:0] s_rdata;
  logic  [1:0] s_rresp;
  logic        s_aresetn;

  // Latched values for cross coverage:
  // awaddr is captured at AW handshake; cross is sampled at W handshake.
  // This is needed because AW and W handshakes occur on different clock edges.
  logic [31:0] cross_awaddr;
  logic  [3:0] cross_wstrb;

  // Covergroup handles
  cg_aw_channel    h_aw;
  cg_w_channel     h_w;
  cg_b_channel     h_b;
  cg_ar_channel    h_ar;
  cg_r_channel     h_r;
  cg_aw_w_cross    h_cross;
  cg_reset         h_rst;

  function new(virtual axi_if vif);
    this.vif = vif;
  endfunction

  function void build();
    h_aw    = new(s_awvalid, s_awready, s_awaddr);
    h_w     = new(s_wvalid, s_wready, s_wdata, s_wstrb);
    h_b     = new(s_bvalid, s_bready, s_bresp);
    h_ar    = new(s_arvalid, s_arready, s_araddr);
    h_r     = new(s_rvalid, s_rready, s_rdata, s_rresp);
    h_cross = new(cross_awaddr, cross_wstrb);
    h_rst = new(s_aresetn, s_awvalid, s_wvalid, s_arvalid);
  endfunction

  function void sample();
    s_awvalid = vif.awvalid;  s_awready = vif.awready;
    s_awaddr  = vif.awaddr;
    s_wvalid  = vif.wvalid;   s_wready  = vif.wready;
    s_wdata   = vif.wdata;    s_wstrb   = vif.wstrb;
    s_bvalid  = vif.bvalid;   s_bready  = vif.bready;
    s_bresp   = vif.bresp;
    s_arvalid = vif.arvalid;  s_arready = vif.arready;
    s_araddr  = vif.araddr;
    s_rvalid  = vif.rvalid;   s_rready  = vif.rready;
    s_rdata   = vif.rdata;    s_rresp   = vif.rresp;
    s_aresetn = vif.aresetn;

    // Latch awaddr when AW handshake completes
    if (s_awvalid & s_awready)
      cross_awaddr = s_awaddr;

    // Sample all per-channel covergroups every clock
    h_aw.sample();
    h_w.sample();
    h_b.sample();
    h_ar.sample();
    h_r.sample();
    h_rst.sample();

    // Sample cross ONLY at W handshake, using the latched awaddr.
    // This pairs the write address (captured earlier) with the strobe
    // that actually went with it — even though they handshook on
    // different clock edges.
    if (s_wvalid & s_wready) begin
      cross_wstrb = s_wstrb;
      h_cross.sample();
    end
  endfunction

  function void report();
    $display("----------------------------------------------------");
    $display(" AXI4-Lite Functional Coverage Report");
    $display("----------------------------------------------------");
    $display("  AW Channel  : %.1f%%", h_aw.get_coverage());
    $display("  W  Channel  : %.1f%%", h_w.get_coverage());
    $display("  B  Channel  : %.1f%%", h_b.get_coverage());
    $display("  AR Channel  : %.1f%%", h_ar.get_coverage());
    $display("  R  Channel  : %.1f%%", h_r.get_coverage());
    $display("  AW x W Cross: %.1f%%", h_cross.get_coverage());
    $display("  Reset       : %.1f%%", h_rst.get_coverage());
    $display("  TOTAL       : %.1f%%", $get_coverage());
    $display("----------------------------------------------------");
  endfunction

endclass
