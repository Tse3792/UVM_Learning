`ifndef APB_SRAM_MON
`define APB_SRAM_MON

import uvm_pkg::*;
`include "uvm_macros.svh"

class apb_sram_mon extends uvm_monitor;
    local virtual apb_sram_if vif;
    uvm_analysis_port#(mon_t) ap;

    `uvm_component_utils(apb_sram_mon)

    function new(string name = "apb_sram_mon", uvm_component parent = null);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction: new

    extern function void set_interface(virtual apb_sram_if vif);
    extern task run_phase(uvm_phase phase);
    extern task collect_if_signal();

endclass: apb_sram_mon

function void apb_sram_mon::set_interface(virtual apb_sram_if vif);
    if(vif == null)
        `uvm_fatal(get_type_name(), "could not get vif handle!")
    else
        this.vif = vif;
endfunction: set_interface

task apb_sram_mon::run_phase(uvm_phase phase);
    this.collect_if_signal();
endtask: run_phase

task apb_sram_mon::collect_if_signal();
    mon_t mon_data;
    forever begin
        @(posedge vif.pclk iff(vif.rstn===1'b1 && vif.mon_ck.psel===1'b1 && vif.mon_ck.penable===1'b1 && vif.mon_ck.pready===1'b1));
        if(vif.mon_ck.pwrite) begin
            mon_data.data = vif.mon_ck.pwdata;
            mon_data.write = 1;
            mon_data.addr = vif.mon_ck.paddr;
        end
        else begin
            mon_data.data = vif.mon_ck.prdata;
            mon_data.write = 0;
            mon_data.addr = vif.mon_ck.paddr;
        end
        ap.write(mon_data);
        `uvm_info(get_type_name(), $sformatf("monitored data 'h%8x , direction is %0d(1 is write, 0 is read)", mon_data.data, mon_data.write), UVM_HIGH)
    end
endtask: collect_if_signal

`endif
