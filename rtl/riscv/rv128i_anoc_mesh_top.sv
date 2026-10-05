`timescale 1ns/1ps

module rv128i_anoc_mesh_top #(
    parameter int DATA_WIDTH  = 128,
    parameter int COORD_WIDTH = 4
) (
    input  logic         clk,
    input  logic         rst,

    input  logic         req_valid,
    output logic         req_ready,
    input  logic         req_write,
    input  logic [127:0] req_addr,
    input  logic [127:0] req_wdata,

    input  logic [3:0]   dest_x,
    input  logic [3:0]   dest_y,

    output logic [127:0] resp_rdata,
    output logic         resp_valid,

    output logic         mem_write_complete,
    output logic [127:0] mem_write_addr,
    output logic [127:0] mem_write_data
);

    localparam int N     = 4;
    localparam int NODES = 16;

    /*
     * Flat mesh buses.
     */
    logic [NODES*DATA_WIDTH-1:0]   mesh_data_in;
    logic [NODES*COORD_WIDTH-1:0]  mesh_dest_x;
    logic [NODES*COORD_WIDTH-1:0]  mesh_dest_y;
    logic [NODES-1:0]               mesh_valid_in;
    logic [NODES-1:0]               mesh_ready_in;

    logic [NODES*DATA_WIDTH-1:0]   mesh_data_out;
    logic [NODES-1:0]               mesh_valid_out;

    logic [127:0] cpu_flit_out;
    logic         cpu_valid_out;
    logic         cpu_ready_out;

    logic [127:0] cpu_flit_in;
    logic         cpu_valid_in;
    logic         cpu_ready_in;

    logic [127:0] mem_flit_out;
    logic         mem_valid_out;
    logic         mem_ready_out;

    logic [127:0] mem_flit_in;
    logic         mem_valid_in;

    integer i;

    rv128i_anoc_node u_cpu_node (
        .clk            (clk),
        .rst            (rst),

        .req_valid      (req_valid),
        .req_ready      (req_ready),
        .req_write      (req_write),
        .req_addr       (req_addr),
        .req_wdata      (req_wdata),

        .src_x          (4'd0),
        .src_y          (4'd0),
        .dest_x         (dest_x),
        .dest_y         (dest_y),

        .resp_rdata     (resp_rdata),
        .resp_valid     (resp_valid),

        .noc_flit_out   (cpu_flit_out),
        .noc_valid_out  (cpu_valid_out),
        .noc_ready_out  (cpu_ready_out),

        .noc_flit_in    (cpu_flit_in),
        .noc_valid_in   (cpu_valid_in),
        .noc_ready_in   (cpu_ready_in)
    );

    /*
     * Build mesh input buses.
     *
     * Node 0  = CPU injection
     * Node 15 = memory response injection
     */
    always_comb begin
        mesh_data_in  = '0;
        mesh_dest_x   = '0;
        mesh_dest_y   = '0;
        mesh_valid_in = '0;

        /* CPU request at node 0 */
        mesh_data_in[0*DATA_WIDTH +: DATA_WIDTH] = cpu_flit_out;

        mesh_dest_x[0*COORD_WIDTH +: COORD_WIDTH] = dest_x;
        mesh_dest_y[0*COORD_WIDTH +: COORD_WIDTH] = dest_y;

        mesh_valid_in[0] = cpu_valid_out;

        /* Memory response at node 15 */
        mesh_data_in[15*DATA_WIDTH +: DATA_WIDTH] = mem_flit_out;

        mesh_dest_x[15*COORD_WIDTH +: COORD_WIDTH] = 4'd0;
        mesh_dest_y[15*COORD_WIDTH +: COORD_WIDTH] = 4'd0;

        mesh_valid_in[15] = mem_valid_out;

        cpu_ready_out = mesh_ready_in[0];
        mem_ready_out = mesh_ready_in[15];
    end

    /*
     * Local outputs.
     */
    assign cpu_flit_in =
        mesh_data_out[0*DATA_WIDTH +: DATA_WIDTH];

    assign cpu_valid_in =
        mesh_valid_out[0];

    assign mem_flit_in =
        mesh_data_out[15*DATA_WIDTH +: DATA_WIDTH];

    assign mem_valid_in =
        mesh_valid_out[15];

    anoc_rv_mesh #(
        .N           (N),
        .DATA_WIDTH  (DATA_WIDTH),
        .COORD_WIDTH (COORD_WIDTH)
    ) u_anoc_mesh (
        .clk       (clk),
        .rst_n     (~rst),

        .data_in   (mesh_data_in),
        .dest_x    (mesh_dest_x),
        .dest_y    (mesh_dest_y),
        .valid_in  (mesh_valid_in),
        .ready_in  (mesh_ready_in),

        .data_out  (mesh_data_out),
        .valid_out (mesh_valid_out)
    );

    rv128i_anoc_memory u_memory (
        .clk             (clk),
        .rst              (rst),

        .flit_in         (mem_flit_in),
        .flit_valid      (mem_valid_in),

        .resp_flit_out   (mem_flit_out),
        .resp_valid_out  (mem_valid_out),
        .resp_ready_out  (mem_ready_out),

        .write_complete  (mem_write_complete),
        .write_addr      (mem_write_addr),
        .write_data      (mem_write_data),
        .write_is_valid  ()
    );

endmodule
