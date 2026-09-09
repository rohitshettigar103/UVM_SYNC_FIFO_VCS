# VCS / vlogan filelist
# Paths are relative to the project root (the directory that contains DESIGN/ and VERIFICATION/).
# Compile order matters: RAM -> FIFO -> interface -> UVM package -> tb_top

+incdir+VERIFICATION

DESIGN/ram_dp_ar_aw.sv
DESIGN/syn_fifo.sv
VERIFICATION/fifo_interface.sv
VERIFICATION/fifo_tst_pkg.sv
VERIFICATION/tb_top.sv
