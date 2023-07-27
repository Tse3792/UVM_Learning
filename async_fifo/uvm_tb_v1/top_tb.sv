`ifndef TOP_TB
`define TOP_TB

`timescale 1ns/1ps

module top_tb();
    
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    bit     wclk;
    bit     wrstn;
    bit     rclk;
    bit     rrstn;

    async_fifo_if async_fifo_if(
        .wclk   (wclk),
        .wrstn  (wrstn),
        .rclk   (rclk),
        .rrstn  (rrstn)
    );

    initial begin
        wclk = 0;
        forever #5ns wclk = !wclk;
    end

    initial begin
        rclk = 0;
        forever #11ns rclk = !rclk;
    end

    initial begin
        wrstn = 1;
        #1ns;
        wrstn = 0;
        #1ns;
        wrstn = 1;
    end

    initial begin
        rrstn = 1;
        #1ns;
        rrstn = 0;
        #1ns;
        rrstn = 1;
    end

    initial begin
        fork
            forever begin
                wait(wrstn === 0);
                $assertoff();
                wait(wrstn === 1);
                $asserton();
            end
            forever begin
                wait(rrstn === 0);
                $assertoff();
                wait(rrstn === 1);
                $asserton();
            end
        join_none
    end

    initial begin
        $fsdbDumpfile("top_tb.fsdb");
        $fsdbDumpvars(0);
    end

    initial begin
        run_test("async_fifo_test");
    end

    initial begin
        uvm_config_db#(virtual async_fifo_if)::set(uvm_root::get(), "uvm_test_top", "vif", async_fifo_if);
    end

    async_fifo#(
        .DATAWIDTH      (`DATAWIDTH),
        .FIFO_DEPTH     (`FIFO_DEPTH)
    ) dut (
        .wclk           (wclk),
        .wrstn          (wrstn),
        .rclk           (rclk),
        .rrstn          (rrstn),

        .fifo_wr        (async_fifo_if.fifo_wr),
        .fifo_din       (async_fifo_if.fifo_din),
        .fifo_rd        (async_fifo_if.fifo_rd),
        .fifo_dout      (async_fifo_if.fifo_dout),

        .fifo_full      (async_fifo_if.fifo_full),
        .fifo_empty     (async_fifo_if.fifo_empty),
        .almost_full    (async_fifo_if.almost_full),
        .almost_empty   (async_fifo_if.almost_empty)
    );

endmodule: top_tb

`endif // TOP_TB
