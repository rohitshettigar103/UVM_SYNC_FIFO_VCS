class fifo_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(fifo_scoreboard)

  uvm_tlm_analysis_fifo #(fifo_transaction) in_fifo;

  bit [`DW-1:0] fifo_q[$];
  int unsigned  pass_data;
  int unsigned  fail_data;
  int unsigned  pass_flag;
  int unsigned  fail_flag;

  function new(string name = "fifo_scoreboard", uvm_component parent = null);
    super.new(name, parent);
    in_fifo = new("in_fifo", this);
  endfunction

  task run_phase(uvm_phase phase);
    fifo_transaction tr;
    forever begin
      in_fifo.get(tr);
      check_txn(tr);
    end
  endtask

  function void check_txn(fifo_transaction tr);
    bit do_wr, do_rd;
    bit [`DW-1:0] exp_data;
    int unsigned  pre_size;
    bit exp_full, exp_empty;

    if (tr.rst) begin
      fifo_q.delete();
      if (tr.empty === 1'b1 && tr.full === 1'b0) begin
        pass_flag++;
        `uvm_info("SCB", "RESET MATCH  empty=1 full=0", UVM_HIGH)
      end
      else begin
        fail_flag++;
        `uvm_error("SCB", $sformatf("RESET MISMATCH  empty=%0b full=%0b (exp empty=1 full=0)",
                                    tr.empty, tr.full))
      end
      return;
    end

    // Controls sampled with the DUT outputs they produced this posedge.
    pre_size = fifo_q.size();
    do_rd = tr.rd_cs && tr.rd_en && (pre_size != 0);
    do_wr = tr.wr_cs && tr.wr_en && (pre_size != `DEPTH || do_rd);

    if (do_rd) begin
      exp_data = fifo_q.pop_front();
      if (tr.data_out === exp_data) begin
        pass_data++;
        `uvm_info("SCB", $sformatf("DATA MATCH     exp=0x%02h act=0x%02h",
                                   exp_data, tr.data_out), UVM_LOW)
      end
      else begin
        fail_data++;
        `uvm_error("SCB", $sformatf("DATA MISMATCH  exp=0x%02h act=0x%02h",
                                    exp_data, tr.data_out))
      end
    end

    if (do_wr)
      fifo_q.push_back(tr.data_in);

    exp_empty = (fifo_q.size() == 0);
    exp_full  = (fifo_q.size() == `DEPTH);

    if (tr.empty === exp_empty) pass_flag++;
    else begin
      fail_flag++;
      `uvm_error("SCB", $sformatf("EMPTY MISMATCH exp=%0b act=%0b (occ=%0d)",
                                  exp_empty, tr.empty, fifo_q.size()))
    end

    if (tr.full === exp_full) pass_flag++;
    else begin
      fail_flag++;
      `uvm_error("SCB", $sformatf("FULL MISMATCH  exp=%0b act=%0b (occ=%0d)",
                                  exp_full, tr.full, fifo_q.size()))
    end
  endfunction

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("SCB", $sformatf(
      "\n=========================================\n  FINAL SCOREBOARD SUMMARY\n  DATA   PASSED : %0d\n  DATA   FAILED : %0d\n  FLAGS  PASSED : %0d\n  FLAGS  FAILED : %0d\n=========================================",
      pass_data, fail_data, pass_flag, fail_flag), UVM_LOW)

    if (fail_data != 0 || fail_flag != 0)
      `uvm_error("SCB", "TEST FAILED - see mismatches above")
    else
      `uvm_info("SCB", "TEST PASSED", UVM_LOW)
  endfunction

endclass
