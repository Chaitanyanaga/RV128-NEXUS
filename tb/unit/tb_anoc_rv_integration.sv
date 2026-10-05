`timescale 1ns/1ps

module tb_anoc_rv_integration;

    localparam int DATA_WIDTH  = 128;
    localparam int COORD_WIDTH = 4;
    localparam int NUM_PORTS   = 5;

    localparam int LOCAL = 0;
    localparam int NORTH = 1;
    localparam int SOUTH = 2;
    localparam int EAST  = 3;
    localparam int WEST  = 4;

    logic clk;
    logic rst_n;

    logic [COORD_WIDTH-1:0] current_x, current_y;

    logic [DATA_WIDTH-1:0] data_in [0:NUM_PORTS-1];
    logic [COORD_WIDTH-1:0] dest_x [0:NUM_PORTS-1];
    logic [COORD_WIDTH-1:0] dest_y [0:NUM_PORTS-1];
    logic valid_in [0:NUM_PORTS-1];
    logic ready_in [0:NUM_PORTS-1];

    logic ready_out [0:NUM_PORTS-1];
    logic [DATA_WIDTH-1:0] data_out [0:NUM_PORTS-1];
    logic valid_out [0:NUM_PORTS-1];

    integer i;
    integer errors;

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

    task clear_inputs;
        begin
            for (i = 0; i < NUM_PORTS; i = i + 1) begin
                data_in[i] = '0;
                dest_x[i] = '0;
                dest_y[i] = '0;
                valid_in[i] = 1'b0;
                ready_out[i] = 1'b0;
            end
        end
    endtask

    task send_packet;
        input integer in_port;
        input integer out_port;
        input [127:0] packet_data;
        begin
            @(negedge clk);

            data_in[in_port] = packet_data;
            dest_x[in_port] = current_x;
            dest_y[in_port] = current_y;
            valid_in[in_port] = 1'b1;

            case (out_port)
                LOCAL: begin
                    dest_x[in_port] = current_x;
                    dest_y[in_port] = current_y;
                end
                NORTH: begin
                    dest_x[in_port] = current_x;
                    dest_y[in_port] = current_y + 1;
                end
                SOUTH: begin
                    dest_x[in_port] = current_x;
                    dest_y[in_port] = current_y - 1;
                end
                EAST: begin
                    dest_x[in_port] = current_x + 1;
                    dest_y[in_port] = current_y;
                end
                WEST: begin
                    dest_x[in_port] = current_x - 1;
                    dest_y[in_port] = current_y;
                end
            endcase

            #1;

            if (!ready_in[in_port]) begin
                errors = errors + 1;
                $display("FAIL : input %0d buffer was not ready", in_port);
            end
            else begin
                $display("PASS : input %0d buffer ready", in_port);
            end

            @(posedge clk);
            #1;

            $display("PASS : packet accepted on input %0d", in_port);

            @(negedge clk);
            valid_in[in_port] = 1'b0;
            ready_out[out_port] = 1'b1;

            #1;

            if (!valid_out[out_port]) begin
                errors = errors + 1;
                $display("FAIL : packet did not route to output %0d", out_port);
            end
            else if (data_out[out_port] !== packet_data) begin
                errors = errors + 1;
                $display("FAIL : data corruption on output %0d", out_port);
            end
            else begin
                $display("PASS : packet correctly routed to output %0d",
                         out_port);
            end

            @(posedge clk);
            #1;

            @(negedge clk);
            ready_out[out_port] = 1'b0;
        end
    endtask

    initial begin
        clk = 1'b0;
        rst_n = 1'b0;
        errors = 0;

        current_x = 4;
        current_y = 4;

        clear_inputs();

        repeat (2) @(posedge clk);
        rst_n = 1'b1;

        $display("");
        $display("==============================================");
        $display("ANOC-RV 5-DIRECTION INTEGRATION TEST");
        $display("==============================================");

        // LOCAL
        send_packet(0, LOCAL,
            128'h00000000000000000000000000000011);

        // NORTH
        send_packet(0, NORTH,
            128'h00000000000000000000000000000022);

        // SOUTH
        send_packet(0, SOUTH,
            128'h00000000000000000000000000000033);

        // EAST
        send_packet(0, EAST,
            128'h00000000000000000000000000000044);

        // WEST
        send_packet(0, WEST,
            128'h00000000000000000000000000000055);

        $display("");
        $display("==============================================");
        $display("TEST: OUTPUT CONTENTION");
        $display("==============================================");

        // Two inputs request EAST simultaneously.
        @(negedge clk);

        data_in[0] = 128'h000000000000000000000000AAAA0001;
        dest_x[0] = current_x + 1;
        dest_y[0] = current_y;
        valid_in[0] = 1'b1;

        data_in[1] = 128'h000000000000000000000000BBBB0002;
        dest_x[1] = current_x + 1;
        dest_y[1] = current_y;
        valid_in[1] = 1'b1;

        @(posedge clk);
        #1;

        @(negedge clk);
        valid_in[0] = 1'b0;
        valid_in[1] = 1'b0;
        ready_out[EAST] = 1'b1;

        #1;

        if (valid_out[EAST] !== 1'b1) begin
            errors = errors + 1;
            $display("FAIL : EAST contention produced no winner");
        end
        else if (data_out[EAST] !==
                 128'h000000000000000000000000AAAA0001) begin
            errors = errors + 1;
            $display("FAIL : arbitration winner was incorrect");
            $display("Actual EAST data = %032h", data_out[EAST]);
        end
        else begin
            $display("PASS : EAST contention resolved, input 0 wins");
        end

        @(posedge clk);
        #1;

        @(negedge clk);
        ready_out[EAST] = 1'b0;

        // Allow input 1 to win after input 0 is consumed.
        @(negedge clk);
        ready_out[EAST] = 1'b1;

        #1;

        if (valid_out[EAST] !== 1'b1) begin
            errors = errors + 1;
            $display("FAIL : second contending packet was lost");
        end
        else if (data_out[EAST] !==
                 128'h000000000000000000000000BBBB0002) begin
            errors = errors + 1;
            $display("FAIL : second arbitration winner incorrect");
        end
        else begin
            $display("PASS : second packet released after first consumed");
        end

        @(posedge clk);
        #1;

        $display("");
        $display("==============================================");
        $display("INTEGRATION TEST SUMMARY");
        $display("==============================================");
        $display("Directions tested : 5");
        $display("Contention tested : YES");
        $display("FLIT width        : %0d bits", DATA_WIDTH);
        $display("Errors            : %0d", errors);

        if (errors == 0) begin
            $display("");
            $display("***************************************");
            $display("* ANOC-RV INTEGRATION TEST PASS      *");
            $display("***************************************");
        end
        else begin
            $display("");
            $display("***************************************");
            $display("* ANOC-RV INTEGRATION TEST FAIL      *");
            $display("***************************************");
        end

        $finish;
    end

endmodule
