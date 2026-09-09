class fifo_subscriber extends uvm_subscriber #(fifo_transaction);
  `uvm_component_utils(fifo_subscriber)

  bit           rst_v, wr_cs_v, wr_en_v, rd_cs_v, rd_en_v, full_v, empty_v;
  bit [`DW-1:0] data_in_v, data_out_v;

  covergroup fifo_cg;
    option.per_instance = 1;
    option.name         = "fifo_cg";

    WR_CS : coverpoint wr_cs_v { bins b0 = {0}; bins b1 = {1}; }
    WR_EN : coverpoint wr_en_v { bins b0 = {0}; bins b1 = {1}; }
    RD_CS : coverpoint rd_cs_v { bins b0 = {0}; bins b1 = {1}; }
    RD_EN : coverpoint rd_en_v { bins b0 = {0}; bins b1 = {1}; }
    FULL  : coverpoint full_v  { bins b0 = {0}; bins b1 = {1}; }
    EMPTY : coverpoint empty_v { bins b0 = {0}; bins b1 = {1}; }
    RST   : coverpoint rst_v   { bins b0 = {0}; bins b1 = {1}; }

    DATA_IN : coverpoint data_in_v {
      bins zero    = {0};
      bins max_val = {8'hFF};
      bins low     = {[8'h01:8'h3F]};
      bins mid     = {[8'h40:8'hBF]};
      bins high    = {[8'hC0:8'hFE]};
    }

    WR_FULL : cross WR_CS, WR_EN, FULL {
      bins write_while_full =
        binsof(WR_CS) intersect {1} &&
        binsof(WR_EN) intersect {1} &&
        binsof(FULL)  intersect {1};
    }

    RD_EMPTY : cross RD_CS, RD_EN, EMPTY {
      bins read_while_empty =
        binsof(RD_CS) intersect {1} &&
        binsof(RD_EN) intersect {1} &&
        binsof(EMPTY) intersect {1};
    }

    RD_WR : cross RD_CS, WR_CS {
      bins read_only  = binsof(RD_CS) intersect {1} && binsof(WR_CS) intersect {0};
      bins write_only = binsof(RD_CS) intersect {0} && binsof(WR_CS) intersect {1};
      bins both       = binsof(RD_CS) intersect {1} && binsof(WR_CS) intersect {1};
      bins neither    = binsof(RD_CS) intersect {0} && binsof(WR_CS) intersect {0};
    }

    FULL_EMPTY : cross FULL, EMPTY {
      bins full_nempty = binsof(FULL)  intersect {1} && binsof(EMPTY) intersect {0};
      bins empty_nfull = binsof(EMPTY) intersect {1} && binsof(FULL)  intersect {0};
      illegal_bins both_set =
        binsof(FULL) intersect {1} && binsof(EMPTY) intersect {1};
    }

    RST_CROSS : cross RST, WR_CS, RD_CS;
  endgroup

  function new(string name = "fifo_subscriber", uvm_component parent = null);
    super.new(name, parent);
    fifo_cg = new();
  endfunction

  function void write(fifo_transaction t);
    rst_v      = t.rst;
    wr_cs_v    = t.wr_cs;
    wr_en_v    = t.wr_en;
    rd_cs_v    = t.rd_cs;
    rd_en_v    = t.rd_en;
    full_v     = t.full;
    empty_v    = t.empty;
    data_in_v  = t.data_in;
    data_out_v = t.data_out;
    fifo_cg.sample();
  endfunction

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("SUB",
      $sformatf("Functional Coverage = %0.2f%%", fifo_cg.get_coverage()),
      UVM_LOW)
  endfunction

endclass
