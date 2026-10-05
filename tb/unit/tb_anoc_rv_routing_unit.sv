`timescale 1ns/1ps

module tb_anoc_rv_routing_unit;

    localparam int COORD_WIDTH = 4;

    localparam logic [2:0] ROUTE_LOCAL = 3'd0;
    localparam logic [2:0] ROUTE_NORTH = 3'd1;
    localparam logic [2:0] ROUTE_SOUTH = 3'd2;
    localparam logic [2:0] ROUTE_EAST  = 3'd3;
    localparam logic [2:0] ROUTE_WEST  = 3'd4;

    logic [COORD_WIDTH-1:0] current_x;
    logic [COORD_WIDTH-1:0] current_y;
    logic [COORD_WIDTH-1:0] dest_x;
    logic [COORD_WIDTH-1:0] dest_y;

    logic [2:0] route;

    integer errors;

    anoc_rv_routing_unit #(
        .COORD_WIDTH(COORD_WIDTH)
    ) dut (
        .current_x(current_x),
        .current_y(current_y),
        .dest_x(dest_x),
        .dest_y(dest_y),
        .route(route)
    );

    task automatic check_route(
        input logic [COORD_WIDTH-1:0] dx,
        input logic [COORD_WIDTH-1:0] dy,
        input logic [2:0] expected
    );
        begin
            dest_x = dx;
            dest_y = dy;
            #1;

            if (route !== expected) begin
                $display("ERROR: current=(%0d,%0d) dest=(%0d,%0d) expected=%0d got=%0d",
                         current_x, current_y, dest_x, dest_y,
                         expected, route);
                errors = errors + 1;
            end
            else begin
                $display("PASS : current=(%0d,%0d) dest=(%0d,%0d) route=%0d",
                         current_x, current_y, dest_x, dest_y, route);
            end
        end
    endtask

    initial begin
        errors = 0;

        current_x = 2;
        current_y = 2;

        $dumpfile("results/simulation/routing_unit.vcd");
        $dumpvars(0, tb_anoc_rv_routing_unit);

        $display("");
        $display("========================================");
        $display("ROUTING UNIT TEST");
        $display("========================================");

        check_route(2, 2, ROUTE_LOCAL);
        check_route(3, 2, ROUTE_EAST);
        check_route(4, 2, ROUTE_EAST);
        check_route(1, 2, ROUTE_WEST);
        check_route(0, 2, ROUTE_WEST);
        check_route(2, 3, ROUTE_NORTH);
        check_route(2, 4, ROUTE_NORTH);
        check_route(2, 1, ROUTE_SOUTH);
        check_route(2, 0, ROUTE_SOUTH);

        // XY routing: X direction has priority over Y
        check_route(3, 4, ROUTE_EAST);
        check_route(1, 4, ROUTE_WEST);
        check_route(3, 0, ROUTE_EAST);
        check_route(1, 0, ROUTE_WEST);

        $display("");
        $display("========================================");
        $display("ROUTING TEST SUMMARY");
        $display("========================================");
        $display("Errors : %0d", errors);

        if (errors == 0) begin
            $display("");
            $display("***************************************");
            $display("* ROUTING UNIT TEST PASS              *");
            $display("***************************************");
        end
        else begin
            $display("");
            $display("***************************************");
            $display("* ROUTING UNIT TEST FAIL              *");
            $display("***************************************");
        end

        $finish;
    end

endmodule
