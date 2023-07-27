`include "apb_sram_if.sv"

package apb_sram_test_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    
    import apb_sram_types::*;
    //`include "apb_sram_defines.svh"
    //`include "apb_sram_types.svh"

    //`include "apb_sram_if.sv"
    `include "apb_sram_trans.sv"
    `include "apb_sram_drv.sv"
    `include "apb_sram_mon.sv"
    `include "apb_sram_sqr.sv"
    `include "apb_sram_agt.sv"
    `include "apb_sram_env.sv"
    `include "apb_sram_rfm.sv"
    `include "apb_sram_scb.sv"
    `include "apb_sram_seq.sv"
    `include "apb_sram_virt_seq.sv"
    `include "apb_sram_virt_sqr.sv"
    `include "apb_sram_test.sv"

endpackage: apb_sram_test_pkg
