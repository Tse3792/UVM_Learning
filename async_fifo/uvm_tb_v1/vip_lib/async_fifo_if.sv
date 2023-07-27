`ifndef ASYNC_FIFO_IF
`define ASYNC_FIFO_IF

interface async_fifo_if(input logic wclk, input logic wrstn, input logic rclk, input logic rrstn);
    
    logic                       fifo_wr;
    logic   [`DATAWIDTH-1 :0]   fifo_din;
    logic                       fifo_rd;
    logic   [`DATAWIDTH-1 :0]   fifo_dout;

    logic                       fifo_empty;
    logic                       fifo_full;
    logic                       almost_empty;
    logic                       almost_full;
    
    clocking wr_drv_ck@(posedge wclk);
        default input #2ns output #2ns;
        output  fifo_wr, fifo_din;
        input   fifo_full, almost_full;
    endclocking

    clocking rd_drv_ck@(posedge rclk);
        default input #2ns output #2ns;
        output  fifo_rd;
        input   fifo_dout, fifo_empty, almost_empty;
    endclocking

    clocking wr_mon_ck@(posedge wclk);
        default input #0ns output #0ns;
        input   fifo_wr, fifo_din;
        input   fifo_full, almost_full;
    endclocking

    clocking rd_mon_ck@(posedge rclk);
        default input #0ns output #0ns;
        input   fifo_rd;
        input   fifo_dout, fifo_empty, almost_empty;
    endclocking

endinterface: async_fifo_if

`endif // ASYNC_FIFO_IF
