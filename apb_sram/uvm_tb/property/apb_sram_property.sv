module apb_sram_property(
    input   logic                               pclk,
    input   logic                               rstn,

    input   logic                               psel,
    input   logic                               penable,
    input   logic                               pwrite,
    input   logic   [`DATAWIDTH-1:0]            pwdata,
    input   logic   [$clog2(`RAM_DEPTH)-1:0]    paddr,

    input   logic   [`DATAWIDTH-1:0]            prdata,
    input   logic                               pready
);
    //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
    //------------------- :: Check#1: setup_state ::-------------------------
    //   In the setup_state psel should high and penable should low,
    //   setup_state can be determined by detecting rising edge of psel.
    //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
    property setup_state;
        @(posedge pclk) disable iff (!rstn)
            $rose(psel) |-> penable === 0;
    endproperty

    assert property(setup_state)
        else `uvm_error("ASSERTION FAILED", $sformatf("------ :: Check#1: enable_state FAILED :: ------"))

    //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
    //------------------- :: Check#2: enable_state ::-------------------------
    //   In the enable_state $rose(psel) then ##1 penable should high;
    //   enable_state can be determined by rising edge of psel.
    //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
    property enable_state;
        @(posedge pclk) disable iff (!rstn)
            $rose(psel) |=> penable === 1;
    endproperty

    assert property(enable_state)
        else `uvm_error("ASSERTION FAILED", $sformatf("------ :: Check#2: enable_state FAILED :: ------"))

    //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
    //------------------- :: Check#3: stable_valid_pwdata_in_setup_state ::-------------------------
    //   In the setup state, pwdata should stable and valid, "x" or "z" are not expected.
    //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
    property stable_valid_pwdata_in_setup_state;
        @(posedge pclk) disable iff (!rstn)
            psel && !penable && pwrite |=> $stable(pwdata) && (!$isunknown(pwdata));
    endproperty

    assert property(stable_valid_pwdata_in_setup_state)
        else `uvm_error("ASSERTION FAILED", $sformatf("------ :: Check#3: stable_valid_pwdata_in_setup_state FAILED :: ------"))

    //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
    //------------------- :: Check#4: stable_valid_paddr_in_setup_state ::-------------------------
    //   In the setup state, paddr should stable and valid, "x" or "z" are not expected.
    //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
    property stable_valid_paddr_in_setup_state;
        @(posedge pclk) disable iff (!rstn)
            psel && !penable |=> $stable(paddr) && (!$isunknown(paddr));
    endproperty

    assert property(stable_valid_paddr_in_setup_state)
        else `uvm_error("ASSERTION FAILED", $sformatf("------ :: Check#4: stable_valid_paddr_in_setup_state FAILED :: ------"))

    //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
    //------------------- :: Check#5: pready_is_low_in_setup_state ::-------------------------
    //   In the setup state, pready should be low.
    //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
    property pready_is_low_in_setup_state;
        @(posedge pclk) disable iff (!rstn)
            psel && !penable |=> !pready;
    endproperty

    assert property(pready_is_low_in_setup_state)
        else `uvm_error("ASSERTION FAILED", $sformatf("------ :: Check#5: pready_is_low_in_setup_state FAILED :: ------"))

    //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
    //------------------- :: Check#6: pready_high_in_write_enable_state ::-------------------------
    //   In the write operation of enable state, pready should be high.
    //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
    property pready_high_in_write_enable_state;
        @(posedge pclk) disable iff (!rstn)
            psel && $rose(penable) && pwrite |=> pready === 1;
    endproperty

    assert property(pready_high_in_write_enable_state)
        else `uvm_error("ASSERTION FAILED", $sformatf("------ :: Check#6: pready_high_in_write_enable_state FAILED :: ------"))

    //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
    //------------------- :: Check#7: pready_high_in_read_enable_state ::-------------------------
    //   In the read operation of enable state's next clk, pready should be high.
    //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
    property pready_high_in_read_enable_state;
        @(posedge pclk) disable iff (!rstn)
            psel && $rose(penable) && !pwrite |=> ##1 pready === 1;
    endproperty

    assert property(pready_high_in_read_enable_state)
        else `uvm_error("ASSERTION FAILED", $sformatf("------ :: Check#7: pready_high_in_read_enable_state FAILED :: ------"))

    //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
    //------------------- :: Check#8: stable_valid_prdata_in_read_state ::-------------------------
    //   In the read state, prdata should stable and valid, "x" or "z" are not expected.
    //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
    property stable_valid_prdata_in_read_state;
        @(posedge pclk) disable iff (!rstn)
            psel && !penable && !pwrite |=> ##1 $stable(prdata) && (!$isunknown(prdata));
    endproperty

    assert property(stable_valid_prdata_in_read_state)
        else `uvm_error("ASSERTION FAILED", $sformatf("------ :: Check#8: stable_valid_prdata_in_read_state FAILED :: ------"))


endmodule: apb_sram_property
