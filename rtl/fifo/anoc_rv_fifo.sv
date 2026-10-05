`timescale 1ns/1ps
module anoc_rv_fifo #(
    parameter int WIDTH = 128,
    parameter int DEPTH = 4
) (
    input  logic             clk,
    input  logic             rst_n,

    input  logic             wr_valid,
    output logic             wr_ready,
    input  logic [WIDTH-1:0] wr_data,

    output logic             rd_valid,
    input  logic             rd_ready,
    output logic [WIDTH-1:0] rd_data,

    output logic             full,
    output logic             empty
);


    // ------------------------------------------------------------
    // Parameter validation
    // ------------------------------------------------------------



    // ------------------------------------------------------------
    // Local parameters
    // ------------------------------------------------------------

    localparam int PTR_WIDTH =
        (DEPTH <= 1) ? 1 : $clog2(DEPTH);

    // ------------------------------------------------------------
    // FIFO storage
    // ------------------------------------------------------------

    logic [WIDTH-1:0] mem [0:DEPTH-1];

    logic [PTR_WIDTH-1:0] wr_ptr;
    logic [PTR_WIDTH-1:0] rd_ptr;

    logic [PTR_WIDTH:0] count;

    // ------------------------------------------------------------
    // Status
    // ------------------------------------------------------------

    assign full     = (count == DEPTH);
    assign empty    = (count == 0);

    assign wr_ready = !full;
    assign rd_valid = !empty;

    assign rd_data  = mem[rd_ptr];

    // ------------------------------------------------------------
    // Handshake events
    // ------------------------------------------------------------

    logic do_write;
    logic do_read;

    assign do_write = wr_valid && wr_ready;
    assign do_read  = rd_valid && rd_ready;

    // ------------------------------------------------------------
    // Sequential logic
    // ------------------------------------------------------------

    always_ff @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin

            wr_ptr <= '0;
            rd_ptr <= '0;
            count  <= '0;

        end
        else begin

            // ----------------------------------------------------
            // Write
            // ----------------------------------------------------

            if (do_write) begin

                mem[wr_ptr] <= wr_data;

                if (wr_ptr == DEPTH-1)
                    wr_ptr <= '0;
                else
                    wr_ptr <= wr_ptr + 1'b1;

            end

            // ----------------------------------------------------
            // Read
            // ----------------------------------------------------

            if (do_read) begin

                if (rd_ptr == DEPTH-1)
                    rd_ptr <= '0;
                else
                    rd_ptr <= rd_ptr + 1'b1;

            end

            // ----------------------------------------------------
            // Occupancy counter
            // ----------------------------------------------------

            case ({do_write, do_read})

                2'b10: count <= count + 1'b1;

                2'b01: count <= count - 1'b1;

                2'b11: count <= count;

                default: count <= count;

            endcase

        end

    end

endmodule
