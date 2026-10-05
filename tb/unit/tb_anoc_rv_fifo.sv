`timescale 1ns/1ps

module tb_anoc_rv_fifo;

    timeunit 1ns;
    timeprecision 1ps;

    localparam int WIDTH = 128;
    localparam int DEPTH = 4;

    logic clk;
    logic rst_n;

    logic             wr_valid;
    logic             wr_ready;
    logic [WIDTH-1:0] wr_data;

    logic             rd_valid;
    logic             rd_ready;
    logic [WIDTH-1:0] rd_data;

    logic full;
    logic empty;

    // ------------------------------------------------------------
    // Reference model
    // ------------------------------------------------------------

    logic [WIDTH-1:0] expected_queue[$];

    int error_count;
    int write_count;
    int read_count;

    // ------------------------------------------------------------
    // DUT
    // ------------------------------------------------------------

    anoc_rv_fifo #(
        .WIDTH(WIDTH),
        .DEPTH(DEPTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),

        .wr_valid(wr_valid),
        .wr_ready(wr_ready),
        .wr_data(wr_data),

        .rd_valid(rd_valid),
        .rd_ready(rd_ready),
        .rd_data(rd_data),

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
        $dumpfile("results/simulation/fifo.vcd");
        $dumpvars(0, tb_anoc_rv_fifo);
    end

    // ------------------------------------------------------------
    // Reset
    // ------------------------------------------------------------

    task automatic reset_dut();

        begin

            rst_n     = 1'b0;
            wr_valid  = 1'b0;
            wr_data   = '0;
            rd_ready  = 1'b0;

            expected_queue.delete();

            repeat (2)
                @(posedge clk);

            rst_n = 1'b1;

            @(posedge clk);

            $display("[TEST] Reset completed");

        end

    endtask

    // ------------------------------------------------------------
    // Write one item
    // ------------------------------------------------------------

    task automatic write_data(
        input logic [WIDTH-1:0] data
    );

        begin

            @(negedge clk);

            wr_valid = 1'b1;
            wr_data  = data;

            @(posedge clk);

            if (wr_ready) begin

                expected_queue.push_back(data);
                write_count++;

                $display(
                    "[WRITE] data=%h queue_size=%0d",
                    data,
                    expected_queue.size()
                );

            end
            else begin

                $display(
                    "[WRITE BLOCKED] FIFO FULL data=%h",
                    data
                );

            end

            @(negedge clk);

            wr_valid = 1'b0;

        end

    endtask

    // ------------------------------------------------------------
    // Read one item
    // ------------------------------------------------------------

    task automatic read_data();

        logic [WIDTH-1:0] expected;

        begin

            @(negedge clk);

            rd_ready = 1'b1;

            @(posedge clk);

            if (rd_valid) begin

                expected = expected_queue.pop_front();

                read_count++;

                if (rd_data !== expected) begin

                    $error(
                        "[ERROR] Expected=%h Got=%h",
                        expected,
                        rd_data
                    );

                    error_count++;

                end
                else begin

                    $display(
                        "[READ PASS] data=%h",
                        rd_data
                    );

                end

            end
            else begin

                if (expected_queue.size() != 0) begin

                    $error(
                        "[ERROR] FIFO empty but reference queue contains %0d items",
                        expected_queue.size()
                    );

                    error_count++;

                end

            end

            @(negedge clk);

            rd_ready = 1'b0;

        end

    endtask

    // ------------------------------------------------------------
    // Main test
    // ------------------------------------------------------------

    initial begin

        error_count = 0;
        write_count = 0;
        read_count  = 0;

        reset_dut();

        // ========================================================
        // TEST 1: Basic write/read
        // ========================================================

        $display("");
        $display("========================================");
        $display("TEST 1: BASIC WRITE/READ");
        $display("========================================");

        write_data(128'h000000000000000000000000AAAA0001);
        write_data(128'h000000000000000000000000AAAA0002);
        write_data(128'h000000000000000000000000AAAA0003);

        read_data();
        read_data();
        read_data();

        // ========================================================
        // TEST 2: Fill FIFO
        // ========================================================

        $display("");
        $display("========================================");
        $display("TEST 2: FIFO FULL");
        $display("========================================");

        write_data(128'h000000000000000000000000BBBB0001);
        write_data(128'h000000000000000000000000BBBB0002);
        write_data(128'h000000000000000000000000BBBB0003);
        write_data(128'h000000000000000000000000BBBB0004);

        @(posedge clk);

        if (!full) begin

            $error("[ERROR] FIFO should be FULL");

            error_count++;

        end
        else begin

            $display("[PASS] FIFO FULL detected");

        end

        // ========================================================
        // TEST 3: Overflow protection
        // ========================================================

        $display("");
        $display("========================================");
        $display("TEST 3: OVERFLOW PROTECTION");
        $display("========================================");

        @(negedge clk);

        wr_valid = 1'b1;
        wr_data  = 128'h000000000000000000000000DEADBEEF;

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
        // TEST 4: Empty FIFO
        // ========================================================

        $display("");
        $display("========================================");
        $display("TEST 4: FIFO EMPTY");
        $display("========================================");

        read_data();
        read_data();
        read_data();
        read_data();

        @(posedge clk);

        if (!empty) begin

            $error("[ERROR] FIFO should be EMPTY");

            error_count++;

        end
        else begin

            $display("[PASS] FIFO EMPTY detected");

        end

        // ========================================================
        // TEST 5: Underflow protection
        // ========================================================

        $display("");
        $display("========================================");
        $display("TEST 5: UNDERFLOW PROTECTION");
        $display("========================================");

        @(negedge clk);

        rd_ready = 1'b1;

        @(posedge clk);

        if (rd_valid) begin

            $error("[ERROR] FIFO produced data while EMPTY");

            error_count++;

        end
        else begin

            $display("[PASS] Underflow prevented");

        end

        @(negedge clk);

        rd_ready = 1'b0;

        // ========================================================
        // Final result
        // ========================================================

        repeat (2)
            @(posedge clk);

        $display("");
        $display("========================================");
        $display("FIFO VERIFICATION SUMMARY");
        $display("========================================");

        $display("Writes       : %0d", write_count);
        $display("Reads        : %0d", read_count);
        $display("Errors       : %0d", error_count);
        $display(
            "Queue left   : %0d",
            expected_queue.size()
        );

        if (error_count == 0 && expected_queue.size() == 0) begin

            $display("");
            $display("***************************************");
            $display("*       FIFO VERIFICATION PASS        *");
            $display("***************************************");

        end
        else begin

            $display("");
            $display("***************************************");
            $display("*       FIFO VERIFICATION FAIL        *");
            $display("***************************************");

        end

        $finish;

    end

endmodule
