#############################
# User variables
#############################
TB       = top_tb
SEED     = 3
TESTNAME ?= async_fifo_test
DFILES   = ../design/async_fifo.sv
VFILES  += ../uvm_tb_v1/vip_lib/async_fifo_trans.sv \
		   ../uvm_tb_v1/vip_lib/async_fifo_if.sv \
		   ../uvm_tb_v1/vip_lib/async_fifo_cfg.sv \
		   ../uvm_tb_v1/vip_lib/async_fifo_drv.sv \
		   ../uvm_tb_v1/vip_lib/async_fifo_up_mon.sv \
		   ../uvm_tb_v1/vip_lib/async_fifo_down_mon.sv \
	       ../uvm_tb_v1/vip_lib/async_fifo_sqr.sv \
		   ../uvm_tb_v1/vip_lib/async_fifo_up_agt.sv \
		   ../uvm_tb_v1/vip_lib/async_fifo_down_agt.sv \
		   ../uvm_tb_v1/async_fifo_vsqr.sv \
		   ../uvm_tb_v1/async_fifo_scb.sv \
		   ../uvm_tb_v1/async_fifo_rfm.sv \
		   ../uvm_tb_v1/async_fifo_cov.sv \
		   ../uvm_tb_v1/async_fifo_env.sv \
		   ../uvm_tb_v1/seq_lib/async_fifo_write_continuous_seq.sv \
		   ../uvm_tb_v1/seq_lib/async_fifo_read_continuous_seq.sv \
		   ../uvm_tb_v1/seq_lib/async_fifo_full_random_seq.sv \
		   ../uvm_tb_v1/seq_lib/async_fifo_vseq.sv \
		   ../uvm_tb_v1/async_fifo_test.sv \
		   ../uvm_tb_v1/$(TB).sv
INC = +incdir+../uvm_tb_v1/async_fifo_macros 

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
	rm -rf *.log* *.vpd *.h urgReport 64 *.fsdb* *.rc

