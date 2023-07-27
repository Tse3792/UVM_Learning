`ifndef ASYNC_FIFO_DOWN_MON
`define ASYNC_FIFO_DOWN_MON

import uvm_pkg::*;
`include "uvm_macros.svh"

class async_fifo_down_mon extends uvm_monitor;

    local virtual async_fifo_if vif;
    uvm_analysis_port #(down_mon_t) down_mon_wr_ap;
    uvm_analysis_port #(down_mon_t) down_mon_rd_ap;

    `uvm_component_utils(async_fifo_down_mon)

    function new(string name = "async_fifo_down_mon", uvm_component parent = null);
        super.new(name, parent);
    endfunction: new
    
    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
    extern function void set_if(virtual async_fifo_if vif);
    extern task run_phase(uvm_phase phase);
    extern task collect_down_sig();
    extern function void print_down_mon_data(down_mon_t down_mon_data);
endclass: async_fifo_down_mon

function void async_fifo_down_mon::build_phase(uvm_phase phase);
    super.build_phase(phase);
    down_mon_wr_ap = new("down_mon_wr_ap", this);
    down_mon_rd_ap = new("down_mon_rd_ap", this);
endfunction: build_phase

function void async_fifo_down_mon::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
endfunction: connect_phase

function void async_fifo_down_mon::set_if(virtual async_fifo_if vif);
    if(vif == null)
        `uvm_fatal("async_fifo_down_mon", "get a null vif")
    else
        this.vif = vif;
endfunction: set_if

task async_fifo_down_mon::run_phase(uvm_phase phase);
    /*fork
        @(posedge vif.wrstn);
        @(posedge vif.rrstn);
        `uvm_info("async_fifo_down_mon", "wait until two reset sigs release, down_monitor start to collect sigs", UVM_LOW)
    join*/
    this.collect_down_sig();
endtask: run_phase

task async_fifo_down_mon::collect_down_sig();
    down_mon_t    down_mon_data_wr;
    down_mon_t    down_mon_data_rd;
    `uvm_info("async_fifo_down_mon", "async_fifo_down_mon start to mon sig", UVM_LOW)

    fork
        forever begin // collect wr sigs
            @(posedge vif.wclk iff(vif.wrstn === 1 && vif.wr_mon_ck.fifo_wr === 1)) begin
                `uvm_info("async_fifo_down_mon", "dowm_monitor mon the fifo_wr is 1, start to wait one wclk", UVM_LOW)
                @(posedge vif.wclk iff(vif.wrstn === 1));
                `uvm_info("async_fifo_down_mon", "dowm_monitor wait finish, start to collect write sigs", UVM_LOW)
                down_mon_data_wr.is_write = 1;
                down_mon_data_wr.is_read = 0;
                down_mon_data_wr.full = vif.wr_mon_ck.fifo_full;
                down_mon_data_wr.empty = 0;
                down_mon_data_wr.almost_full = vif.wr_mon_ck.almost_full;
                down_mon_data_wr.almost_empty = 0; 
                down_mon_data_wr.rdata = 0;
                `uvm_info("async_fifo_down_mon", "down_mon collect write sigs on if", UVM_LOW)
                this.print_down_mon_data(down_mon_data_wr);
                down_mon_wr_ap.write(down_mon_data_wr);
            end
        end
        forever begin // collect rd sigs
            @(posedge vif.rclk iff(vif.rrstn === 1 && vif.rd_mon_ck.fifo_rd === 1)) begin
                @(posedge vif.rclk iff(vif.rrstn === 1));
                down_mon_data_rd.is_write = 0;
                down_mon_data_rd.is_read = 1;
                down_mon_data_rd.full = 0;
                down_mon_data_rd.empty = vif.rd_mon_ck.fifo_empty;
                down_mon_data_rd.almost_full = 0;
                down_mon_data_rd.almost_empty = vif.rd_mon_ck.almost_empty;
                down_mon_data_rd.rdata = vif.rd_mon_ck.fifo_dout;
                `uvm_info("async_fifo_down_mon", "down_mon collect read sigs on if", UVM_LOW)
                this.print_down_mon_data(down_mon_data_rd);
                down_mon_rd_ap.write(down_mon_data_rd);
            end
        end
    join

    /*forever begin  
        fork begin   // guard fork
            fork: mon_down_data_two_thread
                begin // mon wr
                    @(posedge vif.wclk iff(vif.wrstn === 1 && vif.wr_mon_ck.fifo_wr === 1)) begin
                        `uvm_info("async_fifo_down_mon", "dowm_monitor mon the fifo_wr is 1, start to wait one wclk", UVM_LOW)
                        @(posedge vif.wclk iff(vif.wrstn === 1));
                        `uvm_info("async_fifo_down_mon", "dowm_monitor wait finish, start to collect write sigs", UVM_LOW)
                        down_mon_data_wr.is_write = 1;
                        down_mon_data_wr.is_read = 0;
                        down_mon_data_wr.full = vif.wr_mon_ck.fifo_full;
                        down_mon_data_wr.empty = 0;
                        down_mon_data_wr.almost_full = vif.wr_mon_ck.almost_full;
                        down_mon_data_wr.almost_empty = 0; 
                        down_mon_data_wr.rdata = 0;
                        `uvm_info("async_fifo_down_mon", "down_mon collect write sigs on if", UVM_LOW)
                        this.print_down_mon_data(down_mon_data_wr);
                        down_mon_ap.write(down_mon_data_wr);
                    end
                end
                begin // mon rd
                    @(posedge vif.rclk iff(vif.rrstn === 1 && vif.rd_mon_ck.fifo_rd === 1)) begin
                        @(posedge vif.rclk iff(vif.rrstn === 1));
                        down_mon_data_rd.is_write = 0;
                        down_mon_data_rd.is_read = 1;
                        down_mon_data_rd.full = 0;
                        down_mon_data_rd.empty = vif.rd_mon_ck.fifo_empty;
                        down_mon_data_rd.almost_full = 0;
                        down_mon_data_rd.almost_empty = vif.rd_mon_ck.almost_empty;
                        down_mon_data_rd.rdata = vif.rd_mon_ck.fifo_dout;
                        `uvm_info("async_fifo_down_mon", "down_mon collect read sigs on if", UVM_LOW)
                        this.print_down_mon_data(down_mon_data_rd);
                        down_mon_ap.write(down_mon_data_rd);
                    end
                end
            join_any
            disable mon_down_data_two_thread;
        end join
        `uvm_info("async_fifo_down_mon", "async_fifo_down_mon monite one down_mon_data and write into fifo", UVM_LOW)
    end*/
endtask: collect_down_sig

function void async_fifo_down_mon::print_down_mon_data(down_mon_t down_mon_data);
    `uvm_info("async_fifo_down_mon", "----------------- down_mon_data context as below: -----------------", UVM_LOW)
    `uvm_info("async_fifo_down_mon", $sformatf("          is_write --- %0d", down_mon_data.is_write), UVM_LOW)
    `uvm_info("async_fifo_down_mon", $sformatf("          is_read  --- %0d", down_mon_data.is_read), UVM_LOW)
    `uvm_info("async_fifo_down_mon", $sformatf("          full     --- %0d", down_mon_data.full), UVM_LOW)
    `uvm_info("async_fifo_down_mon", $sformatf("          empty    --- %0d", down_mon_data.empty), UVM_LOW)
    `uvm_info("async_fifo_down_mon", $sformatf("       almost_full --- %0d", down_mon_data.almost_full), UVM_LOW)
    `uvm_info("async_fifo_down_mon", $sformatf("      almost_empty --- %0d", down_mon_data.almost_empty), UVM_LOW)
    `uvm_info("async_fifo_down_mon", $sformatf("        rdata      --- 'h%8h", down_mon_data.rdata), UVM_LOW)
    `uvm_info("async_fifo_down_mon", "----------------- down_mon_data context show end -----------------", UVM_LOW)
endfunction: print_down_mon_data

`endif // ASYNC_FIFO_DOWN_MON
