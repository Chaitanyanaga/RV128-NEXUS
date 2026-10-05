module anoc_rv_router_buffered_synth #(
    parameter int DATA_WIDTH = 128,
    parameter int COORD_WIDTH = 4,
    parameter int NUM_PORTS = 5
)(
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

    integer i;
    integer j;
    integer r;

    reg [2:0] route [0:NUM_PORTS-1];
    reg [NUM_PORTS-1:0] requests [0:NUM_PORTS-1];
    reg [NUM_PORTS-1:0] grants [0:NUM_PORTS-1];

    always_comb begin
        for (i = 0; i < NUM_PORTS; i = i + 1)
            ready_in[i] = !buf_valid[i];
    end

    always_comb begin
        for (i = 0; i < NUM_PORTS; i = i + 1) begin
            if (buf_dest_x[i] > current_x)
                route[i] = 3'd3;
            else if (buf_dest_x[i] < current_x)
                route[i] = 3'd4;
            else if (buf_dest_y[i] > current_y)
                route[i] = 3'd1;
            else if (buf_dest_y[i] < current_y)
                route[i] = 3'd2;
            else
                route[i] = 3'd0;
        end
    end

    always_comb begin
        for (i = 0; i < NUM_PORTS; i = i + 1)
            requests[i] = '0;

        for (i = 0; i < NUM_PORTS; i = i + 1)
            if (buf_valid[i])
                requests[route[i]][i] = 1'b1;
    end

    always_comb begin
        for (i = 0; i < NUM_PORTS; i = i + 1)
            grants[i] = '0;

        for (i = 0; i < NUM_PORTS; i = i + 1)
            for (j = 0; j < NUM_PORTS; j = j + 1)
                if ((grants[i] == '0) && requests[i][j])
                    grants[i][j] = 1'b1;
    end

    always_comb begin
        data_out = '0;
        valid_out = '0;
        dest_x_out = '0;
        dest_y_out = '0;

        for (i = 0; i < NUM_PORTS; i = i + 1) begin
            for (j = 0; j < NUM_PORTS; j = j + 1) begin
                if (grants[i][j]) begin
                    data_out[i*DATA_WIDTH +: DATA_WIDTH] =
                        buf_data[j];

                    valid_out[i] = 1'b1;

                    dest_x_out[i*COORD_WIDTH +: COORD_WIDTH] =
                        buf_dest_x[j];

                    dest_y_out[i*COORD_WIDTH +: COORD_WIDTH] =
                        buf_dest_y[j];
                end
            end
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (r = 0; r < NUM_PORTS; r = r + 1) begin
                buf_valid[r] <= 1'b0;
                buf_data[r] <= '0;
                buf_dest_x[r] <= '0;
                buf_dest_y[r] <= '0;
            end
        end
        else begin
            for (r = 0; r < NUM_PORTS; r = r + 1) begin

                if (valid_in[r] && ready_in[r]) begin
                    buf_valid[r] <= 1'b1;

                    buf_data[r] <=
                        data_in[r*DATA_WIDTH +: DATA_WIDTH];

                    buf_dest_x[r] <=
                        dest_x[r*COORD_WIDTH +: COORD_WIDTH];

                    buf_dest_y[r] <=
                        dest_y[r*COORD_WIDTH +: COORD_WIDTH];
                end
                else if (buf_valid[r] &&
                         ready_out[route[r]] &&
                         grants[route[r]][r]) begin
                    buf_valid[r] <= 1'b0;
                end
            end
        end
    end

endmodule
