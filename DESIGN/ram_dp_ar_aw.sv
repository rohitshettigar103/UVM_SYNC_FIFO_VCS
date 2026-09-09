//-------------------------------------------------------------
// Dual-port RAM used by syn_fifo
//   Port 0 : synchronous write  (FIFO write path)
//   Port 1 : asynchronous read  (FIFO read  path)
//
// VCS notes:
//   * ANSI ports (no inout / Z-on-reg) to avoid VCS port-connection errors
//   * Memory initialized to 0 so VCS X-propagation does not poison data_out
//-------------------------------------------------------------
module ram_dp_ar_aw #(
  parameter DATA_WIDTH = 8,
  parameter ADDR_WIDTH = 8,
  parameter RAM_DEPTH  = (1 << ADDR_WIDTH)
)(
  input  wire                    clk,
  input  wire [ADDR_WIDTH-1:0]   address_0,
  input  wire [DATA_WIDTH-1:0]   data_0,
  input  wire                    cs_0,
  input  wire                    we_0,
  input  wire                    oe_0,       // unused (write port)
  input  wire [ADDR_WIDTH-1:0]   address_1,
  output wire [DATA_WIDTH-1:0]   data_1,
  input  wire                    cs_1,
  input  wire                    we_1,       // unused (read  port)
  input  wire                    oe_1
);

  reg [DATA_WIDTH-1:0] mem [0:RAM_DEPTH-1];

  integer i;
  initial begin
    for (i = 0; i < RAM_DEPTH; i = i + 1)
      mem[i] = {DATA_WIDTH{1'b0}};
  end

  // Port 0 : edge-triggered write (samples stable pre-edge values)
  always @(posedge clk) begin
    if (cs_0 && we_0)
      mem[address_0] <= data_0;
  end

  // Port 1 : combinational read (syn_fifo registers data_out itself)
  assign data_1 = (cs_1 && oe_1 && !we_1) ? mem[address_1]
                                          : {DATA_WIDTH{1'b0}};

endmodule
