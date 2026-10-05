`timescale 1ns/1ps

module tb_anoc_rv_packet_parser;

    localparam int FLIT_WIDTH    = 128;
    localparam int COORD_WIDTH   = 4;
    localparam int FLAGS_WIDTH   = 4;
    localparam int PAYLOAD_WIDTH = 106;

    logic [FLIT_WIDTH-1:0] flit;

    logic [COORD_WIDTH-1:0] src_x, src_y;
    logic [COORD_WIDTH-1:0] dest_x, dest_y;
    logic [FLAGS_WIDTH-1:0] flags;
    logic [FLIT_WIDTH-1:0] payload;
    logic [1:0] packet_type;

    integer errors;

    anoc_rv_packet_parser #(
        .COORD_WIDTH(COORD_WIDTH),
        .FLIT_WIDTH(FLIT_WIDTH),
        .FLAGS_WIDTH(FLAGS_WIDTH)
    ) dut (
        .flit(flit),
        .src_x(src_x),
        .src_y(src_y),
        .dest_x(dest_x),
        .dest_y(dest_y),
        .flags(flags),
        .payload(payload),
        .packet_type(packet_type)
    );

    task automatic check_flit(
        input logic [COORD_WIDTH-1:0] expected_src_x,
        input logic [COORD_WIDTH-1:0] expected_src_y,
        input logic [COORD_WIDTH-1:0] expected_dest_x,
        input logic [COORD_WIDTH-1:0] expected_dest_y,
        input logic [FLAGS_WIDTH-1:0] expected_flags,
        input logic [PAYLOAD_WIDTH-1:0] expected_payload,
        input logic [1:0] expected_type
    );
        begin
            #1;

            if (src_x !== expected_src_x) begin
                $display("ERROR: src_x expected=%0d got=%0d",
                         expected_src_x, src_x);
                errors = errors + 1;
            end

            if (src_y !== expected_src_y) begin
                $display("ERROR: src_y expected=%0d got=%0d",
                         expected_src_y, src_y);
                errors = errors + 1;
            end

            if (dest_x !== expected_dest_x) begin
                $display("ERROR: dest_x expected=%0d got=%0d",
                         expected_dest_x, dest_x);
                errors = errors + 1;
            end

            if (dest_y !== expected_dest_y) begin
                $display("ERROR: dest_y expected=%0d got=%0d",
                         expected_dest_y, dest_y);
                errors = errors + 1;
            end

            if (flags !== expected_flags) begin
                $display("ERROR: flags expected=%b got=%b",
                         expected_flags, flags);
                errors = errors + 1;
            end

            if (payload[PAYLOAD_WIDTH-1:0] !== expected_payload) begin
                $display("ERROR: payload mismatch");
                $display("       expected=%h", expected_payload);
                $display("       got     =%h", payload[PAYLOAD_WIDTH-1:0]);
                errors = errors + 1;
            end

            if (packet_type !== expected_type) begin
                $display("ERROR: type expected=%b got=%b",
                         expected_type, packet_type);
                errors = errors + 1;
            end

            if ((src_x === expected_src_x) &&
                (src_y === expected_src_y) &&
                (dest_x === expected_dest_x) &&
                (dest_y === expected_dest_y) &&
                (flags === expected_flags) &&
                (payload[PAYLOAD_WIDTH-1:0] === expected_payload) &&
                (packet_type === expected_type)) begin

                $display("PASS : src=(%0d,%0d) dest=(%0d,%0d) flags=%b type=%b payload=%h",
                         src_x, src_y,
                         dest_x, dest_y,
                         flags, packet_type,
                         payload[PAYLOAD_WIDTH-1:0]);
            end
        end
    endtask

    initial begin
        errors = 0;

        $dumpfile("results/simulation/packet_parser.vcd");
        $dumpvars(0, tb_anoc_rv_packet_parser);

        $display("");
        $display("========================================");
        $display("128-BIT FLIT PARSER TEST");
        $display("========================================");

        // TEST 1
        flit = {
            2'b01,
            4'b0001,
            4'd2,
            4'd1,
            4'd0,
            4'd0,
            106'h1
        };

        $display("");
        $display("TEST 1: HEAD FLIT");
        check_flit(0, 0, 1, 2, 4'b0001, 106'h1, 2'b01);

        // TEST 2
        flit = {
            2'b10,
            4'b1010,
            4'd5,
            4'd7,
            4'd3,
            4'd2,
            106'h1555555555555555555555555555
        };

        $display("");
        $display("TEST 2: BODY FLIT");
        check_flit(2, 3, 7, 5, 4'b1010,
                   106'h1555555555555555555555555555, 2'b10);

        // TEST 3
        flit = {
            2'b11,
            4'b1111,
            4'd12,
            4'd13,
            4'd14,
            4'd15,
            {106{1'b1}}
        };

        $display("");
        $display("TEST 3: MAXIMUM VALUES");
        check_flit(15, 14, 13, 12, 4'b1111,
                   {106{1'b1}}, 2'b11);

        // TEST 4
        flit = {
            2'b00,
            4'b0000,
            4'd4,
            4'd4,
            4'd4,
            4'd4,
            106'h2AAAAAAAAAAAAAAAAAAAAAAAAAAA
        };

        $display("");
        $display("TEST 4: LOCAL FLIT");
        check_flit(4, 4, 4, 4, 4'b0000,
                   106'h2AAAAAAAAAAAAAAAAAAAAAAAAAAA, 2'b00);

        $display("");
        $display("========================================");
        $display("128-BIT FLIT PARSER TEST SUMMARY");
        $display("========================================");
        $display("FLIT width : %0d bits", FLIT_WIDTH);
        $display("Payload    : %0d bits", PAYLOAD_WIDTH);
        $display("Errors     : %0d", errors);

        if (errors == 0) begin
            $display("");
            $display("***************************************");
            $display("* 128-BIT FLIT PARSER TEST PASS      *");
            $display("***************************************");
        end
        else begin
            $display("");
            $display("***************************************");
            $display("* 128-BIT FLIT PARSER TEST FAIL      *");
            $display("***************************************");
        end

        $finish;
    end

endmodule
