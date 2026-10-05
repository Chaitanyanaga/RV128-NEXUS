`timescale 1ns/1ps

module tb_rv128i_fetch;

    logic clk = 0;
    logic rst = 1;
    logic enable;
    logic branch_taken;
    logic [127:0] branch_target;

    logic [31:0] instr_mem_rdata;
    logic [127:0] pc;
    logic [127:0] instr_mem_addr;
    logic [31:0] instruction;

    rv128i_fetch dut (
        .clk,
        .rst,
        .enable,
        .branch_taken,
        .branch_target,
        .instr_mem_rdata,
        .pc,
        .instr_mem_addr,
        .instruction
    );

    always #5 clk = ~clk;

    initial begin
        enable        = 0;
        branch_taken  = 0;
        branch_target = 0;
        instr_mem_rdata = 32'h002081B3; // ADD x3,x1,x2

        repeat (2) @(posedge clk);
        #1;
        rst = 0;
        enable = 1;

        @(posedge clk);
        #1;

        if (pc !== 128'd4)
            $fatal(1, "FETCH PC FAIL: %h", pc);

        if (instr_mem_addr !== pc)
            $fatal(1, "FETCH ADDRESS FAIL: %h", instr_mem_addr);

        if (instruction !== 32'h002081B3)
            $fatal(1, "INSTRUCTION FAIL: %h", instruction);

        $display("PC PASS        : %h", pc);
        $display("ADDRESS PASS   : %h", instr_mem_addr);
        $display("INSTRUCTION PASS: %h", instruction);

        $display("========================================");
        $display("      RV128I FETCH TEST PASS");
        $display("========================================");

        $finish;
    end

endmodule
