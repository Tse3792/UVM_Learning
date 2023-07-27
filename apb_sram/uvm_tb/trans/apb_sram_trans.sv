`ifndef APB_SRAM_TRANS
`define APB_SRAM_TRANS

import uvm_pkg::*;
`include "uvm_macros.svh"
import apb_sram_types::*;

class apb_sram_trans extends uvm_sequence_item;
    //interface signals
    //bit                                 psel;
    //bit                                 penable;
    //rand bit                            pwrite;
    //rand bit [`DATAWIDTH-1:0]           pwdata;
    rand bit [`DATAWIDTH-1:0]            pwdata[];
    rand bit [$clog2(`RAM_DEPTH)-1:0]    paddr[];
    
    //bit                                 pready;
    //bit      [`DATAWIDTH-1:0]           prdata;

    //control vars
    bit                                 rsp;
    rand int                            data_nidles;
    rand int                            pkt_nidles;
    rand op_t                           operation;
    
    `uvm_object_utils_begin(apb_sram_trans)
        //`uvm_field_int(psel, UVM_ALL_ON)
        //`uvm_field_int(penable, UVM_ALL_ON)
        //`uvm_field_int(pwrite, UVM_ALL_ON)
        //`uvm_field_int(pwdata, UVM_ALL_ON)
        `uvm_field_array_int(pwdata, UVM_ALL_ON)
        `uvm_field_array_int(paddr, UVM_ALL_ON)
        //`uvm_field_int(pready, UVM_ALL_ON)
        //`uvm_field_int(prdata, UVM_ALL_ON)
        `uvm_field_int(rsp, UVM_ALL_ON)
        `uvm_field_int(data_nidles, UVM_ALL_ON)
        `uvm_field_int(pkt_nidles, UVM_ALL_ON)
        `uvm_field_enum(op_t, operation, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "apb_sram_trans");
        super.new(name);
    endfunction: new

    constraint apb_sram_cstr {
        //soft pwrite inside {[0:1]};
        //soft pwdata[1:0] == 2'b11;
        //soft pwdata[`DATAWIDTH-1 -: 2] == 2'b11;
        soft data_nidles inside {[0:5]};
        soft pkt_nidles inside {[0:10]};
        soft pwdata.size() inside {[1:`RAM_DEPTH-1]}; //// constraint ERROR cause that req randomize fail , `uvm_do_with could not sent item
        //foreach(pwdata[i]) pwdata[i][`DATAWIDTH-1 -: 2] == 2'b11;
        //foreach(pwdata[i]) pwdata[i][1:0] == 2'b11;
        foreach(pwdata[i]) pwdata[i] % 3 == 0;
        soft paddr.size() == pwdata.size();
        foreach(paddr[i])
            foreach(paddr[j])
                if(i != j)
                    paddr[i] != paddr[j];
        soft operation inside {DO_PURE_WRITE, DO_WRITE_AND_READ, DO_WRITE_CROSS_READ};
    };

endclass: apb_sram_trans

`endif
