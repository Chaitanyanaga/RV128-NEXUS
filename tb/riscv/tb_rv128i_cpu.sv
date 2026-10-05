`timescale 1ns/1ps

module tb_rv128i_cpu;

    logic clk = 0;
    logic rst = 1;

    logic [127:0] imem_addr;
    logic [31:0]  imem_rdata;

    logic         dmem_valid;
    logic         dmem_ready;
    logic         dmem_we;
    logic [127:0] dmem_addr;
    logic [127:0] dmem_wdata;
    logic [127:0] dmem_rdata;

    logic halted;

    logic [31:0] imem [0:31];
    logic [127:0] memory [0:31];

    rv128i_cpu dut (
        .clk,
        .rst,
        .imem_addr,
        .imem_rdata,
        .dmem_valid,
        .dmem_ready,
        .dmem_we,
        .dmem_addr,
        .dmem_wdata,
        .dmem_rdata,
        .halted
    );

    always #5 clk = ~clk;

    assign imem_rdata = imem[imem_addr[6:2]];
    assign dmem_rdata = memory[dmem_addr[6:2]];
    assign dmem_ready = dmem_valid;

    always_ff @(posedge clk) begin
        if (!rst && dmem_valid && dmem_we)
            memory[dmem_addr[6:2]] <= dmem_wdata;
    end

    initial begin
        integer i;

        for (i = 0; i < 32; i = i + 1) begin
            imem[i]   = 32'h00000013; // NOP
            memory[i] = 128'd0;
        end

        // ADDI x1, x0, 10
        imem[0] = 32'h00A00093;

        // ADDI x2, x0, 5
        imem[1] = 32'h00500113;

        // ADD x3, x1, x2
        imem[2] = 32'h002081B3;

        // EBREAK
        imem[3] = 32'h00100073;

        repeat (2) @(posedge clk);
        #1;
        rst = 0;

        wait (halted);
        #2;

        $display("========================================");
        $display("        RV128I CPU TEST");
        $display("========================================");

        $display("x1 = %0d", dut.u_regfile.regs[1]);
        $display("x2 = %0d", dut.u_regfile.regs[2]);
        $display("x3 = %0d", dut.u_regfile.regs[3]);

        if (dut.u_regfile.regs[1] == 128'd10 &&
            dut.u_regfile.regs[2] == 128'd5 &&
            dut.u_regfile.regs[3] == 128'd15) begin

            $display("***** RV128I CPU TEST PASS *****");

        end else begin

            $display("***** RV128I CPU TEST FAIL *****");
            $fatal(1);

        end

        $finish;
    end
        initial begin
        $dumpfile("results/riscv/rv128i_cpu_wave.vcd");
        $dumpvars(0, tb_rv128i_cpu);
    end
endmodule
