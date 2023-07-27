`ifndef ASYNC_FIFO_TEST
`define ASYNC_FIFO_TEST

import uvm_pkg::*;
`include "uvm_macros.svh"

class async_fifo_test extends uvm_test;
    
    local virtual async_fifo_if vif;
    async_fifo_env env;
    async_fifo_cfg up_agt_cfg;
    async_fifo_cfg down_agt_cfg;

    `uvm_component_utils(async_fifo_test)

    function new(string name = "async_fifo_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction: new

    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);
    extern function void set_if(virtual async_fifo_if vif);
    extern task run_virtual_sequence();
endclass: async_fifo_test

function void async_fifo_test::build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = async_fifo_env::type_id::create("env", this);
    up_agt_cfg = async_fifo_cfg::type_id::create("up_agt_cfg", this);
    down_agt_cfg = async_fifo_cfg::type_id::create("down_agt_cfg", this);
    up_agt_cfg.is_active = UVM_ACTIVE;
    down_agt_cfg.is_active = UVM_PASSIVE;
    uvm_config_db#(async_fifo_cfg)::set(this, "env.up_agt", "up_agt_cfg", up_agt_cfg);
    uvm_config_db#(async_fifo_cfg)::set(this, "env.down_agt", "down_agt_cfg", down_agt_cfg);
endfunction: build_phase

function void async_fifo_test::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if(!uvm_config_db #(virtual async_fifo_if)::get(this, "", "vif", vif))
        `uvm_fatal("async_fifo_test", "async_fifo_test cannot get vif handle")
    this.set_if(this.vif);
endfunction: connect_phase

function void async_fifo_test::set_if(virtual async_fifo_if vif);
    if(vif == null)
        `uvm_fatal("async_fifo_test", "async_fifo_test cannot get vif handle")
    else
        this.env.set_if(vif);
endfunction: set_if

task async_fifo_test::run_phase(uvm_phase phase);
    phase.raise_objection(this);
    //super.run_phase(phase);
        
    this.run_virtual_sequence();

    phase.drop_objection(this);
endtask: run_phase

task async_fifo_test::run_virtual_sequence();
    async_fifo_vseq vseq = new();
    vseq.start(env.vsqr);
endtask: run_virtual_sequence

`endif // ASYNC_FIFO_TEST
