//==============================================================
// AXI Sequencer - Generates transactions
//==============================================================
class axi_sequencer;
  mailbox #(axi_transaction) seq_mb = new();

  task start();
    axi_transaction tr;
    
    $display("[%0t] SEQ: Starting to generate transactions", $time);
    
    // Generate 4 write/read transactions
    for (int i = 0; i < 4; i++) begin
      tr = new();
      tr.addr = 32'h10 + (i * 4);  // 0x10, 0x14, 0x18, 0x1C
      tr.data = 32'h12345678 + i;   // 0x12345678, 0x12345679, ...
      
      $display("[%0t] SEQ: Generated transaction %0d: addr=0x%08h data=0x%08h", 
               $time, i, tr.addr, tr.data);
      
      seq_mb.put(tr);
    end
    
    $display("[%0t] SEQ: All transactions generated", $time);
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
