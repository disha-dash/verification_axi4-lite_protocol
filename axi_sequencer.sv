//==============================================================
// AXI Sequencer
//==============================================================
class axi_sequencer;
  mailbox #(axi_transaction) seq_mb = new();

  task start();
    axi_transaction tr;
    int i = 0;
    $display("[%0t] SEQ: Starting to generate transactions", $time);

    // ---- Group A: mid-region 0x10-0x1C, full strobe ----
    // Covers: mid_regs, offsets 0-3, full_word strobe, mid_range data
    for (int k = 0; k < 4; k++) begin
      tr = new(); tr.addr = 32'h10 + (k*4);
      tr.data = 32'h12345678 + k; tr.strb = 4'hF;
      $display("[%0t] SEQ: Tx %0d  addr=0x%08h data=0x%08h strb=0x%0h",
               $time,i++,tr.addr,tr.data,tr.strb);
      seq_mb.put(tr);
    end

    // ---- Group B: low-region 0x00-0x0C, full strobe ----
    // Covers: low_regs, offsets 0-3
    for (int k = 0; k < 4; k++) begin
      tr = new(); tr.addr = 32'h00 + (k*4);
      tr.data = 32'hDEAD0000 + k; tr.strb = 4'hF;
      $display("[%0t] SEQ: Tx %0d  addr=0x%08h data=0x%08h strb=0x%0h",
               $time,i++,tr.addr,tr.data,tr.strb);
      seq_mb.put(tr);
    end

    // ---- Group C: high-region 0x20, full strobe ----
    // Covers: high_regs, full_word, cross region_high x full
    tr = new(); tr.addr = 32'h20; tr.data = 32'hCAFEF00D; tr.strb = 4'hF;
    $display("[%0t] SEQ: Tx %0d  addr=0x%08h data=0x%08h strb=0x%0h (high+full)",
             $time,i++,tr.addr,tr.data,tr.strb);
    seq_mb.put(tr);

    // ---- Group D: edge-case data values ----
    // Covers: all_zeros (W + R), all_ones (W + R)
    tr = new(); tr.addr = 32'h08; tr.data = 32'h00000000; tr.strb = 4'hF;
    $display("[%0t] SEQ: Tx %0d  addr=0x%08h data=0x%08h strb=0x%0h (all-zeros)",
             $time,i++,tr.addr,tr.data,tr.strb);
    seq_mb.put(tr);

    tr = new(); tr.addr = 32'h0C; tr.data = 32'hFFFFFFFF; tr.strb = 4'hF;
    $display("[%0t] SEQ: Tx %0d  addr=0x%08h data=0x%08h strb=0x%0h (all-ones)",
             $time,i++,tr.addr,tr.data,tr.strb);
    seq_mb.put(tr);

    // ---- Group E: half-word strobes on mid-region ----
    // Covers: upper_half(C), lower_half(3), cross region_low x partial
    tr = new(); tr.addr = 32'h10; tr.data = 32'hAABBCCDD; tr.strb = 4'hC;
    $display("[%0t] SEQ: Tx %0d  addr=0x%08h data=0x%08h strb=0x%0h (upper-half mid)",
             $time,i++,tr.addr,tr.data,tr.strb);
    seq_mb.put(tr);

    tr = new(); tr.addr = 32'h14; tr.data = 32'h11223344; tr.strb = 4'h3;
    $display("[%0t] SEQ: Tx %0d  addr=0x%08h data=0x%08h strb=0x%0h (lower-half mid)",
             $time,i++,tr.addr,tr.data,tr.strb);
    seq_mb.put(tr);

    // ---- Group F: single-byte strobes ----
    // Covers: byte3(8), byte2(4), byte1(2), byte0(1)
    tr = new(); tr.addr = 32'h00; tr.data = 32'hAA000000; tr.strb = 4'h8;
    $display("[%0t] SEQ: Tx %0d  addr=0x%08h data=0x%08h strb=0x%0h (byte3)",
             $time,i++,tr.addr,tr.data,tr.strb);
    seq_mb.put(tr);

    tr = new(); tr.addr = 32'h04; tr.data = 32'h00BB0000; tr.strb = 4'h4;
    $display("[%0t] SEQ: Tx %0d  addr=0x%08h data=0x%08h strb=0x%0h (byte2)",
             $time,i++,tr.addr,tr.data,tr.strb);
    seq_mb.put(tr);

    tr = new(); tr.addr = 32'h18; tr.data = 32'h0000CC00; tr.strb = 4'h2;
    $display("[%0t] SEQ: Tx %0d  addr=0x%08h data=0x%08h strb=0x%0h (byte1)",
             $time,i++,tr.addr,tr.data,tr.strb);
    seq_mb.put(tr);

    tr = new(); tr.addr = 32'h1C; tr.data = 32'h000000DD; tr.strb = 4'h1;
    $display("[%0t] SEQ: Tx %0d  addr=0x%08h data=0x%08h strb=0x%0h (byte0)",
             $time,i++,tr.addr,tr.data,tr.strb);
    seq_mb.put(tr);

    // ---- Group G: high-region + partial strobe ----
    // Covers: cross region_high x partial  (both sub-bins)
    tr = new(); tr.addr = 32'h20; tr.data = 32'hAABBCCDD; tr.strb = 4'hC;
    $display("[%0t] SEQ: Tx %0d  addr=0x%08h data=0x%08h strb=0x%0h (high+upper-half)",
             $time,i++,tr.addr,tr.data,tr.strb);
    seq_mb.put(tr);

    tr = new(); tr.addr = 32'h24; tr.data = 32'hAABBCCDD; tr.strb = 4'hC;
    $display("[%0t] SEQ: Tx %0d  addr=0x%08h data=0x%08h strb=0x%0h (high+partial-2)",
             $time,i++,tr.addr,tr.data,tr.strb);
    seq_mb.put(tr);

    tr = new(); tr.addr = 32'h24; tr.data = 32'h11223344; tr.strb = 4'h3;
    $display("[%0t] SEQ: Tx %0d  addr=0x%08h data=0x%08h strb=0x%0h (high+lower-half)",
             $time,i++,tr.addr,tr.data,tr.strb);
    seq_mb.put(tr);

    $display("[%0t] SEQ: All %0d transactions generated", $time, i);
  endtask

  task get_next_item(output axi_transaction tr);
    seq_mb.get(tr);
    $display("[%0t] SEQ: Delivered transaction addr=0x%08h", $time, tr.addr);
  endtask

  task item_done(input axi_transaction tr);
    $display("[%0t] SEQ: Transaction done addr=0x%08h data=0x%08h",
             $time, tr.addr, tr.data);
  endtask
endclass
