`timescale 1ns/1ps

module tb_anoc_rv_mesh_contention;

    parameter int N = 4;
    parameter int DATA_WIDTH = 128;
    parameter int COORD_WIDTH = 4;
    parameter int NODES = N*N;

    logic clk;
    logic rst_n;

    logic [DATA_WIDTH-1:0] data_in [0:NODES-1];
    logic [COORD_WIDTH-1:0] dest_x [0:NODES-1];
    logic [COORD_WIDTH-1:0] dest_y [0:NODES-1];
    logic valid_in [0:NODES-1];
    logic ready_in [0:NODES-1];

    logic [DATA_WIDTH-1:0] data_out [0:NODES-1];
    logic valid_out [0:NODES-1];

    integer errors;
    integer k;
    integer cycle;
    integer received;
    reg [DATA_WIDTH-1:0] expected [0:3];
    reg [3:0] got;

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
        errors = 0;
        received = 0;
        got = 0;

        clear_inputs();

        repeat (3) @(posedge clk);
        rst_n = 1;
        @(posedge clk);
        #1;

        $display("");
        $display("==============================================");
        $display("ANOC-RV NxN CONTENTION TEST");
        $display("==============================================");
        $display("Mesh  : %0dx%0d", N, N);
        $display("Target: R15");
        $display("");

        // ==============================================================
        // TEST 1: Four simultaneous packets -> R15
        // Sources: R0, R1, R2, R3
        // ==============================================================
        $display("TEST 1: FOUR SOURCES -> SAME DESTINATION R15");

        expected[0] = 128'h00000000_00000000_AAAA0000_00000001;
        expected[1] = 128'h00000000_00000000_BBBB0000_00000002;
        expected[2] = 128'h00000000_00000000_CCCC0000_00000003;
        expected[3] = 128'h00000000_00000000_DDDD0000_00000004;

        for (k = 0; k < 4; k = k + 1) begin
            data_in[k]  = expected[k];
            dest_x[k]   = 3;
            dest_y[k]   = 3;
            valid_in[k] = 1'b1;
        end

        @(posedge clk);
        #1;

        clear_inputs();

        // Wait until all four packets arrive at R15.
        for (cycle = 0; cycle < 100; cycle = cycle + 1) begin
            @(posedge clk);
            #1;

            if (valid_out[15]) begin
                $display("  R15 received: %h", data_out[15]);

                if (data_out[15] === expected[0]) got[0] = 1'b1;
                if (data_out[15] === expected[1]) got[1] = 1'b1;
                if (data_out[15] === expected[2]) got[2] = 1'b1;
                if (data_out[15] === expected[3]) got[3] = 1'b1;

                received = received + 1;
            end

            if (received == 4)
                cycle = 100;
        end

        if (got == 4'b1111) begin
            $display("PASS : all 4 packets reached R15");
        end
        else begin
            $display("FAIL : missing packets, got = %b", got);
            errors = errors + 1;
        end

        @(posedge clk);
        #1;

        // ==============================================================
        // TEST 2: Four simultaneous packets -> different destinations
        // ==============================================================
        $display("");
        $display("TEST 2: FOUR SIMULTANEOUS INDEPENDENT FLOWS");

        received = 0;
        got = 0;

        expected[0] = 128'h11111111_00000000_00000000_00000001;
        expected[1] = 128'h22222222_00000000_00000000_00000002;
        expected[2] = 128'h33333333_00000000_00000000_00000003;
        expected[3] = 128'h44444444_00000000_00000000_00000004;

        // R0 -> R15
        data_in[0]  = expected[0];
        dest_x[0]   = 3;
        dest_y[0]   = 3;
        valid_in[0] = 1'b1;

        // R3 -> R12
        data_in[3]  = expected[1];
        dest_x[3]   = 0;
        dest_y[3]   = 3;
        valid_in[3] = 1'b1;

        // R12 -> R3
        data_in[12]  = expected[2];
        dest_x[12]   = 3;
        dest_y[12]   = 0;
        valid_in[12] = 1'b1;

        // R15 -> R0
        data_in[15]  = expected[3];
        dest_x[15]   = 0;
        dest_y[15]   = 0;
        valid_in[15] = 1'b1;

        @(posedge clk);
        #1;

        clear_inputs();

        // Check independently for up to 100 cycles.
        for (cycle = 0; cycle < 100; cycle = cycle + 1) begin
            @(posedge clk);
            #1;

            if (valid_out[15] && data_out[15] === expected[0])
                got[0] = 1'b1;

            if (valid_out[12] && data_out[12] === expected[1])
                got[1] = 1'b1;

            if (valid_out[3] && data_out[3] === expected[2])
                got[2] = 1'b1;

            if (valid_out[0] && data_out[0] === expected[3])
                got[3] = 1'b1;

            if (got == 4'b1111)
                cycle = 100;
        end

        if (got == 4'b1111) begin
            $display("PASS : all 4 independent flows reached destinations");
        end
        else begin
            $display("FAIL : independent flow missing, got = %b", got);
            errors = errors + 1;
        end

        // ==============================================================
        // SUMMARY
        // ==============================================================
        $display("");
        $display("==============================================");
        $display("NxN CONTENTION TEST SUMMARY");
        $display("==============================================");
        $display("Mesh   : %0dx%0d", N, N);
        $display("Tests  : 2");
        $display("Errors : %0d", errors);

        if (errors == 0) begin
            $display("");
            $display("***************************************");
            $display("* NxN CONTENTION TEST PASS            *");
            $display("***************************************");
        end
        else begin
            $display("");
            $display("***************************************");
            $display("* NxN CONTENTION TEST FAIL            *");
            $display("***************************************");
        end

        $finish;
    end

endmodule
