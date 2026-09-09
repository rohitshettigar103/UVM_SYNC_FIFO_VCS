# DESIGN - Synchronous FIFO

| File              | Description                                      |
|-------------------|--------------------------------------------------|
| `syn_fifo.sv`     | Single-clock FIFO (status-count architecture)    |
| `ram_dp_ar_aw.sv` | Dual-port RAM: sync write, async read            |

## Parameters

| Name        | Default | Overridden from TB |
|-------------|---------|--------------------|
| DATA_WIDTH  | 8       | `DW` = 8           |
| ADDR_WIDTH  | 8       | `AW` = 2 (DEPTH=4) |

## Ports

`clk, rst, wr_cs, rd_cs, wr_en, rd_en, data_in[7:0], data_out[7:0], full, empty`

- `rst` is **asynchronous, active-high**
- A write commits only when `wr_cs & wr_en & (!full | read_this_cycle)`
- A read  commits only when `rd_cs & rd_en & !empty`
- `data_out` is **registered** (updated on the read clock edge)
