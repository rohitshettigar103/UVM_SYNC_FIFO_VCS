class fifo_driver extends uvm_driver #(fifo_transaction);
  `uvm_component_utils(fifo_driver)

  virtual fifo_inf vif;

  function new(string name = "fifo_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual fifo_inf)::get(this, "", "vif", vif))
      `uvm_fatal("DRV", "virtual interface 'vif' not found in config_db")
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(req);
      drive(req);
      seq_item_port.item_done();
    end
  endtask

  // Drive on NEGEDGE so values are stable well before the next posedge
  // that the DUT and monitor use. Do not hierarchical-access a modport
  // (vif.DRV.xxx) — VCS reports Error-[VIHIAC].
  task drive(fifo_transaction tr);
    @(negedge vif.clk);
    vif.rst     <= tr.rst;
    vif.wr_cs   <= tr.wr_cs;
    vif.rd_cs   <= tr.rd_cs;
    vif.wr_en   <= tr.wr_en;
    vif.rd_en   <= tr.rd_en;
    vif.data_in <= tr.data_in;
  endtask

endclass
