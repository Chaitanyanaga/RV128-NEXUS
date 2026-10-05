module anoc_rv_packet_parser #(
    parameter int COORD_WIDTH = 4,
    parameter int FLIT_WIDTH  = 128,
    parameter int FLAGS_WIDTH = 4
) (
    input logic [FLIT_WIDTH-1:0] flit,

    output logic [COORD_WIDTH-1:0] src_x,
    output logic [COORD_WIDTH-1:0] src_y,
    output logic [COORD_WIDTH-1:0] dest_x,
    output logic [COORD_WIDTH-1:0] dest_y,

    output logic [FLAGS_WIDTH-1:0] flags,
    output logic [FLIT_WIDTH-1:0] payload,

    output logic [1:0] packet_type
);

    localparam int PAYLOAD_WIDTH =
        FLIT_WIDTH - 2 - FLAGS_WIDTH - (4 * COORD_WIDTH);

    always_comb begin

        packet_type = flit[127:126];

        flags = flit[125:122];

        dest_y = flit[121:118];

        dest_x = flit[117:114];

        src_y = flit[113:110];

        src_x = flit[109:106];

        payload = '0;
        payload[PAYLOAD_WIDTH-1:0] =
            flit[PAYLOAD_WIDTH-1:0];

    end

endmodule
