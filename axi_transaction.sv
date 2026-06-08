//==============================================================
// AXI Transaction
//==============================================================
class axi_transaction;
  rand bit [31:0] addr;
  rand bit [31:0] data;
  rand bit  [3:0] strb;  // write strobe (default full-word)

  function new();
    strb = 4'hF;  // default: full word write
  endfunction
endclass
