class fifo_env extends uvm_env;
  `uvm_component_utils(fifo_env)

  fifo_agent       agnt;
  fifo_scoreboard  scr;
  fifo_subscriber  sub;

  function new(string name = "fifo_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agnt = fifo_agent::type_id::create("agnt", this);
    scr  = fifo_scoreboard::type_id::create("scr", this);
    sub  = fifo_subscriber::type_id::create("sub", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    agnt.mon.mon_port.connect(scr.in_fifo.analysis_export);
    agnt.mon.mon_port.connect(sub.analysis_export);
  endfunction

endclass
