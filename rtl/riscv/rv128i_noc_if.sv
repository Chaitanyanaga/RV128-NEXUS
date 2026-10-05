`timescale 1ns/1ps

module rv128i_noc_if #(
    parameter int DATA_WIDTH = 128
) (
    input  logic                   clk,
    input  logic                   rst,

    // CPU memory request side
    input  logic                   cpu_valid,
    output logic                   cpu_ready,
    input  logic                   cpu_we,
    input  logic [127:0]           cpu_addr,
    input  logic [127:0]           cpu_wdata,
    output logic [127:0]           cpu_rdata,

    // Destination of this request in the NoC
    input  logic [3:0]             dest_x,
    input  logic [3:0]             dest_y,

    // ANoC 128-bit FLIT output
    output logic [DATA_WIDTH-1:0]  noc_flit_out,
    output logic                   noc_valid_out,
    input  logic                   noc_ready_out,

    // ANoC 128-bit FLIT input
    input  logic [DATA_WIDTH-1:0]  noc_flit_in,
    input  logic                   noc_valid_in,
    output logic                   noc_ready_in
);

    logic waiting_response;

    // Existing ANoC FLIT convention used here:
    // [127:124] source/destination metadata
    // [123:120] destination X
    // [119:116] destination Y
    // [115:114] packet type
    // [113:110] flags
    // [105:0]   payload
    //
    // Payload mapping for this experimental RV128I interface:
    // [105:0] -> lower 106 bits of request data/address metadata.
    //
    // Full 128-bit CPU address/data cannot fit into a single 106-bit
    // payload, so a two-flit transaction will be introduced later.
    //
    // This first milestone carries address + control in the first FLIT
    // and is intended to validate the interface handshake itself.

    always_comb begin
        noc_flit_out = '0;

        // Destination information.
        noc_flit_out[123:120] = dest_x;
        noc_flit_out[119:116] = dest_y;

        // HEAD packet.
        noc_flit_out[115:114] = 2'b00;

        // flags[0] = write enable.
        noc_flit_out[109] = cpu_we;

        // Address/control payload for first transaction flit.
        noc_flit_out[105:0] = cpu_addr[105:0];

        noc_valid_out = cpu_valid && !waiting_response;
        cpu_ready     = cpu_valid &&
                        !waiting_response &&
                        noc_ready_out;

        noc_ready_in  = waiting_response;
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            waiting_response <= 1'b0;
            cpu_rdata        <= 128'b0;
        end
        else begin
            // Request accepted by NoC.
            if (cpu_valid && !waiting_response && noc_ready_out) begin
                if (cpu_we)
                    waiting_response <= 1'b0;
                else
                    waiting_response <= 1'b1;
            end

            // Read response accepted.
            if (waiting_response && noc_valid_in) begin
                cpu_rdata        <= noc_flit_in;
                waiting_response <= 1'b0;
            end
        end
    end

endmodule
