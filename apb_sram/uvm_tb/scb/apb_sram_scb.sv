`ifndef APB_SRAM_SCB
`define APB_SRAM_SCB

import uvm_pkg::*;
`include "uvm_macros.svh"

class apb_sram_scb extends uvm_scoreboard;
    uvm_blocking_get_port#(mon_t) bg_port_expect;
    uvm_blocking_get_port#(mon_t) bg_port_actual;


    `uvm_component_utils(apb_sram_scb)

    function new(string name = "apb_sram_scb", uvm_component parent = null);
        super.new(name, parent);
    endfunction: new

    extern function void build_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);
    
endclass: apb_sram_scb

function void apb_sram_scb::build_phase(uvm_phase phase);
    super.build_phase(phase);
    bg_port_expect = new("bg_port_expect", this);
    bg_port_actual = new("bg_port_actual", this);
endfunction: build_phase

task apb_sram_scb::run_phase(uvm_phase phase);
    mon_t expect_data;
    mon_t actual_data;

    forever begin
        bg_port_expect.get(expect_data);
        bg_port_actual.get(actual_data);
        if(expect_data.write == 1 && actual_data.write == 1) begin
            if(expect_data.data == actual_data.data && expect_data.addr == actual_data.addr)
                `uvm_info(get_type_name(), "It is write item, jump over this item, compare successfully!", UVM_LOW)
            else
                `uvm_fatal(get_type_name(), "[ERROR] write item 's context is different!")
        end
        else if (expect_data.write == 0 && actual_data.write == 0) begin
            if(expect_data.data == actual_data.data && expect_data.addr == actual_data.addr)
                `uvm_info(get_type_name(), "It is read item, compare successfully!", UVM_LOW)
            else
                `uvm_fatal(get_type_name(), "[ERROR] read item 's context is different!")
        end
        else
            `uvm_fatal(get_type_name(), "read write type mismatch, compare ERROR")
    end

endtask: run_phase

`endif
