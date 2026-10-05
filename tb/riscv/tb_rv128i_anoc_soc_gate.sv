`timescale 1ns/1ps

module tb_rv128i_anoc_soc_gate;

    logic clk;
    logic rst;
    wire  halted;

    rv128i_anoc_soc_top dut (
        .clk    (clk),
        .rst    (rst),
        .halted (halted)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 1'b0;
        rst = 1'b1;

        $display("========================================");
        $display("RV128I + ANoC GATE-LEVEL TEST");
        $display("========================================");

        #20;
        rst = 1'b0;

        /*
         * Allow the synthesized CPU/control logic
         * to execute its programmed instruction sequence.
         */
        #500;

        if (halted) begin
            $display("GATE-LEVEL HALT PASS");
            $display("RV128I + ANoC GATE-LEVEL TEST PASS");
        end
        else begin
            $display("GATE-LEVEL HALT FAIL");
            $display("RV128I + ANoC GATE-LEVEL TEST FAIL");
        end

        $finish;
    end

endmodule
