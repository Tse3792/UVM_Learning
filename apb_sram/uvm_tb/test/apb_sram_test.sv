`ifndef APB_SRAM_TEST
`define APB_SRAM_TEST

import uvm_pkg::*;
`include "uvm_macros.svh"

class apb_sram_test extends uvm_test;
    local virtual apb_sram_if vif;

    `uvm_component_utils(apb_sram_test)

    function new(string name = "apb_sram_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction: new

    apb_sram_env env;

    function void set_interface(virtual apb_sram_if vif);
        if(vif == null)
            `uvm_fatal(get_type_name(), "cannot get vif handle")
        else
            this.env.set_interface(vif);
    endfunction: set_interface

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = apb_sram_env::type_id::create("env", this);
        if(!uvm_config_db#(virtual apb_sram_if)::get(this, "", "vif", vif))
            `uvm_fatal(get_type_name(), "cannot get vif handle from config DB")
    endfunction: build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        this.set_interface(this.vif);
    endfunction: connect_phase

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        //super.run_phase(phase);
        
        run_top_virtual_sequence();

        phase.drop_objection(this);
    endtask: run_phase

    virtual task run_top_virtual_sequence();
        apb_sram_virt_seq top_virt_seq = new();
        top_virt_seq.start(env.virt_sqr);
    endtask: run_top_virtual_sequence

endclass: apb_sram_test

`endif
