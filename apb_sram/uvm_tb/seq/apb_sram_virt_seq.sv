`ifndef APB_SRAM_VIRT_SEQ
`define APB_SRAM_VIRT_SEQ

import uvm_pkg::*;
`include "uvm_macros.svh"

class apb_sram_virt_seq extends uvm_sequence;
    apb_sram_seq seq;

    `uvm_object_utils(apb_sram_virt_seq)
    `uvm_declare_p_sequencer(apb_sram_virt_sqr)

    function new(string name = "apb_sram_virt_seq");
        super.new(name);
    endfunction: new

    extern virtual task body();
    extern virtual task do_data();

endclass: apb_sram_virt_seq

task apb_sram_virt_seq::body();
    `uvm_info(get_type_name(), "=====================START=====================", UVM_LOW)
        
    this.do_data();

    `uvm_info(get_type_name(), "=====================FINISHED====================", UVM_LOW)
endtask: body

task apb_sram_virt_seq::do_data();
    `uvm_do_on_with(seq, p_sequencer.sqr, {ntrans == 100;})
    `uvm_info(get_type_name(), "DO DATA FINISH", UVM_LOW)
endtask: do_data

`endif
