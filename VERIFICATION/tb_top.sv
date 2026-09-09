`timescale 1ns/1ps

`include "uvm_macros.svh"
`include "fifo_defines.svh"

import uvm_pkg::*;
import fifo_tst_pkg::*;

module tb_top;

  bit clk;

  initial clk = 1'b0;
  always #5 clk = ~clk;   // 100 MHz, 10 ns period

  fifo_inf vif (clk);

  syn_fifo #(
    .DATA_WIDTH (`DW),
    .ADDR_WIDTH (`AW)
  ) dut (
    .clk      (vif.clk),
    .rst      (vif.rst),
    .wr_cs    (vif.wr_cs),
    .rd_cs    (vif.rd_cs),
    .wr_en    (vif.wr_en),
    .rd_en    (vif.rd_en),
    .data_in  (vif.data_in),
    .data_out (vif.data_out),
    .full     (vif.full),
    .empty    (vif.empty)
  );

  // VCS boots every 2-state/4-state signal at X. Drive a known reset
  // value at time 0 so the async-reset DUT leaves X immediately.
  initial begin
    vif.rst     = 1'b1;
    vif.wr_cs   = 1'b0;
    vif.rd_cs   = 1'b0;
    vif.wr_en   = 1'b0;
    vif.rd_en   = 1'b0;
    vif.data_in = '0;
  end

  initial begin
    uvm_config_db#(virtual fifo_inf)::set(null, "*", "vif", vif);
    run_test();   // +UVM_TESTNAME=test3
  end

  // Waves: VCD always. FSDB/VPD via +define+DUMP_FSDB / DUMP_VPD
  initial begin
`ifdef DUMP_FSDB
    $fsdbDumpfile("fifo.fsdb");
    $fsdbDumpvars(0, tb_top);
    $fsdbDumpMDA();
`elsif DUMP_VPD
    $vcdplusfile("fifo.vpd");
    $vcdpluson(0, tb_top);
`else
    $dumpfile("fifo.vcd");
    $dumpvars(0, tb_top);
`endif
  end

endmodule
