//-------------------------------------------------------------
// syn_fifo - Synchronous (single-clock) FIFO
//
// Fixes vs. original:
//   * RAM write is gated by wr_valid so a write-while-full cannot
//     corrupt mem[wr_pointer] (which equals rd_pointer when full).
//   * Simultaneous read+write is allowed when FULL  (count stays).
//   * Simultaneous read+write is NOT allowed when EMPTY (registered
//     read cannot return the data being written this same cycle).
//   * ANSI ports, parameters overridable from the testbench.
//-------------------------------------------------------------
module syn_fifo #(
  parameter DATA_WIDTH = 8,
  parameter ADDR_WIDTH = 8,
  parameter RAM_DEPTH  = (1 << ADDR_WIDTH)
)(
  input  wire                    clk,
  input  wire                    rst,       // async, active-high
  input  wire                    wr_cs,
  input  wire                    rd_cs,
  input  wire [DATA_WIDTH-1:0]   data_in,
  input  wire                    rd_en,
  input  wire                    wr_en,
  output reg  [DATA_WIDTH-1:0]   data_out,
  output wire                    empty,
  output wire                    full
);

  reg  [ADDR_WIDTH-1:0] wr_pointer;
  reg  [ADDR_WIDTH-1:0] rd_pointer;
  reg  [ADDR_WIDTH  :0] status_cnt;
  wire [DATA_WIDTH-1:0] data_ram;

  assign full  = (status_cnt == RAM_DEPTH);
  assign empty = (status_cnt == 0);

  // Legal operations this cycle
  wire wr_valid = wr_cs && wr_en && (!full  || (rd_cs && rd_en));
  wire rd_valid = rd_cs && rd_en &&  !empty;

  always @(posedge clk or posedge rst) begin : WRITE_POINTER
    if (rst)
      wr_pointer <= {ADDR_WIDTH{1'b0}};
    else if (wr_valid)
      wr_pointer <= wr_pointer + 1'b1;
  end

  always @(posedge clk or posedge rst) begin : READ_POINTER
    if (rst)
      rd_pointer <= {ADDR_WIDTH{1'b0}};
    else if (rd_valid)
      rd_pointer <= rd_pointer + 1'b1;
  end

  always @(posedge clk or posedge rst) begin : READ_DATA
    if (rst)
      data_out <= {DATA_WIDTH{1'b0}};
    else if (rd_valid)
      data_out <= data_ram;
  end

  always @(posedge clk or posedge rst) begin : STATUS_COUNTER
    if (rst)
      status_cnt <= {(ADDR_WIDTH+1){1'b0}};
    else if ( rd_valid && !wr_valid)
      status_cnt <= status_cnt - 1'b1;
    else if ( wr_valid && !rd_valid)
      status_cnt <= status_cnt + 1'b1;
    // both valid -> occupancy unchanged
  end

  ram_dp_ar_aw #(
    .DATA_WIDTH (DATA_WIDTH),
    .ADDR_WIDTH (ADDR_WIDTH)
  ) DP_RAM (
    .clk       (clk),
    .address_0 (wr_pointer),
    .data_0    (data_in),
    .cs_0      (wr_valid),   // gate write so full+write cannot corrupt
    .we_0      (wr_valid),
    .oe_0      (1'b0),
    .address_1 (rd_pointer),
    .data_1    (data_ram),
    .cs_1      (1'b1),
    .we_1      (1'b0),
    .oe_1      (1'b1)
  );

endmodule
