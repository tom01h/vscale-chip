SHELL = /bin/bash

VSCALE_DIR = ../vscale

include $(VSCALE_DIR)/Makefrag

V_CORE_DIR = $(VSCALE_DIR)/src/main/verilog

V_SRC_DIR = src/main/verilog

V_TEST_DIR = src/test/verilog

CXX_TEST_DIR = src/test/cxx

SIM_DIR = sim

MEM_DIR = $(VSCALE_DIR)/src/test/inputs

OUT_DIR = output

MODELSIM_DIR = work

VLOG = vlog.exe
VLOG_OPTS = +incdir+$(V_CORE_DIR)
VLIB = vlib.exe
VSIM = vsim.exe
VSIM_OPTS = -c work.vscale_hex_tb -lib work -do " \
	add wave -noupdate /vscale_hex_tb/* -recursive; \
	add wave -noupdate /vscale_hex_tb/DUT/chip/vscale/pipeline/regfile/data; \
	add wave -noupdate /vscale_hex_tb/DUT/chip/vscale/pipeline/fregfile/data; \
	run 30ns; quit"

VERILATOR = verilator

VERILATOR_OPTS = \
	-Wall \
	-Wno-WIDTH \
	-Wno-UNUSED \
	-Wno-BLKSEQ \
	--cc \
	-I$(V_CORE_DIR) \
	+1364-2001ext+v \
	-Wno-fatal \
	--Mdir sim \
	--trace \
	--l2-name v \

VERILATOR_MAKE_OPTS = OPT_FAST="-O3"

VCS = vcs -full64

VCS_OPTS = -PP -notice -line +lint=all,noVCDE,noUI +v2k -timescale=1ns/10ps -quiet \
	+define+DEBUG -debug_pp \
	+incdir+$(V_SRC_DIR) -Mdirectory=$(SIM_DIR)/csrc \
	+vc+list -CC "-I$(VCS_HOME)/include" \
	-CC "-std=c++11" \

MAX_CYCLES = 180000

SIMV_OPTS = -k $(OUT_DIR)/ucli.key -q

CORE_SRCS = $(addprefix $(V_CORE_DIR)/, \
vscale_core.v \
vscale_hasti_bridge.v \
vscale_pipeline.v \
vscale_ctrl.v \
vscale_regfile.v \
vscale_fregfile.v \
vscale_imm_gen.v \
vscale_alu.v \
vscale_mul_div.v \
vscale_csr_file.v \
vscale_PC_mux.v \
)

DESIGN_SRCS = $(addprefix $(V_SRC_DIR)/, \
vscale_chip.v \
vscale_xbar.v \
ahbmem.v \
uart_sim.v \
uart/sasc_brg.v \
uart/sasc_fifo4.v \
uart/sasc_top.v \
uart/uart.v \
)
SIM_SRCS = $(addprefix $(V_TEST_DIR)/, \
vscale_sim_top.v \
)

VCS_TOP = $(V_TEST_DIR)/vscale_hex_tb.v

VERILATOR_CPP_TB = $(CXX_TEST_DIR)/vscale_hex_tb.cpp

VERILATOR_TOP = $(V_TEST_DIR)/vscale_verilator_top.sv

MODELSIM_TOP = $(V_TEST_DIR)/vscale_hex_tb_modelsim.sv

HDRS = $(addprefix $(V_CORE_DIR)/, \
vscale_ctrl_constants.vh \
rv32_opcodes.vh \
vscale_alu_ops.vh \
vscale_md_constants.vh \
vscale_hasti_constants.vh \
vscale_csr_addr_map.vh \
)

TEST_VPD_FILES = $(addprefix $(OUT_DIR)/,$(addsuffix .vpd,$(RV32_TESTS)))

VERILATOR_VCD_FILES = $(addprefix $(OUT_DIR)/,$(addsuffix .verilator.vcd,$(RV32_TESTS)))

MODELSIM_WLF_FILES = $(addprefix $(OUT_DIR)/,$(addsuffix .wlf,$(RV32_TESTS)))

default: $(SIM_DIR)/simv

run-asm-tests: $(TEST_VPD_FILES)

verilator-sim: $(SIM_DIR)/Vvscale_verilator_top

verilator-run-asm-tests: $(VERILATOR_VCD_FILES)

verilator-board-test: tmp.vcd

modelsim-sim: $(MODELSIM_DIR) $(MODELSIM_DIR)/_vmake

modelsim-run-asm-tests: $(MODELSIM_WLF_FILES)

$(OUT_DIR)/%.vpd: $(MEM_DIR)/%.hex $(SIM_DIR)/simv
	mkdir -p output
	$(SIM_DIR)/simv $(SIMV_OPTS) +max-cycles=$(MAX_CYCLES) +loadmem=$< +vpdfile=$@ && [ $$PIPESTATUS -eq 0 ]

tmp.vcd: src/main/c/bootload/kzload.ihex $(SIM_DIR)/Vvscale_verilator_top
	cp src/main/c/bootload/kzload.ihex loadmem.ihex
	cp src/main/c/os/kozos xmodem.dat
	touch ram.data3 ram.data2 ram.data1 ram.data0
	$(SIM_DIR)/Vvscale_verilator_top +max-cycles=$(MAX_CYCLES) --vcdfile=$@
	rm ram.data3 ram.data2 ram.data1 ram.data0

$(OUT_DIR)/%.verilator.vcd: $(MEM_DIR)/%.ihex $(SIM_DIR)/Vvscale_verilator_top
	mkdir -p output
	cp $< loadmem.ihex
	touch ram.data3 ram.data2 ram.data1 ram.data0
	$(SIM_DIR)/Vvscale_verilator_top +max-cycles=$(MAX_CYCLES) --vcdfile=$@ > log
	mv log $@.log
	rm ram.data3 ram.data2 ram.data1 ram.data0

$(OUT_DIR)/%.wlf: $(MEM_DIR)/%.ihex $(MODELSIM_DIR)/_vmake
	mkdir -p output
	cp $< loadmem.ihex
	$(VSIM) $(VSIM_OPTS)
	mv transcript $@.log
	mv vsim.wlf $@

$(SIM_DIR)/simv: $(VCS_TOP) $(SIM_SRCS) $(DESIGN_SRCS) $(CORE_SRCS) $(HDRS)
	mkdir -p sim
	$(VCS) $(VCS_OPTS) -o $@ $(VCS_TOP) $(SIM_SRCS) $(DESIGN_SRCS) $(CORE_SRCS)

$(SIM_DIR)/Vvscale_verilator_top: $(VERILATOR_TOP) $(SIM_SRCS) $(DESIGN_SRCS) $(CORE_SRCS) $(HDRS) $(VERILATOR_CPP_TB)
	$(VERILATOR) $(VERILATOR_OPTS) $(VERILATOR_TOP) $(SIM_SRCS) $(DESIGN_SRCS) $(CORE_SRCS) --exe ../$(VERILATOR_CPP_TB)
	cd sim; make $(VERILATOR_MAKE_OPTS) -f Vvscale_verilator_top.mk Vvscale_verilator_top__ALL.a
	cd sim; make $(VERILATOR_MAKE_OPTS) -f Vvscale_verilator_top.mk Vvscale_verilator_top

$(MODELSIM_DIR):
	$(VLIB) $(MODELSIM_DIR)

$(MODELSIM_DIR)/_vmake: $(MODELSIM_TOP) $(SIM_SRCS) $(DESIGN_SRCS) $(CORE_SRCS) $(MODELSIM_DIR)
	$(VLOG) $(VLOG_OPTS) $(MODELSIM_TOP) $(SIM_SRCS) $(DESIGN_SRCS) $(CORE_SRCS)

clean:
	rm -rf $(SIM_DIR)/* $(OUT_DIR)/* $(MODELSIM_DIR) tmp.vcd loadmem.ihex xmodem.dat

.PHONY: clean run-asm-tests verilator-run-asm-tests
