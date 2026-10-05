`timescale 1ns/1ps

module tb_rv128i_noc_packetizer;

    logic clk = 0;
    logic rst = 1;

    logic         req_valid;
    logic         req_ready;
    logic         req_write;
    logic [127:0] req_addr;
    logic [127:0] req_wdata;

    logic [3:0]   src_x;
    logic [3:0]   src_y;
    logic [3:0]   dest_x;
    logic [3:0]   dest_y;

    logic [127:0] flit_out;
    logic         flit_valid;
    logic         flit_ready;

    rv128i_noc_packetizer dut (
        .clk        (clk),
        .rst        (rst),

        .req_valid  (req_valid),
        .req_ready  (req_ready),
        .req_write  (req_write),
        .req_addr   (req_addr),
        .req_wdata  (req_wdata),

        .src_x      (src_x),
        .src_y      (src_y),
        .dest_x     (dest_x),
        .dest_y     (dest_y),

        .flit_out   (flit_out),
        .flit_valid (flit_valid),
        .flit_ready (flit_ready)
    );

    always #5 clk = ~clk;

    initial begin
        req_valid = 1'b0;
        req_write = 1'b1;

        src_x = 4'd0;
        src_y = 4'd0;

        dest_x = 4'd3;
        dest_y = 4'd3;

        req_addr =
            128'h1234_5678_9ABC_DEF0_1111_2222_3333_4444;

        req_wdata =
            128'hAAAA_BBBB_CCCC_DDDD_EEEE_FFFF_1234_5678;

        flit_ready = 1'b1;

        repeat (2) @(posedge clk);
        #1;
        rst = 1'b0;

        // Start request
        req_valid = 1'b1;

        #1;

        if (!req_ready)
            $fatal(1, "REQUEST READY FAIL");

        @(posedge clk);
        #1;
        req_valid = 1'b0;

        // ========================================================
        // HEAD
        // ========================================================
        if (!flit_valid)
            $fatal(1, "HEAD VALID FAIL");

        if (flit_out[127:126] !== 2'b01)
            $fatal(1, "HEAD TYPE FAIL: %b", flit_out[127:126]);

        if (flit_out[125:122] !== 4'b0001)
            $fatal(1, "HEAD FLAGS FAIL: %b", flit_out[125:122]);

        if (flit_out[121:118] !== dest_y)
            $fatal(1, "HEAD DEST_Y FAIL");

        if (flit_out[117:114] !== dest_x)
            $fatal(1, "HEAD DEST_X FAIL");

        if (flit_out[113:110] !== src_y)
            $fatal(1, "HEAD SRC_Y FAIL");

        if (flit_out[109:106] !== src_x)
            $fatal(1, "HEAD SRC_X FAIL");

        if (flit_out[105:0] !== req_addr[105:0])
            $fatal(1, "HEAD ADDRESS FAIL");

        $display("HEAD FLIT PASS : %032h", flit_out);

        @(posedge clk);
        #1;

        // ========================================================
        // BODY
        // ========================================================
        if (!flit_valid)
            $fatal(1, "BODY VALID FAIL");

        if (flit_out[127:126] !== 2'b10)
            $fatal(1, "BODY TYPE FAIL");

        if (flit_out[121:118] !== dest_y ||
            flit_out[117:114] !== dest_x ||
            flit_out[113:110] !== src_y ||
            flit_out[109:106] !== src_x)
            $fatal(1, "BODY ROUTING FIELDS FAIL");

        if (flit_out[21:0] !== req_addr[127:106])
            $fatal(1, "BODY ADDRESS FAIL");

        if (flit_out[105:22] !== req_wdata[83:0])
            $fatal(1, "BODY DATA FAIL");

        $display("BODY FLIT PASS : %032h", flit_out);

        @(posedge clk);
        #1;

        // ========================================================
        // TAIL
        // ========================================================
        if (!flit_valid)
            $fatal(1, "TAIL VALID FAIL");

        if (flit_out[127:126] !== 2'b11)
            $fatal(1, "TAIL TYPE FAIL");

        if (flit_out[121:118] !== dest_y ||
            flit_out[117:114] !== dest_x ||
            flit_out[113:110] !== src_y ||
            flit_out[109:106] !== src_x)
            $fatal(1, "TAIL ROUTING FIELDS FAIL");

        if (flit_out[43:0] !== req_wdata[127:84])
            $fatal(1, "TAIL DATA FAIL");

        $display("TAIL FLIT PASS : %032h", flit_out);

        @(posedge clk);
        #1;

        if (!req_ready)
            $fatal(1, "PACKETIZER DID NOT RETURN IDLE");

        $display("========================================");
        $display("   RV128I 3-FLIT PACKETIZER TEST PASS");
        $display("========================================");

        $finish;
    end

endmodule
