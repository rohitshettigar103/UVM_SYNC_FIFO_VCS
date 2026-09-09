class fifo_monitor extends uvm_monitor;
  `uvm_component_utils(fifo_monitor)

  virtual fifo_inf vif;
  uvm_analysis_port #(fifo_transaction) mon_port;

  function new(string name = "fifo_monitor", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    mon_port = new("mon_port", this);
    if (!uvm_config_db#(virtual fifo_inf)::get(this, "", "vif", vif))
      `uvm_fatal("MON", "virtual interface 'vif' not found in config_db")
  endfunction

  task run_phase(uvm_phase phase);
    fifo_transaction tr;
    forever begin
      tr = fifo_transaction::type_id::create("tr");
      sample(tr);
      `uvm_info("MON", {"Sampled -> ", tr.convert2string()}, UVM_HIGH)
      mon_port.write(tr);
    end
  endtask

  // Sample 1 ns after posedge: DUT NBA (data_out, pointers, status_cnt)
  // has settled, and the driver will not change inputs until the NEGEDGE
  // (5 ns later). Controls and outputs therefore belong to the same cycle.
  // Do not hierarchical-access a modport (vif.MON.xxx) — VCS Error-[VIHIAC].
  task sample(fifo_transaction t);
    @(posedge vif.clk);
    #1ns;
    t.rst      = vif.rst;
    t.wr_cs    = vif.wr_cs;
    t.rd_cs    = vif.rd_cs;
    t.wr_en    = vif.wr_en;
    t.rd_en    = vif.rd_en;
    t.data_in  = vif.data_in;
    t.data_out = vif.data_out;
    t.full     = vif.full;
    t.empty    = vif.empty;
  endtask

endclass
