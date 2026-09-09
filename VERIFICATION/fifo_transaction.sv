class fifo_transaction extends uvm_sequence_item;

  rand bit           rst;
  rand bit           wr_cs;
  rand bit           rd_cs;
  rand bit           wr_en;
  rand bit           rd_en;
  rand bit [`DW-1:0] data_in;

  logic [`DW-1:0]    data_out;
  logic              full;
  logic              empty;

  constraint c_rst_off {
    soft rst == 1'b0;
  }

  constraint c_cs_dist {
    soft wr_cs dist { 1 := 90, 0 := 10 };
    soft rd_cs dist { 1 := 90, 0 := 10 };
  }

  `uvm_object_utils_begin(fifo_transaction)
    `uvm_field_int(rst,      UVM_ALL_ON)
    `uvm_field_int(wr_cs,    UVM_ALL_ON)
    `uvm_field_int(rd_cs,    UVM_ALL_ON)
    `uvm_field_int(wr_en,    UVM_ALL_ON)
    `uvm_field_int(rd_en,    UVM_ALL_ON)
    `uvm_field_int(data_in,  UVM_ALL_ON)
    `uvm_field_int(data_out, UVM_ALL_ON)
    `uvm_field_int(full,     UVM_ALL_ON)
    `uvm_field_int(empty,    UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "fifo_transaction");
    super.new(name);
  endfunction

  function string convert2string();
    return $sformatf("rst=%0b wr_cs=%0b wr_en=%0b rd_cs=%0b rd_en=%0b din=0x%02h dout=0x%02h full=%0b empty=%0b",
                     rst, wr_cs, wr_en, rd_cs, rd_en, data_in, data_out, full, empty);
  endfunction

endclass
