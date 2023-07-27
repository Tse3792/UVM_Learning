`timescale 1ns/1ps
//`include "apb_sram_if.sv"

module top_tb();
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    //import apb_sram_test_pkg::*;

    bit pclk;
    bit rstn;

    apb_sram_if apb_if(pclk, rstn);

    initial begin
        pclk = 0;
        forever #5 pclk = !pclk;
    end

    initial begin
        rstn = 1;
        #15ns;
        rstn = 0;
        #19ns;
        rstn = 1;
    end

    initial begin
        $fsdbDumpfile("top_tb.fsdb");
        $fsdbDumpvars();
    end

    initial begin
        fork
            forever begin
                wait(rstn === 0);
                $assertoff();
                wait(rstn === 1);
                $asserton();
            end
        join_none
    end

    initial begin
        uvm_config_db#(virtual apb_sram_if)::set(uvm_root::get(), "uvm_test_top", "vif", apb_if);
        //uvm_config_db#(virtual my_input_if)::set(uvm_root::get(), "uvm_test_top.env.i_agt.mon", "vif", in_if);
        //uvm_config_db#(virtual my_output_if)::set(uvm_root::get(), "uvm_test_top.env.o_agt.mon", "vif", out_if);
        //uvm_config_db#(virtual my_input_if)::set(uvm_root::get(), "uvm_test_top.env.cov", "in_vif", in_if);
        //uvm_config_db#(virtual my_output_if)::set(uvm_root::get(), "uvm_test_top.env.cov", "out_vif", out_if);
    end

    initial begin
        run_test("apb_sram_test");
    end

    apb_sram#(
        .DATAWIDTH      (`DATAWIDTH),
        .RAM_DEPTH      (`RAM_DEPTH)
    ) dut(
        .pclk           (pclk),
        .rstn           (rstn),

        .psel           (apb_if.psel),
        .penable        (apb_if.penable),
        .pwrite         (apb_if.pwrite),
        .paddr          (apb_if.paddr),
        .pwdata         (apb_if.pwdata),

        .pready         (apb_if.pready),
        .prdata         (apb_if.prdata)
    );

    apb_sram_property assertions (
        .pclk           (pclk),
        .rstn           (rstn),

        .psel           (apb_if.psel),
        .penable        (apb_if.penable),
        .pwrite         (apb_if.pwrite),
        .paddr          (apb_if.paddr),
        .pwdata         (apb_if.pwdata),

        .pready         (apb_if.pready),
        .prdata         (apb_if.prdata)
    );

endmodule: top_tb
