`timescale 1ns/1ps

module tb_rv128i_core;

    logic clk = 0;
    logic rst = 1;

    logic [3:0]   alu_op;
    logic [4:0]   rs1_addr;
    logic [4:0]   rs2_addr;
    logic [4:0]   rd_addr;
    logic         reg_write;

    logic [127:0] rs1_value;
    logic [127:0] rs2_value;
    logic [127:0] alu_result;
    logic         zero;

    localparam ALU_ADD = 4'd0;
    localparam ALU_SUB = 4'd1;
    localparam ALU_AND = 4'd2;
    localparam ALU_OR  = 4'd3;
    localparam ALU_XOR = 4'd4;

    rv128i_core dut (
        .clk,
        .rst,
        .alu_op,
        .rs1_addr,
        .rs2_addr,
        .rd_addr,
        .reg_write,
        .rs1_value,
        .rs2_value,
        .alu_result,
        .zero
    );

    always #5 clk = ~clk;

    task automatic write_reg(
        input logic [4:0] addr,
        input logic [127:0] data
    );
        begin
            // Use ADD with x0 to generate the desired test value.
            // This block will be replaced by instruction decode later.
            dut.u_regfile.regs[addr] = data;
        end
    endtask

    initial begin
        alu_op    = ALU_ADD;
        rs1_addr  = 0;
        rs2_addr  = 0;
        rd_addr   = 0;
        reg_write = 0;

        repeat (2) @(posedge clk);
        rst = 0;

        write_reg(5'd1, 128'h0000_0000_0000_0000_0000_0000_0000_000A);
        write_reg(5'd2, 128'h0000_0000_0000_0000_0000_0000_0000_0005);

        rs1_addr = 5'd1;
        rs2_addr = 5'd2;
        alu_op   = ALU_ADD;
        #1;

        if (alu_result !== 128'h0000_0000_0000_0000_0000_0000_0000_000F)
            $fatal(1, "ADD FAILED: %h", alu_result);

        $display("ADD PASS: %h", alu_result);

        alu_op = ALU_SUB;
        #1;

        if (alu_result !== 128'h0000_0000_0000_0000_0000_0000_0000_0005)
            $fatal(1, "SUB FAILED: %h", alu_result);

        $display("SUB PASS: %h", alu_result);

        alu_op = ALU_AND;
        #1;

        if (alu_result !== 128'h0000_0000_0000_0000_0000_0000_0000_0000)
            $fatal(1, "AND FAILED: %h", alu_result);

        $display("AND PASS: %h", alu_result);

        alu_op = ALU_OR;
        #1;

        if (alu_result !== 128'h0000_0000_0000_0000_0000_0000_0000_000F)
            $fatal(1, "OR FAILED: %h", alu_result);

        $display("OR PASS: %h", alu_result);

        alu_op = ALU_XOR;
        #1;

        if (alu_result !== 128'h0000_0000_0000_0000_0000_0000_0000_000F)
            $fatal(1, "XOR FAILED: %h", alu_result);

        $display("XOR PASS: %h", alu_result);

        $display("========================================");
        $display("      RV128I DATAPATH TEST PASS");
        $display("========================================");

        $finish;
    end

endmodule
