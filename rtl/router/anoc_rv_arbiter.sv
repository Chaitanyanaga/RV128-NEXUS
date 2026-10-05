module anoc_rv_arbiter #(
    parameter int NUM_INPUTS = 5
) (
    input  logic [NUM_INPUTS-1:0] req,
    output logic [NUM_INPUTS-1:0] grant
);

    integer i;
    logic granted;

    always_comb begin
        grant   = '0;
        granted = 1'b0;

        // Fixed-priority arbitration:
        // Input 0 has highest priority.
        for (i = 0; i < NUM_INPUTS; i = i + 1) begin
            if (req[i] && !granted) begin
                grant[i] = 1'b1;
                granted  = 1'b1;
            end
        end
    end

endmodule
