`timescale 1ns/1ps

module anoc_rv_mesh #(
    parameter int DATA_WIDTH  = 128,
    parameter int COORD_WIDTH = 4,
    parameter int NUM_PORTS   = 5,
    parameter int MESH_X      = 3,
    parameter int MESH_Y      = 3
)(
    input  logic clk,
    input  logic rst_n,

    input  logic [DATA_WIDTH-1:0] data_in [0:MESH_X*MESH_Y-1],
    input  logic [COORD_WIDTH-1:0] dest_x [0:MESH_X*MESH_Y-1],
    input  logic [COORD_WIDTH-1:0] dest_y [0:MESH_X*MESH_Y-1],
    input  logic valid_in [0:MESH_X*MESH_Y-1],
    output logic ready_in [0:MESH_X*MESH_Y-1],

    output logic [DATA_WIDTH-1:0] data_out [0:MESH_X*MESH_Y-1],
    output logic valid_out [0:MESH_X*MESH_Y-1]
);

    localparam int NODES = MESH_X * MESH_Y;

    genvar x, y;

    generate
        for (y = 0; y < MESH_Y; y = y + 1) begin : ROW
            for (x = 0; x < MESH_X; x = x + 1) begin : COL

                localparam int ID = y*MESH_X + x;

                localparam logic [COORD_WIDTH-1:0] CX = x;
                localparam logic [COORD_WIDTH-1:0] CY = y;

                logic [DATA_WIDTH-1:0] din [0:NUM_PORTS-1];
                logic [COORD_WIDTH-1:0] dxin [0:NUM_PORTS-1];
                logic [COORD_WIDTH-1:0] dyin [0:NUM_PORTS-1];
                logic vin [0:NUM_PORTS-1];
                logic rin [0:NUM_PORTS-1];

                logic [DATA_WIDTH-1:0] dout [0:NUM_PORTS-1];
                logic vout [0:NUM_PORTS-1];
                logic [COORD_WIDTH-1:0] dxout [0:NUM_PORTS-1];
                logic [COORD_WIDTH-1:0] dyout [0:NUM_PORTS-1];

                logic rout [0:NUM_PORTS-1];

                integer k;

                always_comb begin

                    // Default all ports
                    for (k = 0; k < NUM_PORTS; k = k + 1) begin
                        din[k]  = '0;
                        dxin[k] = '0;
                        dyin[k] = '0;
                        vin[k]  = 1'b0;
                        rout[k] = 1'b1;
                    end

                    // ====================================================
                    // LOCAL INPUT
                    // ====================================================
                    din[0]  = data_in[ID];
                    dxin[0] = dest_x[ID];
                    dyin[0] = dest_y[ID];
                    vin[0]  = valid_in[ID];

                    ready_in[ID] = rin[0];

                    // ====================================================
                    // NORTH
                    // Current NORTH input comes from router at y+1.
                    // ====================================================
                    if (y < MESH_Y-1) begin
                        din[1]  = ROW[y+1].COL[x].dout[2];
                        dxin[1] = ROW[y+1].COL[x].dxout[2];
                        dyin[1] = ROW[y+1].COL[x].dyout[2];
                        vin[1]  = ROW[y+1].COL[x].vout[2];

                        rout[1] = ROW[y+1].COL[x].rin[2];
                    end

                    // ====================================================
                    // SOUTH
                    // Current SOUTH input comes from router at y-1.
                    // ====================================================
                    if (y > 0) begin
                        din[2]  = ROW[y-1].COL[x].dout[1];
                        dxin[2] = ROW[y-1].COL[x].dxout[1];
                        dyin[2] = ROW[y-1].COL[x].dyout[1];
                        vin[2]  = ROW[y-1].COL[x].vout[1];

                        rout[2] = ROW[y-1].COL[x].rin[1];
                    end

                    // ====================================================
                    // EAST
                    // Current EAST input comes from router at x+1.
                    // ====================================================
                    if (x < MESH_X-1) begin
                        din[3]  = ROW[y].COL[x+1].dout[4];
                        dxin[3] = ROW[y].COL[x+1].dxout[4];
                        dyin[3] = ROW[y].COL[x+1].dyout[4];
                        vin[3]  = ROW[y].COL[x+1].vout[4];

                        rout[3] = ROW[y].COL[x+1].rin[4];
                    end

                    // ====================================================
                    // WEST
                    // Current WEST input comes from router at x-1.
                    // ====================================================
                    if (x > 0) begin
                        din[4]  = ROW[y].COL[x-1].dout[3];
                        dxin[4] = ROW[y].COL[x-1].dxout[3];
                        dyin[4] = ROW[y].COL[x-1].dyout[3];
                        vin[4]  = ROW[y].COL[x-1].vout[3];

                        rout[4] = ROW[y].COL[x-1].rin[3];
                    end

                    // LOCAL OUTPUT
                    data_out[ID]  = dout[0];
                    valid_out[ID] = vout[0];

                end

                anoc_rv_router_buffered #(
                    .DATA_WIDTH(DATA_WIDTH),
                    .COORD_WIDTH(COORD_WIDTH),
                    .NUM_PORTS(NUM_PORTS)
                ) router (
                    .clk(clk),
                    .rst_n(rst_n),

                    .current_x(CX),
                    .current_y(CY),

                    .data_in(din),
                    .dest_x(dxin),
                    .dest_y(dyin),
                    .valid_in(vin),
                    .ready_in(rin),

                    .ready_out(rout),

                    .data_out(dout),
                    .valid_out(vout),
                    .dest_x_out(dxout),
                    .dest_y_out(dyout)
                );

            end
        end
    endgenerate

endmodule
