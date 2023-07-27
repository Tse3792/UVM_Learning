`ifndef ASYNC_FIFO_SCB
`define ASYNC_FIFO_SCB

import uvm_pkg::*;
`include "uvm_macros.svh"

class async_fifo_scb extends uvm_component;

    uvm_blocking_get_port #(down_mon_t) scb_expect_bg_port;
    uvm_blocking_get_port #(down_mon_t) scb_actual_wr_bg_port;
    uvm_blocking_get_port #(down_mon_t) scb_actual_rd_bg_port;

    `uvm_component_utils(async_fifo_scb)

    function new(string name = "async_fifo_scb", uvm_component parent = null);
        super.new(name, parent);
    endfunction: new

    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);
    extern function void compare_data(down_mon_t expect_data, down_mon_t actual_data);
endclass: async_fifo_scb

function void async_fifo_scb::build_phase(uvm_phase phase);
    super.build_phase(phase);
    scb_expect_bg_port = new("scb_expect_bg_port", this);
    scb_actual_wr_bg_port = new("scb_actual_wr_bg_port", this);
    scb_actual_rd_bg_port = new("scb_actual_rd_bg_port", this);
endfunction: build_phase

function void async_fifo_scb::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
endfunction: connect_phase

task async_fifo_scb::run_phase(uvm_phase phase);
    
    down_mon_t  expect_data;
    down_mon_t  actual_data;

    forever begin
        `uvm_info("async_fifo_scb", "async_fifo_scb start to get expect_data and actual_data", UVM_LOW)
        scb_expect_bg_port.get(expect_data);
        `uvm_info("async_fifo_scb", "async_fifo_scb has got expect_data", UVM_LOW)
        if(expect_data.is_write) begin
            scb_actual_wr_bg_port.get(actual_data);
            `uvm_info("async_fifo_scb", "async_fifo_scb has got actual_data from wr_fifo", UVM_LOW)
        end
        else if(expect_data.is_read) begin
            scb_actual_rd_bg_port.get(actual_data);
            `uvm_info("async_fifo_scb", "async_fifo_scb has got actual_data from rd_fifo", UVM_LOW)
        end
        else
            `uvm_fatal("async_fifo_scb", "ERROR: expect_data and actual_data type mismatch")
        assert(expect_data.is_write == actual_data.is_write && expect_data.is_read == actual_data.is_read)
            else `uvm_info("async_fifo_scb", "expect_data's type is mismatched with actual_data", UVM_LOW)
        if(expect_data.is_write == actual_data.is_write && expect_data.is_read == actual_data.is_read) begin
            this.compare_data(expect_data, actual_data);
        end
        else begin
            `uvm_info("async_fifo_scb", "expect_data is different with actual_data, context as below:", UVM_LOW)
            this.compare_data(expect_data, actual_data);
        end
    end
endtask: run_phase

function void async_fifo_scb::compare_data(down_mon_t expect_data, down_mon_t actual_data);
    `uvm_info("async_fifo_scb", "----------------- compare context as below: -----------------", UVM_LOW)
    `uvm_info("async_fifo_scb", "                   expect_data         actual_data", UVM_LOW)
    `uvm_info("async_fifo_scb", $sformatf("is_write              %0d                    %0d", expect_data.is_write, actual_data.is_write), UVM_LOW)
    `uvm_info("async_fifo_scb", $sformatf("is_read               %0d                    %0d", expect_data.is_read, actual_data.is_read), UVM_LOW)
    `uvm_info("async_fifo_scb", $sformatf("full                  %0d                    %0d", expect_data.full, actual_data.full), UVM_LOW)
    `uvm_info("async_fifo_scb", $sformatf("empty                 %0d                    %0d", expect_data.empty, actual_data.empty), UVM_LOW)
    `uvm_info("async_fifo_scb", $sformatf("almost_full           %0d                    %0d", expect_data.almost_full, actual_data.almost_full), UVM_LOW)
    `uvm_info("async_fifo_scb", $sformatf("almost_empty          %0d                    %0d", expect_data.almost_empty, actual_data.almost_empty), UVM_LOW)
    `uvm_info("async_fifo_scb", $sformatf("rdata                'h%8h                  'h%8h", expect_data.rdata, actual_data.rdata), UVM_LOW)
    `uvm_info("async_fifo_scb", "----------------- compare context show end -----------------", UVM_LOW)
    if( expect_data.is_write == actual_data.is_write &&
        expect_data.is_read == actual_data.is_read &&
        expect_data.full == actual_data.full &&
        expect_data.empty == actual_data.empty &&
        expect_data.almost_full == actual_data.almost_full &&
        expect_data.almost_empty == actual_data.almost_empty &&
        expect_data.rdata == actual_data.rdata )
        `uvm_info("async_fifo_scb", "CONCLUSION: Compare Successfully!", UVM_LOW)
    else
        `uvm_info("async_fifo_scb", "CONCLUSION: Compare Fail!", UVM_LOW)
endfunction: compare_data

`endif // ASYNC_FIFO_SCB
