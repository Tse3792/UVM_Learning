//`ifndef APB_SRAM_TYPES
//`define APB_SRAM_TYPES
package apb_sram_types;

`define DATAWIDTH 32
`define RAM_DEPTH 128

typedef enum bit [1:0]{
    DO_PURE_WRITE,
    DO_WRITE_AND_READ,
    DO_WRITE_CROSS_READ
} op_t;

typedef struct packed {
    bit [`DATAWIDTH-1:0]            data;
    bit                             write;
    bit [$clog2(`RAM_DEPTH)-1:0]    addr;
} mon_t;

endpackage: apb_sram_types
//`endif APB_SRAM_TYPES
