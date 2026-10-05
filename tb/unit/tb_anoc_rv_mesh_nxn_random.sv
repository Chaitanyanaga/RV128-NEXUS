`timescale 1ns/1ps

module tb_anoc_rv_mesh_nxn_random;

    parameter int N = 4;
    parameter int DATA_WIDTH = 128;
    parameter int COORD_WIDTH = 4;
    parameter int NODES = N*N;
    parameter int NUM_TESTS = 200;

    logic clk;
    logic rst_n;

    logic [DATA_WIDTH-1:0] data_in [0:NODES-1];
    logic [COORD_WIDTH-1:0] dest_x [0:NODES-1];
    logic [COORD_WIDTH-1:0] dest_y [0:NODES-1];
    logic valid_in [0:NODES-1];
    logic ready_in [0:NODES-1];

    logic [DATA_WIDTH-1:0] data_out [0:NODES-1];
    logic valid_out [0:NODES-1];

    integer test_num;
    integer src;
    integer dst;
    integer errors;
    integer timeout;

    reg [DATA_WIDTH-1:0] expected_data;

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
        integer k;
        begin
            for (k = 0; k < NODES; k = k + 1) begin
                data_in[k]  = '0;
                dest_x[k]   = '0;
                dest_y[k]   = '0;
                valid_in[k] = 1'b0;
            end
        end
    endtask

    initial begin
        clk = 0;
        rst_n = 0;
        errors = 0;

        clear_inputs();

        repeat (3) @(posedge clk);
        rst_n = 1;

        @(posedge clk);
        #1;

        $display("");
        $display("==============================================");
        $display("ANOC-RV NxN RANDOM MESH TEST");
        $display("==============================================");
        $display("Mesh  : %0dx%0d", N, N);
        $display("Nodes : %0d", NODES);
        $display("Tests : %0d", NUM_TESTS);
        $display("FLIT  : %0d bits", DATA_WIDTH);
        $display("");

        for (test_num = 1; test_num <= NUM_TESTS; test_num = test_num + 1) begin

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

            data_in[src] = expected_data;
            dest_x[src] = dst % N;
            dest_y[src] = dst / N;
            valid_in[src] = 1'b1;

            while (!ready_in[src])
                @(posedge clk);

            @(posedge clk);
            #1;

            valid_in[src] = 1'b0;

            timeout = 0;

            while (!valid_out[dst] && timeout < 100) begin
                @(posedge clk);
                #1;
                timeout = timeout + 1;
            end

            if (!valid_out[dst]) begin
                errors = errors + 1;
                $display("FAIL TEST %0d : R%0d -> R%0d : TIMEOUT",
                         test_num, src, dst);
            end
            else if (data_out[dst] !== expected_data) begin
                errors = errors + 1;
                $display("FAIL TEST %0d : R%0d -> R%0d : DATA MISMATCH",
                         test_num, src, dst);
            end
            else if ((test_num <= 10) || (test_num % 25 == 0)) begin
                $display("PASS TEST %0d : R%0d -> R%0d",
                         test_num, src, dst);
            end

            clear_inputs();

            @(posedge clk);
            #1;
        end

        $display("");
        $display("==============================================");
        $display("NxN RANDOM MESH TEST SUMMARY");
        $display("==============================================");
        $display("Mesh   : %0dx%0d", N, N);
        $display("Nodes  : %0d", NODES);
        $display("Tests  : %0d", NUM_TESTS);
        $display("Errors : %0d", errors);

        if (errors == 0) begin
            $display("");
            $display("***************************************");
            $display("* NxN RANDOM MESH TEST PASS          *");
            $display("***************************************");
        end
        else begin
            $display("");
            $display("***************************************");
            $display("* NxN RANDOM MESH TEST FAIL          *");
            $display("***************************************");
        end

        $finish;
    end

endmodule
