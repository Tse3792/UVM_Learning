//import uvm_pkg::*;
//`include "uvm_macros.svh"
`ifndef APB_SRAM_AGT
`define APB_SRAM_AGT

import uvm_pkg::*;
`include "uvm_macros.svh"

class apb_sram_agt extends uvm_agent;
    apb_sram_drv drv;
    apb_sram_sqr sqr;
    apb_sram_mon mon;

    `uvm_component_utils(apb_sram_agt)

    //local virtual apb_sram_if vif;
    uvm_analysis_port#(mon_t) ap;

    function new(string name = "apb_sram_agt", uvm_component parent = null);
        super.new(name, parent);
    endfunction: new

    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
    extern function void set_interface(virtual apb_sram_if vif);
    
endclass: apb_sram_agt

function void apb_sram_agt::build_phase(uvm_phase phase);
    super.build_phase(phase);
    drv = apb_sram_drv::type_id::create("drv", this);
    sqr = apb_sram_sqr::type_id::create("sqr", this);
    mon = apb_sram_mon::type_id::create("mon", this);
endfunction: build_phase

function void apb_sram_agt::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    drv.seq_item_port.connect(sqr.seq_item_export);
    `uvm_info(get_type_name(), "drv connect to sqr", UVM_LOW)
    ap = mon.ap;
endfunction: connect_phase

function void apb_sram_agt::set_interface(virtual apb_sram_if vif);
    if(vif == null)
        `uvm_fatal(get_type_name(), "could not get vif handle!")
    else begin
        //this.vif = vif;
        this.drv.set_interface(vif);
        this.mon.set_interface(vif);
    end
endfunction: set_interface

`endif
