`timescale 1ns/1ps

module anoc_rv_mesh_2x2 #(
    parameter int DATA_WIDTH  = 128,
    parameter int COORD_WIDTH = 4,
    parameter int NUM_PORTS   = 5
)(
    input logic clk,
    input logic rst_n,

    // ------------------------------------------------
    // External node interfaces
    // ------------------------------------------------

    input  logic [DATA_WIDTH-1:0] r0_data_in,
    input logic [COORD_WIDTH-1:0] r0_dest_x,
    input logic [COORD_WIDTH-1:0] r0_dest_y,
    input logic r0_valid_in,
    output logic r0_ready_in,

    input  logic [DATA_WIDTH-1:0] r1_data_in,
    input logic [COORD_WIDTH-1:0] r1_dest_x,
    input logic [COORD_WIDTH-1:0] r1_dest_y,
    input logic r1_valid_in,
    output logic r1_ready_in,

    input logic [DATA_WIDTH-1:0] r2_data_in,
    input logic [COORD_WIDTH-1:0] r2_dest_x,
    input logic [COORD_WIDTH-1:0] r2_dest_y,
    input logic r2_valid_in,
    output logic r2_ready_in,

    input logic [DATA_WIDTH-1:0] r3_data_in,
    input logic [COORD_WIDTH-1:0] r3_dest_x,
    input logic [COORD_WIDTH-1:0] r3_dest_y,
    input logic r3_valid_in,
    output logic r3_ready_in,

    output logic [DATA_WIDTH-1:0] r0_data_out,
    output logic r0_valid_out,

    output logic [DATA_WIDTH-1:0] r1_data_out,
    output logic r1_valid_out,

    output logic [DATA_WIDTH-1:0] r2_data_out,
    output logic r2_valid_out,

    output logic [DATA_WIDTH-1:0] r3_data_out,
    output logic r3_valid_out
);

    localparam int LOCAL = 0;
    localparam int NORTH = 1;
    localparam int SOUTH = 2;
    localparam int EAST  = 3;
    localparam int WEST  = 4;

    // ============================================================
    // Router 0
    // ============================================================

    logic [DATA_WIDTH-1:0] r0_di [0:NUM_PORTS-1];
    logic [COORD_WIDTH-1:0] r0_dxi [0:NUM_PORTS-1];
    logic [COORD_WIDTH-1:0] r0_dyi [0:NUM_PORTS-1];
    logic r0_vi [0:NUM_PORTS-1];
    logic r0_ri [0:NUM_PORTS-1];

    logic r0_ro [0:NUM_PORTS-1];
    logic [DATA_WIDTH-1:0] r0_do [0:NUM_PORTS-1];
    logic r0_vo [0:NUM_PORTS-1];
    logic [COORD_WIDTH-1:0] r0_dxo [0:NUM_PORTS-1];
    logic [COORD_WIDTH-1:0] r0_dyo [0:NUM_PORTS-1];

    // ============================================================
    // Router 1
    // ============================================================

    logic [DATA_WIDTH-1:0] r1_di [0:NUM_PORTS-1];
    logic [COORD_WIDTH-1:0] r1_dxi [0:NUM_PORTS-1];
    logic [COORD_WIDTH-1:0] r1_dyi [0:NUM_PORTS-1];
    logic r1_vi [0:NUM_PORTS-1];
    logic r1_ri [0:NUM_PORTS-1];

    logic r1_ro [0:NUM_PORTS-1];
    logic [DATA_WIDTH-1:0] r1_do [0:NUM_PORTS-1];
    logic r1_vo [0:NUM_PORTS-1];
    logic [COORD_WIDTH-1:0] r1_dxo [0:NUM_PORTS-1];
    logic [COORD_WIDTH-1:0] r1_dyo [0:NUM_PORTS-1];

    // ============================================================
    // Router 2
    // ============================================================

    logic [DATA_WIDTH-1:0] r2_di [0:NUM_PORTS-1];
    logic [COORD_WIDTH-1:0] r2_dxi [0:NUM_PORTS-1];
    logic [COORD_WIDTH-1:0] r2_dyi [0:NUM_PORTS-1];
    logic r2_vi [0:NUM_PORTS-1];
    logic r2_ri [0:NUM_PORTS-1];

    logic r2_ro [0:NUM_PORTS-1];
    logic [DATA_WIDTH-1:0] r2_do [0:NUM_PORTS-1];
    logic r2_vo [0:NUM_PORTS-1];
    logic [COORD_WIDTH-1:0] r2_dxo [0:NUM_PORTS-1];
    logic [COORD_WIDTH-1:0] r2_dyo [0:NUM_PORTS-1];

    // ============================================================
    // Router 3
    // ============================================================

    logic [DATA_WIDTH-1:0] r3_di [0:NUM_PORTS-1];
    logic [COORD_WIDTH-1:0] r3_dxi [0:NUM_PORTS-1];
    logic [COORD_WIDTH-1:0] r3_dyi [0:NUM_PORTS-1];
    logic r3_vi [0:NUM_PORTS-1];
    logic r3_ri [0:NUM_PORTS-1];

    logic r3_ro [0:NUM_PORTS-1];
    logic [DATA_WIDTH-1:0] r3_do [0:NUM_PORTS-1];
    logic r3_vo [0:NUM_PORTS-1];
    logic [COORD_WIDTH-1:0] r3_dxo [0:NUM_PORTS-1];
    logic [COORD_WIDTH-1:0] r3_dyo [0:NUM_PORTS-1];

    integer i;

    // ============================================================
    // Network interconnect
    // ============================================================

    always_comb begin

        // Defaults
        for (i = 0; i < NUM_PORTS; i = i + 1) begin

            r0_di[i] = '0;
            r0_dxi[i] = '0;
            r0_dyi[i] = '0;
            r0_vi[i] = 1'b0;
            r0_ro[i] = 1'b1;

            r1_di[i] = '0;
            r1_dxi[i] = '0;
            r1_dyi[i] = '0;
            r1_vi[i] = 1'b0;
            r1_ro[i] = 1'b1;

            r2_di[i] = '0;
            r2_dxi[i] = '0;
            r2_dyi[i] = '0;
            r2_vi[i] = 1'b0;
            r2_ro[i] = 1'b1;

            r3_di[i] = '0;
            r3_dxi[i] = '0;
            r3_dyi[i] = '0;
            r3_vi[i] = 1'b0;
            r3_ro[i] = 1'b1;

        end

        // ------------------------------------------------
        // External LOCAL inputs
        // ------------------------------------------------

        r0_di[LOCAL] = r0_data_in;
        r0_dxi[LOCAL] = r0_dest_x;
        r0_dyi[LOCAL] = r0_dest_y;
        r0_vi[LOCAL] = r0_valid_in;

        r1_di[LOCAL] = r1_data_in;
        r1_dxi[LOCAL] = r1_dest_x;
        r1_dyi[LOCAL] = r1_dest_y;
        r1_vi[LOCAL] = r1_valid_in;

        r2_di[LOCAL] = r2_data_in;
        r2_dxi[LOCAL] = r2_dest_x;
        r2_dyi[LOCAL] = r2_dest_y;
        r2_vi[LOCAL] = r2_valid_in;

        r3_di[LOCAL] = r3_data_in;
        r3_dxi[LOCAL] = r3_dest_x;
        r3_dyi[LOCAL] = r3_dest_y;
        r3_vi[LOCAL] = r3_valid_in;

        // ------------------------------------------------
        // R0 <-> R1
        // ------------------------------------------------

        r1_di[WEST] = r0_do[EAST];
        r1_dxi[WEST] = r0_dxo[EAST];
        r1_dyi[WEST] = r0_dyo[EAST];
        r1_vi[WEST] = r0_vo[EAST];

        r0_di[EAST] = r1_do[WEST];
        r0_dxi[EAST] = r1_dxo[WEST];
        r0_dyi[EAST] = r1_dyo[WEST];
        r0_vi[EAST] = r1_vo[WEST];

        // ------------------------------------------------
        // R2 <-> R3
        // ------------------------------------------------

        r3_di[WEST] = r2_do[EAST];
        r3_dxi[WEST] = r2_dxo[EAST];
        r3_dyi[WEST] = r2_dyo[EAST];
        r3_vi[WEST] = r2_vo[EAST];

        r2_di[EAST] = r3_do[WEST];
        r2_dxi[EAST] = r3_dxo[WEST];
        r2_dyi[EAST] = r3_dyo[WEST];
        r2_vi[EAST] = r3_vo[WEST];

        // ------------------------------------------------
        // R0 <-> R2
        //
        // R0 = (0,0), R2 = (0,1)
        // R0 sends NORTH to reach R2.
        // R2 receives on SOUTH.
        // ------------------------------------------------

        r2_di[SOUTH] = r0_do[NORTH];
        r2_dxi[SOUTH] = r0_dxo[NORTH];
        r2_dyi[SOUTH] = r0_dyo[NORTH];
        r2_vi[SOUTH] = r0_vo[NORTH];

        r0_di[NORTH] = r2_do[SOUTH];
        r0_dxi[NORTH] = r2_dxo[SOUTH];
        r0_dyi[NORTH] = r2_dyo[SOUTH];
        r0_vi[NORTH] = r2_vo[SOUTH];

        // ------------------------------------------------
        // R1 <-> R3
        //
        // R1 = (1,0), R3 = (1,1)
        // R1 sends NORTH to reach R3.
        // R3 receives on SOUTH.
        // ------------------------------------------------

        r3_di[SOUTH] = r1_do[NORTH];
        r3_dxi[SOUTH] = r1_dxo[NORTH];
        r3_dyi[SOUTH] = r1_dyo[NORTH];
        r3_vi[SOUTH] = r1_vo[NORTH];

        r1_di[NORTH] = r3_do[SOUTH];
        r1_dxi[NORTH] = r3_dxo[SOUTH];
        r1_dyi[NORTH] = r3_dyo[SOUTH];
        r1_vi[NORTH] = r3_vo[SOUTH];

        // ------------------------------------------------
        // External outputs
        // ------------------------------------------------

        r0_data_out = r0_do[LOCAL];
        r0_valid_out = r0_vo[LOCAL];

        r1_data_out = r1_do[LOCAL];
        r1_valid_out = r1_vo[LOCAL];

        r2_data_out = r2_do[LOCAL];
        r2_valid_out = r2_vo[LOCAL];

        r3_data_out = r3_do[LOCAL];
        r3_valid_out = r3_vo[LOCAL];

        // External ready
        r0_ready_in = r0_ri[LOCAL];
        r1_ready_in = r1_ri[LOCAL];
        r2_ready_in = r2_ri[LOCAL];
        r3_ready_in = r3_ri[LOCAL];

    end

    // ============================================================
    // Router instances
    // ============================================================

    anoc_rv_router_buffered #(
        .DATA_WIDTH(DATA_WIDTH),
        .COORD_WIDTH(COORD_WIDTH),
        .NUM_PORTS(NUM_PORTS)
    ) router0 (
        .clk(clk),
        .rst_n(rst_n),
        .current_x(4'd0),
        .current_y(4'd0),
        .data_in(r0_di),
        .dest_x(r0_dxi),
        .dest_y(r0_dyi),
        .valid_in(r0_vi),
        .ready_in(r0_ri),
        .ready_out(r0_ro),
        .data_out(r0_do),
        .valid_out(r0_vo),
        .dest_x_out(r0_dxo),
        .dest_y_out(r0_dyo)
    );

    anoc_rv_router_buffered #(
        .DATA_WIDTH(DATA_WIDTH),
        .COORD_WIDTH(COORD_WIDTH),
        .NUM_PORTS(NUM_PORTS)
    ) router1 (
        .clk(clk),
        .rst_n(rst_n),
        .current_x(4'd1),
        .current_y(4'd0),
        .data_in(r1_di),
        .dest_x(r1_dxi),
        .dest_y(r1_dyi),
        .valid_in(r1_vi),
        .ready_in(r1_ri),
        .ready_out(r1_ro),
        .data_out(r1_do),
        .valid_out(r1_vo),
        .dest_x_out(r1_dxo),
        .dest_y_out(r1_dyo)
    );

    anoc_rv_router_buffered #(
        .DATA_WIDTH(DATA_WIDTH),
        .COORD_WIDTH(COORD_WIDTH),
        .NUM_PORTS(NUM_PORTS)
    ) router2 (
        .clk(clk),
        .rst_n(rst_n),
        .current_x(4'd0),
        .current_y(4'd1),
        .data_in(r2_di),
        .dest_x(r2_dxi),
        .dest_y(r2_dyi),
        .valid_in(r2_vi),
        .ready_in(r2_ri),
        .ready_out(r2_ro),
        .data_out(r2_do),
        .valid_out(r2_vo),
        .dest_x_out(r2_dxo),
        .dest_y_out(r2_dyo)
    );

    anoc_rv_router_buffered #(
        .DATA_WIDTH(DATA_WIDTH),
        .COORD_WIDTH(COORD_WIDTH),
        .NUM_PORTS(NUM_PORTS)
    ) router3 (
        .clk(clk),
        .rst_n(rst_n),
        .current_x(4'd1),
        .current_y(4'd1),
        .data_in(r3_di),
        .dest_x(r3_dxi),
        .dest_y(r3_dyi),
        .valid_in(r3_vi),
        .ready_in(r3_ri),
        .ready_out(r3_ro),
        .data_out(r3_do),
        .valid_out(r3_vo),
        .dest_x_out(r3_dxo),
        .dest_y_out(r3_dyo)
    );

endmodule
