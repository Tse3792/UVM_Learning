`ifndef APB_SRAM_RFM
`define APB_SRAM_RFM

import uvm_pkg::*;
`include "uvm_macros.svh"

class apb_sram_rfm extends uvm_component;
    uvm_blocking_get_port#(mon_t) bg_port;
    uvm_analysis_port#(mon_t) ap;

    `uvm_component_utils(apb_sram_rfm)

    function new(string name = "apb_sram_rfm", uvm_component parent = null);
        super.new(name, parent);
    endfunction: new

    extern function void build_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);
    extern function mon_t mon_t_copy(mon_t mon_data);
    extern function void mon_t_print(mon_t mon_data);

endclass: apb_sram_rfm

function void apb_sram_rfm::build_phase(uvm_phase phase);
    super.build_phase(phase);
    bg_port = new("bg_port", this);
    ap = new("ap", this);
endfunction: build_phase

task apb_sram_rfm::run_phase(uvm_phase phase);
    mon_t mon_data_from_mon;
    mon_t mon_data_to_scb;

    bit [`DATAWIDTH-1:0] mem [bit [$clog2(`RAM_DEPTH)-1:0]];

    forever begin
        bg_port.get(mon_data_from_mon);
        this.mon_t_print(mon_data_from_mon);
        if(mon_data_from_mon.write == 1) begin
            mem[mon_data_from_mon.addr] = mon_data_from_mon.data;
            `uvm_info(get_type_name(), $sformatf("write op : mem[%2h] = %8h", mon_data_from_mon.addr, mon_data_from_mon.data), UVM_LOW)
            mon_data_to_scb = this.mon_t_copy(mon_data_from_mon);
            ap.write(mon_data_to_scb);
        end
        else begin
            mon_data_to_scb.data = mem[mon_data_from_mon.addr];
            mon_data_to_scb.write = 0;
            mon_data_to_scb.addr = mon_data_from_mon.addr;
            `uvm_info(get_type_name(), $sformatf("read op : data %8h read from mem[%2h]", mem[mon_data_from_mon.addr], mon_data_from_mon.addr), UVM_LOW)
            ap.write(mon_data_to_scb);
        end
    end
endtask: run_phase

function mon_t apb_sram_rfm::mon_t_copy(mon_t mon_data);
    mon_t temp;
    temp.data = mon_data.data;
    temp.write = mon_data.write;
    temp.addr = mon_data.addr;
    return temp;
endfunction: mon_t_copy

function void apb_sram_rfm::mon_t_print(mon_t mon_data);
    `uvm_info(get_type_name(), "============== mon_data's context from monitor is as below: ==============", UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("data is %8h \n write is %0b \n addr is %2h", mon_data.data, mon_data.write, mon_data.addr), UVM_LOW)
    `uvm_info(get_type_name(), "============== mon_data's context show end ==============", UVM_LOW)
endfunction: mon_t_print

`endif
