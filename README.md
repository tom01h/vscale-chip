### Arty FPGA Board

Boot ROM & Program  
select UART in defines.h (#define SERIAL_DEFAULT_DEVICE 0) in src/main/c/{bootrom,os}
```
cd src/main/c/bootload/
make
cd src/main/c/os/
make
```
Build
```
prepare ../vscale
open ARTY/vscale_chip.xpr by Vivado
Generate bitstream & Program device
```
Set serial terminal
```
19200 bps
data 8bit
parity none
stop 1bit
flow none
```
Run
```
type load & sent src/main/c/os/kozos by XMODEM
type run
```
### Simulation
If verilator 3.882 or earlier, remove "--l2-name v" option in Makefile  
XMODEM (load command) is not supported yet

Boot ROM & Program  
select UART_SIM in defines.h (#define SERIAL_DEFAULT_DEVICE 1) in src/main/c/{bootrom,os}
```
cd src/main/c/bootload/
make
cd src/main/c/os/
make
```
Build & Run
```
make verilator-sim
make verilator-board-test
```
simulation log
```
cp src/main/c/bootload/kzload.ihex loadmem.ihex
touch ram.data3 ram.data2 ram.data1 ram.data0
sim/Vvscale_verilator_top +max-cycles=10000 --vcdfile=tmp.vcd
Running ...
kzload (kozos boot loader) started.
kzload> dump <- TYPE
dump
size: ffffffff
no data.
kzload> run <- TYPE
run
run error!
kzload> aa <- TYPE
aa
unknown.
kzload> q <- TYPE
rm ram.data3 ram.data2 ram.data1 ram.data0
```
