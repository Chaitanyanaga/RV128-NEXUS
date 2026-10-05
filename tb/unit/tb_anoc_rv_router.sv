`timescale 1ns/1ps

module tb_anoc_rv_router;

    localparam int DATA_WIDTH = 128;
    localparam int COORD_WIDTH = 4;
    localparam int NUM_PORTS = 5;

    logic [COORD_WIDTH-1:0] current_x;
    logic [COORD_WIDTH-1:0] current_y;

    logic [DATA_WIDTH-1:0] data_in [0:NUM_PORTS-1];
    logic [COORD_WIDTH-1:0] dest_x [0:NUM_PORTS-1];
    logic [COORD_WIDTH-1:0] dest_y [0:NUM_PORTS-1];
    logic valid_in [0:NUM_PORTS-1];

    logic [DATA_WIDTH-1:0] data_out [0:NUM_PORTS-1];
    logic valid_out [0:NUM_PORTS-1];
    logic ready_in [0:NUM_PORTS-1];

    integer errors;
    integer i;

    anoc_rv_router #(
        .DATA_WIDTH(DATA_WIDTH),
        .COORD_WIDTH(COORD_WIDTH),
        .NUM_PORTS(NUM_PORTS)
    ) dut (
        .current_x(current_x),
        .current_y(current_y),
        .data_in(data_in),
        .dest_x(dest_x),
        .dest_y(dest_y),
        .valid_in(valid_in),
        .data_out(data_out),
        .valid_out(valid_out),
        .ready_in(ready_in)
    );

    task automatic clear_inputs;
        begin
            for (i = 0; i < NUM_PORTS; i = i + 1) begin
                data_in[i] = 0;
                dest_x[i] = 2;
                dest_y[i] = 2;
                valid_in[i] = 0;
            end
        end
    endtask

    task automatic check_output(
        input integer output_port,
        input logic [DATA_WIDTH-1:0] expected_data
    );
        begin
            #1;

            if (!valid_out[output_port]) begin
                $display("ERROR: output[%0d] not valid", output_port);
                errors = errors + 1;
            end
            else if (data_out[output_port] !== expected_data) begin
                $display("ERROR: output[%0d] expected=%h got=%h",
                         output_port, expected_data, data_out[output_port]);
                errors = errors + 1;
            end
            else begin
                $display("PASS : output[%0d] data=%h",
                         output_port, data_out[output_port]);
            end
        end
    endtask

    initial begin
        errors = 0;

        current_x = 2;
        current_y = 2;

        $dumpfile("results/simulation/router.vcd");
        $dumpvars(0, tb_anoc_rv_router);

        $display("");
        $display("========================================");
        $display("5-PORT ROUTER TEST");
        $display("========================================");

        // ----------------------------------------
        // TEST 1: LOCAL
        // ----------------------------------------
        clear_inputs;

        data_in[0] = 128'h000000000000000000000000AAAA0001;
        dest_x[0] = 2;
        dest_y[0] = 2;
        valid_in[0] = 1;

        $display("");
        $display("TEST 1: LOCAL routing");
        check_output(0, 128'h000000000000000000000000AAAA0001);

        // ----------------------------------------
        // TEST 2: EAST
        // ----------------------------------------
        clear_inputs;

        data_in[1] = 128'h000000000000000000000000BBBB0002;
        dest_x[1] = 3;
        dest_y[1] = 2;
        valid_in[1] = 1;

        $display("");
        $display("TEST 2: EAST routing");
        check_output(3, 128'h000000000000000000000000BBBB0002);

        // ----------------------------------------
        // TEST 3: WEST
        // ----------------------------------------
        clear_inputs;

        data_in[2] = 128'h000000000000000000000000CCCC0003;
        dest_x[2] = 1;
        dest_y[2] = 2;
        valid_in[2] = 1;

        $display("");
        $display("TEST 3: WEST routing");
        check_output(4, 128'h000000000000000000000000CCCC0003);

        // ----------------------------------------
        // TEST 4: NORTH
        // ----------------------------------------
        clear_inputs;

        data_in[3] = 128'h000000000000000000000000DDDD0004;
        dest_x[3] = 2;
        dest_y[3] = 3;
        valid_in[3] = 1;

        $display("");
        $display("TEST 4: NORTH routing");
        check_output(1, 128'h000000000000000000000000DDDD0004);

        // ----------------------------------------
        // TEST 5: SOUTH
        // ----------------------------------------
        clear_inputs;

        data_in[4] = 128'h000000000000000000000000EEEE0005;
        dest_x[4] = 2;
        dest_y[4] = 1;
        valid_in[4] = 1;

        $display("");
        $display("TEST 5: SOUTH routing");
        check_output(2, 128'h000000000000000000000000EEEE0005);

        // ----------------------------------------
        // TEST 6: Multiple independent routes
        // ----------------------------------------
        clear_inputs;

        data_in[0] = 128'h00000000000000000000000010000001;
        dest_x[0] = 3;
        dest_y[0] = 2;
        valid_in[0] = 1;

        data_in[1] = 128'h00000000000000000000000020000002;
        dest_x[1] = 1;
        dest_y[1] = 2;
        valid_in[1] = 1;

        data_in[2] = 128'h00000000000000000000000030000003;
        dest_x[2] = 2;
        dest_y[2] = 3;
        valid_in[2] = 1;

        data_in[3] = 128'h00000000000000000000000040000004;
        dest_x[3] = 2;
        dest_y[3] = 1;
        valid_in[3] = 1;

        data_in[4] = 128'h00000000000000000000000050000005;
        dest_x[4] = 2;
        dest_y[4] = 2;
        valid_in[4] = 1;

        $display("");
        $display("TEST 6: Multiple independent routes");

        check_output(3, 128'h00000000000000000000000010000001);
        check_output(4, 128'h00000000000000000000000020000002);
        check_output(1, 128'h00000000000000000000000030000003);
        check_output(2, 128'h00000000000000000000000040000004);
        check_output(0, 128'h00000000000000000000000050000005);

        // ----------------------------------------
        // TEST 7: Arbitration
        // Input 0 and Input 1 both request EAST.
        // Input 0 must win.
        // ----------------------------------------
        clear_inputs;

        data_in[0] = 128'h000000000000000000000000AAAA1111;
        dest_x[0] = 3;
        dest_y[0] = 2;
        valid_in[0] = 1;

        data_in[1] = 128'h000000000000000000000000BBBB2222;
        dest_x[1] = 4;
        dest_y[1] = 2;
        valid_in[1] = 1;

        $display("");
        $display("TEST 7: EAST arbitration");

        check_output(3, 128'h000000000000000000000000AAAA1111);

        if (ready_in[0] !== 1'b1) begin
            $display("ERROR: input 0 should be granted");
            errors = errors + 1;
        end
        else begin
            $display("PASS : input 0 granted");
        end

        if (ready_in[1] !== 1'b0) begin
            $display("ERROR: input 1 should not be granted");
            errors = errors + 1;
        end
        else begin
            $display("PASS : input 1 blocked");
        end

        $display("");
        $display("========================================");
        $display("ROUTER TEST SUMMARY");
        $display("========================================");
        $display("Errors : %0d", errors);

        if (errors == 0) begin
            $display("");
            $display("***************************************");
            $display("* 5-PORT ROUTER TEST PASS             *");
            $display("***************************************");
        end
        else begin
            $display("");
            $display("***************************************");
            $display("* 5-PORT ROUTER TEST FAIL             *");
            $display("***************************************");
        end

        $finish;
    end

endmodule
