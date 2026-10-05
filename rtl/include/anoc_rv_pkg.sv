package anoc_rv_pkg;

    // ============================================================
    // ANoC-RV Global Parameters
    // ============================================================

    parameter int FLIT_WIDTH    = 128;
    parameter int COORD_WIDTH   = 4;
    parameter int TYPE_WIDTH    = 2;
    parameter int FLAGS_WIDTH   = 4;

    localparam int HEADER_WIDTH =
        TYPE_WIDTH + FLAGS_WIDTH + (4 * COORD_WIDTH);

    localparam int PAYLOAD_WIDTH =
        FLIT_WIDTH - HEADER_WIDTH;

    parameter int ADDR_WIDTH = 8;
    parameter int NUM_PORTS  = 5;

    // ============================================================
    // Router Ports
    // ============================================================

    typedef enum logic [2:0] {
        PORT_LOCAL = 3'd0,
        PORT_NORTH = 3'd1,
        PORT_SOUTH = 3'd2,
        PORT_EAST  = 3'd3,
        PORT_WEST  = 3'd4
    } port_t;

    // ============================================================
    // Flit Types
    // ============================================================

    typedef enum logic [TYPE_WIDTH-1:0] {
        PKT_HEAD = 2'b01,
        PKT_BODY = 2'b10,
        PKT_TAIL = 2'b11
    } flit_type_t;

    // ============================================================
    // 128-bit FLIT
    //
    // [127:126] Type
    // [125:122] Flags
    // [121:118] Dest Y
    // [117:114] Dest X
    // [113:110] Src Y
    // [109:106] Src X
    // [105:0]   Payload
    // ============================================================

    typedef struct packed {
        flit_type_t                   flit_type;
        logic [FLAGS_WIDTH-1:0]       flags;
        logic [COORD_WIDTH-1:0]       dest_y;
        logic [COORD_WIDTH-1:0]       dest_x;
        logic [COORD_WIDTH-1:0]       src_y;
        logic [COORD_WIDTH-1:0]       src_x;
        logic [PAYLOAD_WIDTH-1:0]     payload;
    } flit_t;

endpackage
