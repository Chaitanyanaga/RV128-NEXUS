`timescale 1ns/1ps

module tb_anoc_rv_mesh_stress;

    parameter int N = 4;
    parameter int DATA_WIDTH = 128;
    parameter int COORD_WIDTH = 4;
    parameter int NODES = N*N;
    parameter int NUM_TESTS = 500;

    logic clk;
    logic rst_n;

    logic [DATA_WIDTH-1:0] data_in [0:NODES-1];
    logic [COORD_WIDTH-1:0] dest_x [0:NODES-1];
    logic [COORD_WIDTH-1:0] dest_y [0:NODES-1];
    logic valid_in [0:NODES-1];
    logic ready_in [0:NODES-1];

    logic [DATA_WIDTH-1:0] data_out [0:NODES-1];
    logic valid_out [0:NODES-1];

    reg [DATA_WIDTH-1:0] expected_data;
    reg [DATA_WIDTH-1:0] expected [0:NODES-1];
    reg pending [0:NODES-1];

    integer sent;
    integer received;
    integer errors;
    integer src;
    integer dst;
    integer k;
    integer timeout;

    anoc_rv_mesh #(
        .DATA_WIDTH(DATA_WIDTH),
        .COORD_WIDTH(COORD_WIDTH),
        .NUM_PORTS(5),
        .N(N)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(data_in),
        .dest_x(dest_x),
        .dest_y(dest_y),
        .valid_in(valid_in),
        .ready_in(ready_in),
        .data_out(data_out),
        .valid_out(valid_out)
    );

    always #5 clk = ~clk;

    task clear_inputs;
        integer i;
        begin
            for (i = 0; i < NODES; i = i + 1) begin
                data_in[i]  = '0;
                dest_x[i]   = '0;
                dest_y[i]   = '0;
                valid_in[i] = 1'b0;
            end
        end
    endtask

    initial begin

        clk = 0;
        rst_n = 0;

        sent = 0;
        received = 0;
        errors = 0;

        clear_inputs();

        for (k = 0; k < NODES; k = k + 1) begin
            expected[k] = '0;
            pending[k] = 1'b0;
        end

        repeat (3) @(posedge clk);
        rst_n = 1;

        @(posedge clk);
        #1;

        $display("");
        $display("==============================================");
        $display("ANOC-RV NxN STRESS TEST");
        $display("==============================================");
        $display("Mesh        : %0dx%0d", N, N);
        $display("Nodes       : %0d", NODES);
        $display("Packets     : %0d", NUM_TESTS);
        $display("FLIT        : %0d bits", DATA_WIDTH);
        $display("");

        // ==========================================================
        // PHASE 1
        // Send packets one-by-one while continuously checking outputs.
        // ==========================================================

        for (sent = 0; sent < NUM_TESTS; sent = sent + 1) begin

            src = $urandom % NODES;
            dst = $urandom % NODES;

            while (dst == src)
                dst = $urandom % NODES;

            expected_data = {
                $urandom,
                $urandom,
                $urandom,
                $urandom
            };

            expected[dst] = expected_data;
            pending[dst] = 1'b1;

            data_in[src] = expected_data;
            dest_x[src] = dst % N;
            dest_y[src] = dst / N;
            valid_in[src] = 1'b1;

            while (!ready_in[src]) begin
                @(posedge clk);
            end

            @(posedge clk);
            #1;

            valid_in[src] = 1'b0;
            data_in[src] = '0;
            dest_x[src] = '0;
            dest_y[src] = '0;

            // Wait for destination.
            timeout = 0;

            while (!valid_out[dst] && timeout < 100) begin

                @(posedge clk);
                #1;

                // Check any unexpected output.
                for (k = 0; k < NODES; k = k + 1) begin
                    if (valid_out[k] && k != dst) begin
                        // A packet at another node is allowed only if
                        // it belongs to a pending transaction.
                        if (!pending[k]) begin
                            errors = errors + 1;
                            $display(
                                "FAIL: unexpected output at R%0d during packet %0d",
                                k, sent+1
                            );
                        end
                    end
                end

                timeout = timeout + 1;
            end

            if (!valid_out[dst]) begin
                errors = errors + 1;
                $display(
                    "FAIL PACKET %0d : R%0d -> R%0d TIMEOUT",
                    sent+1, src, dst
                );
            end
            else if (data_out[dst] !== expected_data) begin
                errors = errors + 1;
                $display(
                    "FAIL PACKET %0d : R%0d -> R%0d DATA MISMATCH",
                    sent+1, src, dst
                );
            end
            else begin
                received = received + 1;
                pending[dst] = 1'b0;

                if ((sent < 10) || ((sent+1) % 100 == 0)) begin
                    $display(
                        "PASS PACKET %0d : R%0d -> R%0d",
                        sent+1, src, dst
                    );
                end
            end

            @(posedge clk);
            #1;
        end

        // ==========================================================
        // SUMMARY
        // ==========================================================

        $display("");
        $display("==============================================");
        $display("NxN STRESS TEST SUMMARY");
        $display("==============================================");
        $display("Mesh            : %0dx%0d", N, N);
        $display("Nodes           : %0d", NODES);
        $display("Packets sent    : %0d", NUM_TESTS);
        $display("Packets received: %0d", received);
        $display("Errors          : %0d", errors);
        $display("");

        if ((errors == 0) && (received == NUM_TESTS)) begin
            $display("***************************************");
            $display("* NxN STRESS TEST PASS               *");
            $display("***************************************");
        end
        else begin
            $display("***************************************");
            $display("* NxN STRESS TEST FAIL               *");
            $display("***************************************");
        end

        $finish;
    end

endmodule
