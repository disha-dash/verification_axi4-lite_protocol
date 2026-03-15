//==============================================================
// AXI4-Lite Slave 
//==============================================================
module axi_slave #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter STRB_WIDTH = DATA_WIDTH/8,
    parameter NUM_REGS = 16
)(
    input  logic                 aclk,
    input  logic                 aresetn,

    // Write address channel
    input  logic                 s_awvalid,
    output logic                 s_awready,
    input  logic [ADDR_WIDTH-1:0] s_awaddr,

    // Write data channel
    input  logic                 s_wvalid,
    output logic                 s_wready,
    input  logic [DATA_WIDTH-1:0] s_wdata,
    input  logic [STRB_WIDTH-1:0] s_wstrb,

    // Write response channel
    output logic                 s_bvalid,
    input  logic                 s_bready,
    output logic [1:0]           s_bresp,

    // Read address channel
    input  logic                 s_arvalid,
    output logic                 s_arready,
    input  logic [ADDR_WIDTH-1:0] s_araddr,

    // Read data channel
    output logic                 s_rvalid,
    input  logic                 s_rready,
    output logic [DATA_WIDTH-1:0] s_rdata,
    output logic [1:0]           s_rresp
);

    // Internal registers
    logic [DATA_WIDTH-1:0] regs [0:NUM_REGS-1];
    logic [ADDR_WIDTH-1:0] awaddr_reg;
    logic aw_seen;

    assign s_bresp = 2'b00;
    assign s_rresp = 2'b00;
    assign s_awready = !aw_seen;
    assign s_wready  = aw_seen;

    always_ff @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            aw_seen <= 0;
            s_bvalid <= 0;
            s_arready <= 0;
            s_rvalid <= 0;
            s_rdata <= 0;
            for (int i=0;i<NUM_REGS;i++) regs[i]<=0;
        end else begin
            // Write address
            if (s_awvalid && s_awready) begin
                aw_seen <= 1;
                awaddr_reg <= s_awaddr;
            end

            // Write data
            if (s_wvalid && s_wready) begin
                int idx;
                idx = (awaddr_reg >> 2) % NUM_REGS;
                for (int j=0;j<STRB_WIDTH;j++)
                    if (s_wstrb[j])
                        regs[idx][8*j +: 8] <= s_wdata[8*j +: 8];
                s_bvalid <= 1;
            end else if (s_bvalid && s_bready)
                s_bvalid <= 0;

            // Clear after write response
            if (s_bvalid && s_bready)
                aw_seen <= 0;

            // Read address
            if (s_arvalid && !s_rvalid) begin
                int ridx;
                ridx = (s_araddr >> 2) % NUM_REGS;
                s_rdata <= regs[ridx];
                s_rvalid <= 1;
                s_arready <= 1;
            end else s_arready <= 0;

            // Read response done
            if (s_rvalid && s_rready)
                s_rvalid <= 0;
        end
    end
endmodule
