`timescale 1ns/1ps

module tb_rv128i_anoc_read;

    logic clk = 0;
    logic rst = 1;

    logic         req_valid;
    logic         req_ready;
    logic         req_write;
    logic [127:0] req_addr;
    logic [127:0] req_wdata;

    logic [3:0]   dest_x;
    logic [3:0]   dest_y;

    logic [127:0] resp_rdata;
    logic         resp_valid;

    logic         mem_write_complete;
    logic [127:0] mem_write_addr;
    logic [127:0] mem_write_data;

    localparam logic [127:0] TEST_ADDR =
        128'h0000_0000_0000_0000_0000_0000_0000_0080;

    localparam logic [127:0] TEST_DATA =
        128'hDEAD_BEEF_1234_5678_AAAA_BBBB_CAFE_4321;

    rv128i_anoc_mesh_top dut (
        .clk                (clk),
        .rst                (rst),

        .req_valid          (req_valid),
        .req_ready          (req_ready),
        .req_write          (req_write),
        .req_addr           (req_addr),
        .req_wdata          (req_wdata),

        .dest_x             (dest_x),
        .dest_y             (dest_y),

        .resp_rdata         (resp_rdata),
        .resp_valid         (resp_valid),

        .mem_write_complete (mem_write_complete),
        .mem_write_addr     (mem_write_addr),
        .mem_write_data     (mem_write_data)
    );

    always #5 clk = ~clk;

    initial begin
        req_valid = 1'b0;
        req_write = 1'b0;
        req_addr  = 128'd0;
        req_wdata = 128'd0;

        // Destination memory node = Router 15 = (3,3)
        dest_x = 4'd3;
        dest_y = 4'd3;

        repeat (3) @(posedge clk);
        #1;
        rst = 1'b0;

        // ========================================================
        // STEP 1: WRITE TEST DATA INTO REMOTE MEMORY
        // ========================================================
        req_addr  = TEST_ADDR;
        req_wdata = TEST_DATA;
        req_write = 1'b1;
        req_valid = 1'b1;

        wait (req_ready);
        @(posedge clk);
        #1;
        req_valid = 1'b0;

        wait (mem_write_complete);
        #1;

        if (mem_write_addr !== TEST_ADDR)
            $fatal(1, "WRITE ADDRESS MISMATCH");

        if (mem_write_data !== TEST_DATA)
            $fatal(1, "WRITE DATA MISMATCH");

        $display("WRITE PASS");
        $display("ADDR = %032h", mem_write_addr);
        $display("DATA = %032h", mem_write_data);

        // ========================================================
        // STEP 2: READ SAME ADDRESS
        // ========================================================
        req_addr  = TEST_ADDR;
        req_wdata = 128'd0;
        req_write = 1'b0;
        req_valid = 1'b1;

        wait (req_ready);
        @(posedge clk);
        #1;
        req_valid = 1'b0;

        // Wait for response to travel back through mesh.
        wait (resp_valid);
        #1;

        $display("READ RESPONSE");
        $display("DATA = %032h", resp_rdata);

        if (resp_rdata !== TEST_DATA)
            $fatal(1, "READ DATA MISMATCH");

        $display("READ PASS");

        $display("========================================");
        $display(" RV128I -> ANoC -> MEMORY READ/WRITE");
        $display("========================================");
        $display("DESTINATION : (%0d,%0d)", dest_x, dest_y);
        $display("WRITE       : PASS");
        $display("READ        : PASS");
        $display("DATA MATCH  : PASS");
        $display("========================================");
        $display(" RV128I ANOC BIDIRECTIONAL TEST PASS ");
        $display("========================================");

        $finish;
    end

    initial begin
        #10000;
        $fatal(1, "TIMEOUT: READ RESPONSE NOT RECEIVED");
    end

endmodule
