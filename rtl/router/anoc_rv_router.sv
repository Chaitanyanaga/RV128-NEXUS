module anoc_rv_router #(
    parameter int DATA_WIDTH  = 128,
    parameter int COORD_WIDTH = 4,
    parameter int NUM_PORTS   = 5
) (
    input  logic [COORD_WIDTH-1:0] current_x,
    input  logic [COORD_WIDTH-1:0] current_y,

    input  logic [NUM_PORTS*DATA_WIDTH-1:0] data_in,
    input  logic [NUM_PORTS*COORD_WIDTH-1:0] dest_x,
    input  logic [NUM_PORTS*COORD_WIDTH-1:0] dest_y,
    input  logic [NUM_PORTS-1:0] valid_in,

    output logic [NUM_PORTS*DATA_WIDTH-1:0] data_out,
    output logic [NUM_PORTS-1:0] valid_out,
    output logic [NUM_PORTS-1:0] ready_in
);

    localparam int SEL_WIDTH = $clog2(NUM_PORTS);

    logic [2:0] route [0:NUM_PORTS-1];
    logic [NUM_PORTS-1:0] requests [0:NUM_PORTS-1];
    logic [NUM_PORTS-1:0] grants   [0:NUM_PORTS-1];
    logic [SEL_WIDTH-1:0] select [0:NUM_PORTS-1];

    integer i;
    integer j;

    logic [DATA_WIDTH-1:0] data_in_vec [0:NUM_PORTS-1];
    logic [COORD_WIDTH-1:0] dest_x_vec [0:NUM_PORTS-1];
    logic [COORD_WIDTH-1:0] dest_y_vec [0:NUM_PORTS-1];
    logic [DATA_WIDTH-1:0] data_out_vec [0:NUM_PORTS-1];

    /*
     * Unpack flat input buses.
     */
    always_comb begin
        for (i = 0; i < NUM_PORTS; i = i + 1) begin
            data_in_vec[i] =
                data_in[i*DATA_WIDTH +: DATA_WIDTH];

            dest_x_vec[i] =
                dest_x[i*COORD_WIDTH +: COORD_WIDTH];

            dest_y_vec[i] =
                dest_y[i*COORD_WIDTH +: COORD_WIDTH];
        end
    end

    /*
     * Routing decision for every input.
     * 0 = LOCAL
     * 1 = NORTH
     * 2 = SOUTH
     * 3 = EAST
     * 4 = WEST
     */
    always_comb begin
        for (i = 0; i < NUM_PORTS; i = i + 1) begin
            if (dest_x_vec[i] > current_x)
                route[i] = 3'd3;
            else if (dest_x_vec[i] < current_x)
                route[i] = 3'd4;
            else if (dest_y_vec[i] > current_y)
                route[i] = 3'd1;
            else if (dest_y_vec[i] < current_y)
                route[i] = 3'd2;
            else
                route[i] = 3'd0;
        end
    end

    /*
     * Build request matrix.
     * requests[output][input]
     */
    always_comb begin
        for (i = 0; i < NUM_PORTS; i = i + 1)
            requests[i] = '0;

        for (i = 0; i < NUM_PORTS; i = i + 1) begin
            if (valid_in[i])
                requests[route[i]][i] = 1'b1;
        end
    end

    /*
     * One fixed-priority arbiter per output.
     * Input 0 has highest priority.
     */
    always_comb begin
        for (i = 0; i < NUM_PORTS; i = i + 1)
            grants[i] = '0;

        for (i = 0; i < NUM_PORTS; i = i + 1) begin
            for (j = 0; j < NUM_PORTS; j = j + 1) begin
                if ((grants[i] == '0) && requests[i][j])
                    grants[i][j] = 1'b1;
            end
        end
    end

    /*
     * Crossbar selection and outputs.
     */
    always_comb begin
        for (i = 0; i < NUM_PORTS; i = i + 1) begin
            select[i]      = '0;
            data_out_vec[i] = '0;
            valid_out[i]   = 1'b0;
        end

        for (i = 0; i < NUM_PORTS; i = i + 1) begin
            for (j = 0; j < NUM_PORTS; j = j + 1) begin
                if (grants[i][j]) begin
                    select[i]       = j;
                    data_out_vec[i] = data_in_vec[j];
                    valid_out[i]    = valid_in[j];
                end
            end
        end
    end

    /*
     * An input is ready when granted by its requested output.
     */
    always_comb begin
        ready_in = '0;

        for (i = 0; i < NUM_PORTS; i = i + 1) begin
            for (j = 0; j < NUM_PORTS; j = j + 1) begin
                if (grants[i][j])
                    ready_in[j] = 1'b1;
            end
        end
    end

    /*
     * Pack output data back into a flat bus.
     */
    always_comb begin
        data_out = '0;

        for (i = 0; i < NUM_PORTS; i = i + 1)
            data_out[i*DATA_WIDTH +: DATA_WIDTH] = data_out_vec[i];
    end

endmodule
