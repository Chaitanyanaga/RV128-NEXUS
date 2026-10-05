`timescale 1ns/1ps

module rv128i_pc #(
    parameter logic [127:0] RESET_PC = 128'h0
) (
    input  logic         clk,
    input  logic         rst,
    input  logic         enable,
    input  logic         branch_taken,
    input  logic [127:0] branch_target,

    output logic [127:0] pc
);

    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            pc <= RESET_PC;
        else if (enable) begin
            if (branch_taken)
                pc <= branch_target;
            else
                pc <= pc + 128'd4;
        end
    end

endmodule
