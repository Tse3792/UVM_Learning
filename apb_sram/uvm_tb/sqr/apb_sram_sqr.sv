`ifndef APB_SRAM_SQR
`define APB_SRAM_SQR

import uvm_pkg::*;
`include "uvm_macros.svh"

class apb_sram_sqr extends uvm_sequencer#(apb_sram_trans);
    `uvm_component_utils(apb_sram_sqr)
    
    function new(string name = "apb_sram_sqr", uvm_component parent = null);
        super.new(name, parent);
    endfunction: new
endclass: apb_sram_sqr

`endif
