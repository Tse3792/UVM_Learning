`ifndef ASYNC_FIFO_MACROS
`define ASYNC_FIFO_MACROS

`define DATAWIDTH 32
`define FIFO_DEPTH 16

typedef struct {
    bit                         is_write;
    bit                         is_read;
    bit     [`DATAWIDTH-1 :0]   wdata;
} up_mon_t;

typedef struct {
    bit                         is_write;
    bit                         is_read;
    bit                         full;
    bit                         empty;
    bit                         almost_full;
    bit                         almost_empty;
    bit     [`DATAWIDTH-1 :0]   rdata;
} down_mon_t;

`endif // ASYNC_FIFO_MACROS
