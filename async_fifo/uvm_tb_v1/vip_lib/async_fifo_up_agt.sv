`ifndef ASYNC_FIFO_UP_AGT
`define ASYNC_FIFO_UP_AGT

import uvm_pkg::*;
`include "uvm_macros.svh"

class async_fifo_up_agt extends uvm_agent;

    uvm_analysis_port #(up_mon_t) agt_up_ap;

    async_fifo_cfg up_agt_cfg;
    async_fifo_sqr sqr;
    async_fifo_drv drv;
    async_fifo_up_mon up_mon;

    `uvm_component_utils(async_fifo_up_agt)

    function new(string name = "async_fifo_up_agt", uvm_component parent = null);
        super.new(name, parent);
    endfunction: new

    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
    extern function void set_if(virtual async_fifo_if vif);

endclass: async_fifo_up_agt

function void async_fifo_up_agt::build_phase(uvm_phase phase);
    super.build_phase(phase);
    agt_up_ap = new("agt_up_ap", this);
    if(!uvm_config_db#(async_fifo_cfg)::get(this, "", "up_agt_cfg", up_agt_cfg))
        `uvm_fatal("async_fifo_up_agt", "Could not get valid async_fifo_cfg")
    up_mon = async_fifo_up_mon::type_id::create("up_mon", this);
    if(up_agt_cfg.is_active == UVM_ACTIVE) begin
        sqr = async_fifo_sqr::type_id::create("sqr", this);
        drv = async_fifo_drv::type_id::create("drv", this);
    end
endfunction: build_phase

function void async_fifo_up_agt::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if(up_agt_cfg.is_active == UVM_ACTIVE)
        drv.seq_item_port.connect(sqr.seq_item_export);
    agt_up_ap = up_mon.up_mon_ap;
endfunction: connect_phase

function void async_fifo_up_agt::set_if(virtual async_fifo_if vif);
    if(vif == null)
        `uvm_fatal("async_fifo_up_agt", "get a null vif")
    else begin
        this.drv.set_if(vif);
        this.up_mon.set_if(vif);
    end
endfunction: set_if

`endif // ASYNC_FIFO_UP_AGT
