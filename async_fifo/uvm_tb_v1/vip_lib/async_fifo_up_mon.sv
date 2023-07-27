`ifndef ASYNC_FIFO_UP_MON
`define ASYNC_FIFO_UP_MON

import uvm_pkg::*;
`include "uvm_macros.svh"

class async_fifo_up_mon extends uvm_monitor;

    local virtual async_fifo_if vif;
    uvm_analysis_port #(up_mon_t) up_mon_ap;

    `uvm_component_utils(async_fifo_up_mon)

    function new(string name = "async_fifo_up_mon", uvm_component parent = null);
        super.new(name, parent);
    endfunction: new
    
    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
    extern function void set_if(virtual async_fifo_if vif);
    extern task run_phase(uvm_phase phase);
    extern task collect_up_sig();

endclass: async_fifo_up_mon

function void async_fifo_up_mon::build_phase(uvm_phase phase);
    super.build_phase(phase);
    up_mon_ap = new("up_mon_ap", this);
endfunction: build_phase

function void async_fifo_up_mon::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
endfunction: connect_phase

function void async_fifo_up_mon::set_if(virtual async_fifo_if vif);
    if(vif == null)
        `uvm_fatal("async_fifo_up_mon", "get a null vif")
    else
        this.vif = vif;
endfunction: set_if

task async_fifo_up_mon::run_phase(uvm_phase phase);
    fork
        @(posedge vif.wrstn);
        @(posedge vif.rrstn);
        `uvm_info("async_fifo_up_mon", "wait until two reset sigs release, up_monitor start to collect sigs", UVM_LOW)
    join
    this.collect_up_sig();
endtask: run_phase

task async_fifo_up_mon::collect_up_sig();
    up_mon_t    up_mon_data_wr;
    up_mon_t    up_mon_data_rd;
    `uvm_info("async_fifo_up_mon", "async_fifo_up_mon start to mon sig", UVM_LOW)
    forever begin  
        fork begin   // guard fork
            fork: mon_up_data_two_thread
                begin // mon wr
                    @(posedge vif.wclk iff(vif.wrstn === 1 && vif.wr_mon_ck.fifo_wr === 1));
                    up_mon_data_wr.is_write = vif.wr_mon_ck.fifo_wr;
                    up_mon_data_wr.is_read = 0;
                    up_mon_data_wr.wdata = vif.wr_mon_ck.fifo_din;
                    up_mon_ap.write(up_mon_data_wr);
                end
                begin // mon rd
                    @(posedge vif.rclk iff(vif.rrstn === 1 && vif.rd_mon_ck.fifo_rd === 1));
                    up_mon_data_rd.is_write = 0;
                    up_mon_data_rd.is_read = vif.rd_mon_ck.fifo_rd;
                    up_mon_data_rd.wdata = 0;
                    up_mon_ap.write(up_mon_data_rd);
                end
            join_any
            disable mon_up_data_two_thread;
        end join
        `uvm_info("async_fifo_up_mon", "async_fifo_up_mon monite one up_mon_data and write into fifo", UVM_LOW)
    end
endtask: collect_up_sig

`endif // ASYNC_FIFO_UP_MON
