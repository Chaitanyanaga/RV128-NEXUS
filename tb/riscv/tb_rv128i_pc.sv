`timescale 1ns/1ps

module tb_rv128i_pc;

    logic clk = 0;
    logic rst = 1;
    logic enable;
    logic branch_taken;
    logic [127:0] branch_target;
    logic [127:0] pc;

    rv128i_pc dut (
        .clk           (clk),
        .rst           (rst),
        .enable        (enable),
        .branch_taken  (branch_taken),
        .branch_target (branch_target),
        .pc             (pc)
    );

    always #5 clk = ~clk;

    initial begin
        enable        = 1'b0;
        branch_taken  = 1'b0;
        branch_target = 128'd0;

        // Hold reset through a complete clock edge.
        repeat (2) @(posedge clk);
        #1;
        rst = 1'b0;

        // Enable only after reset has been released.
        #1;
        enable = 1'b1;

        @(posedge clk);
        #1;
        if (pc !== 128'd4)
            $fatal(1, "PC +4 FAIL: %h", pc);
        $display("PC +4 PASS: %h", pc);

        @(posedge clk);
        #1;
        if (pc !== 128'd8)
            $fatal(1, "PC +4 SECOND FAIL: %h", pc);
        $display("PC +4 SECOND PASS: %h", pc);

        branch_target = 128'h0000_0000_0000_0000_0000_0000_0000_0100;
        branch_taken  = 1'b1;

        @(posedge clk);
        #1;
        if (pc !== branch_target)
            $fatal(1, "BRANCH TARGET FAIL: %h", pc);
        $display("BRANCH TARGET PASS: %h", pc);

        branch_taken = 1'b0;

        $display("========================================");
        $display("        RV128I PC TEST PASS");
        $display("========================================");

        $finish;
    end

endmodule
