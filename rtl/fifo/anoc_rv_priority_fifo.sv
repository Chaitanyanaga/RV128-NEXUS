`timescale 1ns/1ps
module anoc_rv_priority_fifo #(
    parameter int WIDTH         = 128,
    parameter int PRIORITY_BITS = 2,
    parameter int DEPTH         = 8
) (
    input  logic                     clk,
    input  logic                     rst_n,

    input  logic                     wr_valid,
    output logic                     wr_ready,
    input  logic [WIDTH-1:0]         wr_data,
    input  logic [PRIORITY_BITS-1:0] wr_priority,

    output logic                     rd_valid,
    input  logic                     rd_ready,
    output logic [WIDTH-1:0]         rd_data,
    output logic [PRIORITY_BITS-1:0] rd_priority,

    output logic                     full,
    output logic                     empty
);


    // ============================================================
    // Parameter checking
    // ============================================================



    // ============================================================
    // Local parameters
    // ============================================================

    localparam int NUM_PRIORITIES = 1 << PRIORITY_BITS;

    localparam int PTR_WIDTH =
        (DEPTH <= 1) ? 1 : $clog2(DEPTH);

    // ============================================================
    // Storage
    //
    // Each priority has its own FIFO queue.
    //
    // priority 3 -> queue 3
    // priority 2 -> queue 2
    // priority 1 -> queue 1
    // priority 0 -> queue 0
    // ============================================================

    logic [WIDTH-1:0] data_mem
        [0:NUM_PRIORITIES-1][0:DEPTH-1];

    logic [PTR_WIDTH-1:0] wr_ptr
        [0:NUM_PRIORITIES-1];

    logic [PTR_WIDTH-1:0] rd_ptr
        [0:NUM_PRIORITIES-1];

    logic [PTR_WIDTH:0] count
        [0:NUM_PRIORITIES-1];

    // ============================================================
    // Total occupancy
    // ============================================================

    logic [PTR_WIDTH+PRIORITY_BITS:0] total_count;

    integer p;

    always_comb begin

        total_count = '0;

        for (p = 0; p < NUM_PRIORITIES; p = p + 1) begin
            total_count = total_count + count[p];
        end

    end

    // ============================================================
    // Status
    // ============================================================

    assign full  = (total_count == DEPTH);
    assign empty = (total_count == 0);

    assign wr_ready = !full;

    // ============================================================
    // Highest-priority arbitration
    //
    // Search from highest priority toward lowest priority.
    // ============================================================

    logic [PRIORITY_BITS-1:0] selected_priority;
    logic                     selected_valid;

    integer sel;

    always @(*) begin

        selected_priority = '0;
        selected_valid    = 1'b0;

        for (sel = NUM_PRIORITIES-1; sel >= 0; sel = sel - 1) begin

            if (!selected_valid && (count[sel] != 0)) begin

                selected_priority = sel[PRIORITY_BITS-1:0];
                selected_valid    = 1'b1;

            end

        end

    end

    // ============================================================
    // Read interface
    // ============================================================

    assign rd_valid = selected_valid;

    assign rd_priority = selected_priority;

    assign rd_data =
        data_mem[selected_priority][rd_ptr[selected_priority]];

    // ============================================================
    // Sequential logic
    // ============================================================

    integer i;

    always_ff @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin

            for (i = 0; i < NUM_PRIORITIES; i = i + 1) begin

                wr_ptr[i] <= '0;
                rd_ptr[i] <= '0;
                count[i]  <= '0;

            end

        end
        else begin

            // ====================================================
            // WRITE
            // ====================================================

            if (wr_valid && wr_ready) begin

                data_mem[wr_priority][wr_ptr[wr_priority]]
                    <= wr_data;

                if (wr_ptr[wr_priority] == DEPTH-1)
                    wr_ptr[wr_priority] <= '0;
                else
                    wr_ptr[wr_priority]
                        <= wr_ptr[wr_priority] + 1'b1;

            end

            // ====================================================
            // READ
            // ====================================================

            if (rd_valid && rd_ready) begin

                if (rd_ptr[selected_priority] == DEPTH-1)
                    rd_ptr[selected_priority] <= '0;
                else
                    rd_ptr[selected_priority]
                        <= rd_ptr[selected_priority] + 1'b1;

            end

            // ====================================================
            // Per-priority occupancy
            // ====================================================

            for (i = 0; i < NUM_PRIORITIES; i = i + 1) begin

                case ({
                    wr_valid &&
                    wr_ready &&
                    (wr_priority == i),

                    rd_valid &&
                    rd_ready &&
                    (selected_priority == i)
                })

                    2'b10:
                        count[i] <= count[i] + 1'b1;

                    2'b01:
                        count[i] <= count[i] - 1'b1;

                    2'b11:
                        count[i] <= count[i];

                    default:
                        count[i] <= count[i];

                endcase

            end

        end

    end

endmodule
