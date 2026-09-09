# VERIFICATION

UVM-1.2 testbench, compiled as a single package (`fifo_tst_pkg`) plus
`fifo_interface` and `tb_top`.

```
fifo_tst_pkg
 ├── fifo_transaction
 ├── fifo_sequence  (fifo_rst, fifo_write, fifo_read, fifo_read_write, fifo_idle)
 ├── fifo_sequencer
 ├── fifo_driver        virtual fifo_inf  (vif.drv_cb)
 ├── fifo_monitor       virtual fifo_inf  (vif.mon_cb)  --> analysis port
 ├── fifo_agent
 ├── fifo_scoreboard    uvm_tlm_analysis_fifo golden queue
 ├── fifo_subscriber    covergroup fifo_cg
 ├── fifo_env
 └── fifo_test / test1 / test2 / test3
```

Do **not** add the class `.sv` files to `filelist.f` — they are
`` `include ``'d from `fifo_tst_pkg.sv`. Adding them on the VCS command
line causes `package/class already defined` errors.
