`timescale 1ns/1ps

module tb_anoc_rv_router_buffered;

    localparam int DATA_WIDTH = 128;
    localparam int COORD_WIDTH = 4;
    localparam int NUM_PORTS = 5;

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

    integer errors;
    integer i;

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

    task automatic clear_inputs;
        begin
            for (i = 0; i < NUM_PORTS; i = i + 1) begin
                data_in[i] = '0;
                dest_x[i] = current_x;
                dest_y[i] = current_y;
                valid_in[i] = 1'b0;
                ready_out[i] = 1'b1;
            end
        end
    endtask

    initial begin
        errors = 0;
        clk = 0;
        rst_n = 0;

        current_x = 2;
        current_y = 2;

        clear_inputs;

        $dumpfile("results/simulation/router_buffered.vcd");
        $dumpvars(0, tb_anoc_rv_router_buffered);

        $display("");
        $display("========================================");
        $display("BUFFERED ROUTER TEST");
        $display("========================================");

        #12;
        rst_n = 1;

        // Input 0 sends EAST.
        data_in[0] = 128'h000000000000000000000000AAAA1234;
        dest_x[0] = 3;
        dest_y[0] = 2;
        valid_in[0] = 1'b1;

        @(posedge clk);
        #1;

        valid_in[0] = 1'b0;

        // Packet must remain buffered and visible at EAST.
        #1;

        if (valid_out[3] !== 1'b1) begin
            $display("ERROR: EAST output not valid");
            errors = errors + 1;
        end
        else if (data_out[3] !== 128'h000000000000000000000000AAAA1234) begin
            $display("ERROR: EAST data mismatch expected=AAAA1234 got=%h",
                     data_out[3]);
            errors = errors + 1;
        end
        else begin
            $display("PASS : packet buffered and routed EAST");
        end

        // Consume EAST packet.
        ready_out[3] = 1'b1;

        @(posedge clk);
        #1;

        if (valid_out[3] !== 1'b0) begin
            $display("ERROR: EAST output still valid after consume");
            errors = errors + 1;
        end
        else begin
            $display("PASS : packet consumed successfully");
        end

        // Test blocked output.
        data_in[1] = 128'h000000000000000000000000BBBB5678;
        dest_x[1] = 1;
        dest_y[1] = 2;
        valid_in[1] = 1'b1;

        @(posedge clk);
        #1;

        valid_in[1] = 1'b0;
        ready_out[4] = 1'b0;

        #1;

        if (valid_out[4] !== 1'b1) begin
            $display("ERROR: WEST packet missing");
            errors = errors + 1;
        end
        else begin
            $display("PASS : packet held while WEST output blocked");
        end

        // Re-enable WEST.
        ready_out[4] = 1'b1;

        @(posedge clk);
        #1;

        if (valid_out[4] !== 1'b0) begin
            $display("ERROR: WEST packet not consumed");
            errors = errors + 1;
        end
        else begin
            $display("PASS : blocked packet released after ready");
        end

        $display("");
        $display("========================================");
        $display("BUFFERED ROUTER TEST SUMMARY");
        $display("========================================");
        $display("Errors : %0d", errors);

        if (errors == 0) begin
            $display("");
            $display("***************************************");
            $display("* BUFFERED ROUTER TEST PASS           *");
            $display("***************************************");
        end
        else begin
            $display("");
            $display("***************************************");
            $display("* BUFFERED ROUTER TEST FAIL           *");
            $display("***************************************");
        end

        $finish;
    end

endmodule
