module anoc_rv_routing_unit #(
    parameter int COORD_WIDTH = 4
) (
    input  logic [COORD_WIDTH-1:0] current_x,
    input  logic [COORD_WIDTH-1:0] current_y,

    input  logic [COORD_WIDTH-1:0] dest_x,
    input  logic [COORD_WIDTH-1:0] dest_y,

    output logic [2:0] route
);

    localparam logic [2:0] ROUTE_LOCAL = 3'd0;
    localparam logic [2:0] ROUTE_NORTH = 3'd1;
    localparam logic [2:0] ROUTE_SOUTH = 3'd2;
    localparam logic [2:0] ROUTE_EAST  = 3'd3;
    localparam logic [2:0] ROUTE_WEST  = 3'd4;

    always_comb begin
        if (dest_x > current_x)
            route = ROUTE_EAST;
        else if (dest_x < current_x)
            route = ROUTE_WEST;
        else if (dest_y > current_y)
            route = ROUTE_NORTH;
        else if (dest_y < current_y)
            route = ROUTE_SOUTH;
        else
            route = ROUTE_LOCAL;
    end

endmodule
