`ifndef FIFO_INTERFACE_SV
`define FIFO_INTERFACE_SV

`timescale 1ns/1ps
`include "fifo_defines.svh"

interface fifo_inf (input logic clk);

  logic              rst;
  logic              wr_cs;
  logic              rd_cs;
  logic              wr_en;
  logic              rd_en;
  logic [`DW-1:0]    data_in;
  logic [`DW-1:0]    data_out;
  logic              full;
  logic              empty;

  // LRM default: input #1step (Observed region = post-NBA DUT outputs
  // together with the controls the DUT used this edge), output #0
  // (Re-NBA, so the DUT consumes new values on the NEXT posedge).
  // Access as vif.drv_cb.* / vif.mon_cb.*  -- never vif.DRV.drv_cb.*
  clocking drv_cb @(posedge clk);
    default input #1step output #0;
    output rst;
    output wr_cs;
    output rd_cs;
    output wr_en;
    output rd_en;
    output data_in;
  endclocking

  clocking mon_cb @(posedge clk);
    default input #1step output #0;
    input rst;
    input wr_cs;
    input rd_cs;
    input wr_en;
    input rd_en;
    input data_in;
    input data_out;
    input full;
    input empty;
  endclocking

  modport DRV (clocking drv_cb, input clk);
  modport MON (clocking mon_cb, input clk);

  // ------------- SVA (compiled by VCS with -assert svaext) -------------
  property p_not_full_and_empty;
    @(posedge clk) disable iff (rst) !(full && empty);
  endproperty
  a_not_full_and_empty: assert property (p_not_full_and_empty)
    else $error("FIFO illegal state: full && empty");

  property p_full_no_write_holds;
    @(posedge clk) disable iff (rst)
      (full && wr_cs && wr_en && !(rd_cs && rd_en)) |=> full;
  endproperty
  a_full_hold: assert property (p_full_no_write_holds)
    else $error("full dropped without a read");

  property p_empty_no_read_holds;
    @(posedge clk) disable iff (rst)
      (empty && rd_cs && rd_en && !(wr_cs && wr_en)) |=> empty;
  endproperty
  a_empty_hold: assert property (p_empty_no_read_holds)
    else $error("empty dropped without a write");

endinterface

`endif
