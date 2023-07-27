`ifndef ASYNC_FIFO_ENV
`define ASYNC_FIFO_ENV

import uvm_pkg::*;
`include "uvm_macros.svh"

class async_fifo_env extends uvm_env;
    
    async_fifo_up_agt up_agt;
    async_fifo_down_agt down_agt;
    async_fifo_rfm rfm;
    async_fifo_scb scb;
    async_fifo_vsqr vsqr;
    async_fifo_cov cov;

    uvm_tlm_analysis_fifo #(up_mon_t) up_agt2rfm_fifo;
    uvm_tlm_analysis_fifo #(down_mon_t) down_agt2scb_wr_fifo;
    uvm_tlm_analysis_fifo #(down_mon_t) down_agt2scb_rd_fifo;
    uvm_tlm_analysis_fifo #(down_mon_t) rfm2scb_fifo;

    `uvm_component_utils(async_fifo_env)

    function new(string name = "async_fifo_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction: new

    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);
    extern function void set_if(virtual async_fifo_if vif);

endclass: async_fifo_env

function void async_fifo_env::build_phase(uvm_phase phase);
    super.build_phase(phase);
    up_agt = async_fifo_up_agt::type_id::create("up_agt", this);
    down_agt = async_fifo_down_agt::type_id::create("down_agt", this);
    rfm = async_fifo_rfm::type_id::create("rfm", this);
    scb = async_fifo_scb::type_id::create("scb", this);
    vsqr = async_fifo_vsqr::type_id::create("vsqr", this);
    cov = async_fifo_cov::type_id::create("cov", this);

    up_agt2rfm_fifo = new("up_agt2rfm_fifo", this);
    down_agt2scb_wr_fifo = new("down_agt2scb_wr_fifo", this);
    down_agt2scb_rd_fifo = new("down_agt2scb_rd_fifo", this);
    rfm2scb_fifo = new("rfm2scb_fifo", this);
endfunction: build_phase

function void async_fifo_env::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    up_agt.agt_up_ap.connect(up_agt2rfm_fifo.analysis_export);
    down_agt.agt_down_wr_ap.connect(down_agt2scb_wr_fifo.analysis_export);
    down_agt.agt_down_rd_ap.connect(down_agt2scb_rd_fifo.analysis_export);
    rfm.rfm_ap.connect(rfm2scb_fifo.analysis_export);

    rfm.rfm_bg_port.connect(up_agt2rfm_fifo.blocking_get_export);
    scb.scb_expect_bg_port.connect(rfm2scb_fifo.blocking_get_export);
    scb.scb_actual_wr_bg_port.connect(down_agt2scb_wr_fifo.blocking_get_export);
    scb.scb_actual_rd_bg_port.connect(down_agt2scb_rd_fifo.blocking_get_export);

    vsqr.sqr = up_agt.sqr;
endfunction: connect_phase

function void async_fifo_env::set_if(virtual async_fifo_if vif);
    if(vif == null)
        `uvm_fatal("async_fifo_env", "Could not get valid virtual interface in async_fifo_env")
    else begin
        up_agt.set_if(vif);
        down_agt.set_if(vif);
        cov.set_if(vif);
    end
endfunction: set_if

`endif // ASYNC_FIFO_ENV
