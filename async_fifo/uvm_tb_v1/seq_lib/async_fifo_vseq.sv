`ifndef ASYNC_FIFO_VSEQ
`define ASYNC_FIFO_VSEQ

import uvm_pkg::*;
`include "uvm_macros.svh"

class async_fifo_vseq extends uvm_sequence;

    async_fifo_write_continuous_seq wr_seq;
    async_fifo_read_continuous_seq rd_seq;
    async_fifo_full_random_seq random_seq;

    `uvm_object_utils(async_fifo_vseq)
    `uvm_declare_p_sequencer(async_fifo_vsqr)

    function new(string name = "async_fifo_vseq");
        super.new(name);
    endfunction: new

    extern task body();
endclass: async_fifo_vseq

task async_fifo_vseq::body();
    //super.body();
    `uvm_info("async_fifo_vseq", "Executing async_fifo_write_continuous_seq", UVM_LOW)
    `uvm_do_on_with(wr_seq, p_sequencer.sqr, {wr_num == `FIFO_DEPTH + 16;})
    `uvm_info("async_fifo_vseq", "async_fifo_write_continuous_seq complete", UVM_LOW)

    `uvm_info("async_fifo_vseq", "Executing async_fifo_read_continuous_seq", UVM_LOW)
    `uvm_do_on_with(rd_seq, p_sequencer.sqr, {rd_num == `FIFO_DEPTH + 16;})
    `uvm_info("async_fifo_vseq", "async_fifo_read_continuous_seq complete", UVM_LOW)

    `uvm_info("async_fifo_vseq", "Executing async_fifo_full_random_seq", UVM_LOW)
    `uvm_do_on_with(random_seq, p_sequencer.sqr, {random_num == `FIFO_DEPTH + 4096;})
    `uvm_info("async_fifo_vseq", "async_fifo_full_random_seq complete", UVM_LOW)

endtask: body

`endif // ASYNC_FIFO_VSEQ
