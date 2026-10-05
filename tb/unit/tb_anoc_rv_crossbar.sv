`timescale 1ns/1ps

module tb_anoc_rv_crossbar;

    localparam int NUM_PORTS = 5;
    localparam int DATA_WIDTH = 128;
    localparam int SEL_WIDTH = $clog2(NUM_PORTS);

    logic [DATA_WIDTH-1:0] data_in [0:NUM_PORTS-1];
    logic [SEL_WIDTH-1:0] select [0:NUM_PORTS-1];
    logic [DATA_WIDTH-1:0] data_out [0:NUM_PORTS-1];

    integer errors;
    integer i;

    anoc_rv_crossbar #(
        .NUM_PORTS(NUM_PORTS),
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .data_in(data_in),
        .select(select),
        .data_out(data_out)
    );

    task automatic check_crossbar;
        begin
            #1;

            for (i = 0; i < NUM_PORTS; i = i + 1) begin
                if (data_out[i] !== data_in[select[i]]) begin
                    $display("ERROR: output[%0d] expected=%h got=%h",
                             i, data_in[select[i]], data_out[i]);
                    errors = errors + 1;
                end
                else begin
                    $display("PASS : output[%0d] = input[%0d] = %h",
                             i, select[i], data_out[i]);
                end
            end
        end
    endtask

    initial begin
        errors = 0;

        $dumpfile("results/simulation/crossbar.vcd");
        $dumpvars(0, tb_anoc_rv_crossbar);

        $display("");
        $display("========================================");
        $display("CROSSBAR TEST");
        $display("========================================");

        // Unique data on all five inputs
        data_in[0] = 128'hAAAA0000000000000000000000000001;
        data_in[1] = 128'hBBBB1111000000000000000000000002;
        data_in[2] = 128'hCCCC2222000000000000000000000003;
        data_in[3] = 128'hDDDD3333000000000000000000000004;
        data_in[4] = 128'hEEEE4444000000000000000000000005;

        // Test 1: identity
        select[0] = 0;
        select[1] = 1;
        select[2] = 2;
        select[3] = 3;
        select[4] = 4;

        $display("");
        $display("TEST 1: Identity routing");
        check_crossbar;

        // Test 2: reverse
        select[0] = 4;
        select[1] = 3;
        select[2] = 2;
        select[3] = 1;
        select[4] = 0;

        $display("");
        $display("TEST 2: Reverse routing");
        check_crossbar;

        // Test 3: arbitrary routing
        select[0] = 2;
        select[1] = 4;
        select[2] = 0;
        select[3] = 3;
        select[4] = 1;

        $display("");
        $display("TEST 3: Arbitrary routing");
        check_crossbar;

        // Test 4: multiple outputs selecting same input
        select[0] = 2;
        select[1] = 2;
        select[2] = 2;
        select[3] = 2;
        select[4] = 2;

        $display("");
        $display("TEST 4: Multiple outputs from same input");
        check_crossbar;

        $display("");
        $display("========================================");
        $display("CROSSBAR TEST SUMMARY");
        $display("========================================");
        $display("Errors : %0d", errors);

        if (errors == 0) begin
            $display("");
            $display("***************************************");
            $display("* CROSSBAR TEST PASS                 *");
            $display("***************************************");
        end
        else begin
            $display("");
            $display("***************************************");
            $display("* CROSSBAR TEST FAIL                 *");
            $display("***************************************");
        end

        $finish;
    end

endmodule
