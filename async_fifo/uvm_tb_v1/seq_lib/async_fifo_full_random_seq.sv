`ifndef ASYNC_FIFO_FULL_RANDOM_SEQ
`define ASYNC_FIFO_FULL_RANDOM_SEQ

import uvm_pkg::*;
`include "uvm_macros.svh"

class async_fifo_full_random_seq extends uvm_sequence #(async_fifo_trans);

    rand    int         random_num;

    `uvm_object_utils_begin(async_fifo_full_random_seq)
        `uvm_field_int(random_num, UVM_ALL_ON)
    `uvm_object_utils_end
    `uvm_declare_p_sequencer(async_fifo_sqr)

    function new(string name = "async_fifo_full_random_seq");
        super.new(name);
    endfunction: new

    constraint async_fifo_full_random_seq_cstr {
        soft random_num == `FIFO_DEPTH + 64;   
    }

    extern task body();
    extern task send_trans();

endclass: async_fifo_full_random_seq

task async_fifo_full_random_seq::body();
    `uvm_info("async_fifo_full_random_seq", "enter body() task", UVM_LOW)
    repeat(random_num) this.send_trans();
    `uvm_info("async_fifo_full_random_seq", "exit body() task", UVM_LOW)
endtask: body

task async_fifo_full_random_seq::send_trans();
    
    async_fifo_trans req;
    async_fifo_trans rsp;
    `uvm_info("async_fifo_full_random_seq", "enter send_trans() task", UVM_LOW)

    `uvm_do_with(req, { {req.is_write, req.is_wr_idle, req.is_rd_idle} inside {3'b100, 3'b110, 3'b000, 3'b001};
                        req.wdata inside {['h0000_0000 : 'hFFFF_FFFF]};
                        req.data_nidles inside {[0:4]};
                      })
    get_response(rsp);
    `uvm_info("async_fifo_full_random_seq", "req has been sent to sqr and got rsp, context as below:", UVM_LOW)
    `uvm_info("async_fifo_full_random_seq", rsp.sprint(), UVM_LOW)
    assert(rsp.rsp)
        else `uvm_fatal("async_fifo_full_random_seq", "get ERROR rsp")

    `uvm_info("async_fifo_full_random_seq", "rsp asserted SUCC", UVM_LOW)
endtask: send_trans

`endif // ASYNC_FIFO_FULL_RANDOM_SEQ
