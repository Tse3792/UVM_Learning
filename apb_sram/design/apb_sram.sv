`timescale 1ns/1ps

module apb_sram#(
    parameter   DATAWIDTH = 32,
    parameter   RAM_DEPTH = 128
)(
    input   logic                           pclk,
    input   logic                           rstn,

    input   logic                           psel,
    input   logic                           penable,
    input   logic                           pwrite,
    input   logic   [$clog2(RAM_DEPTH)-1:0] paddr,
    input   logic   [DATAWIDTH-1:0]         pwdata,

    output  logic                           pready,
    output  logic   [DATAWIDTH-1:0]         prdata
);
    
    logic apb_read_flag;
    logic apb_write_flag;
    
    logic [$clog2(RAM_DEPTH)-1:0]   apb_addr;
    logic                           apb_read;
    logic                           apb_write;
    logic [DATAWIDTH-1:0]           apb_wdata;

    //logic [1:0]                     apb_ready_dly;
    logic                           setup_state;
    logic [2:0]                     setup_state_dly;

    assign pready = pwrite==1'b1 ? setup_state_dly[1] : setup_state_dly[2];
    assign setup_state = psel && !penable;
    assign apb_read_flag = setup_state_dly[0] && !pwrite;
    assign apb_write_flag = setup_state_dly[0] && pwrite;

    always_ff@(posedge pclk or negedge rstn) begin
        if(!rstn)
            setup_state_dly <= 'd0;
        else
            setup_state_dly <= {setup_state_dly[1:0],setup_state};
    end

    always_ff@(posedge pclk or negedge rstn) begin
        if(!rstn)
            apb_addr <= 'd0;
        else if(psel && !penable)
            apb_addr <= paddr;
    end

    always_ff@(posedge pclk or negedge rstn) begin
        if(!rstn)
            apb_read <= 1'b0;
        else
            apb_read <= apb_read_flag;
    end

    always_ff@(posedge pclk or negedge rstn) begin
        if(!rstn)
            apb_write <= 1'b0;
        else
            apb_write <= apb_write_flag;
    end

    always_ff@(posedge pclk or negedge rstn) begin
        if(!rstn)
            apb_wdata <= 'd0;
        else
            apb_wdata <= pwdata;
    end

    /*always_ff@(posedge pclk or negedge rstn) begin
        if(!rstn)
            apb_ready_dly <= 'd0;
        else
            apb_ready_dly <= {apb_ready_dly[0], apb_read};
    end*/

    spram#(
        .DATAWIDTH  (DATAWIDTH),
        .RAM_DEPTH  (RAM_DEPTH)
    ) spram(
        .clk        (pclk),
        .rstn       (rstn),

        .ram_sel    (apb_write || apb_read),
        .ram_we     (apb_write),
        .ram_addr   (apb_addr),
        .ram_wdata  (apb_wdata),

        .ram_rdata  (prdata)
    );

endmodule: apb_sram
