//==============================================================
// Scoreboard - Compares Expected vs Observed Data
//==============================================================
class axi_scoreboard;
  mailbox mon2sb;
  logic [31:0] expected [0:15];

  function new(mailbox mon2sb);
    this.mon2sb = mon2sb;
    for (int i = 0; i < 16; i++) expected[i] = 0;
  endfunction

  task write_expected(int idx, logic [31:0] val);
    expected[idx] = val;
  endtask

  task run();
    logic [63:0] pkt;
    logic [31:0] addr;
    logic [31:0] data;
    int idx;

    forever begin
      mon2sb.get(pkt);
      addr = pkt[63:32];
      data = pkt[31:0];
      idx  = addr >> 2;

      if (expected[idx] !== data)
        $display("** SB ERROR ** idx=%0d exp=0x%08h got=0x%08h",
                 idx, expected[idx], data);
      else
        $display("SB OK idx=%0d val=0x%08h", idx, data);
    end
  endtask
endclass
