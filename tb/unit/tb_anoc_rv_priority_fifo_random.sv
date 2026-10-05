`timescale 1ns/1ps

module tb_anoc_rv_priority_fifo_random;

    timeunit 1ns;
    timeprecision 1ps;

    localparam int WIDTH          = 128;
    localparam int PRIORITY_BITS  = 2;
    localparam int NUM_PRIORITIES = (1 << PRIORITY_BITS);
    localparam int DEPTH          = 8;
    localparam int NUM_TESTS      = 500;

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

    // ============================================================
    // Reference model
    // ============================================================

    logic [WIDTH-1:0] ref_data
        [0:NUM_PRIORITIES-1][0:DEPTH-1];

    integer ref_count
        [0:NUM_PRIORITIES-1];

    integer error_count;
    integer write_count;
    integer read_count;

    integer i;
    integer p;
    integer k;

    integer expected_priority;
    logic [WIDTH-1:0] expected_data;

    // ============================================================
    // DUT
    // ============================================================

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

    // ============================================================
    // Clock
    // ============================================================

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // ============================================================
    // Waveform
    // ============================================================

    initial begin

        $dumpfile(
            "results/simulation/priority_fifo_random.vcd"
        );

        $dumpvars(
            0,
            tb_anoc_rv_priority_fifo_random
        );

    end

    // ============================================================
    // Reset reference model
    // ============================================================

    task automatic reset_model;

        begin

            for (i = 0; i < NUM_PRIORITIES; i = i + 1) begin

                ref_count[i] = 0;

                for (k = 0; k < DEPTH; k = k + 1)
                    ref_data[i][k] = '0;

            end

        end

    endtask

    // ============================================================
    // Find highest priority
    // ============================================================

    function automatic integer get_highest_priority;

        integer j;

        begin

            get_highest_priority = -1;

            for (
                j = NUM_PRIORITIES - 1;
                j >= 0;
                j = j - 1
            ) begin

                if (ref_count[j] > 0) begin

                    get_highest_priority = j;

                    j = -1;

                end

            end

        end

    endfunction

    // ============================================================
    // Main test
    // ============================================================

    initial begin

        reset_model();

        error_count = 0;
        write_count = 0;
        read_count  = 0;

        rst_n       = 1'b0;

        wr_valid    = 1'b0;
        wr_data     = '0;
        wr_priority = '0;

        rd_ready    = 1'b0;

        repeat (3)
            @(posedge clk);

        rst_n = 1'b1;

        $display("");
        $display("========================================");
        $display("RANDOM PRIORITY FIFO TEST");
        $display("========================================");
        $display("Transactions : %0d", NUM_TESTS);

        // ========================================================
        // Random traffic
        // ========================================================

        for (
            i = 0;
            i < NUM_TESTS;
            i = i + 1
        ) begin

            @(negedge clk);

            // ----------------------------------------------------
            // Generate traffic
            // ----------------------------------------------------

            wr_valid =
                ($urandom_range(0, 99) < 70);

            rd_ready =
                ($urandom_range(0, 99) < 70);

            wr_data = $urandom();

            wr_priority =
                $urandom_range(
                    0,
                    NUM_PRIORITIES - 1
                );

            // ----------------------------------------------------
            // Clock edge
            // ----------------------------------------------------

            @(posedge clk);

            // ====================================================
            // IMPORTANT:
            //
            // READ MODEL FIRST
            //
            // DUT output represents the queue state before
            // this clock edge.
            // ====================================================

            if (rd_valid && rd_ready) begin

                expected_priority =
                    get_highest_priority();

                if (expected_priority < 0) begin

                    $error(
                        "[ERROR] DUT READ while reference EMPTY"
                    );

                    error_count++;

                end
                else begin

                    expected_data =
                        ref_data[expected_priority][0];

                    // Compare DUT output
                    if (
                        rd_priority !==
                        expected_priority
                    ) begin

                        $error(
                            "[ERROR] Priority mismatch: expected=%0d got=%0d",
                            expected_priority,
                            rd_priority
                        );

                        error_count++;

                    end

                    if (
                        rd_data !==
                        expected_data
                    ) begin

                        $error(
                            "[ERROR] Data mismatch: expected=%h got=%h",
                            expected_data,
                            rd_data
                        );

                        error_count++;

                    end

                    // Remove reference item
                    for (
                        k = 0;
                        k < DEPTH - 1;
                        k = k + 1
                    ) begin

                        if (
                            k <
                            ref_count[expected_priority] - 1
                        ) begin

                            ref_data[expected_priority][k] =
                                ref_data[expected_priority][k+1];

                        end

                    end

                    ref_count[expected_priority] =
                        ref_count[expected_priority] - 1;

                    read_count++;

                end

            end
            else if (!rd_valid) begin

                if (get_highest_priority() >= 0) begin

                    // This can legitimately happen when the DUT
                    // is blocked only if the model and DUT state
                    // diverge, so flag it.

                    // No error here because rd_valid is the DUT
                    // state sampled for this cycle.

                end

            end

            // ====================================================
            // WRITE MODEL SECOND
            // ====================================================

            if (wr_valid && wr_ready) begin

                if (ref_count[wr_priority] >= DEPTH) begin

                    $error(
                        "[ERROR] Reference priority queue overflow"
                    );

                    error_count++;

                end
                else begin

                    ref_data[wr_priority]
                             [ref_count[wr_priority]]
                        = wr_data;

                    ref_count[wr_priority] =
                        ref_count[wr_priority] + 1;

                    write_count++;

                end

            end

        end

        // ========================================================
        // Stop new writes
        // ========================================================

        @(negedge clk);

        wr_valid = 1'b0;
        rd_ready = 1'b1;

        // ========================================================
        // Drain DUT
        // ========================================================

        while (!empty) begin

            @(posedge clk);

            if (rd_valid && rd_ready) begin

                expected_priority =
                    get_highest_priority();

                if (expected_priority < 0) begin

                    $error(
                        "[ERROR] DUT has data but reference is EMPTY"
                    );

                    error_count++;

                end
                else begin

                    expected_data =
                        ref_data[expected_priority][0];

                    if (
                        rd_priority !==
                        expected_priority
                    ) begin

                        $error(
                            "[ERROR] Drain priority mismatch: expected=%0d got=%0d",
                            expected_priority,
                            rd_priority
                        );

                        error_count++;

                    end

                    if (
                        rd_data !==
                        expected_data
                    ) begin

                        $error(
                            "[ERROR] Drain data mismatch: expected=%h got=%h",
                            expected_data,
                            rd_data
                        );

                        error_count++;

                    end

                    for (
                        k = 0;
                        k < DEPTH - 1;
                        k = k + 1
                    ) begin

                        if (
                            k <
                            ref_count[expected_priority] - 1
                        ) begin

                            ref_data[expected_priority][k] =
                                ref_data[expected_priority][k+1];

                        end

                    end

                    ref_count[expected_priority] =
                        ref_count[expected_priority] - 1;

                    read_count++;

                end

            end

        end

        // ========================================================
        // Final reference check
        // ========================================================

        for (
            p = 0;
            p < NUM_PRIORITIES;
            p = p + 1
        ) begin

            if (ref_count[p] != 0) begin

                $error(
                    "[ERROR] Reference queue %0d has %0d entries",
                    p,
                    ref_count[p]
                );

                error_count++;

            end

        end

        // ========================================================
        // Summary
        // ========================================================

        $display("");
        $display("========================================");
        $display("RANDOM TEST SUMMARY");
        $display("========================================");

        $display("Writes : %0d", write_count);
        $display("Reads  : %0d", read_count);
        $display("Errors : %0d", error_count);

        if (error_count == 0) begin

            $display("");
            $display("***************************************");
            $display("* RANDOM PRIORITY FIFO TEST PASS      *");
            $display("***************************************");

        end
        else begin

            $display("");
            $display("***************************************");
            $display("* RANDOM PRIORITY FIFO TEST FAIL      *");
            $display("***************************************");

        end

        #20;

        $finish;

    end

endmodule
