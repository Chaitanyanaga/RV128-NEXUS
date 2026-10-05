`timescale 1ns/1ps

module tb_rv128i_decoder;

    logic [31:0] instr;

    logic [6:0] opcode;
    logic [4:0] rd, rs1, rs2;
    logic [2:0] funct3;
    logic [6:0] funct7;

    logic [3:0] alu_op;
    logic reg_write;
    logic mem_read;
    logic mem_write;
    logic branch;
    logic jump;

    rv128i_decoder dut (
        .instr,
        .opcode,
        .rd,
        .rs1,
        .rs2,
        .funct3,
        .funct7,
        .alu_op,
        .reg_write,
        .mem_read,
        .mem_write,
        .branch,
        .jump
    );

    initial begin

        // ADD x3, x1, x2
        instr = 32'h002081B3;
        #1;

        if (opcode == 7'b0110011 &&
            rd == 5'd3 &&
            rs1 == 5'd1 &&
            rs2 == 5'd2 &&
            reg_write &&
            alu_op == 4'd0)
            $display("ADD DECODE PASS");
        else
            $fatal(1, "ADD DECODE FAIL");

        // SUB x4, x3, x2
        instr = 32'h40218233;
        #1;

        if (reg_write && alu_op == 4'd1)
            $display("SUB DECODE PASS");
        else
            $fatal(1, "SUB DECODE FAIL");

        // LW x5, 0(x1)
        instr = 32'h0000A283;
        #1;

        if (mem_read && reg_write && alu_op == 4'd0)
            $display("LOAD DECODE PASS");
        else
            $fatal(1, "LOAD DECODE FAIL");

        // SW x4, 0(x1)
        instr = 32'h0040A023;
        #1;

        if (mem_write && !reg_write && alu_op == 4'd0)
            $display("STORE DECODE PASS");
        else
            $fatal(1, "STORE DECODE FAIL");

        // BEQ
        instr = 32'h00208063;
        #1;

        if (branch)
            $display("BRANCH DECODE PASS");
        else
            $fatal(1, "BRANCH DECODE FAIL");

        // JAL
        instr = 32'h0000006F;
        #1;

        if (jump && reg_write)
            $display("JAL DECODE PASS");
        else
            $fatal(1, "JAL DECODE FAIL");

        $display("========================================");
        $display("      RV128I DECODER TEST PASS");
        $display("========================================");

        $finish;
    end

endmodule
