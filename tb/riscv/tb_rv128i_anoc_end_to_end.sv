`timescale 1ns/1ps

module tb_rv128i_anoc_end_to_end;

    logic clk = 0;
    logic rst = 1;

    logic         req_valid;
    logic         req_ready;
    logic         req_write;
    logic [127:0] req_addr;
    logic [127:0] req_wdata;

    logic [3:0] dest_x;
    logic [3:0] dest_y;

    logic         mem_write_complete;
    logic [127:0] mem_write_addr;
    logic [127:0] mem_write_data;

    rv128i_anoc_mesh_top dut (
        .clk,
        .rst,

        .req_valid,
        .req_ready,
        .req_write,
        .req_addr,
        .req_wdata,

        .dest_x,
        .dest_y,

        .mem_write_complete,
        .mem_write_addr,
        .mem_write_data
    );

    always #5 clk = ~clk;

    initial begin
        req_valid = 1'b0;
        req_write = 1'b1;

        req_addr =
            128'h0000_0000_0000_0000_0000_0000_0000_0100;

        req_wdata =
            128'hAAAA_BBBB_CCCC_DDDD_EEEE_FFFF_1234_5678;

        // Destination Router 15 = (3,3)
        dest_x = 4'd3;
        dest_y = 4'd3;

        repeat (3) @(posedge clk);
        #1;
        rst = 1'b0;

        // Submit write request
        req_valid = 1'b1;

        wait (req_ready);
        @(posedge clk);
        #1;

        req_valid = 1'b0;

        // Wait for complete route + memory reception.
        wait (mem_write_complete);
        #1;

        $display("========================================");
        $display("     RV128I -> ANoC -> MEMORY TEST");
        $display("========================================");

        $display("Destination : (%0d,%0d)", dest_x, dest_y);
        $display("Write Addr  : %032h", mem_write_addr);
        $display("Write Data  : %032h", mem_write_data);

        if (mem_write_addr !== req_addr)
            $fatal(1, "ADDRESS MISMATCH");

        if (mem_write_data !== req_wdata)
            $fatal(1, "DATA MISMATCH");

        $display("MESH ROUTING PASS");
        $display("MEMORY WRITE PASS");
        $display("========================================");
        $display("   RV128I ANOC END-TO-END TEST PASS");
        $display("========================================");

        $finish;
    end

    initial begin
        #5000;
        $fatal(1, "TIMEOUT: packet did not reach memory");
    end

    initial begin
    $dumpfile("results/riscv/rv128i_anoc_end_to_end_wave.vcd");
    $dumpvars(0, tb_rv128i_anoc_end_to_end);
 end

endmodule
