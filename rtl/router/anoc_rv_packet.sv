module anoc_rv_packet #(
    parameter int COORD_WIDTH = 4,
    parameter int FLIT_WIDTH  = 128,
    parameter int FLAGS_WIDTH = 4
) (
    input  logic [COORD_WIDTH-1:0] src_x,
    input  logic [COORD_WIDTH-1:0] src_y,
    input  logic [COORD_WIDTH-1:0] dest_x,
    input  logic [COORD_WIDTH-1:0] dest_y,

    input  logic [FLAGS_WIDTH-1:0] flags,
    input  logic [FLIT_WIDTH-1:0] payload,

    input  logic [1:0] packet_type,

    output logic [127:0] flit
);

    localparam int PAYLOAD_WIDTH =
        FLIT_WIDTH - 2 - FLAGS_WIDTH - (4 * COORD_WIDTH);

    always_comb begin
        flit = {
            packet_type,
            flags,
            dest_y,
            dest_x,
            src_y,
            src_x,
            payload[PAYLOAD_WIDTH-1:0]
        };
    end

endmodule
