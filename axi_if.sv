//==============================================================
// AXI4-Lite Interface
//==============================================================
interface axi_if #(parameter ADDR_WIDTH = 32, DATA_WIDTH = 32);

  //============================================================
  // AXI4-Lite Signal Declarations
  //============================================================
  logic awvalid, awready;
  logic [ADDR_WIDTH-1:0] awaddr;

  logic wvalid, wready;
  logic [DATA_WIDTH-1:0] wdata;
  logic [(DATA_WIDTH/8)-1:0] wstrb;

  logic bvalid, bready;
  logic [1:0] bresp;

  logic arvalid, arready;
  logic [ADDR_WIDTH-1:0] araddr;

  logic rvalid, rready;
  logic [DATA_WIDTH-1:0] rdata;
  logic [1:0] rresp;

  logic aclk;
  logic aresetn;

  //============================================================
  // Modports
  //============================================================
  modport DUT (
    input  aclk, aresetn,
    input  awvalid, awaddr, wvalid, wdata, wstrb, bready,
    input  arvalid, araddr, rready,
    output awready, wready, bvalid, bresp, arready, rvalid, rdata, rresp
  );

  modport TB (
    input  aclk, aresetn,
    output awvalid, awaddr, wvalid, wdata, wstrb, bready,
    output arvalid, araddr, rready,
    input  awready, wready, bvalid, bresp, arready, rvalid, rdata, rresp
  );

endinterface : axi_if
