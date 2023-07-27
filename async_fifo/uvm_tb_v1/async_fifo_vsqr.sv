`ifndef ASYNC_FIFO_VSQR
`define ASYNC_FIFO_VSQR

import uvm_pkg::*;
`include "uvm_macros.svh"

class async_fifo_vsqr extends uvm_sequencer;

    async_fifo_sqr sqr;

    `uvm_component_utils(async_fifo_vsqr)

    function new(string name = "async_fifo_vsqr", uvm_component parent = null);
        super.new(name, parent);
    endfunction: new

endclass: async_fifo_vsqr

`endif // ASYNC_FIFO_VSQR
