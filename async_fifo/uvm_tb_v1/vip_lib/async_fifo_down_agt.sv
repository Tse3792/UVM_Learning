`ifndef ASYNC_FIFO_DOWN_AGT
`define ASYNC_FIFO_DOWN_AGT

import uvm_pkg::*;
`include "uvm_macros.svh"

class async_fifo_down_agt extends uvm_agent;

    uvm_analysis_port #(down_mon_t) agt_down_wr_ap;
    uvm_analysis_port #(down_mon_t) agt_down_rd_ap;

    async_fifo_cfg down_agt_cfg;
    async_fifo_sqr sqr;
    async_fifo_drv drv;
    async_fifo_down_mon down_mon;

    `uvm_component_utils(async_fifo_down_agt)

    function new(string name = "async_fifo_down_agt", uvm_component parent = null);
        super.new(name, parent);
    endfunction: new

    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
    extern function void set_if(virtual async_fifo_if vif);

endclass: async_fifo_down_agt

function void async_fifo_down_agt::build_phase(uvm_phase phase);
    super.build_phase(phase);
    agt_down_wr_ap = new("agt_down_wr_ap", this);
    agt_down_rd_ap = new("agt_down_rd_ap", this);
    if(!uvm_config_db#(async_fifo_cfg)::get(this, "", "down_agt_cfg", down_agt_cfg))
        `uvm_fatal("async_fifo_down_agt", "Could not get valid async_fifo_cfg")
    down_mon = async_fifo_down_mon::type_id::create("down_mon", this);
    if(down_agt_cfg.is_active == UVM_ACTIVE) begin
        sqr = async_fifo_sqr::type_id::create("sqr", this);
        drv = async_fifo_drv::type_id::create("drv", this);
    end
endfunction: build_phase

function void async_fifo_down_agt::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if(down_agt_cfg.is_active == UVM_ACTIVE)
        drv.seq_item_port.connect(sqr.seq_item_export);
    agt_down_wr_ap = down_mon.down_mon_wr_ap;
    agt_down_rd_ap = down_mon.down_mon_rd_ap;
endfunction: connect_phase

function void async_fifo_down_agt::set_if(virtual async_fifo_if vif);
    if(vif == null)
        `uvm_fatal("async_fifo_down_agt", "get a null vif")
    else begin
        if(down_agt_cfg.is_active == UVM_ACTIVE)
            this.drv.set_if(vif);
        this.down_mon.set_if(vif);
    end
endfunction: set_if

`endif // ASYNC_FIFO_DOWN_AGT
