#############################
# User variables
#############################
TB       = top_tb
SEED     = 3
TESTNAME ?= apb_sram_test
DFILES   = ../design/{spram.sv,apb_sram.sv}
VFILES  += ../uvm_tb/apb_sram_macros/apb_sram_types.sv \
		   ../uvm_tb/interface/apb_sram_if.sv \
		   ../uvm_tb/trans/apb_sram_trans.sv \
		   ../uvm_tb/property/apb_sram_property.sv \
		   ../uvm_tb/driver/apb_sram_drv.sv \
		   ../uvm_tb/cov/apb_sram_cov.sv \
		   ../uvm_tb/sqr/{apb_sram_sqr.sv,apb_sram_virt_sqr.sv} \
		   ../uvm_tb/seq/{apb_sram_seq.sv,apb_sram_virt_seq.sv} \
		   ../uvm_tb/monitor/apb_sram_mon.sv \
		   ../uvm_tb/agent/apb_sram_agt.sv \
		   ../uvm_tb/scb/apb_sram_scb.sv \
		   ../uvm_tb/rfm/apb_sram_rfm.sv \
		   ../uvm_tb/env/apb_sram_env.sv \
		   ../uvm_tb/test/apb_sram_test.sv \
		   ../uvm_tb/top_tb/$(TB).sv
#VFILES  += ../uvm_tb/apb_sram_macros/apb_sram_types.sv \
		   ../uvm_tb/interface/apb_sram_if.sv \
		   ../uvm_tb/top_tb/apb_sram_test_pkg.sv \
		   ../uvm_tb/top_tb/$(TB).sv
INC = +incdir+../uvm_tb/apb_sram_macros \
	  +incdir+../uvm_tb/interface \
	  +incdir+../uvm_tb/trans \
	  +incdir+../uvm_tb/driver \
	  +incdir+../uvm_tb/sqr \
	  +incdir+../uvm_tb/seq \
	  +incdir+../uvm_tb/monitor \
	  +incdir+../uvm_tb/agent \
	  +incdir+../uvm_tb/scb \
	  +incdir+../uvm_tb/rfm \
	  +incdir+../uvm_tb/env \
	  +incdir+../uvm_tb/test \
	  +incdir+../uvm_tb/top_tb


#############################
# Environment variables
#############################
VCOMP                = vlogan -full64 -ntb_opts uvm-1.2 -sverilog -timescale=1ns/1ps -nc -l comp.log $(INC)
ELAB                 = vcs -full64 -fsdb -ntb_opts uvm-1.2 -debug_all -assertdebug -assertcover -l elab.log -sim_res=1ns -cm line+tgl+branch+fsm+cond+assert -cm_hier cm.cfg
RUN                  = $(TB).simv -l run.log -sml -cm line+tgl+branch -cm_name $(TB)_$(SEED) +ntb_random_seed=$(SEED) +UVM_TESTNAME=$(TESTNAME)

comp:
	$(VCOMP) 
	$(VCOMP) $(DFILES) $(VFILES)

elab: comp
	$(ELAB) -top $(TB) -o $(TB).simv

run:
	$(RUN) 

rung:
	$(RUN) -gui

editcov:
	urg -full64 -format both -dir $(TB).simv.vdb 
	dve -cov -dir $(TB).simv.vdb

# option for exlucde file given to generate coverage report 
# if there is such a coverage exclusion file
# urg -dir ... -elfile filename.el
viewcov:
	urg -full64 -format both -dir $(TB).simv.vdb 
	firefox urgReport/dashboard.html

clean:
	rm -rf AN.DB DVEfiles csrc *.simv *.simv.daidir *.simv.vdb ucli.key verdiLog novas.conf
	rm -rf *.log* *.vpd *.h urgReport 64 *.fsdb *.rc

