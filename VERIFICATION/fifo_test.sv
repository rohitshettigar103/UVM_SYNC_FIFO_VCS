class fifo_test extends uvm_test;
  `uvm_component_utils(fifo_test)

  fifo_env env;

  function new(string name = "fifo_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = fifo_env::type_id::create("env", this);
  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    `uvm_info("TOPOLOGY", "UVM testbench topology:", UVM_LOW)
    uvm_top.print_topology();
  endfunction

  function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
    uvm_top.set_timeout(5ms);
  endfunction
endclass


// test1 : reset only
class test1 extends fifo_test;
  `uvm_component_utils(test1)

  function new(string name = "test1", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    fifo_rst seq1;
    phase.raise_objection(this);
    `uvm_info("TEST1", "Starting FIFO reset test", UVM_LOW)
    seq1 = fifo_rst::type_id::create("seq1");
    seq1.start(env.agnt.sqr);
    #100ns;
    phase.drop_objection(this);
  endtask
endclass


// test2 : reset + fill (write past DEPTH)
class test2 extends fifo_test;
  `uvm_component_utils(test2)

  function new(string name = "test2", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    fifo_rst   seq1;
    fifo_write seq2;
    phase.raise_objection(this);
    `uvm_info("TEST2", "Starting FIFO write test", UVM_LOW)
    seq1 = fifo_rst::type_id::create("seq1");
    seq1.start(env.agnt.sqr);
    seq2 = fifo_write::type_id::create("seq2");
    seq2.start(env.agnt.sqr);
    #100ns;
    phase.drop_objection(this);
  endtask
endclass


// test3 : reset + fill + drain + random mixed traffic  (default regression)
class test3 extends fifo_test;
  `uvm_component_utils(test3)

  function new(string name = "test3", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    fifo_rst        seq_rst;
    fifo_write      seq_wr;
    fifo_read       seq_rd;
    fifo_read_write seq_rw;
    fifo_idle       seq_idle;

    phase.raise_objection(this);
    `uvm_info("TEST3", "Starting FIFO full regression (rst/write/read/random)", UVM_LOW)

    seq_rst = fifo_rst::type_id::create("seq_rst");
    seq_rst.start(env.agnt.sqr);

    seq_wr = fifo_write::type_id::create("seq_wr");
    seq_wr.start(env.agnt.sqr);

    seq_rd = fifo_read::type_id::create("seq_rd");
    seq_rd.start(env.agnt.sqr);

    seq_rw = fifo_read_write::type_id::create("seq_rw");
    seq_rw.start(env.agnt.sqr);

    seq_idle = fifo_idle::type_id::create("seq_idle");
    seq_idle.start(env.agnt.sqr);

    #100ns;
    phase.drop_objection(this);
  endtask
endclass
