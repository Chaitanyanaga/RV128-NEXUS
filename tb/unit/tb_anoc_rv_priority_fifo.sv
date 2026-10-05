`timescale 1ns/1ps

module tb_anoc_rv_priority_fifo;

    timeunit 1ns;
    timeprecision 1ps;

    localparam int WIDTH = 128;
    localparam int PRIORITY_BITS = 2;
    localparam int DEPTH         = 8;

    logic                     clk;
    logic                     rst_n;

    logic                     wr_valid;
    logic                     wr_ready;
    logic [WIDTH-1:0]         wr_data;
    logic [PRIORITY_BITS-1:0] wr_priority;

    logic                     rd_valid;
    logic                     rd_ready;
    logic [WIDTH-1:0]         rd_data;
    logic [PRIORITY_BITS-1:0] rd_priority;

    logic full;
    logic empty;

    int error_count;

    // ------------------------------------------------------------
    // DUT
    // ------------------------------------------------------------

    anoc_rv_priority_fifo #(
        .WIDTH(WIDTH),
        .PRIORITY_BITS(PRIORITY_BITS),
        .DEPTH(DEPTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),

        .wr_valid(wr_valid),
        .wr_ready(wr_ready),
        .wr_data(wr_data),
        .wr_priority(wr_priority),

        .rd_valid(rd_valid),
        .rd_ready(rd_ready),
        .rd_data(rd_data),
        .rd_priority(rd_priority),

        .full(full),
        .empty(empty)
    );

    // ------------------------------------------------------------
    // Clock
    // ------------------------------------------------------------

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // ------------------------------------------------------------
    // Waveform
    // ------------------------------------------------------------

    initial begin
        $dumpfile("results/simulation/priority_fifo.vcd");
        $dumpvars(0, tb_anoc_rv_priority_fifo);
    end

    // ------------------------------------------------------------
    // Main test
    // ------------------------------------------------------------

    initial begin

        error_count = 0;

        rst_n       = 1'b0;
        wr_valid    = 1'b0;
        wr_data     = '0;
        wr_priority = '0;
        rd_ready    = 1'b0;

        repeat (2)
            @(posedge clk);

        rst_n = 1'b1;

        // ========================================================
        // TEST 1: Priority ordering
        // ========================================================

        $display("");
        $display("========================================");
        $display("TEST 1: PRIORITY ORDERING");
        $display("========================================");

        write_item(128'h000000000000000000000000AAAA0001, 2'd1);
        write_item(128'h000000000000000000000000AAAA0003, 2'd3);
        write_item(128'h000000000000000000000000AAAA0000, 2'd0);
        write_item(128'h000000000000000000000000AAAA0002, 2'd2);
        write_item(128'h000000000000000000000000BBBB0003, 2'd3);

        $display("");
        $display("Expected order:");
        $display("AAAA_0003  Priority 3");
        $display("BBBB_0003  Priority 3");
        $display("AAAA_0002  Priority 2");
        $display("AAAA_0001  Priority 1");
        $display("AAAA_0000  Priority 0");

        $display("");
        $display("Actual order:");

        read_item(128'h000000000000000000000000AAAA0003, 2'd3);
        read_item(128'h000000000000000000000000BBBB0003, 2'd3);
        read_item(128'h000000000000000000000000AAAA0002, 2'd2);
        read_item(128'h000000000000000000000000AAAA0001, 2'd1);
        read_item(128'h000000000000000000000000AAAA0000, 2'd0);

        // ========================================================
        // TEST 2: Empty
        // ========================================================

        $display("");
        $display("========================================");
        $display("TEST 2: EMPTY CHECK");
        $display("========================================");

        @(posedge clk);

        if (!empty) begin

            $error("[ERROR] FIFO should be EMPTY");
            error_count++;

        end
        else begin

            $display("[PASS] FIFO EMPTY");

        end

        // ========================================================
        // TEST 3: Fill FIFO
        // ========================================================

        $display("");
        $display("========================================");
        $display("TEST 3: FIFO FULL");
        $display("========================================");

        write_item(128'h00000000000000000000000010000000, 2'd0);
        write_item(128'h00000000000000000000000010000001, 2'd1);
        write_item(128'h00000000000000000000000010000002, 2'd2);
        write_item(128'h00000000000000000000000010000003, 2'd3);
        write_item(128'h00000000000000000000000010000004, 2'd0);
        write_item(128'h00000000000000000000000010000005, 2'd1);
        write_item(128'h00000000000000000000000010000006, 2'd2);
        write_item(128'h00000000000000000000000010000007, 2'd3);

        @(posedge clk);

        if (!full) begin

            $error("[ERROR] FIFO should be FULL");
            error_count++;

        end
        else begin

            $display("[PASS] FIFO FULL");

        end

        // ========================================================
        // TEST 4: Overflow protection
        // ========================================================

        $display("");
        $display("========================================");
        $display("TEST 4: OVERFLOW PROTECTION");
        $display("========================================");

        @(negedge clk);

        wr_valid    = 1'b1;
        wr_data     = 128'h000000000000000000000000DEADBEEF;
        wr_priority = 2'd3;

        @(posedge clk);

        if (wr_ready) begin

            $error("[ERROR] FIFO accepted data while FULL");
            error_count++;

        end
        else begin

            $display("[PASS] Overflow prevented");

        end

        @(negedge clk);

        wr_valid = 1'b0;

        // ========================================================
        // TEST 5: Read all entries
        // ========================================================

        $display("");
        $display("========================================");
        $display("TEST 5: READ AFTER FULL");
        $display("========================================");

        read_item(128'h00000000000000000000000010000003, 2'd3);
        read_item(128'h00000000000000000000000010000007, 2'd3);
        read_item(128'h00000000000000000000000010000002, 2'd2);
        read_item(128'h00000000000000000000000010000006, 2'd2);
        read_item(128'h00000000000000000000000010000001, 2'd1);
        read_item(128'h00000000000000000000000010000005, 2'd1);
        read_item(128'h00000000000000000000000010000000, 2'd0);
        read_item(128'h00000000000000000000000010000004, 2'd0);

        // ========================================================
        // Final empty check
        // ========================================================

        @(posedge clk);

        if (!empty) begin

            $error("[ERROR] FIFO should be EMPTY");
            error_count++;

        end
        else begin

            $display("[PASS] FIFO EMPTY after all reads");

        end

        // ========================================================
        // Summary
        // ========================================================

        $display("");
        $display("========================================");
        $display("PRIORITY FIFO VERIFICATION SUMMARY");
        $display("========================================");

        $display("Errors : %0d", error_count);

        if (error_count == 0) begin

            $display("");
            $display("***************************************");
            $display("*   PRIORITY FIFO VERIFICATION PASS   *");
            $display("***************************************");

        end
        else begin

            $display("");
            $display("***************************************");
            $display("*   PRIORITY FIFO VERIFICATION FAIL   *");
            $display("***************************************");

        end

        #20;

        $finish;

    end

    // ------------------------------------------------------------
    // Write task
    // ------------------------------------------------------------

    task automatic write_item(
        input logic [WIDTH-1:0] data,
        input logic [PRIORITY_BITS-1:0] prio
    );

        begin

            @(negedge clk);

            wr_valid    = 1'b1;
            wr_data     = data;
            wr_priority = prio;

            @(posedge clk);

            if (wr_ready) begin

                $display(
                    "[WRITE] data=%h priority=%0d",
                    wr_data,
                    wr_priority
                );

            end
            else begin

                $error("[ERROR] FIFO unexpectedly FULL");
                error_count++;

            end

            @(negedge clk);

            wr_valid = 1'b0;

        end

    endtask

    // ------------------------------------------------------------
    // Read task
    // ------------------------------------------------------------

    task automatic read_item(
        input logic [WIDTH-1:0] expected_data,
        input logic [PRIORITY_BITS-1:0] expected_prio
    );

        begin

            @(negedge clk);

            rd_ready = 1'b1;

            @(posedge clk);

            if (!rd_valid) begin

                $error("[ERROR] FIFO unexpectedly EMPTY");
                error_count++;

            end
            else if (
                rd_data !== expected_data ||
                rd_priority !== expected_prio
            ) begin

                $error(
                    "[ERROR] Expected data=%h priority=%0d, Got data=%h priority=%0d",
                    expected_data,
                    expected_prio,
                    rd_data,
                    rd_priority
                );

                error_count++;

            end
            else begin

                $display(
                    "[READ PASS] data=%h priority=%0d",
                    rd_data,
                    rd_priority
                );

            end

            @(negedge clk);

            rd_ready = 1'b0;

        end

    endtask

endmodule
