import uvm_pkg::*;
`include "uvm_macros.svh"

class apb_sram_cov extends uvm_component;
    local virtual apb_sram_if vif;

    `uvm_component_utils(apb_sram_cov)

    covergroup cg_apb_port_cov;
        psel: coverpoint vif.mon_ck.psel {
            type_option.weight = 0;
            wildcard bins sel = {1'b1};
            wildcard bins not_sel = {1'b0};
        }
        penable: coverpoint vif.mon_ck.penable {
            type_option.weight = 0;
            wildcard bins en = {1'b1};
            wildcard bins not_en = {1'b0};
        }
        pwrite: coverpoint vif.mon_ck.pwrite {
            type_option.weight = 0;
            wildcard bins write = {1'b1};
            wildcard bins read = {1'b0};
        }
        pwdata: coverpoint vif.mon_ck.pwdata {
            //type_option.weight = 0;
            //option.auto_bin_max = 4;
            bins pwdata_part1 = {['h0000_0000:'h1FFF_FFFF]};
            bins pwdata_part2 = {['h2000_0000:'h3FFF_FFFF]};
            bins pwdata_part3 = {['h4000_0000:'h5FFF_FFFF]};
            bins pwdata_part4 = {['h6000_0000:'h7FFF_FFFF]};
            bins pwdata_part5 = {['h8000_0000:'h9FFF_FFFF]};
            bins pwdata_part6 = {['hA000_0000:'hBFFF_FFFF]};
            bins pwdata_part7 = {['hC000_0000:'hDFFF_FFFF]};
            bins pwdata_part8 = {['hE000_0000:'hFFFF_FFFF]};
            bins pwdata_not_care = default;
        }
        paddr: coverpoint vif.mon_ck.paddr {
            type_option.weight = 0;
            bins paddr_part1 = {[  'd0: 'd31]};
            bins paddr_part2 = {[ 'd32: 'd63]};
            bins paddr_part3 = {[ 'd64: 'd95]};
            bins paddr_part4 = {[ 'd96:'d127]};
        }
        pready: coverpoint vif.mon_ck.pready {
            type_option.weight = 0;
            wildcard bins rdy = {1'b1};
            wildcard bins not_rdy = {1'b0};
        }
        prdata: coverpoint vif.mon_ck.prdata {
            type_option.weight = 0;
            //option.auto_bin_max = 4;
            bins prdata_part1 = {['h0000_0000:'h1FFF_FFFF]};
            bins prdata_part2 = {['h2000_0000:'h3FFF_FFFF]};
            bins prdata_part3 = {['h4000_0000:'h5FFF_FFFF]};
            bins prdata_part4 = {['h6000_0000:'h7FFF_FFFF]};
            bins prdata_part5 = {['h8000_0000:'h9FFF_FFFF]};
            bins prdata_part6 = {['hA000_0000:'hBFFF_FFFF]};
            bins prdata_part7 = {['hC000_0000:'hDFFF_FFFF]};
            bins prdata_part8 = {['hE000_0000:'hFFFF_FFFF]};
            bins prdata_not_care = default;
        }
        state: cross psel, penable {
            bins idle = binsof(psel.not_sel) && binsof(penable.not_en);
            bins setup = binsof(psel.sel) && binsof(penable.not_en);
            bins enable = binsof(psel.sel) && binsof(penable.en);
            illegal_bins illegal_case = binsof(psel.not_sel) && binsof(penable.en);
        }
        write: cross psel, penable, pwrite {
            bins write_op = binsof(psel.sel) && binsof(penable.en) && binsof(pwrite.write);
            ignore_bins others1 = binsof(psel.not_sel);
            ignore_bins others2 = binsof(psel.sel) && binsof(penable.not_en);
            ignore_bins others3 = binsof(psel.sel) && binsof(penable.en) && binsof(pwrite.read);
        }
        read: cross psel, penable, pwrite, pready {
            bins read_op_phase1 = binsof(psel.sel) && binsof(penable.en) && binsof(pwrite.read) && binsof(pready.not_rdy);
            bins read_op_phase2 = binsof(psel.sel) && binsof(penable.en) && binsof(pwrite.read) && binsof(pready.rdy);
            ignore_bins others1 = binsof(psel.not_sel);
            ignore_bins others2 = binsof(psel.sel) && binsof(penable.not_en);
            ignore_bins others3 = binsof(psel.sel) && binsof(penable.en) && binsof(pwrite.write);
            //ignore_bins others = default;
        }
        /*data_in: coverpoint in_vif.mon_ck.data_in {
            type_option.weight = 0;
            bins data_in_part1 = {[  0: 63]};
            bins data_in_part2 = {[ 64:127]};
            bins data_in_part3 = {[128:191]};
            bins data_in_part4 = {[192:255]};
        }
        data_in_vld: coverpoint in_vif.mon_ck.data_in_vld {
            type_option.weight = 0;
            wildcard bins valid = {1'b1};
            wildcard bins not_valid = {1'b0};
        }
        data_in_vldXdata_in: cross data_in, data_in_vld {
            bins vld_data_part1 = binsof(data_in_vld.valid) && binsof(data_in.data_in_part1);
            bins vld_data_part2 = binsof(data_in_vld.valid) && binsof(data_in.data_in_part2);
            bins vld_data_part3 = binsof(data_in_vld.valid) && binsof(data_in.data_in_part3);
            bins vld_data_part4 = binsof(data_in_vld.valid) && binsof(data_in.data_in_part4);
            bins not_vld_data_part1 = binsof(data_in_vld.not_valid) && binsof(data_in.data_in_part1);
            bins not_vld_data_part2 = binsof(data_in_vld.not_valid) && binsof(data_in.data_in_part2);
            bins not_vld_data_part3 = binsof(data_in_vld.not_valid) && binsof(data_in.data_in_part3);
            bins not_vld_data_part4 = binsof(data_in_vld.not_valid) && binsof(data_in.data_in_part4);
        }*/
    endgroup
    
    function new(string name = "apb_sram_cov", uvm_component parent = null);
        super.new(name, parent);
        this.cg_apb_port_cov = new();
    endfunction: new

    extern function void build_phase(uvm_phase phase);
    extern function void set_interface(virtual apb_sram_if vif);
    extern task run_phase(uvm_phase phase);
    extern task do_apb_sample();
    extern function void report_phase(uvm_phase phase);

endclass: apb_sram_cov

function void apb_sram_cov::build_phase(uvm_phase phase);
    super.build_phase(phase);
endfunction: build_phase

function void apb_sram_cov::set_interface(virtual apb_sram_if vif);
    if(vif == null)
        `uvm_fatal(get_type_name(), "could not get vif")
    else begin
        this.vif = vif;
        //`uvm_info(get_type_name(), "cov get vif handle from up!", UVM_LOW)
    end
endfunction: set_interface

task apb_sram_cov::run_phase(uvm_phase phase);
    this.do_apb_sample();
endtask: run_phase

task apb_sram_cov::do_apb_sample();
    forever begin
        @(posedge vif.pclk iff(vif.rstn === 1'b1));
        //`uvm_info(get_type_name(), $sformatf("before sample, pwdata is %8h, prdata is %8h", vif.mon_ck.pwdata, vif.mon_ck.prdata), UVM_LOW)
        this.cg_apb_port_cov.sample();
        //`uvm_info(get_type_name(), $sformatf("after sample, pwdata is %8h, prdata is %8h", vif.mon_ck.pwdata, vif.mon_ck.prdata), UVM_LOW)
    end
endtask: do_apb_sample

function  void apb_sram_cov::report_phase(uvm_phase phase);
    string s;
    super.report_phase(phase);
    s = "\n---------------------------------------------------------------\n";
    s = {s, "COVERAGE SUMMARY \n"}; 
    s = {s, $sformatf("total coverage: %.1f \n", $get_coverage())}; 
    s = {s, $sformatf("  cg_apb_port_cov: %.1f \n", this.cg_apb_port_cov.get_coverage())}; 
    `uvm_info(get_type_name(), s, UVM_LOW)
endfunction: report_phase
