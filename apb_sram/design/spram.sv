`timescale 1ns/1ps

module spram#(
    parameter   DATAWIDTH = 32,
    parameter   RAM_DEPTH = 128
)(
    input   logic                           clk,
    input   logic                           rstn,

    input   logic                           ram_sel,
    input   logic                           ram_we,
    input   logic   [$clog2(RAM_DEPTH)-1:0] ram_addr,
    input   logic   [DATAWIDTH-1:0]         ram_wdata,

    output  logic   [DATAWIDTH-1:0]         ram_rdata
);
    logic [DATAWIDTH-1:0] mem [0:RAM_DEPTH-1];

    integer i;
    always_ff@(posedge clk or negedge rstn) begin
        if(!rstn) begin
            for(i=0; i<RAM_DEPTH; i++) begin
                mem[i] <= 'd0;
                //$display("mem reset");
            end
        end
        else if(ram_sel && ram_we) begin
            mem[ram_addr] <= ram_wdata;
            //$display("data %8h is write into address %2h", ram_wdata, ram_addr);
        end
    end

    always_ff@(posedge clk or negedge rstn) begin
        if(!rstn)
            ram_rdata <= 'd0;
        else if(ram_sel && !ram_we) begin
            ram_rdata <= mem[ram_addr];
            //$display("data %8h in mem address %2h is read onto bus", mem[ram_addr], ram_addr);
        end
    end

endmodule: spram
