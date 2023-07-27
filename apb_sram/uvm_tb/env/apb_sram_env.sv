`ifndef APB_SRAM_ENV
`define APB_SRAM_ENV

import uvm_pkg::*;
`include "uvm_macros.svh"

class apb_sram_env extends uvm_env;
    apb_sram_agt agt;
    apb_sram_rfm rfm;
    apb_sram_scb scb;
    apb_sram_virt_sqr virt_sqr;
    apb_sram_cov cov;

    uvm_tlm_analysis_fifo#(mon_t) agt2rfm_fifo;
    uvm_tlm_analysis_fifo#(mon_t) agt2scb_fifo;
    uvm_tlm_analysis_fifo#(mon_t) rfm2scb_fifo;

    `uvm_component_utils(apb_sram_env)
    
    function new(string name = "apb_sram_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction: new

    extern function void set_interface(virtual apb_sram_if vif);
    extern virtual function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);

endclass: apb_sram_env

function void apb_sram_env::set_interface(virtual apb_sram_if vif);
    if(vif == null)
        `uvm_fatal(get_type_name(), "could not get vif handle!")
    else begin
        //`uvm_info(get_type_name(), "send vif handle to agt and cov!", UVM_LOW)
        this.agt.set_interface(vif);
        this.cov.set_interface(vif);
    end
endfunction: set_interface

function void apb_sram_env::build_phase(uvm_phase phase);
    super.build_phase(phase);
    agt = apb_sram_agt::type_id::create("agt", this);
    rfm = apb_sram_rfm::type_id::create("rfm", this);
    scb = apb_sram_scb::type_id::create("scb", this);
    virt_sqr = apb_sram_virt_sqr::type_id::create("virt_sqr", this);
    cov = apb_sram_cov::type_id::create("cov", this);

    agt2rfm_fifo = new("agt2rfm_fifo", this);
    agt2scb_fifo = new("agt2scb_fifo", this);
    rfm2scb_fifo = new("rfm2scb_fifo", this);
endfunction: build_phase

function void apb_sram_env::connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    agt.ap.connect(agt2rfm_fifo.analysis_export);
    rfm.bg_port.connect(agt2rfm_fifo.blocking_get_export);

    agt.ap.connect(agt2scb_fifo.analysis_export);
    scb.bg_port_actual.connect(agt2scb_fifo.blocking_get_export);

    rfm.ap.connect(rfm2scb_fifo.analysis_export);
    scb.bg_port_expect.connect(rfm2scb_fifo.blocking_get_export);

    virt_sqr.sqr = agt.sqr;
endfunction: connect_phase

`endif
