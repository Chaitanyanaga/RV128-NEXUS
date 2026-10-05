`timescale 1ns/1ps

module tb_anoc_rv_integration_random;

    localparam int DATA_WIDTH  = 128;
    localparam int COORD_WIDTH = 4;
    localparam int NUM_PORTS   = 5;
    localparam int NUM_TESTS   = 200;

    localparam int LOCAL = 0;
    localparam int NORTH = 1;
    localparam int SOUTH = 2;
    localparam int EAST  = 3;
    localparam int WEST  = 4;

    logic clk;
    logic rst_n;

    logic [COORD_WIDTH-1:0] current_x;
    logic [COORD_WIDTH-1:0] current_y;

    logic [DATA_WIDTH-1:0] data_in [0:NUM_PORTS-1];
    logic [COORD_WIDTH-1:0] dest_x [0:NUM_PORTS-1];
    logic [COORD_WIDTH-1:0] dest_y [0:NUM_PORTS-1];

    logic valid_in [0:NUM_PORTS-1];
    logic ready_in [0:NUM_PORTS-1];

    logic ready_out [0:NUM_PORTS-1];
    logic [DATA_WIDTH-1:0] data_out [0:NUM_PORTS-1];
    logic valid_out [0:NUM_PORTS-1];

    integer test_num;
    integer input_sel;
    integer route_sel;
    integer expected_output;
    integer wait_cycles;
    integer errors;
    integer accepted;
    integer checked;

    reg [DATA_WIDTH-1:0] test_data;

    anoc_rv_router_buffered #(
        .DATA_WIDTH(DATA_WIDTH),
        .COORD_WIDTH(COORD_WIDTH),
        .NUM_PORTS(NUM_PORTS)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .current_x(current_x),
        .current_y(current_y),
        .data_in(data_in),
        .dest_x(dest_x),
        .dest_y(dest_y),
        .valid_in(valid_in),
        .ready_in(ready_in),
        .ready_out(ready_out),
        .data_out(data_out),
        .valid_out(valid_out)
    );

    always #5 clk = ~clk;

    function automatic integer calc_route(
        input [COORD_WIDTH-1:0] dx,
        input [COORD_WIDTH-1:0] dy
    );
        begin
            if (dx > current_x)
                calc_route = EAST;
            else if (dx < current_x)
                calc_route = WEST;
            else if (dy > current_y)
                calc_route = NORTH;
            else if (dy < current_y)
                calc_route = SOUTH;
            else
                calc_route = LOCAL;
        end
    endfunction

    task clear_all_inputs;
        integer n;
        begin
            for (n = 0; n < NUM_PORTS; n = n + 1) begin
                data_in[n]  = '0;
                dest_x[n]   = current_x;
                dest_y[n]   = current_y;
                valid_in[n] = 1'b0;
                ready_out[n] = 1'b1;
            end
        end
    endtask

    initial begin

        clk = 1'b0;
        rst_n = 1'b0;

        current_x = 4;
        current_y = 4;

        errors = 0;
        accepted = 0;
        checked = 0;

        clear_all_inputs();

        repeat (3) @(posedge clk);
        rst_n = 1'b1;

        // Give the DUT one complete cycle to leave reset
        // before starting the first transaction.
        @(posedge clk);
        #1;

        $display("");
        $display("================================================");
        $display("ANOC-RV RANDOM 128-BIT INTEGRATION TEST");
        $display("================================================");
        $display("Tests : %0d", NUM_TESTS);
        $display("FLIT  : %0d bits", DATA_WIDTH);

        for (test_num = 1; test_num <= NUM_TESTS; test_num = test_num + 1) begin

            // -----------------------------------------
            // Generate one random packet
            // -----------------------------------------
            input_sel = $urandom % NUM_PORTS;
            route_sel = $urandom % NUM_PORTS;

            test_data = {
                $urandom,
                $urandom,
                $urandom,
                $urandom
            };

            case (route_sel)

                LOCAL: begin
                    dest_x[input_sel] = current_x;
                    dest_y[input_sel] = current_y;
                end

                NORTH: begin
                    dest_x[input_sel] = current_x;
                    dest_y[input_sel] = current_y + 1;
                end

                SOUTH: begin
                    dest_x[input_sel] = current_x;
                    dest_y[input_sel] = current_y - 1;
                end

                EAST: begin
                    dest_x[input_sel] = current_x + 1;
                    dest_y[input_sel] = current_y;
                end

                WEST: begin
                    dest_x[input_sel] = current_x - 1;
                    dest_y[input_sel] = current_y;
                end

            endcase

            data_in[input_sel] = test_data;
            valid_in[input_sel] = 1'b1;

            expected_output = calc_route(
                dest_x[input_sel],
                dest_y[input_sel]
            );

            // -----------------------------------------
            // Wait until input is accepted
            // -----------------------------------------
            wait_cycles = 0;

            while (!ready_in[input_sel] && wait_cycles < 20) begin
                @(posedge clk);
                #1;
                wait_cycles = wait_cycles + 1;
            end

            if (!ready_in[input_sel]) begin
                errors = errors + 1;
                $display("FAIL TEST %0d : input %0d never became ready",
                         test_num, input_sel);

                valid_in[input_sel] = 1'b0;
                clear_all_inputs();

                @(posedge clk);
                continue;
            end

            accepted = accepted + 1;

            @(posedge clk);
            #1;

            // Keep valid asserted through the acceptance edge,
            // then release it after the buffered packet is visible.
            valid_in[input_sel] = 1'b0;

            // Allow combinational routing/arbitration to settle.
            #1;

            // -----------------------------------------
            // Wait for packet at expected output
            // -----------------------------------------
            wait_cycles = 0;

            while (!valid_out[expected_output] &&
                   wait_cycles < 20) begin

                @(posedge clk);
                #1;
                wait_cycles = wait_cycles + 1;
            end

            if (!valid_out[expected_output]) begin
                errors = errors + 1;

                $display("FAIL TEST %0d : packet never reached output %0d",
                         test_num,
                         expected_output);

            end
            else if (data_out[expected_output] !== test_data) begin

                errors = errors + 1;

                $display("FAIL TEST %0d : DATA mismatch", test_num);
                $display("  Input    = %032h", test_data);
                $display("  Output   = %032h", data_out[expected_output]);
                $display("  Expected output = %0d", expected_output);

            end
            else begin

                checked = checked + 1;

                if ((test_num <= 10) || (test_num % 25 == 0)) begin
                    $display("PASS TEST %0d : input %0d -> output %0d",
                             test_num,
                             input_sel,
                             expected_output);
                end
            end

            // Packet consumed because ready_out = 1.
            @(posedge clk);
            #1;

            clear_all_inputs();

            // Give one clean cycle before next packet.
            @(posedge clk);
            #1;
        end

        // -----------------------------------------
        // Final result
        // -----------------------------------------
        $display("");
        $display("================================================");
        $display("RANDOM INTEGRATION TEST SUMMARY");
        $display("================================================");
        $display("Tests executed : %0d", NUM_TESTS);
        $display("Packets accepted: %0d", accepted);
        $display("Packets checked : %0d", checked);
        $display("Errors          : %0d", errors);

        if (errors == 0) begin
            $display("");
            $display("***************************************");
            $display("* RANDOM INTEGRATION TEST PASS       *");
            $display("***************************************");
        end
        else begin
            $display("");
            $display("***************************************");
            $display("* RANDOM INTEGRATION TEST FAIL       *");
            $display("***************************************");
        end

        $finish;
    end

endmodule
