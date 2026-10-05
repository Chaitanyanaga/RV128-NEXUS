module anoc_rv_crossbar #(
    parameter int NUM_PORTS  = 5,
    parameter int DATA_WIDTH = 128
) (
    input  logic [NUM_PORTS*DATA_WIDTH-1:0] data_in,
    input  logic [NUM_PORTS*3-1:0]          select,
    output logic [NUM_PORTS*DATA_WIDTH-1:0] data_out
);

    integer i;
    integer sel;

    always_comb begin
        data_out = '0;

        for (i = 0; i < NUM_PORTS; i = i + 1) begin
            sel = select[i*3 +: 3];

            if (sel < NUM_PORTS)
                data_out[i*DATA_WIDTH +: DATA_WIDTH] =
                    data_in[sel*DATA_WIDTH +: DATA_WIDTH];
        end
    end

endmodule
