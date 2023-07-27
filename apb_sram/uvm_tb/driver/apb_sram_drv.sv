//import uvm_pkg::*;
//`include "uvm_macros.svh"

`ifndef APB_SRAM_DRV
`define APB_SRAM_DRV

import uvm_pkg::*;
`include "uvm_macros.svh"

class apb_sram_drv extends uvm_driver#(apb_sram_trans);
    local virtual apb_sram_if vif;

    `uvm_component_utils(apb_sram_drv)

    function new(string name = "apb_sram_drv", uvm_component parent = null);
        super.new(name, parent);
    endfunction: new

    extern function void set_interface(virtual apb_sram_if vif);
    extern task run_phase(uvm_phase phase);
    extern task do_reset();
    extern task do_drive();
    extern task do_pure_write(apb_sram_trans req);
    extern task do_write_and_read(apb_sram_trans req);
    extern task do_write_cross_read(apb_sram_trans req);
    extern task write_item(input logic [$clog2(`RAM_DEPTH)-1:0] addr, input logic [`DATAWIDTH-1:0] wdata);
    extern task read_item(input logic [$clog2(`RAM_DEPTH)-1:0] addr);
    extern task do_idle();
    extern task sram_init();

endclass: apb_sram_drv

function void apb_sram_drv::set_interface(virtual apb_sram_if vif);
    if(vif == null)
        `uvm_fatal(get_type_name(), "could not get vif handle!")
    else begin
        this.vif = vif;
        //`uvm_info(get_type_name(), "drv get vif", UVM_LOW)
    end
endfunction: set_interface

task apb_sram_drv::run_phase(uvm_phase phase);
    // do sram init
    sram_init();
    // do sram drive
    fork
        `uvm_info(get_type_name(), "enter fork", UVM_LOW)
        this.do_reset();
        this.do_drive();
    join
endtask: run_phase

task apb_sram_drv::do_reset();
    forever begin
        @(negedge vif.rstn);
        vif.drv_ck.psel <= 1'b0;
        vif.drv_ck.pwrite <= 1'b0;
        vif.drv_ck.penable <= 1'b0;
        vif.drv_ck.pwdata <= 'd0;
        vif.drv_ck.paddr <= 'd0;
    end
endtask: do_reset

task apb_sram_drv::sram_init();
    `uvm_info(get_type_name(), "============================ start do sram init ============================", UVM_LOW)
    for(int i=0; i<`RAM_DEPTH; i++) begin: sram_init
        //`uvm_info(get_type_name(), "enter init loop", UVM_LOW)
        this.write_item(i, 'hcccc_0000+i);
    end
    `uvm_info(get_type_name(), "============================ do sram init done ============================", UVM_LOW)
endtask: sram_init

task apb_sram_drv::do_drive();
    apb_sram_trans req;
    apb_sram_trans rsp;
    @(posedge vif.pclk iff(vif.rstn === 1'b1));
    forever begin
        `uvm_info(get_type_name(), "start to wait an item from seq_item_port", UVM_LOW)
        seq_item_port.get_next_item(req);
        `uvm_info(get_type_name(), "Get an item from seq_item_port", UVM_LOW)
        if(req.operation == DO_PURE_WRITE) 
            this.do_pure_write(req);
        else if(req.operation == DO_WRITE_AND_READ)
            this.do_write_and_read(req);
        else if(req.operation == DO_WRITE_CROSS_READ)
            this.do_write_cross_read(req);
        else
            `uvm_fatal(get_type_name(), "illegal operation type of apb_sram_trans")
        void'($cast(rsp, req.clone()));
        rsp.rsp = 1;
        rsp.set_sequence_id(req.get_sequence_id());
        seq_item_port.item_done(rsp);
    end
endtask: do_drive

task apb_sram_drv::do_pure_write(apb_sram_trans req);
    `uvm_info(get_type_name(), "============================ start do pure write ============================", UVM_LOW)
    foreach(req.pwdata[i]) begin
        this.write_item(req.paddr[i], req.pwdata[i]);
        repeat(req.data_nidles) this.do_idle();
    end
    repeat(req.pkt_nidles) this.do_idle();
    `uvm_info(get_type_name(), "============================ do pure write end ============================", UVM_LOW)
endtask: do_pure_write

task apb_sram_drv::do_write_and_read(apb_sram_trans req);
    `uvm_info(get_type_name(), "============================ start do write and read ============================", UVM_LOW)
    foreach(req.pwdata[i]) begin
        this.write_item(req.paddr[i], req.pwdata[i]);
        repeat(req.data_nidles) this.do_idle();
    end
    repeat(req.pkt_nidles) this.do_idle();
    foreach(req.paddr[i]) this.read_item(req.paddr[i]);
    `uvm_info(get_type_name(), "============================ do write and read end ============================", UVM_LOW)
endtask: do_write_and_read

task apb_sram_drv::do_write_cross_read(apb_sram_trans req);
    `uvm_info(get_type_name(), "============================ start do write cross read ============================", UVM_LOW)
    foreach(req.pwdata[i]) begin
        this.write_item(req.paddr[i], req.pwdata[i]);
        this.read_item(req.paddr[i]);
    end
    `uvm_info(get_type_name(), "============================ do write cross read end ============================", UVM_LOW)
endtask: do_write_cross_read

task apb_sram_drv::write_item(input logic [$clog2(`RAM_DEPTH)-1:0] addr, input logic [`DATAWIDTH-1:0] wdata);
    @(posedge vif.pclk iff(vif.rstn === 1'b1));
    vif.drv_ck.psel <= 1'b1;
    vif.drv_ck.paddr <= addr;
    vif.drv_ck.pwrite <= 1'b1;
    vif.drv_ck.pwdata <= wdata;
    vif.drv_ck.penable <= 1'b0;
    @(posedge vif.pclk iff(vif.rstn === 1'b1));
    vif.drv_ck.penable <= 1'b1;
    @(posedge vif.pclk iff(vif.rstn === 1'b1));
    while(!vif.drv_ck.pready) begin
        @(posedge vif.pclk iff(vif.rstn === 1'b1));
    end
    `uvm_info(get_type_name(), $sformatf("write data %8h to address %2h", wdata, addr), UVM_LOW)
    vif.drv_ck.psel <= 1'b0;
    vif.drv_ck.penable <= 1'b0;
endtask: write_item

task apb_sram_drv::read_item(input logic [$clog2(`RAM_DEPTH)-1:0] addr);
    @(posedge vif.pclk iff(vif.rstn === 1'b1));
    vif.drv_ck.psel <= 1'b1;
    vif.drv_ck.paddr <= addr;
    vif.drv_ck.pwrite <= 1'b0;
    vif.drv_ck.penable <= 1'b0;
    @(posedge vif.pclk iff(vif.rstn === 1'b1));
    vif.drv_ck.penable <= 1'b1;
    @(posedge vif.pclk iff(vif.rstn === 1'b1));
    while(!vif.drv_ck.pready) begin
        @(posedge vif.pclk iff(vif.rstn === 1'b1));
    end
    `uvm_info(get_type_name(), $sformatf("read data %8h from address %2h", vif.drv_ck.prdata, addr), UVM_LOW)
    vif.drv_ck.psel <= 1'b0;
    vif.drv_ck.penable <= 1'b0;
endtask: read_item

task apb_sram_drv::do_idle();
    @(posedge vif.pclk iff(vif.rstn === 1'b1));
    vif.drv_ck.psel <= 1'b0;
    vif.drv_ck.pwrite <= 1'b0;
    vif.drv_ck.penable <= 1'b0;
    vif.drv_ck.pwdata <= 'd0;
    vif.drv_ck.paddr <= 'd0;
endtask: do_idle

`endif
