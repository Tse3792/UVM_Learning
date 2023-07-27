`ifndef ASYNC_FIFO_SQR
`define ASYNC_FIFO_SQR

import uvm_pkg::*;
`include "uvm_macros.svh"

class async_fifo_sqr extends uvm_sequencer #(async_fifo_trans);

    `uvm_component_utils(async_fifo_sqr)

    function new(string name = "async_fifo_sqr", uvm_component parent = null);
        super.new(name, parent);
    endfunction: new

endclass: async_fifo_sqr

`endif // ASYNC_FIFO_SQR
