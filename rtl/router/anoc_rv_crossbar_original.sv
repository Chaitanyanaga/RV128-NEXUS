module anoc_rv_crossbar #(
    parameter int NUM_PORTS = 5,
    parameter int DATA_WIDTH = 128
) (
    input  logic [DATA_WIDTH-1:0] data_in [0:NUM_PORTS-1],

    input  logic [$clog2(NUM_PORTS)-1:0] select [0:NUM_PORTS-1],

    output logic [DATA_WIDTH-1:0] data_out [0:NUM_PORTS-1]
);

    integer i;

    always_comb begin
        for (i = 0; i < NUM_PORTS; i = i + 1) begin
            data_out[i] = '0;

            if (select[i] < NUM_PORTS)
                data_out[i] = data_in[select[i]];
        end
    end

endmodule
