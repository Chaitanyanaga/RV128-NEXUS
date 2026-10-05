`timescale 1ns/1ps

module anoc_rv_mesh_4x4_asic_top #(
    parameter int DATA_WIDTH  = 128,
    parameter int COORD_WIDTH = 4,
    parameter int NUM_PORTS   = 5,
    parameter int NODES       = 16
)(
    input  logic                   clk,
    input  logic                   rst,

    input  logic [3:0]             source_id,
    input  logic [3:0]             sink_id,
    input  logic [DATA_WIDTH-1:0]  flit_in,
    input  logic [COORD_WIDTH-1:0] dest_x,
    input  logic [COORD_WIDTH-1:0] dest_y,
    input  logic                   valid_in,
    output logic                   ready_in,

    output logic [DATA_WIDTH-1:0]  flit_out,
    output logic                   valid_out,
    input  logic                   ready_out
);

    localparam int NODE_DATA_W  = NUM_PORTS * DATA_WIDTH;
    localparam int NODE_COORD_W = NUM_PORTS * COORD_WIDTH;

    logic [NODES*NODE_DATA_W-1:0]  mesh_data_in;
    logic [NODES*NODE_COORD_W-1:0] mesh_dest_x;
    logic [NODES*NODE_COORD_W-1:0] mesh_dest_y;
    logic [NODES*NUM_PORTS-1:0]    mesh_valid_in;
    logic [NODES*NUM_PORTS-1:0]    mesh_ready_in;
    logic [NODES*NUM_PORTS-1:0]    mesh_ready_out;
    logic [NODES*NODE_DATA_W-1:0]  mesh_data_out;
    logic [NODES*NUM_PORTS-1:0]    mesh_valid_out;

    // 1-entry output register to break the critical mesh -> IO path.
    logic [DATA_WIDTH-1:0] out_data_reg;
    logic                  out_valid_reg;

    logic [DATA_WIDTH-1:0] selected_data;
    logic                  selected_valid;

    always_comb begin
        mesh_data_in   = '0;
        mesh_dest_x    = '0;
        mesh_dest_y    = '0;
        mesh_valid_in  = '0;
        mesh_ready_out = '0;

        flit_out  = out_data_reg;
        valid_out = out_valid_reg;
        ready_in  = 1'b0;

        selected_data  = '0;
        selected_valid = 1'b0;

        // ------------------------------------------------------------
        // Source-node selection
        // ------------------------------------------------------------
        case (source_id)
            4'd0: begin
                mesh_data_in[0*NODE_DATA_W +: DATA_WIDTH] = flit_in;
                mesh_dest_x[0*NODE_COORD_W +: COORD_WIDTH] = dest_x;
                mesh_dest_y[0*NODE_COORD_W +: COORD_WIDTH] = dest_y;
                mesh_valid_in[0*NUM_PORTS] = valid_in;
                ready_in = mesh_ready_in[0*NUM_PORTS];
            end

            4'd1: begin
                mesh_data_in[1*NODE_DATA_W +: DATA_WIDTH] = flit_in;
                mesh_dest_x[1*NODE_COORD_W +: COORD_WIDTH] = dest_x;
                mesh_dest_y[1*NODE_COORD_W +: COORD_WIDTH] = dest_y;
                mesh_valid_in[1*NUM_PORTS] = valid_in;
                ready_in = mesh_ready_in[1*NUM_PORTS];
            end

            4'd2: begin
                mesh_data_in[2*NODE_DATA_W +: DATA_WIDTH] = flit_in;
                mesh_dest_x[2*NODE_COORD_W +: COORD_WIDTH] = dest_x;
                mesh_dest_y[2*NODE_COORD_W +: COORD_WIDTH] = dest_y;
                mesh_valid_in[2*NUM_PORTS] = valid_in;
                ready_in = mesh_ready_in[2*NUM_PORTS];
            end

            4'd3: begin
                mesh_data_in[3*NODE_DATA_W +: DATA_WIDTH] = flit_in;
                mesh_dest_x[3*NODE_COORD_W +: COORD_WIDTH] = dest_x;
                mesh_dest_y[3*NODE_COORD_W +: COORD_WIDTH] = dest_y;
                mesh_valid_in[3*NUM_PORTS] = valid_in;
                ready_in = mesh_ready_in[3*NUM_PORTS];
            end

            4'd4: begin
                mesh_data_in[4*NODE_DATA_W +: DATA_WIDTH] = flit_in;
                mesh_dest_x[4*NODE_COORD_W +: COORD_WIDTH] = dest_x;
                mesh_dest_y[4*NODE_COORD_W +: COORD_WIDTH] = dest_y;
                mesh_valid_in[4*NUM_PORTS] = valid_in;
                ready_in = mesh_ready_in[4*NUM_PORTS];
            end

            4'd5: begin
                mesh_data_in[5*NODE_DATA_W +: DATA_WIDTH] = flit_in;
                mesh_dest_x[5*NODE_COORD_W +: COORD_WIDTH] = dest_x;
                mesh_dest_y[5*NODE_COORD_W +: COORD_WIDTH] = dest_y;
                mesh_valid_in[5*NUM_PORTS] = valid_in;
                ready_in = mesh_ready_in[5*NUM_PORTS];
            end

            4'd6: begin
                mesh_data_in[6*NODE_DATA_W +: DATA_WIDTH] = flit_in;
                mesh_dest_x[6*NODE_COORD_W +: COORD_WIDTH] = dest_x;
                mesh_dest_y[6*NODE_COORD_W +: COORD_WIDTH] = dest_y;
                mesh_valid_in[6*NUM_PORTS] = valid_in;
                ready_in = mesh_ready_in[6*NUM_PORTS];
            end

            4'd7: begin
                mesh_data_in[7*NODE_DATA_W +: DATA_WIDTH] = flit_in;
                mesh_dest_x[7*NODE_COORD_W +: COORD_WIDTH] = dest_x;
                mesh_dest_y[7*NODE_COORD_W +: COORD_WIDTH] = dest_y;
                mesh_valid_in[7*NUM_PORTS] = valid_in;
                ready_in = mesh_ready_in[7*NUM_PORTS];
            end

            4'd8: begin
                mesh_data_in[8*NODE_DATA_W +: DATA_WIDTH] = flit_in;
                mesh_dest_x[8*NODE_COORD_W +: COORD_WIDTH] = dest_x;
                mesh_dest_y[8*NODE_COORD_W +: COORD_WIDTH] = dest_y;
                mesh_valid_in[8*NUM_PORTS] = valid_in;
                ready_in = mesh_ready_in[8*NUM_PORTS];
            end

            4'd9: begin
                mesh_data_in[9*NODE_DATA_W +: DATA_WIDTH] = flit_in;
                mesh_dest_x[9*NODE_COORD_W +: COORD_WIDTH] = dest_x;
                mesh_dest_y[9*NODE_COORD_W +: COORD_WIDTH] = dest_y;
                mesh_valid_in[9*NUM_PORTS] = valid_in;
                ready_in = mesh_ready_in[9*NUM_PORTS];
            end

            4'd10: begin
                mesh_data_in[10*NODE_DATA_W +: DATA_WIDTH] = flit_in;
                mesh_dest_x[10*NODE_COORD_W +: COORD_WIDTH] = dest_x;
                mesh_dest_y[10*NODE_COORD_W +: COORD_WIDTH] = dest_y;
                mesh_valid_in[10*NUM_PORTS] = valid_in;
                ready_in = mesh_ready_in[10*NUM_PORTS];
            end

            4'd11: begin
                mesh_data_in[11*NODE_DATA_W +: DATA_WIDTH] = flit_in;
                mesh_dest_x[11*NODE_COORD_W +: COORD_WIDTH] = dest_x;
                mesh_dest_y[11*NODE_COORD_W +: COORD_WIDTH] = dest_y;
                mesh_valid_in[11*NUM_PORTS] = valid_in;
                ready_in = mesh_ready_in[11*NUM_PORTS];
            end

            4'd12: begin
                mesh_data_in[12*NODE_DATA_W +: DATA_WIDTH] = flit_in;
                mesh_dest_x[12*NODE_COORD_W +: COORD_WIDTH] = dest_x;
                mesh_dest_y[12*NODE_COORD_W +: COORD_WIDTH] = dest_y;
                mesh_valid_in[12*NUM_PORTS] = valid_in;
                ready_in = mesh_ready_in[12*NUM_PORTS];
            end

            4'd13: begin
                mesh_data_in[13*NODE_DATA_W +: DATA_WIDTH] = flit_in;
                mesh_dest_x[13*NODE_COORD_W +: COORD_WIDTH] = dest_x;
                mesh_dest_y[13*NODE_COORD_W +: COORD_WIDTH] = dest_y;
                mesh_valid_in[13*NUM_PORTS] = valid_in;
                ready_in = mesh_ready_in[13*NUM_PORTS];
            end

            4'd14: begin
                mesh_data_in[14*NODE_DATA_W +: DATA_WIDTH] = flit_in;
                mesh_dest_x[14*NODE_COORD_W +: COORD_WIDTH] = dest_x;
                mesh_dest_y[14*NODE_COORD_W +: COORD_WIDTH] = dest_y;
                mesh_valid_in[14*NUM_PORTS] = valid_in;
                ready_in = mesh_ready_in[14*NUM_PORTS];
            end

            4'd15: begin
                mesh_data_in[15*NODE_DATA_W +: DATA_WIDTH] = flit_in;
                mesh_dest_x[15*NODE_COORD_W +: COORD_WIDTH] = dest_x;
                mesh_dest_y[15*NODE_COORD_W +: COORD_WIDTH] = dest_y;
                mesh_valid_in[15*NUM_PORTS] = valid_in;
                ready_in = mesh_ready_in[15*NUM_PORTS];
            end

            default: begin
                ready_in = 1'b0;
            end
        endcase

        // ------------------------------------------------------------
        // Sink-node selection
        // ------------------------------------------------------------
        case (sink_id)
            4'd0: begin
                selected_data = mesh_data_out[0*NODE_DATA_W +: DATA_WIDTH];
                selected_valid = mesh_valid_out[0*NUM_PORTS];
            end

            4'd1: begin
                selected_data = mesh_data_out[1*NODE_DATA_W +: DATA_WIDTH];
                selected_valid = mesh_valid_out[1*NUM_PORTS];
            end

            4'd2: begin
                selected_data = mesh_data_out[2*NODE_DATA_W +: DATA_WIDTH];
                selected_valid = mesh_valid_out[2*NUM_PORTS];
            end

            4'd3: begin
                selected_data = mesh_data_out[3*NODE_DATA_W +: DATA_WIDTH];
                selected_valid = mesh_valid_out[3*NUM_PORTS];
            end

            4'd4: begin
                selected_data = mesh_data_out[4*NODE_DATA_W +: DATA_WIDTH];
                selected_valid = mesh_valid_out[4*NUM_PORTS];
            end

            4'd5: begin
                selected_data = mesh_data_out[5*NODE_DATA_W +: DATA_WIDTH];
                selected_valid = mesh_valid_out[5*NUM_PORTS];
            end

            4'd6: begin
                selected_data = mesh_data_out[6*NODE_DATA_W +: DATA_WIDTH];
                selected_valid = mesh_valid_out[6*NUM_PORTS];
            end

            4'd7: begin
                selected_data = mesh_data_out[7*NODE_DATA_W +: DATA_WIDTH];
                selected_valid = mesh_valid_out[7*NUM_PORTS];
            end

            4'd8: begin
                selected_data = mesh_data_out[8*NODE_DATA_W +: DATA_WIDTH];
                selected_valid = mesh_valid_out[8*NUM_PORTS];
            end

            4'd9: begin
                selected_data = mesh_data_out[9*NODE_DATA_W +: DATA_WIDTH];
                selected_valid = mesh_valid_out[9*NUM_PORTS];
            end

            4'd10: begin
                selected_data = mesh_data_out[10*NODE_DATA_W +: DATA_WIDTH];
                selected_valid = mesh_valid_out[10*NUM_PORTS];
            end

            4'd11: begin
                selected_data = mesh_data_out[11*NODE_DATA_W +: DATA_WIDTH];
                selected_valid = mesh_valid_out[11*NUM_PORTS];
            end

            4'd12: begin
                selected_data = mesh_data_out[12*NODE_DATA_W +: DATA_WIDTH];
                selected_valid = mesh_valid_out[12*NUM_PORTS];
            end

            4'd13: begin
                selected_data = mesh_data_out[13*NODE_DATA_W +: DATA_WIDTH];
                selected_valid = mesh_valid_out[13*NUM_PORTS];
            end

            4'd14: begin
                selected_data = mesh_data_out[14*NODE_DATA_W +: DATA_WIDTH];
                selected_valid = mesh_valid_out[14*NUM_PORTS];
            end

            4'd15: begin
                selected_data = mesh_data_out[15*NODE_DATA_W +: DATA_WIDTH];
                selected_valid = mesh_valid_out[15*NUM_PORTS];
            end

            default: begin
                selected_data  = '0;
                selected_valid = 1'b0;
            end
        endcase
    end

    // Ready from the mesh depends only on output-register capacity.
    always_comb begin
        mesh_ready_out = '0;
        case (sink_id)
            4'd0:  mesh_ready_out[0*NUM_PORTS]  = (~out_valid_reg) | ready_out;
            4'd1:  mesh_ready_out[1*NUM_PORTS]  = (~out_valid_reg) | ready_out;
            4'd2:  mesh_ready_out[2*NUM_PORTS]  = (~out_valid_reg) | ready_out;
            4'd3:  mesh_ready_out[3*NUM_PORTS]  = (~out_valid_reg) | ready_out;
            4'd4:  mesh_ready_out[4*NUM_PORTS]  = (~out_valid_reg) | ready_out;
            4'd5:  mesh_ready_out[5*NUM_PORTS]  = (~out_valid_reg) | ready_out;
            4'd6:  mesh_ready_out[6*NUM_PORTS]  = (~out_valid_reg) | ready_out;
            4'd7:  mesh_ready_out[7*NUM_PORTS]  = (~out_valid_reg) | ready_out;
            4'd8:  mesh_ready_out[8*NUM_PORTS]  = (~out_valid_reg) | ready_out;
            4'd9:  mesh_ready_out[9*NUM_PORTS]  = (~out_valid_reg) | ready_out;
            4'd10: mesh_ready_out[10*NUM_PORTS] = (~out_valid_reg) | ready_out;
            4'd11: mesh_ready_out[11*NUM_PORTS] = (~out_valid_reg) | ready_out;
            4'd12: mesh_ready_out[12*NUM_PORTS] = (~out_valid_reg) | ready_out;
            4'd13: mesh_ready_out[13*NUM_PORTS] = (~out_valid_reg) | ready_out;
            4'd14: mesh_ready_out[14*NUM_PORTS] = (~out_valid_reg) | ready_out;
            4'd15: mesh_ready_out[15*NUM_PORTS] = (~out_valid_reg) | ready_out;
            default: mesh_ready_out = '0;
        endcase
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            out_data_reg  <= '0;
            out_valid_reg <= 1'b0;
        end else begin
            if (selected_valid && ((~out_valid_reg) || ready_out)) begin
                out_data_reg  <= selected_data;
                out_valid_reg <= 1'b1;
            end else if (out_valid_reg && ready_out) begin
                out_valid_reg <= 1'b0;
            end
        end
    end

    anoc_rv_mesh_4x4_synth mesh (
        .clk       (clk),
        .rst       (rst),
        .data_in   (mesh_data_in),
        .dest_x    (mesh_dest_x),
        .dest_y    (mesh_dest_y),
        .valid_in  (mesh_valid_in),
        .ready_in  (mesh_ready_in),
        .ready_out (mesh_ready_out),
        .data_out  (mesh_data_out),
        .valid_out (mesh_valid_out)
    );

endmodule
