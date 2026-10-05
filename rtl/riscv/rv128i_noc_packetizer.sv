`timescale 1ns/1ps

module rv128i_noc_packetizer #(
    parameter int DATA_WIDTH = 128
) (
    input  logic                  clk,
    input  logic                  rst,

    input  logic                  req_valid,
    output logic                  req_ready,
    input  logic                  req_write,
    input  logic [127:0]          req_addr,
    input  logic [127:0]          req_wdata,

    input  logic [3:0]            src_x,
    input  logic [3:0]            src_y,
    input  logic [3:0]            dest_x,
    input  logic [3:0]            dest_y,

    output logic [127:0]          flit_out,
    output logic                  flit_valid,
    input  logic                  flit_ready
);

    localparam logic [1:0] PKT_HEAD = 2'b01;
    localparam logic [1:0] PKT_BODY = 2'b10;
    localparam logic [1:0] PKT_TAIL = 2'b11;

    typedef enum logic [1:0] {
        S_IDLE = 2'd0,
        S_HEAD = 2'd1,
        S_BODY = 2'd2,
        S_TAIL = 2'd3
    } state_t;

    state_t state;

    logic         write_q;
    logic [127:0] addr_q;
    logic [127:0] data_q;
    logic [3:0]   sx_q, sy_q;
    logic [3:0]   dx_q, dy_q;

    always_comb begin
        flit_out   = 128'd0;
        flit_valid = 1'b0;
        req_ready  = (state == S_IDLE);

        case (state)

            S_HEAD: begin
                flit_valid = 1'b1;

                flit_out[127:126] = PKT_HEAD;
                flit_out[125:122] = {3'b000, write_q};

                flit_out[121:118] = dy_q;
                flit_out[117:114] = dx_q;
                flit_out[113:110] = sy_q;
                flit_out[109:106] = sx_q;

                flit_out[105:0] = addr_q[105:0];
            end

            S_BODY: begin
                flit_valid = 1'b1;

                flit_out[127:126] = PKT_BODY;
                flit_out[125:122] = 4'b0;

                flit_out[121:118] = dy_q;
                flit_out[117:114] = dx_q;
                flit_out[113:110] = sy_q;
                flit_out[109:106] = sx_q;

                flit_out[21:0]  = addr_q[127:106];
                flit_out[105:22] = data_q[83:0];
            end

            S_TAIL: begin
                flit_valid = 1'b1;

                flit_out[127:126] = PKT_TAIL;
                flit_out[125:122] = 4'b0;

                flit_out[121:118] = dy_q;
                flit_out[117:114] = dx_q;
                flit_out[113:110] = sy_q;
                flit_out[109:106] = sx_q;

                flit_out[43:0] = data_q[127:84];
            end

            default: begin
                flit_valid = 1'b0;
            end
        endcase
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state  <= S_IDLE;
            write_q <= 1'b0;
            addr_q  <= 128'd0;
            data_q  <= 128'd0;
            sx_q <= 4'd0;
            sy_q <= 4'd0;
            dx_q <= 4'd0;
            dy_q <= 4'd0;
        end
        else begin
            case (state)
                S_IDLE: begin
                    if (req_valid) begin
                        write_q <= req_write;
                        addr_q  <= req_addr;
                        data_q  <= req_wdata;
                        sx_q    <= src_x;
                        sy_q    <= src_y;
                        dx_q    <= dest_x;
                        dy_q    <= dest_y;
                        state   <= S_HEAD;
                    end
                end

                S_HEAD: if (flit_ready) state <= S_BODY;
                S_BODY: if (flit_ready) state <= S_TAIL;
                S_TAIL: if (flit_ready) state <= S_IDLE;

                default: state <= S_IDLE;
            endcase
        end
    end

endmodule
