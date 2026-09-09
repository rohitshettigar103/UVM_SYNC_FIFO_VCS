class fifo_sequence extends uvm_sequence #(fifo_transaction);
  `uvm_object_utils(fifo_sequence)

  function new(string name = "fifo_sequence");
    super.new(name);
  endfunction
endclass


// -----------------------------------------------------------------------------
// Reset: hold rst for several cycles, then release with controls idle
// -----------------------------------------------------------------------------
class fifo_rst extends fifo_sequence;
  `uvm_object_utils(fifo_rst)

  function new(string name = "fifo_rst");
    super.new(name);
  endfunction

  task body();
    repeat (5) begin
      req = fifo_transaction::type_id::create("req");
      start_item(req);
      if (!req.randomize() with {
            rst     == 1'b1;
            wr_cs   == 1'b0;
            rd_cs   == 1'b0;
            wr_en   == 1'b0;
            rd_en   == 1'b0;
            data_in == '0;
          })
        `uvm_fatal("fifo_rst", "reset assertion randomization failed")
      finish_item(req);
    end

    req = fifo_transaction::type_id::create("req");
    start_item(req);
    if (!req.randomize() with {
          rst     == 1'b0;
          wr_cs   == 1'b0;
          rd_cs   == 1'b0;
          wr_en   == 1'b0;
          rd_en   == 1'b0;
          data_in == '0;
        })
      `uvm_fatal("fifo_rst", "reset deassertion randomization failed")
    finish_item(req);
  endtask
endclass


// -----------------------------------------------------------------------------
// Directed writes (fills past DEPTH to hit FULL)
// -----------------------------------------------------------------------------
class fifo_write extends fifo_sequence;
  `uvm_object_utils(fifo_write)

  int unsigned n_beats = `DEPTH + 8;

  function new(string name = "fifo_write");
    super.new(name);
  endfunction

  task body();
    repeat (n_beats) begin
      req = fifo_transaction::type_id::create("req");
      start_item(req);
      if (!req.randomize() with {
            rst   == 1'b0;
            wr_cs == 1'b1;
            wr_en == 1'b1;
            rd_cs == 1'b0;
            rd_en == 1'b0;
          })
        `uvm_fatal("fifo_write", "write randomization failed")
      finish_item(req);
    end
  endtask
endclass


// -----------------------------------------------------------------------------
// Directed reads
// -----------------------------------------------------------------------------
class fifo_read extends fifo_sequence;
  `uvm_object_utils(fifo_read)

  int unsigned n_beats = `DEPTH + 8;

  function new(string name = "fifo_read");
    super.new(name);
  endfunction

  task body();
    repeat (n_beats) begin
      req = fifo_transaction::type_id::create("req");
      start_item(req);
      if (!req.randomize() with {
            rst     == 1'b0;
            wr_cs   == 1'b0;
            wr_en   == 1'b0;
            rd_cs   == 1'b1;
            rd_en   == 1'b1;
            data_in == '0;
          })
        `uvm_fatal("fifo_read", "read randomization failed")
      finish_item(req);
    end
  endtask
endclass


// -----------------------------------------------------------------------------
// Random mixed traffic (writes, reads, both, idle, chip-select off)
// -----------------------------------------------------------------------------
class fifo_read_write extends fifo_sequence;
  `uvm_object_utils(fifo_read_write)

  int unsigned n_beats = 200;

  function new(string name = "fifo_read_write");
    super.new(name);
  endfunction

  task body();
    repeat (n_beats) begin
      req = fifo_transaction::type_id::create("req");
      start_item(req);
      if (!req.randomize() with { rst == 1'b0; })
        `uvm_fatal("fifo_read_write", "random traffic randomization failed")
      finish_item(req);
    end
  endtask
endclass


// -----------------------------------------------------------------------------
// Idle cycles (all enables low) - useful after fill/drain
// -----------------------------------------------------------------------------
class fifo_idle extends fifo_sequence;
  `uvm_object_utils(fifo_idle)

  int unsigned n_beats = 4;

  function new(string name = "fifo_idle");
    super.new(name);
  endfunction

  task body();
    repeat (n_beats) begin
      req = fifo_transaction::type_id::create("req");
      start_item(req);
      if (!req.randomize() with {
            rst   == 1'b0;
            wr_cs == 1'b0;
            wr_en == 1'b0;
            rd_cs == 1'b0;
            rd_en == 1'b0;
          })
        `uvm_fatal("fifo_idle", "idle randomization failed")
      finish_item(req);
    end
  endtask
endclass
