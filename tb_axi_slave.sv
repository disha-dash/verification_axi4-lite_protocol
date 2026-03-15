//==============================================================
// Simple AXI4-Lite Slave Testbench 
//==============================================================
`timescale 1ns/1ps

module tb_axi_slave;

  localparam ADDR_WIDTH = 32;
  localparam DATA_WIDTH = 32;

  // Clock and Reset
  reg aclk;
  reg aresetn;

  initial begin
    aclk = 0;
    forever #5 aclk = ~aclk; // 100 MHz clock
  end

  initial begin
    aresetn = 0;
    #20;
    aresetn = 1;
  end

  // AXI signals
  reg                 awvalid;
  wire                awready;
  reg  [ADDR_WIDTH-1:0] awaddr;

  reg                 wvalid;
  wire                wready;
  reg  [DATA_WIDTH-1:0] wdata;
  reg  [DATA_WIDTH/8-1:0] wstrb;

  wire                bvalid;
  reg                 bready;
  wire [1:0]          bresp;

  reg                 arvalid;
  wire                arready;
  reg  [ADDR_WIDTH-1:0] araddr;

  wire                rvalid;
  reg                 rready;
  wire [DATA_WIDTH-1:0] rdata;
  wire [1:0]          rresp;

  // Instantiate DUT
  axi_slave dut (
    .aclk(aclk),
    .aresetn(aresetn),
    .s_awvalid(awvalid),
    .s_awready(awready),
    .s_awaddr(awaddr),
    .s_wvalid(wvalid),
    .s_wready(wready),
    .s_wdata(wdata),
    .s_wstrb(wstrb),
    .s_bvalid(bvalid),
    .s_bready(bready),
    .s_bresp(bresp),
    .s_arvalid(arvalid),
    .s_arready(arready),
    .s_araddr(araddr),
    .s_rvalid(rvalid),
    .s_rready(rready),
    .s_rdata(rdata),
    .s_rresp(rresp)
  );

  // ============================================================
  // Simple write and read tasks (non-blocking safe waits)
  // ============================================================
  task axi_write(input [31:0] addr, input [31:0] data);
  begin
    @(posedge aclk);
    awaddr  <= addr;
    awvalid <= 1;
    wdata   <= data;
    wstrb   <= 4'hF;
    wvalid  <= 1;
    bready  <= 1;

    wait(awready);
    wait(wready);

    @(posedge aclk);
    awvalid <= 0;
    wvalid  <= 0;

    wait(bvalid);
    @(posedge aclk);
    bready <= 0;

    $display("[%0t] WRITE: addr=0x%08h data=0x%08h", $time, addr, data);
  end
  endtask

  task axi_read(input [31:0] addr);
  begin
    @(posedge aclk);
    araddr  <= addr;
    arvalid <= 1;
    rready  <= 1;

    wait(arready);
    @(posedge aclk);
    arvalid <= 0;

    wait(rvalid);
    @(posedge aclk);
    $display("[%0t] READ : addr=0x%08h data=0x%08h", $time, addr, rdata);
    rready <= 0;
  end
  endtask

  // ============================================================
  // Stimulus
  // ============================================================
  initial begin
    // Initialize
    awvalid=0; wvalid=0; arvalid=0; bready=0; rready=0;
    awaddr=0; wdata=0; araddr=0; wstrb=0;

    // Optional: dump waves for EPWave
    $dumpfile("axi_slave.vcd");
    $dumpvars(0, tb_axi_slave);

    wait(aresetn);
    $display("\n=== Starting Simple AXI Test ===\n");

    axi_write(32'h0000_0000, 32'hDEAD_BEEF);
    axi_write(32'h0000_0004, 32'hCAFE_F00D);
    axi_write(32'h0000_0008, 32'h1234_5678);
    axi_write(32'h0000_000C, 32'hFACE_B00C);

    #20;
    axi_read(32'h0000_0000);
    axi_read(32'h0000_0004);
    axi_read(32'h0000_0008);
    axi_read(32'h0000_000C);

    #50;
    $display("\n=== Simulation Complete ===\n");
    $finish;
  end

  // Safety timeout
  initial begin
    #2000;
    $display("TIMEOUT: Simulation exceeded 2000ns, forcing finish.");
    $finish;
  end

endmodule
