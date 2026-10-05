`timescale 1ns/1ps

module rv128i_anoc_node #(
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

    output logic [127:0]          resp_rdata,
    output logic                  resp_valid,

    output logic [127:0]          noc_flit_out,
    output logic                  noc_valid_out,
    input  logic                  noc_ready_out,

    input  logic [127:0]          noc_flit_in,
    input  logic                  noc_valid_in,
    output logic                  noc_ready_in
);

    logic packet_req_ready;
    logic [127:0] packet_flit_out;
    logic         packet_flit_valid;

    logic response_waiting;
    logic response_tail_pending;

    logic [105:0] response_low;
    logic [127:106] response_high;

    rv128i_noc_packetizer u_packetizer (
        .clk        (clk),
        .rst        (rst),

        .req_valid  (req_valid),
        .req_ready  (packet_req_ready),
        .req_write  (req_write),
        .req_addr   (req_addr),
        .req_wdata  (req_wdata),

        .src_x      (src_x),
        .src_y      (src_y),
        .dest_x     (dest_x),
        .dest_y     (dest_y),

        .flit_out   (packet_flit_out),
        .flit_valid (packet_flit_valid),
        .flit_ready (noc_ready_out)
    );

    assign req_ready     = packet_req_ready;
    assign noc_flit_out  = packet_flit_out;
    assign noc_valid_out = packet_flit_valid;

    assign noc_ready_in  = response_waiting;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            response_waiting     <= 1'b0;
            response_tail_pending <= 1'b0;
            response_low         <= 106'd0;
            response_high        <= 22'd0;
            resp_rdata           <= 128'd0;
            resp_valid           <= 1'b0;
        end
        else begin
            resp_valid <= 1'b0;

            // A read request has been accepted by the NoC.
            if (req_valid && req_ready && !req_write) begin
                response_waiting <= 1'b1;
            end

            if (response_waiting && noc_valid_in) begin
                case (noc_flit_in[127:126])

                    2'b01: begin
                        response_low <= noc_flit_in[105:0];
                        response_tail_pending <= 1'b1;
                    end

                    2'b11: begin
                        if (response_tail_pending) begin
                            response_high <= noc_flit_in[21:0];

                            resp_rdata <= {
                                noc_flit_in[21:0],
                                response_low
                            };

                            resp_valid            <= 1'b1;
                            response_waiting      <= 1'b0;
                            response_tail_pending <= 1'b0;
                        end
                    end

                    default: begin
                    end

                endcase
            end
        end
    end

endmodule
