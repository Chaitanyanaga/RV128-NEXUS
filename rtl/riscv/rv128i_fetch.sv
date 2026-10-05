`timescale 1ns/1ps

module rv128i_fetch (
    input  logic         clk,
    input  logic         rst,
    input  logic         enable,
    input  logic         branch_taken,
    input  logic [127:0] branch_target,

    input  logic [31:0]  instr_mem_rdata,

    output logic [127:0] pc,
    output logic [127:0] instr_mem_addr,
    output logic [31:0]  instruction
);

    rv128i_pc u_pc (
        .clk           (clk),
        .rst           (rst),
        .enable        (enable),
        .branch_taken  (branch_taken),
        .branch_target (branch_target),
        .pc            (pc)
    );

    assign instr_mem_addr = pc;
    assign instruction    = instr_mem_rdata;

endmodule
