`timescale 1ns/1ps

module anoc_rv_mesh #(
    parameter int DATA_WIDTH  = 128,
    parameter int COORD_WIDTH = 4,
    parameter int NUM_PORTS   = 5,
    parameter int N           = 3
)(
    input  logic clk,
    input  logic rst_n,

    input  logic [N*N*DATA_WIDTH-1:0]  data_in,
    input  logic [N*N*COORD_WIDTH-1:0] dest_x,
    input  logic [N*N*COORD_WIDTH-1:0] dest_y,
    input  logic [N*N-1:0]              valid_in,
    output logic [N*N-1:0]              ready_in,

    output logic [N*N*DATA_WIDTH-1:0]  data_out,
    output logic [N*N-1:0]              valid_out
);

    localparam int NODES = N*N;

    /*
     * One packed bus set per router.
     * These are arrays inside the parent module, so no
     * hierarchical sibling-instance references are needed.
     */
    logic [NUM_PORTS*DATA_WIDTH-1:0]   node_din   [0:NODES-1];
    logic [NUM_PORTS*COORD_WIDTH-1:0]  node_dxin  [0:NODES-1];
    logic [NUM_PORTS*COORD_WIDTH-1:0]  node_dyin  [0:NODES-1];
    logic [NUM_PORTS-1:0]               node_vin   [0:NODES-1];
    logic [NUM_PORTS-1:0]               node_rin   [0:NODES-1];

    logic [NUM_PORTS-1:0]               node_rout  [0:NODES-1];

    logic [NUM_PORTS*DATA_WIDTH-1:0]   node_dout  [0:NODES-1];
    logic [NUM_PORTS*COORD_WIDTH-1:0]  node_dxout [0:NODES-1];
    logic [NUM_PORTS*COORD_WIDTH-1:0]  node_dyout [0:NODES-1];
    logic [NUM_PORTS-1:0]               node_vout  [0:NODES-1];

    genvar x, y;

    generate
        for (y = 0; y < N; y = y + 1) begin : ROW
            for (x = 0; x < N; x = x + 1) begin : COL

                localparam int ID = y*N + x;

                /*
                 * Current node input construction.
                 *
                 * 0 = LOCAL
                 * 1 = NORTH
                 * 2 = SOUTH
                 * 3 = EAST
                 * 4 = WEST
                 */
                always_comb begin
                    node_din[ID]  = '0;
                    node_dxin[ID] = '0;
                    node_dyin[ID] = '0;
                    node_vin[ID]  = '0;
                    node_rout[ID] = '1;

                    /* LOCAL */
                    node_din[ID][0*DATA_WIDTH +: DATA_WIDTH] =
                        data_in[ID*DATA_WIDTH +: DATA_WIDTH];

                    node_dxin[ID][0*COORD_WIDTH +: COORD_WIDTH] =
                        dest_x[ID*COORD_WIDTH +: COORD_WIDTH];

                    node_dyin[ID][0*COORD_WIDTH +: COORD_WIDTH] =
                        dest_y[ID*COORD_WIDTH +: COORD_WIDTH];

                    node_vin[ID][0] = valid_in[ID];

                    /*
                     * NORTH: neighbor y+1, its SOUTH output (port 2)
                     */
                    if (y < N-1) begin
                        node_din[ID][1*DATA_WIDTH +: DATA_WIDTH] =
                            node_dout[ID+N][2*DATA_WIDTH +: DATA_WIDTH];

                        node_dxin[ID][1*COORD_WIDTH +: COORD_WIDTH] =
                            node_dxout[ID+N][2*COORD_WIDTH +: COORD_WIDTH];

                        node_dyin[ID][1*COORD_WIDTH +: COORD_WIDTH] =
                            node_dyout[ID+N][2*COORD_WIDTH +: COORD_WIDTH];

                        node_vin[ID][1] =
                            node_vout[ID+N][2];

                        node_rout[ID][1] =
                            node_rin[ID+N][2];
                    end

                    /*
                     * SOUTH: neighbor y-1, its NORTH output (port 1)
                     */
                    if (y > 0) begin
                        node_din[ID][2*DATA_WIDTH +: DATA_WIDTH] =
                            node_dout[ID-N][1*DATA_WIDTH +: DATA_WIDTH];

                        node_dxin[ID][2*COORD_WIDTH +: COORD_WIDTH] =
                            node_dxout[ID-N][1*COORD_WIDTH +: COORD_WIDTH];

                        node_dyin[ID][2*COORD_WIDTH +: COORD_WIDTH] =
                            node_dyout[ID-N][1*COORD_WIDTH +: COORD_WIDTH];

                        node_vin[ID][2] =
                            node_vout[ID-N][1];

                        node_rout[ID][2] =
                            node_rin[ID-N][1];
                    end

                    /*
                     * EAST: neighbor x+1, its WEST output (port 4)
                     */
                    if (x < N-1) begin
                        node_din[ID][3*DATA_WIDTH +: DATA_WIDTH] =
                            node_dout[ID+1][4*DATA_WIDTH +: DATA_WIDTH];

                        node_dxin[ID][3*COORD_WIDTH +: COORD_WIDTH] =
                            node_dxout[ID+1][4*COORD_WIDTH +: COORD_WIDTH];

                        node_dyin[ID][3*COORD_WIDTH +: COORD_WIDTH] =
                            node_dyout[ID+1][4*COORD_WIDTH +: COORD_WIDTH];

                        node_vin[ID][3] =
                            node_vout[ID+1][4];

                        node_rout[ID][3] =
                            node_rin[ID+1][4];
                    end

                    /*
                     * WEST: neighbor x-1, its EAST output (port 3)
                     */
                    if (x > 0) begin
                        node_din[ID][4*DATA_WIDTH +: DATA_WIDTH] =
                            node_dout[ID-1][3*DATA_WIDTH +: DATA_WIDTH];

                        node_dxin[ID][4*COORD_WIDTH +: COORD_WIDTH] =
                            node_dxout[ID-1][3*COORD_WIDTH +: COORD_WIDTH];

                        node_dyin[ID][4*COORD_WIDTH +: COORD_WIDTH] =
                            node_dyout[ID-1][3*COORD_WIDTH +: COORD_WIDTH];

                        node_vin[ID][4] =
                            node_vout[ID-1][3];

                        node_rout[ID][4] =
                            node_rin[ID-1][3];
                    end

                    /*
                     * Local output.
                     */
                    data_out[ID*DATA_WIDTH +: DATA_WIDTH] =
                        node_dout[ID][0*DATA_WIDTH +: DATA_WIDTH];

                    valid_out[ID] =
                        node_vout[ID][0];

                    ready_in[ID] =
                        node_rin[ID][0];
                end

                /*
                 * Buffered router for this mesh node.
                 */
                anoc_rv_router_buffered #(
                    .DATA_WIDTH(DATA_WIDTH),
                    .COORD_WIDTH(COORD_WIDTH),
                    .NUM_PORTS(NUM_PORTS)
                ) router (
                    .clk        (clk),
                    .rst_n      (rst_n),

                    .current_x  (x),
                    .current_y  (y),

                    .data_in    (node_din[ID]),
                    .dest_x     (node_dxin[ID]),
                    .dest_y     (node_dyin[ID]),
                    .valid_in   (node_vin[ID]),
                    .ready_in   (node_rin[ID]),

                    .ready_out  (node_rout[ID]),

                    .data_out   (node_dout[ID]),
                    .valid_out  (node_vout[ID]),
                    .dest_x_out (node_dxout[ID]),
                    .dest_y_out (node_dyout[ID])
                );

            end
        end
    endgenerate

endmodule
