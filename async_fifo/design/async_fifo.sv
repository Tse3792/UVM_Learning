
`timescale 1ns/1ps

//  .   .   .   1       2       3       4       5       6       7       8       9      10      11      12      13      14      15      16    
//          +---+   +---+   +---+   +---+   +---+   +---+   +---+   +---+   +---+   +---+   +---+   +---+   +---+   +---+   +---+   +---+   +
// clk      |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |
//          +   +---+   +---+   +---+   +---+   +---+   +---+   +---+   +---+   +---+   +---+   +---+   +---+   +---+   +---+   +---+   +---+

//                                                                                                                                           
// sig                                                                                                                                  
//          --------------------------------------------------------------------------------------------------------------------------------

module async_fifo#(
    parameter                               DATAWIDTH = 32,
    parameter                               FIFO_DEPTH = 128
)(
    input   logic                           wclk,
    input   logic                           wrstn,
    input   logic                           fifo_wr,
    input   logic   [DATAWIDTH-1:0]         fifo_din,

    input   logic                           rclk,
    input   logic                           rrstn,
    input   logic                           fifo_rd,
    output  logic   [DATAWIDTH-1:0]         fifo_dout,

    output  logic                           fifo_empty,
    output  logic                           fifo_full,
    output  logic                           almost_empty,
    output  logic                           almost_full
);
    localparam                  ADDRWIDTH = $clog2(FIFO_DEPTH);            
    logic   [DATAWIDTH-1:0]     mem [0:FIFO_DEPTH-1];
    
    // write variable
    logic   [ADDRWIDTH  :0]     wptr_add;
    logic   [ADDRWIDTH  :0]     wptr_bin;

    // write ptr and write data
    assign wptr_add = (fifo_wr && !fifo_full) ? wptr_bin + 'd1 : wptr_bin; // for judging empty & full signal 

    always_ff@(posedge wclk or negedge wrstn) begin
        if(!wrstn)
            wptr_bin <= 'd0;
        else if(fifo_wr && !fifo_full)
            wptr_bin <= wptr_bin + 'd1;
    end

    integer i;
    always_ff@(posedge wclk or negedge wrstn) begin
        if(!wrstn) begin
            for(i=0; i<FIFO_DEPTH; i++) begin: reset_mem
                mem[i] <= 'd0;
            end
        end
        else if(fifo_wr && !fifo_full)
            mem[wptr_bin[ADDRWIDTH-1:0]] <= fifo_din;
    end
    
    // read variable
    logic   [ADDRWIDTH  :0]     rptr_bin;

    // read ptr and read data
    always_ff@(posedge rclk or negedge rrstn) begin
        if(!rrstn)
            rptr_bin <= 'd0;
        else if(fifo_rd && !fifo_empty)
            rptr_bin <= rptr_bin + 'd1;
    end

    always_ff@(posedge rclk or negedge rrstn) begin
        if(!rrstn)
            fifo_dout <= 'd0;
        else if(fifo_rd && !fifo_empty)
            fifo_dout <= mem[rptr_bin[ADDRWIDTH-1:0]];
    end

    // sync read & write ptr(gray code) to another clk domain
        // variable
    logic   [ADDRWIDTH  :0]     wptr_gray;
    logic   [ADDRWIDTH  :0]     rptr_gray;
    logic   [ADDRWIDTH  :0]     wptr_gray_sync0;
    logic   [ADDRWIDTH  :0]     wptr_gray_sync1;
    logic   [ADDRWIDTH  :0]     rptr_gray_sync0;
    logic   [ADDRWIDTH  :0]     rptr_gray_sync1;

        // operation
    assign wptr_gray = wptr_bin ^ wptr_bin>>1;
    assign rptr_gray = rptr_bin ^ rptr_bin>>1;

    always_ff@(posedge wclk or negedge wrstn) begin
        if(!wrstn) begin
            rptr_gray_sync0 <= 'd0;
            rptr_gray_sync1 <= 'd0;
        end
        else begin
            rptr_gray_sync0 <= rptr_gray;
            rptr_gray_sync1 <= rptr_gray_sync0;
        end
    end

    always_ff@(posedge rclk or negedge rrstn) begin
        if(!rrstn) begin
            wptr_gray_sync0 <= 'd0;
            wptr_gray_sync1 <= 'd0;
        end
        else begin
            wptr_gray_sync0 <= wptr_gray;
            wptr_gray_sync1 <= wptr_gray_sync0;
        end
    end

    // empty & full signals generation
    /*always_ff@(posedge wclk or negedge wrstn) begin
        if(!wrstn)
            fifo_full <= 'd0;
        else if({~wptr_bin[ADDRWIDTH-:2], wptr_bin[ADDRWIDTH-2:0]} == rptr_gray_sync[1])
            fifo_full <= 1'b1;
        else
            fifo_full <= 1'b0;
    end

    always_ff@(posedge rclk or negedge rrstn) begin
        if(!wrstn)
            fifo_empty <= 'd0;
        else if(rptr_bin == wptr_gray_sync[1])
            fifo_empty <= 1'b1;
        else
            fifo_empty <= 1'b0;
    end*/

    // almost_empty & almost_full signales generation
        //variable
    logic   [ADDRWIDTH  :0]     wr_domain_data_rem;
    logic   [ADDRWIDTH  :0]     rd_domain_data_rem;
    logic   [ADDRWIDTH  :0]     rptr_gray2bin;
    logic   [ADDRWIDTH  :0]     wptr_gray2bin;
        // operation
            // write domain
    generate
    genvar a;
        for(a=0; a<=ADDRWIDTH; a++) begin: rptr_gray2bin_gen
            if(a == ADDRWIDTH)
                assign rptr_gray2bin[a] = rptr_gray_sync1[a];
            else
                assign rptr_gray2bin[a] = rptr_gray_sync1[a] ^ rptr_gray2bin[a+1];
        end
    endgenerate
            // read domain
    generate
    genvar b;
        for(b=0; b<=ADDRWIDTH; b++) begin: wptr_gray2bin_gen
            if(b == ADDRWIDTH)
                assign wptr_gray2bin[b] = wptr_gray_sync1[b];
            else
                assign wptr_gray2bin[b] = wptr_gray_sync1[b] ^ wptr_gray2bin[b+1];
        end
    endgenerate

            // data rem calc
    always_comb begin
        if(wptr_bin[ADDRWIDTH] == rptr_gray2bin[ADDRWIDTH])
            wr_domain_data_rem = {1'b0, wptr_bin[ADDRWIDTH-1:0]} - {1'b0, rptr_gray2bin[ADDRWIDTH-1:0]};
        else
            wr_domain_data_rem = FIFO_DEPTH + {1'b0, wptr_bin[ADDRWIDTH-1:0]} - {1'b0, rptr_gray2bin[ADDRWIDTH-1:0]};
    end
            
    always_comb begin
        if(rptr_bin[ADDRWIDTH] == wptr_gray2bin[ADDRWIDTH])
            rd_domain_data_rem = {1'b0, wptr_gray2bin[ADDRWIDTH-1:0]} - {1'b0, rptr_bin[ADDRWIDTH-1:0]};
        else
            rd_domain_data_rem = FIFO_DEPTH + {1'b0, wptr_gray2bin[ADDRWIDTH-1:0]} - {1'b0, rptr_bin[ADDRWIDTH-1:0]};
    end

    always_ff@(posedge wclk or negedge wrstn) begin
        if(!wrstn)
            almost_full <= 'd0;
        else if(wr_domain_data_rem+'d2 >= FIFO_DEPTH)
            almost_full <= 1'b1;
        else
            almost_full <= 1'b0;
    end

    always_ff@(posedge rclk or negedge rrstn) begin
        if(!rrstn)
            almost_empty <= 'd0;
        else if(rd_domain_data_rem <= 'd2)
            almost_empty <= 1'b1;
        else
            almost_empty <= 1'b0;
    end

    always_ff@(posedge wclk or negedge wrstn) begin
        if(!wrstn)
            fifo_full <= 'd0;
        else if(wr_domain_data_rem == FIFO_DEPTH)
            fifo_full <= 1'b1;
        else
            fifo_full <= 1'b0;
    end

    always_ff@(posedge rclk or negedge rrstn) begin
        if(!rrstn)
            fifo_empty <= 'd0;
        else if(rd_domain_data_rem == 'd0)
            fifo_empty <= 1'b1;
        else
            fifo_empty <= 1'b0;
    end

endmodule: async_fifo


//async_fifo async_fifo_inst0(/*autoinst*/
/*        .wclk                   (wclk                           ), //input
        .wrstn                  (wrstn                          ), //input
        .fifo_wr                (fifo_wr                        ), //input
        .fifo_din               (fifo_din[DATAWIDTH-1:0]        ), //input
        .rclk                   (rclk                           ), //input
        .rrstn                  (rrstn                          ), //input
        .fifo_rd                (fifo_rd                        ), //input
        .fifo_dout              (fifo_dout[DATAWIDTH-1:0]       ), //output
        .fifo_empty             (fifo_empty                     ), //output
        .fifo_full              (fifo_full                      ), //output
        .almost_empty           (almost_empty                   ), //output
        .almost_full            (almost_full                    )  //output
    );
*/
