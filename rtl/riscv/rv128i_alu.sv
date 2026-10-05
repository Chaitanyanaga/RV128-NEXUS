`timescale 1ns/1ps

module rv128i_alu (
    input  logic [127:0] a,
    input  logic [127:0] b,
    input  logic [3:0]   op,
    output logic [127:0] y,
    output logic         zero
);

    localparam ALU_ADD = 4'd0;
    localparam ALU_SUB = 4'd1;
    localparam ALU_AND = 4'd2;
    localparam ALU_OR  = 4'd3;
    localparam ALU_XOR = 4'd4;
    localparam ALU_SLL = 4'd5;
    localparam ALU_SRL = 4'd6;

    always_comb begin
        case (op)
            ALU_ADD: y = a + b;
            ALU_SUB: y = a - b;
            ALU_AND: y = a & b;
            ALU_OR : y = a | b;
            ALU_XOR: y = a ^ b;
            ALU_SLL: y = a << b[6:0];
            ALU_SRL: y = a >> b[6:0];
            default: y = '0;
        endcase

        zero = (y == 128'b0);
    end

endmodule
