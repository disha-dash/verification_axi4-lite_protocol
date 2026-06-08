//==============================================================
// AXI Sequencer — extended transaction set for better coverage
//
// Generates transactions covering:
//   - Low, mid, and high address regions
//   - All four word-aligned offsets (0,4,8,C)
//   - Full-word strobe (4'hF) and partial strobes
//   - Edge-case data values (0, all-ones, mid-range)
//==============================================================
class axi_sequencer;
  mailbox #(axi_transaction) seq_mb = new();

  task start();
    axi_transaction tr;
    int i = 0;

    $display("[%0t] SEQ: Starting to generate transactions", $time);

    // ----------------------------------------------------------
    // Group A: original mid-region transactions (0x10-0x1C)
    // Covers mid_regs address bin, offsets 0-3, full strobe
    // ----------------------------------------------------------
    for (int k = 0; k < 4; k++) begin
      tr = new();
      tr.addr = 32'h10 + (k * 4);
      tr.data = 32'h12345678 + k;
      tr.strb = 4'hF;
      $display("[%0t] SEQ: Tx %0d addr=0x%08h data=0x%08h strb=0x%0h",
               $time, i++, tr.addr, tr.data, tr.strb);
      seq_mb.put(tr);
    end

    // ----------------------------------------------------------
    // Group B: low-region transactions (0x00-0x0C)
    // Covers low_regs address bin, all four offsets
    // ----------------------------------------------------------
    for (int k = 0; k < 4; k++) begin
      tr = new();
      tr.addr = 32'h00 + (k * 4);
      tr.data = 32'hDEAD0000 + k;
      tr.strb = 4'hF;
      $display("[%0t] SEQ: Tx %0d addr=0x%08h data=0x%08h strb=0x%0h",
               $time, i++, tr.addr, tr.data, tr.strb);
      seq_mb.put(tr);
    end

    // ----------------------------------------------------------
    // Group C: high-region transaction (0x20)
    // Covers high_regs address bin
    // ----------------------------------------------------------
    tr = new();
    tr.addr = 32'h20;
    tr.data = 32'hCAFEF00D;
    tr.strb = 4'hF;
    $display("[%0t] SEQ: Tx %0d addr=0x%08h data=0x%08h strb=0x%0h",
             $time, i++, tr.addr, tr.data, tr.strb);
    seq_mb.put(tr);

    // ----------------------------------------------------------
    // Group D: edge-case data values
    // all_zeros and all_ones data bins
    // ----------------------------------------------------------
    tr = new(); tr.addr = 32'h08; tr.data = 32'h00000000; tr.strb = 4'hF;
    $display("[%0t] SEQ: Tx %0d addr=0x%08h data=0x%08h strb=0x%0h (all-zeros)",
             $time, i++, tr.addr, tr.data, tr.strb);
    seq_mb.put(tr);

    tr = new(); tr.addr = 32'h0C; tr.data = 32'hFFFFFFFF; tr.strb = 4'hF;
    $display("[%0t] SEQ: Tx %0d addr=0x%08h data=0x%08h strb=0x%0h (all-ones)",
             $time, i++, tr.addr, tr.data, tr.strb);
    seq_mb.put(tr);

    // ----------------------------------------------------------
    // Group E: partial strobe patterns
    // Covers upper_half, lower_half strobe bins
    // ----------------------------------------------------------
    tr = new(); tr.addr = 32'h24; tr.data = 32'hAABBCCDD; tr.strb = 4'hC; // upper half
    $display("[%0t] SEQ: Tx %0d addr=0x%08h data=0x%08h strb=0x%0h (upper-half strobe)",
             $time, i++, tr.addr, tr.data, tr.strb);
    seq_mb.put(tr);

    tr = new(); tr.addr = 32'h28; tr.data = 32'h11223344; tr.strb = 4'h3; // lower half
    $display("[%0t] SEQ: Tx %0d addr=0x%08h data=0x%08h strb=0x%0h (lower-half strobe)",
             $time, i++, tr.addr, tr.data, tr.strb);
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
