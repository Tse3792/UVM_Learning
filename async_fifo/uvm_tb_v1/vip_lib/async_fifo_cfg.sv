`ifndef ASYNC_FIFO_CFG
`define ASYNC_FIFO_CFG

import uvm_pkg::*;
`include "uvm_macros.svh"

class async_fifo_cfg extends uvm_object;
    
    uvm_active_passive_enum is_active;

    `uvm_object_utils_begin(async_fifo_cfg)
        `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "async_fifo_cfg");
        super.new(name);
    endfunction: new

endclass: async_fifo_cfg

`endif // ASYNC_FIFO_CFG
