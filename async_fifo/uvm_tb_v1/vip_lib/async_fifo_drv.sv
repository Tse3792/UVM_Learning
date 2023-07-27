`ifndef ASYNC_FIFO_DRV
`define ASYNC_FIFO_DRV

import uvm_pkg::*;
`include "uvm_macros.svh"

class async_fifo_drv extends uvm_driver #(async_fifo_trans);

    local virtual async_fifo_if vif;
    //static semaphore key;

    `uvm_component_utils(async_fifo_drv)

    function new(string name = "async_fifo_drv", uvm_component parent = null);
        super.new(name, parent);
        key = new(1);
    endfunction: new

    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
    extern function void set_if(virtual async_fifo_if vif);
    extern task run_phase(uvm_phase phase);
    extern task push(input bit [`DATAWIDTH-1 :0] wdata, int data_nidles);
    extern task pop(int data_nidles);
    extern task drive_idle();
endclass: async_fifo_drv

function void async_fifo_drv::build_phase(uvm_phase phase);
    super.build_phase(phase);
endfunction: build_phase

function void async_fifo_drv::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
endfunction: connect_phase

function void async_fifo_drv::set_if(virtual async_fifo_if vif);
    if(vif == null)
        `uvm_fatal("async_fifo_drv", "get a null vif")
    else
        this.vif = vif;
endfunction: set_if

task async_fifo_drv::run_phase(uvm_phase phase);
    
    async_fifo_trans req;
    async_fifo_trans rsp;

    super.run_phase(phase);

    fork
        @(posedge vif.wrstn);
        @(posedge vif.rrstn);
        `uvm_info("async_fifo_drv", "wait until two reset sigs release, driver start to get next item", UVM_LOW)
    join
    //this.drive_idle();
    forever begin
        seq_item_port.get_next_item(req);
        `uvm_info("async_fifo_drv", "get a valid async_fifo_trans SUCC", UVM_LOW)
        if(req.is_write && req.is_wr_idle) begin
            assert(req.is_write && !req.is_rd_idle)
                else `uvm_fatal("async_fifo_drv", "illegal async_fifo_trans, is_write is asserted while is_wr_idle is asserted")
            @(posedge vif.wclk iff(vif.wrstn === 1));
            vif.wr_drv_ck.fifo_din <= 'd0;
            vif.wr_drv_ck.fifo_wr <= 0;
        end
        else if(!req.is_write && req.is_rd_idle) begin
            assert(!req.is_write && !req.is_wr_idle)
                else `uvm_fatal("async_fifo_drv", "illegal async_fifo_trans, is_write is asserted while is_rd_idle is asserted")
            @(posedge vif.rclk iff(vif.rrstn === 1));
            vif.rd_drv_ck.fifo_rd <= 0;
        end
        else if(req.is_write) begin // write op
            assert(!req.is_wr_idle && !req.is_rd_idle)
                else `uvm_fatal("async_fifo_drv", "illegal async_fifo_trans, is_write is asserted while is_wr_idle && is_rd_idle are asserted")
            this.push(req.wdata, req.data_nidles);
        end
        else if(!req.is_write) begin
            assert(!req.is_wr_idle && !req.is_rd_idle)
                else `uvm_fatal("async_fifo_drv", "illegal async_fifo_trans, is_write is asserted while is_wr_idle && is_rd_idle are asserted")
            this.pop(req.data_nidles);
        end
        `uvm_info("async_fifo_drv", "drive item to vif SUCC(push or pop finish)", UVM_LOW)
        void'($cast(rsp, req.clone()));
        rsp.rsp = 1;
        rsp.set_sequence_id(req.get_sequence_id());
        seq_item_port.item_done(rsp);
        `uvm_info("async_fifo_drv", "return rsp to sequence SUCC", UVM_LOW)
    end
endtask: run_phase

task async_fifo_drv::push(input bit [`DATAWIDTH-1 :0] wdata, int data_nidles);
    @(posedge vif.wclk iff(vif.wrstn === 1));
    vif.wr_drv_ck.fifo_din <= wdata;
    vif.wr_drv_ck.fifo_wr <= 1;
    @(posedge vif.wclk iff(vif.wrstn === 1));
    vif.wr_drv_ck.fifo_wr <= 0;
    repeat(data_nidles) begin
        @(posedge vif.wclk iff(vif.wrstn === 1));
        vif.wr_drv_ck.fifo_wr <= 0;
    end
    `uvm_info("async_fifo_drv", $sformatf("push op is finish, wdata is 'h%8h, drive %0d idle", wdata, data_nidles), UVM_LOW)
endtask: push

task async_fifo_drv::pop(int data_nidles);
    @(posedge vif.rclk iff(vif.rrstn === 1));
    vif.rd_drv_ck.fifo_rd <= 1;
    @(posedge vif.rclk iff(vif.rrstn === 1));
    vif.rd_drv_ck.fifo_rd <= 0;
    repeat(data_nidles) begin
        @(posedge vif.rclk iff(vif.rrstn === 1));
        vif.rd_drv_ck.fifo_rd <= 0;
    end
    `uvm_info("async_fifo_drv", $sformatf("pop op is finish, drive %0d idle", data_nidles), UVM_LOW);
endtask: pop

task async_fifo_drv::drive_idle();
    fork
        @(posedge vif.wclk iff(vif.wrstn === 1)) begin
            vif.wr_drv_ck.fifo_din <= 'd0;
            vif.wr_drv_ck.fifo_wr <= 0;
        end
        @(posedge vif.rclk iff(vif.rrstn === 1)) begin
            vif.rd_drv_ck.fifo_rd <= 0;
        end
    join
endtask: drive_idle

`endif // ASYNC_FIFO_DRV
