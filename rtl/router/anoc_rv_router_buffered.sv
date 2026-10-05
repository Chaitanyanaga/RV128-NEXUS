module anoc_rv_router_buffered #(
    parameter int DATA_WIDTH  = 128,
    parameter int COORD_WIDTH = 4,
    parameter int NUM_PORTS   = 5
) (
    input  logic clk,
    input  logic rst_n,

    input  logic [COORD_WIDTH-1:0] current_x,
    input  logic [COORD_WIDTH-1:0] current_y,

    input  logic [NUM_PORTS*DATA_WIDTH-1:0] data_in,
    input  logic [NUM_PORTS*COORD_WIDTH-1:0] dest_x,
    input  logic [NUM_PORTS*COORD_WIDTH-1:0] dest_y,
    input  logic [NUM_PORTS-1:0] valid_in,
    output logic [NUM_PORTS-1:0] ready_in,

    input  logic [NUM_PORTS-1:0] ready_out,

    output logic [NUM_PORTS*DATA_WIDTH-1:0] data_out,
    output logic [NUM_PORTS-1:0] valid_out,
    output logic [NUM_PORTS*COORD_WIDTH-1:0] dest_x_out,
    output logic [NUM_PORTS*COORD_WIDTH-1:0] dest_y_out
);

    logic [DATA_WIDTH-1:0] buf_data [0:NUM_PORTS-1];
    logic [COORD_WIDTH-1:0] buf_dest_x [0:NUM_PORTS-1];
    logic [COORD_WIDTH-1:0] buf_dest_y [0:NUM_PORTS-1];
    logic buf_valid [0:NUM_PORTS-1];

    logic [2:0] route [0:NUM_PORTS-1];

    logic [NUM_PORTS-1:0] requests [0:NUM_PORTS-1];
    logic [NUM_PORTS-1:0] grants   [0:NUM_PORTS-1];

    logic [DATA_WIDTH-1:0] data_in_vec [0:NUM_PORTS-1];
    logic [COORD_WIDTH-1:0] dest_x_vec [0:NUM_PORTS-1];
    logic [COORD_WIDTH-1:0] dest_y_vec [0:NUM_PORTS-1];

    logic [DATA_WIDTH-1:0] data_out_vec [0:NUM_PORTS-1];
    logic [COORD_WIDTH-1:0] dest_x_out_vec [0:NUM_PORTS-1];
    logic [COORD_WIDTH-1:0] dest_y_out_vec [0:NUM_PORTS-1];

    /*
     * Unpack flat input buses.
     */
    always_comb begin : unpack_inputs
        integer k;
        for (k = 0; k < NUM_PORTS; k = k + 1) begin
            data_in_vec[k] =
                data_in[k*DATA_WIDTH +: DATA_WIDTH];

            dest_x_vec[k] =
                dest_x[k*COORD_WIDTH +: COORD_WIDTH];

            dest_y_vec[k] =
                dest_y[k*COORD_WIDTH +: COORD_WIDTH];
        end
    end

    /*
     * One-entry input buffer ready signals.
     */
    always_comb begin : buffer_ready
        integer k;
        for (k = 0; k < NUM_PORTS; k = k + 1)
            ready_in[k] = !buf_valid[k];
    end

    /*
     * Buffer storage.
     */
    always_ff @(posedge clk or negedge rst_n) begin : buffer_storage
        integer k;
        if (!rst_n) begin
            for (k = 0; k < NUM_PORTS; k = k + 1) begin
                buf_valid[k]  <= 1'b0;
                buf_data[k]   <= '0;
                buf_dest_x[k] <= '0;
                buf_dest_y[k] <= '0;
            end
        end
        else begin
            for (k = 0; k < NUM_PORTS; k = k + 1) begin
                if (valid_in[k] && ready_in[k]) begin
                    buf_valid[k]  <= 1'b1;
                    buf_data[k]   <= data_in_vec[k];
                    buf_dest_x[k] <= dest_x_vec[k];
                    buf_dest_y[k] <= dest_y_vec[k];
                end
                else if (buf_valid[k] &&
                         ready_out[route[k]] &&
                         grants[route[k]][k]) begin
                    buf_valid[k] <= 1'b0;
                end
            end
        end
    end

    /*
     * XY routing:
     * 0 = LOCAL
     * 1 = NORTH
     * 2 = SOUTH
     * 3 = EAST
     * 4 = WEST
     */
    always_comb begin : xy_routing
        integer k;
        for (k = 0; k < NUM_PORTS; k = k + 1) begin
            if (buf_dest_x[k] > current_x)
                route[k] = 3'd3;
            else if (buf_dest_x[k] < current_x)
                route[k] = 3'd4;
            else if (buf_dest_y[k] > current_y)
                route[k] = 3'd1;
            else if (buf_dest_y[k] < current_y)
                route[k] = 3'd2;
            else
                route[k] = 3'd0;
        end
    end

    /*
     * Request matrix.
     * requests[output][input]
     */
    always_comb begin : request_matrix
        integer k;
        for (k = 0; k < NUM_PORTS; k = k + 1)
            requests[k] = '0;

        for (k = 0; k < NUM_PORTS; k = k + 1) begin
            if (buf_valid[k])
                requests[route[k]][k] = 1'b1;
        end
    end

    /*
     * Fixed-priority arbitration.
     * Input 0 has highest priority.
     */
    always_comb begin : priority_arbitration
        integer o;
        integer k;

        for (o = 0; o < NUM_PORTS; o = o + 1)
            grants[o] = '0;

        for (o = 0; o < NUM_PORTS; o = o + 1) begin
            for (k = 0; k < NUM_PORTS; k = k + 1) begin
                if ((grants[o] == '0) && requests[o][k])
                    grants[o][k] = 1'b1;
            end
        end
    end

    /*
     * Output crossbar.
     */
    always_comb begin : output_crossbar
        integer o;

        for (o = 0; o < NUM_PORTS; o = o + 1) begin
            data_out_vec[o]   = '0;
            dest_x_out_vec[o] = '0;
            dest_y_out_vec[o] = '0;
            valid_out[o]      = 1'b0;

            case (grants[o])
                5'b00001: begin
                    data_out_vec[o]   = buf_data[0];
                    dest_x_out_vec[o] = buf_dest_x[0];
                    dest_y_out_vec[o] = buf_dest_y[0];
                    valid_out[o]      = 1'b1;
                end

                5'b00010: begin
                    data_out_vec[o]   = buf_data[1];
                    dest_x_out_vec[o] = buf_dest_x[1];
                    dest_y_out_vec[o] = buf_dest_y[1];
                    valid_out[o]      = 1'b1;
                end

                5'b00100: begin
                    data_out_vec[o]   = buf_data[2];
                    dest_x_out_vec[o] = buf_dest_x[2];
                    dest_y_out_vec[o] = buf_dest_y[2];
                    valid_out[o]      = 1'b1;
                end

                5'b01000: begin
                    data_out_vec[o]   = buf_data[3];
                    dest_x_out_vec[o] = buf_dest_x[3];
                    dest_y_out_vec[o] = buf_dest_y[3];
                    valid_out[o]      = 1'b1;
                end

                5'b10000: begin
                    data_out_vec[o]   = buf_data[4];
                    dest_x_out_vec[o] = buf_dest_x[4];
                    dest_y_out_vec[o] = buf_dest_y[4];
                    valid_out[o]      = 1'b1;
                end

                default: begin
                    data_out_vec[o]   = '0;
                    dest_x_out_vec[o] = '0;
                    dest_y_out_vec[o] = '0;
                    valid_out[o]      = 1'b0;
                end
            endcase
        end
    end

    /*
     * Pack output buses.
     */
    always_comb begin : pack_outputs
        integer k;

        data_out   = '0;
        dest_x_out = '0;
        dest_y_out = '0;

        for (k = 0; k < NUM_PORTS; k = k + 1) begin
            data_out[k*DATA_WIDTH +: DATA_WIDTH] =
                data_out_vec[k];

            dest_x_out[k*COORD_WIDTH +: COORD_WIDTH] =
                dest_x_out_vec[k];

            dest_y_out[k*COORD_WIDTH +: COORD_WIDTH] =
                dest_y_out_vec[k];
        end
    end

endmodule
