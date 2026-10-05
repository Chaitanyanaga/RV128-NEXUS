`timescale 1ns/1ps

module tb_rv128i_noc_if;

    logic clk = 0;
    logic rst = 1;

    logic         cpu_valid;
    logic         cpu_ready;
    logic         cpu_we;
    logic [127:0] cpu_addr;
    logic [127:0] cpu_wdata;
    logic [127:0] cpu_rdata;

    logic [3:0] dest_x;
    logic [3:0] dest_y;

    logic [127:0] noc_flit_out;
    logic         noc_valid_out;
    logic         noc_ready_out;

    logic [127:0] noc_flit_in;
    logic         noc_valid_in;
    logic         noc_ready_in;

    rv128i_noc_if dut (
        .clk,
        .rst,
        .cpu_valid,
        .cpu_ready,
        .cpu_we,
        .cpu_addr,
        .cpu_wdata,
        .cpu_rdata,
        .dest_x,
        .dest_y,
        .noc_flit_out,
        .noc_valid_out,
        .noc_ready_out,
        .noc_flit_in,
        .noc_valid_in,
        .noc_ready_in
    );

    always #5 clk = ~clk;

    initial begin
        cpu_valid     = 0;
        cpu_we        = 0;
        cpu_addr      = 128'd0;
        cpu_wdata     = 128'd0;
        dest_x        = 4'd2;
        dest_y        = 4'd1;

        noc_ready_out = 1;
        noc_valid_in  = 0;
        noc_flit_in   = 128'd0;

        repeat (2) @(posedge clk);
        #1;
        rst = 0;

        // -----------------------------
        // WRITE REQUEST
        // -----------------------------
        cpu_valid = 1;
        cpu_we    = 1;
        cpu_addr  = 128'h0000_0000_0000_0000_0000_0000_0000_0100;
        cpu_wdata = 128'hAAAA_BBBB_CCCC_DDDD_1111_2222_3333_4444;

        #1;

        if (!noc_valid_out)
            $fatal(1, "WRITE FLIT VALID FAIL");

        if (!cpu_ready)
            $fatal(1, "WRITE CPU READY FAIL");

        if (noc_flit_out[123:120] !== 4'd2)
            $fatal(1, "DEST X FAIL");

        if (noc_flit_out[119:116] !== 4'd1)
            $fatal(1, "DEST Y FAIL");

        if (noc_flit_out[109] !== 1'b1)
            $fatal(1, "WRITE FLAG FAIL");

        $display("WRITE REQUEST FLIT PASS");
        $display("FLIT = %032h", noc_flit_out);

        @(posedge clk);
        #1;
        cpu_valid = 0;

        // -----------------------------
        // READ REQUEST
        // -----------------------------
        cpu_valid = 1;
        cpu_we    = 0;
        cpu_addr  = 128'h0000_0000_0000_0000_0000_0000_0000_0200;

        #1;

        if (!noc_valid_out)
            $fatal(1, "READ FLIT VALID FAIL");

        if (noc_flit_out[109] !== 1'b0)
            $fatal(1, "READ FLAG FAIL");

        $display("READ REQUEST FLIT PASS");
        $display("FLIT = %032h", noc_flit_out);

        @(posedge clk);
        #1;
        cpu_valid = 0;

        // Simulate response.
        noc_flit_in  = 128'h1234_5678_9ABC_DEF0_1111_2222_3333_4444;
        noc_valid_in = 1;

        #1;

        if (!noc_ready_in)
            $fatal(1, "RESPONSE READY FAIL");

        @(posedge clk);
        #1;

        if (cpu_rdata !== noc_flit_in)
            $fatal(1, "RESPONSE DATA FAIL");

        $display("READ RESPONSE PASS");
        $display("DATA = %032h", cpu_rdata);

        noc_valid_in = 0;

        $display("========================================");
        $display("     RV128I NoC INTERFACE TEST PASS");
        $display("========================================");

        $finish;
    end

endmodule
