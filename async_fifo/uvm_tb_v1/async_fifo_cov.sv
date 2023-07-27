`ifndef ASYNC_FIFO_CON
`define ASYNC_FIFO_CON

import uvm_pkg::*;
`include "uvm_macros.svh"

class async_fifo_cov extends uvm_component;
    local virtual async_fifo_if vif;

    `uvm_component_utils(async_fifo_cov)

    covergroup cg_wr_domain;
        fifo_wr: coverpoint vif.wr_mon_ck.fifo_wr {
            //type_option.weight = 0;
            wildcard bins wr = {1'b1};
            wildcard bins not_wr = {1'b0};
        }
        fifo_din: coverpoint vif.wr_mon_ck.fifo_din {
            //type_option.weight = 0;
            bins din_part1 = {['h0000_0000:'h1FFF_FFFF]};
            bins din_part2 = {['h2000_0000:'h3FFF_FFFF]};
            bins din_part3 = {['h4000_0000:'h5FFF_FFFF]};
            bins din_part4 = {['h6000_0000:'h7FFF_FFFF]};
            bins din_part5 = {['h8000_0000:'h9FFF_FFFF]};
            bins din_part6 = {['hA000_0000:'hBFFF_FFFF]};
            bins din_part7 = {['hC000_0000:'hDFFF_FFFF]};
            bins din_part8 = {['hE000_0000:'hFFFF_FFFF]};
            bins din_not_care = default;
        }
        fifo_full: coverpoint vif.wr_mon_ck.fifo_full {
            //type_option.weight = 0;
            wildcard bins full = {1'b1};
            wildcard bins not_full = {1'b0};
        } 
        almost_full: coverpoint vif.wr_mon_ck.almost_full {
            //type_option.weight = 0;
            wildcard bins almost_full = {1'b1};
            wildcard bins not_almost_full = {1'b0};
        }
        wr_op: cross fifo_wr, fifo_din {
            //type_option.weight = 0;
            bins wr_op_part1 = binsof(fifo_wr.wr) && binsof(fifo_din.din_part1);
            bins wr_op_part2 = binsof(fifo_wr.wr) && binsof(fifo_din.din_part2);
            bins wr_op_part3 = binsof(fifo_wr.wr) && binsof(fifo_din.din_part3);
            bins wr_op_part4 = binsof(fifo_wr.wr) && binsof(fifo_din.din_part4);
            bins wr_op_part5 = binsof(fifo_wr.wr) && binsof(fifo_din.din_part5);
            bins wr_op_part6 = binsof(fifo_wr.wr) && binsof(fifo_din.din_part6);
            bins wr_op_part7 = binsof(fifo_wr.wr) && binsof(fifo_din.din_part7);
            bins wr_op_part8 = binsof(fifo_wr.wr) && binsof(fifo_din.din_part8);
        }
    endgroup: cg_wr_domain

    covergroup cg_rd_domain;
        fifo_rd: coverpoint vif.rd_mon_ck.fifo_rd {
            //type_option.weight = 0;
            wildcard bins rd = {1'b1};
            wildcard bins not_rd = {1'b0};
        }
        fifo_dout: coverpoint vif.rd_mon_ck.fifo_dout {
            //type_option.weight = 0;
            bins dout_part1 = {['h0000_0000:'h1FFF_FFFF]};
            bins dout_part2 = {['h2000_0000:'h3FFF_FFFF]};
            bins dout_part3 = {['h4000_0000:'h5FFF_FFFF]};
            bins dout_part4 = {['h6000_0000:'h7FFF_FFFF]};
            bins dout_part5 = {['h8000_0000:'h9FFF_FFFF]};
            bins dout_part6 = {['hA000_0000:'hBFFF_FFFF]};
            bins dout_part7 = {['hC000_0000:'hDFFF_FFFF]};
            bins dout_part8 = {['hE000_0000:'hFFFF_FFFF]};
            bins dout_not_care = default;
        }
        fifo_empty: coverpoint vif.rd_mon_ck.fifo_empty {
            //type_option.weight = 0;
            wildcard bins empty = {1'b1};
            wildcard bins not_empty = {1'b0};
        } 
        almost_empty: coverpoint vif.rd_mon_ck.almost_empty {
            //type_option.weight = 0;
            wildcard bins almost_empty = {1'b1};
            wildcard bins not_almost_empty = {1'b0};
        }
        rd_op: cross fifo_rd, fifo_dout {
            //type_option.weight = 0;
            bins rd_op_part1 = binsof(fifo_rd.rd) && binsof(fifo_dout.dout_part1);
            bins rd_op_part2 = binsof(fifo_rd.rd) && binsof(fifo_dout.dout_part2);
            bins rd_op_part3 = binsof(fifo_rd.rd) && binsof(fifo_dout.dout_part3);
            bins rd_op_part4 = binsof(fifo_rd.rd) && binsof(fifo_dout.dout_part4);
            bins rd_op_part5 = binsof(fifo_rd.rd) && binsof(fifo_dout.dout_part5);
            bins rd_op_part6 = binsof(fifo_rd.rd) && binsof(fifo_dout.dout_part6);
            bins rd_op_part7 = binsof(fifo_rd.rd) && binsof(fifo_dout.dout_part7);
            bins rd_op_part8 = binsof(fifo_rd.rd) && binsof(fifo_dout.dout_part8);
        }
    endgroup: cg_rd_domain
    
    function new(string name = "async_fifo_cov", uvm_component parent = null);
        super.new(name, parent);
        this.cg_wr_domain = new();
        this.cg_rd_domain = new();
    endfunction: new

    extern function void build_phase(uvm_phase phase);
    extern function void set_if(virtual async_fifo_if vif);
    extern task run_phase(uvm_phase phase);
    extern task do_async_fifo_sample();
    extern function void report_phase(uvm_phase phase);

endclass: async_fifo_cov

function void async_fifo_cov::build_phase(uvm_phase phase);
    super.build_phase(phase);
endfunction: build_phase

function void async_fifo_cov::set_if(virtual async_fifo_if vif);
    if(vif == null)
        `uvm_fatal("async_fifo_cov", "could not get vif")
    else begin
        this.vif = vif;
    end
endfunction: set_if

task async_fifo_cov::run_phase(uvm_phase phase);
    this.do_async_fifo_sample();
endtask: run_phase

task async_fifo_cov::do_async_fifo_sample();
    fork
        forever begin
            @(posedge vif.wclk iff(vif.wrstn === 1'b1));
            this.cg_wr_domain.sample();
        end
        forever begin
            @(posedge vif.rclk iff(vif.rrstn === 1'b1));
            this.cg_rd_domain.sample();
        end
    join
endtask: do_async_fifo_sample

function  void async_fifo_cov::report_phase(uvm_phase phase);
    string s;
    super.report_phase(phase);
    s = "\n---------------------------------------------------------------\n";
    s = {s, "COVERAGE SUMMARY \n"}; 
    s = {s, $sformatf("total coverage: %.1f \n", $get_coverage())}; 
    s = {s, $sformatf("  cg_wr_domain_cov: %.1f \n", this.cg_wr_domain.get_coverage())}; 
    s = {s, $sformatf("  cg_rd_domain_cov: %.1f \n", this.cg_rd_domain.get_coverage())};
    `uvm_info("async_fifo_cov", s, UVM_LOW)
endfunction: report_phase

`endif // ASYNC_FIFO_CON
