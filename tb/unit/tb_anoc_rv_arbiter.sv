`timescale 1ns/1ps

module tb_anoc_rv_arbiter;

    localparam int NUM_INPUTS = 5;

    logic [NUM_INPUTS-1:0] req;
    logic [NUM_INPUTS-1:0] grant;

    integer errors;

    anoc_rv_arbiter #(
        .NUM_INPUTS(NUM_INPUTS)
    ) dut (
        .req(req),
        .grant(grant)
    );

    task automatic check_grant(
        input logic [NUM_INPUTS-1:0] test_req,
        input logic [NUM_INPUTS-1:0] expected_grant
    );
        begin
            req = test_req;
            #1;

            if (grant !== expected_grant) begin
                $display("ERROR: req=%b expected=%b got=%b",
                         test_req, expected_grant, grant);
                errors = errors + 1;
            end
            else begin
                $display("PASS : req=%b grant=%b",
                         test_req, grant);
            end
        end
    endtask

    initial begin
        errors = 0;

        $dumpfile("results/simulation/arbiter.vcd");
        $dumpvars(0, tb_anoc_rv_arbiter);

        $display("");
        $display("========================================");
        $display("ARBITER TEST");
        $display("========================================");

        // No requests
        check_grant(5'b00000, 5'b00000);

        // Individual requests
        check_grant(5'b00001, 5'b00001);
        check_grant(5'b00010, 5'b00010);
        check_grant(5'b00100, 5'b00100);
        check_grant(5'b01000, 5'b01000);
        check_grant(5'b10000, 5'b10000);

        // Multiple requests
        check_grant(5'b00011, 5'b00001);
        check_grant(5'b00111, 5'b00001);
        check_grant(5'b01110, 5'b00010);
        check_grant(5'b11100, 5'b00100);
        check_grant(5'b11000, 5'b01000);

        // All inputs requesting
        check_grant(5'b11111, 5'b00001);

        $display("");
        $display("========================================");
        $display("ARBITER TEST SUMMARY");
        $display("========================================");
        $display("Errors : %0d", errors);

        if (errors == 0) begin
            $display("");
            $display("***************************************");
            $display("* ARBITER TEST PASS                   *");
            $display("***************************************");
        end
        else begin
            $display("");
            $display("***************************************");
            $display("* ARBITER TEST FAIL                   *");
            $display("***************************************");
        end

        $finish;
    end

endmodule
