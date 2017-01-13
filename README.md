Boot ROM & Program
```
cd src/main/c/bootload/
make
cd src/main/c/os/
make
```
build for ARTY
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
type run // NOT YET
```
for simulation
```
make modelsim-sim
cp src/main/c/bootload/kzload.ihex loadmem.ihex
vsim.exe -c work.vscale_hex_tb -lib work -do "add wave -noupdate /vscale_hex_tb/* -recursive;add wave -noupdate /vscale_hex_tb/DUT/chip/vscale/pipeline/regfile/data;run 200ns;quit"
```
