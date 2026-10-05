`timescale 1ns/1ps

module rv128i_core (
    input  logic         clk,
    input  logic         rst,

    input  logic [3:0]   alu_op,
    input  logic [4:0]   rs1_addr,
    input  logic [4:0]   rs2_addr,
    input  logic [4:0]   rd_addr,

    input  logic         reg_write,

    output logic [127:0] rs1_value,
    output logic [127:0] rs2_value,
    output logic [127:0] alu_result,
    output logic         zero
);

    logic [127:0] rd_value;

    rv128i_regfile u_regfile (
        .clk      (clk),
        .rst      (rst),
        .rs1_addr (rs1_addr),
        .rs2_addr (rs2_addr),
        .rs1_data (rs1_value),
        .rs2_data (rs2_value),
        .wr_en    (reg_write),
        .rd_addr  (rd_addr),
        .rd_data  (rd_value)
    );

    rv128i_alu u_alu (
        .a    (rs1_value),
        .b    (rs2_value),
        .op   (alu_op),
        .y    (alu_result),
        .zero (zero)
    );

    assign rd_value = alu_result;

endmodule
