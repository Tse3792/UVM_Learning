interface apb_sram_if(input logic pclk, input logic rstn);
    import apb_sram_types::*;

    logic                           psel;
    logic                           pwrite;
    logic                           penable;
    logic [`DATAWIDTH-1:0]          pwdata;
    logic [$clog2(`RAM_DEPTH)-1:0]  paddr;

    logic                           pready;
    logic [`DATAWIDTH-1:0]          prdata;

    clocking drv_ck@(posedge pclk);
        default input #1ns output #1ns;
        input pready, prdata;
        output psel, pwrite, penable, pwdata, paddr;
    endclocking

    clocking mon_ck@(posedge pclk);
        default input #1ns output #1ns;
        input psel, pwrite, penable, pwdata, paddr, pready, prdata;
    endclocking

endinterface: apb_sram_if
