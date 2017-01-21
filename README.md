Boot ROM & Program
```
cd src/main/c/bootload/
make
cd src/main/c/os/
make
```
build for ARTY (57776)
```
prepare ../vscale
open ARTY/vscale_chip.xpr by Vivado
Generate bitstream & Program device
```
set serial terminal
```
19200 bps
data 8bit
parity none
stop 1bit
flow none
```
run on ARTY
```
type load & sent src/main/c/os/kozos by XMODEM
type run
```
for simulation (verilator) (load is not supported yet)
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
