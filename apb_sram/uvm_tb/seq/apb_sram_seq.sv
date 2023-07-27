`ifndef APB_SRAM_SEQ
`define APB_SRAM_SEQ

import uvm_pkg::*;
`include "uvm_macros.svh"

class apb_sram_seq extends uvm_sequence#(apb_sram_trans);
    //rand int        data_nidles = -1;
    //rand int        pkt_nidles = -1;
    //rand op_t       operation = DO_PURE_WRITE;
    rand int        ntrans = 100;

    `uvm_object_utils_begin(apb_sram_seq)
        //`uvm_field_int(data_nidles, UVM_ALL_ON)
        //`uvm_field_int(pkt_nidles, UVM_ALL_ON)
        //`uvm_field_enum(op_t, operation, UVM_ALL_ON)
        `uvm_field_int(ntrans, UVM_ALL_ON)
    `uvm_object_utils_end
    `uvm_declare_p_sequencer(apb_sram_sqr)

    function new(string name = "apb_sram_seq");
        super.new(name);
    endfunction: new

    extern task body();
    extern task send_trans();
    extern function void post_randomize();
endclass: apb_sram_seq

task apb_sram_seq::body();
    //`uvm_info(get_type_name(), "start trans", UVM_LOW)
    repeat(ntrans) send_trans();
    //`uvm_info(get_type_name(), "end trans", UVM_LOW)
endtask: body

task apb_sram_seq::send_trans();
    apb_sram_trans req;
    apb_sram_trans rsp;
    //`uvm_info(get_type_name(), "enter send_trans()", UVM_LOW)
    //`uvm_info(get_type_name(), $sformatf("ntrans = %0d, data_nidles = %0d, pkt_nidles = %0d, op = %0d", this.ntrans, this.data_nidles, this.pkt_nidles, this.operation), UVM_LOW)
    //`uvm_do_with(req, {local::operation != DO_PURE_WRITE -> operation == local::operation;})
    `uvm_do(req)
    //`uvm_do_on(req, p_sequencer)
    //`uvm_info(get_type_name(), $sformatf("ntrans = %0d, data_nidles = %0d, pkt_nidles = %0d, op = %0d", this.ntrans, req.data_nidles, req.pkt_nidles, req.operation), UVM_LOW)
    //`uvm_do(req)
    //`uvm_create_on(req, p_sequencer)
    //`uvm_info(get_type_name(), "uvm_create_on done", UVM_LOW)
    //start_item(req, -1, p_sequencer);
    //`uvm_info(get_type_name(), "start_item done", UVM_LOW)
    `uvm_info(get_type_name(), req.sprint(), UVM_LOW)
    get_response(rsp);
    `uvm_info(get_type_name(), rsp.sprint(), UVM_LOW)
    assert(rsp.rsp)
        else $error("[RSPERR] %0t error response received!", $time);
endtask: send_trans

function void apb_sram_seq::post_randomize();
    string s;
    s = {s, "AFTER RANDOMIZATION \n"};
    s = {s, "=======================================\n"};
    s = {s, "data_sequence object content is as below: \n"};
    s = {s, super.sprint()};
    s = {s, "=======================================\n"};
    `uvm_info(get_type_name(), s, UVM_HIGH)
endfunction: post_randomize

`endif
