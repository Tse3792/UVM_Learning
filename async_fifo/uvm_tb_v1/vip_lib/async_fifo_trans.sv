`ifndef ASYNC_FIFO_TRANS
`define ASYNC_FIFO_TRANS

import uvm_pkg::*;
`include "uvm_macros.svh"

`include "async_fifo_macros.svh"

class async_fifo_trans extends uvm_sequence_item;

    rand    bit                     is_write; // 1 for write, 0 for read
    rand    bit[`DATAWIDTH-1: 0]    wdata;
    rand    bit                     is_wr_idle;
    rand    bit                     is_rd_idle;

            bit                     rsp;
    rand    int                     data_nidles;

    `uvm_object_utils_begin(async_fifo_trans)
        `uvm_field_int(is_write, UVM_ALL_ON)
        `uvm_field_int(wdata, UVM_ALL_ON)
        `uvm_field_int(rsp, UVM_ALL_ON)
        `uvm_field_int(data_nidles, UVM_ALL_ON)
        `uvm_field_int(is_wr_idle, UVM_ALL_ON)
        `uvm_field_int(is_rd_idle, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "async_fifo_trans");
        super.new(name);
    endfunction: new

    constraint async_fifo_trans_cstr {
        soft is_write inside {0, 1};
        soft wdata inside {['h0000_0000 : 'hFFFF_FFFF]};
        soft data_nidles inside {[0:4]};
        soft is_wr_idle inside {0, 1};
        soft is_rd_idle inside {0, 1};
    }

endclass: async_fifo_trans

`endif // ASYNC_FIFO_TRANS
