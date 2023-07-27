`ifndef ASYNC_FIFO_RFM
`define ASYNC_FIFO_RFM

import uvm_pkg::*;
`include "uvm_macros.svh"

class async_fifo_rfm extends uvm_component;
    
    uvm_blocking_get_port #(up_mon_t) rfm_bg_port;
    uvm_analysis_port #(down_mon_t) rfm_ap;

    `uvm_component_utils(async_fifo_rfm)

    function new(string name = "async_fifo_rfm", uvm_component parent = null);
        super.new(name, parent);
    endfunction: new

    extern function void build_phase(uvm_phase phase); 
    extern function void connect_phase(uvm_phase phase); 
    extern task run_phase(uvm_phase phase);
    extern function void up_mon_data_print(up_mon_t up_mon_data);
    extern function void down_mon_data_print(down_mon_t down_mon_data);
endclass: async_fifo_rfm

function void async_fifo_rfm::build_phase(uvm_phase phase);
    super.build_phase(phase);
    rfm_bg_port = new("rfm_bg_port", this);
    rfm_ap = new("rfm_ap", this);
endfunction: build_phase

function void async_fifo_rfm::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
endfunction: connect_phase

task async_fifo_rfm::run_phase(uvm_phase phase);
    
    mailbox #(bit [`DATAWIDTH-1: 0]) fifo = new(`FIFO_DEPTH);
    up_mon_t up_mon_data_from_up_mon;
    down_mon_t down_mon_data_to_scb;
    bit [`DATAWIDTH-1 :0] temp;

    forever begin
        rfm_bg_port.get(up_mon_data_from_up_mon);
        `uvm_info("async_fifo_rfm", "async_fifo_rfm get a new up_mon_data from up_agt(up_mon), context as below:", UVM_LOW)
        this.up_mon_data_print(up_mon_data_from_up_mon);
        assert(up_mon_data_from_up_mon.is_write != up_mon_data_from_up_mon.is_read)
            else `uvm_fatal("async_fifo_rfm", "illegal up_mon_data_from_up_mon, is_write and is_read are asserted all")
        if(up_mon_data_from_up_mon.is_write) begin
            if(!fifo.try_put(up_mon_data_from_up_mon.wdata))
                `uvm_info("async_fifo_rfm", "fifo mailbox in RFM is full, try_put fail", UVM_LOW)
            down_mon_data_to_scb.is_write = 1;
            down_mon_data_to_scb.is_read = 0;
            down_mon_data_to_scb.full = fifo.num() == `FIFO_DEPTH ? 1 : 0;
            down_mon_data_to_scb.empty = 0;
            down_mon_data_to_scb.almost_full = fifo.num() + 2 >= `FIFO_DEPTH ? 1 : 0;
            down_mon_data_to_scb.almost_empty = 0;
            down_mon_data_to_scb.rdata = 0;
            `uvm_info("async_fifo_rfm",  "down_mon_data_to_scb generate SUCC, context as below:", UVM_LOW)
            this.down_mon_data_print(down_mon_data_to_scb);
            rfm_ap.write(down_mon_data_to_scb);
            `uvm_info("async_fifo_rfm", "down_mon_data_to_scb write into tlm_fifo SUCC", UVM_LOW);
            `uvm_info("async_fifo_rfm", $sformatf("RFM fifo's num is %0d", fifo.num()), UVM_LOW);
        end
        else if(up_mon_data_from_up_mon.is_read) begin
            if(!fifo.try_get(temp)) begin
                `uvm_info("async_fifo_rfm", "fifo mailbox in RFM is empty, try_get fail", UVM_LOW)
                //temp = 0;
            end
            down_mon_data_to_scb.is_write = 0;
            down_mon_data_to_scb.is_read = 1;
            down_mon_data_to_scb.full = 0;
            down_mon_data_to_scb.empty = fifo.num() == 0 ? 1 : 0;
            down_mon_data_to_scb.almost_full = 0;
            down_mon_data_to_scb.almost_empty = fifo.num() <= 2 ? 1 : 0;
            down_mon_data_to_scb.rdata = temp;
            `uvm_info("async_fifo_rfm",  "down_mon_data_to_scb generate SUCC, context as below:", UVM_LOW)
            this.down_mon_data_print(down_mon_data_to_scb);
            rfm_ap.write(down_mon_data_to_scb);
            `uvm_info("async_fifo_rfm",  "down_mon_data_to_scb write into tlm_fifo SUCC", UVM_LOW);
            `uvm_info("async_fifo_rfm", $sformatf("RFM fifo's num is %0d", fifo.num()), UVM_LOW);
        end
        else
            `uvm_fatal("async_fifo_rfm", "up_mon_data_from_up_mon ERROR")
    end
endtask: run_phase

function void async_fifo_rfm::up_mon_data_print(up_mon_t up_mon_data);
    `uvm_info("async_fifo_rfm", "-------------up_mon_data 's context-------------", UVM_LOW)
    `uvm_info("async_fifo_rfm", $sformatf("is_write ----- %0d", up_mon_data.is_write), UVM_LOW)
    `uvm_info("async_fifo_rfm", $sformatf(" is_read ----- %0d", up_mon_data.is_read), UVM_LOW)
    `uvm_info("async_fifo_rfm", $sformatf("   wdata ----- 'h%8h", up_mon_data.wdata), UVM_LOW)
    `uvm_info("async_fifo_rfm", "-------------context show end-------------", UVM_LOW)
endfunction: up_mon_data_print

function void async_fifo_rfm::down_mon_data_print(down_mon_t down_mon_data);
    `uvm_info("async_fifo_rfm", "-------------down_mon_data 's context-------------", UVM_LOW)
    `uvm_info("async_fifo_rfm", $sformatf("is_write ----- %0d", down_mon_data.is_write), UVM_LOW)
    `uvm_info("async_fifo_rfm", $sformatf(" is_read ----- %0d", down_mon_data.is_read), UVM_LOW)
    `uvm_info("async_fifo_rfm", $sformatf("    full ----- %0d", down_mon_data.full), UVM_LOW)
    `uvm_info("async_fifo_rfm", $sformatf("   empty ----- %0d", down_mon_data.empty), UVM_LOW)
    `uvm_info("async_fifo_rfm", $sformatf("almost_full ----- %0d", down_mon_data.almost_full), UVM_LOW)
    `uvm_info("async_fifo_rfm", $sformatf("almost_empty----- %0d", down_mon_data.almost_empty), UVM_LOW)
    `uvm_info("async_fifo_rfm", $sformatf("   rdata ----- 'h%8h", down_mon_data.rdata), UVM_LOW)
    `uvm_info("async_fifo_rfm", "-------------context show end-------------", UVM_LOW)
endfunction: down_mon_data_print


`endif // ASYNC_FIFO_RFM
