`timescale 1ns/1ps

module rv128i_anoc_memory #(
    parameter int DATA_WIDTH = 128,
    parameter int MEM_DEPTH  = 256
) (
    input  logic                  clk,
    input  logic                  rst,

    // Request FLITs from local ANoC output
    input  logic [DATA_WIDTH-1:0] flit_in,
    input  logic                  flit_valid,

    // Response FLITs injected into local ANoC input
    output logic [DATA_WIDTH-1:0] resp_flit_out,
    output logic                  resp_valid_out,
    input  logic                  resp_ready_out,

    output logic                  write_complete,
    output logic [127:0]          write_addr,
    output logic [127:0]          write_data,
    output logic                  write_is_valid
);

    localparam logic [1:0] PKT_HEAD = 2'b01;
    localparam logic [1:0] PKT_BODY = 2'b10;
    localparam logic [1:0] PKT_TAIL = 2'b11;

    localparam logic [1:0] RX_IDLE = 2'd0;
    localparam logic [1:0] RX_HEAD = 2'd1;
    localparam logic [1:0] RX_BODY = 2'd2;

    localparam logic [1:0] TX_IDLE = 2'd0;
    localparam logic [1:0] TX_HEAD = 2'd1;
    localparam logic [1:0] TX_TAIL = 2'd2;

    logic [1:0] rx_state;
    logic [1:0] tx_state;

    logic        write_q;
    logic [127:0] addr_q;
    logic [127:0] data_q;

    logic [127:0] mem [0:MEM_DEPTH-1];

    logic [127:0] response_data_q;

    wire [1:0] pkt_type = flit_in[127:126];
    wire [3:0] flags    = flit_in[125:122];

    wire [127:0] mem_index_addr = addr_q;

    integer i;

    always_comb begin
        resp_flit_out  = 128'd0;
        resp_valid_out = 1'b0;

        case (tx_state)

            TX_HEAD: begin
                resp_valid_out = 1'b1;

                // Response uses destination/source fields already present
                // in returned request path. For this first milestone,
                // route back to source node (0,0).
                resp_flit_out[127:126] = PKT_HEAD;
                resp_flit_out[125:122] = 4'b0000;
                resp_flit_out[121:118] = 4'd0; // dest_y
                resp_flit_out[117:114] = 4'd0; // dest_x
                resp_flit_out[113:110] = 4'd3; // source_y = memory node
                resp_flit_out[109:106] = 4'd3; // source_x = memory node

                // lower 106 bits of 128-bit read data
                resp_flit_out[105:0] = response_data_q[105:0];
            end

            TX_TAIL: begin
                resp_valid_out = 1'b1;

                resp_flit_out[127:126] = PKT_TAIL;
                resp_flit_out[125:122] = 4'b0000;
                resp_flit_out[121:118] = 4'd0;
                resp_flit_out[117:114] = 4'd0;
                resp_flit_out[113:110] = 4'd3;
                resp_flit_out[109:106] = 4'd3;

                // remaining 22 bits
                resp_flit_out[21:0] = response_data_q[127:106];
            end

            default: begin
                resp_valid_out = 1'b0;
            end
        endcase
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            rx_state         <= RX_IDLE;
            tx_state         <= TX_IDLE;
            write_q          <= 1'b0;
            addr_q           <= 128'd0;
            data_q           <= 128'd0;
            response_data_q  <= 128'd0;

            write_complete   <= 1'b0;
            write_is_valid   <= 1'b0;
            write_addr       <= 128'd0;
            write_data       <= 128'd0;

            for (i = 0; i < MEM_DEPTH; i = i + 1)
                mem[i] <= 128'd0;
        end
        else begin
            write_complete <= 1'b0;
            write_is_valid <= 1'b0;

            // ---------------- RECEIVE ----------------
            if (flit_valid) begin
                case (rx_state)

                    RX_IDLE: begin
                        if (pkt_type == PKT_HEAD) begin
                            write_q        <= flags[0];
                            addr_q[105:0]  <= flit_in[105:0];
                            addr_q[127:106] <= 22'd0;
                            rx_state       <= RX_HEAD;
                        end
                    end

                    RX_HEAD: begin
                        if (pkt_type == PKT_BODY) begin
                            addr_q[127:106] <= flit_in[21:0];
                            data_q[83:0]    <= flit_in[105:22];
                            rx_state        <= RX_BODY;
                        end
                    end

                    RX_BODY: begin
                        if (pkt_type == PKT_TAIL) begin
                            data_q[127:84] <= flit_in[43:0];

                            if (write_q) begin
                                mem[addr_q[7:0]] <= {
                                    flit_in[43:0],
                                    data_q[83:0]
                                };

                                write_addr <= addr_q;
                                write_data <= {
                                    flit_in[43:0],
                                    data_q[83:0]
                                };

                                write_complete <= 1'b1;
                                write_is_valid <= 1'b1;
                            end
                            else begin
                                response_data_q <= mem[addr_q[7:0]];
                                tx_state <= TX_HEAD;
                            end

                            rx_state <= RX_IDLE;
                        end
                    end

                    default:
                        rx_state <= RX_IDLE;
                endcase
            end

            // ---------------- TRANSMIT ----------------
            if (tx_state == TX_HEAD && resp_ready_out)
                tx_state <= TX_TAIL;
            else if (tx_state == TX_TAIL && resp_ready_out)
                tx_state <= TX_IDLE;
        end
    end

endmodule
