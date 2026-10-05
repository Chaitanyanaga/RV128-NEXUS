`timescale 1ns/1ps

module tb_anoc_rv_packet_roundtrip;

    localparam int FLIT_WIDTH    = 128;
    localparam int COORD_WIDTH   = 4;
    localparam int FLAGS_WIDTH   = 4;
    localparam int PAYLOAD_WIDTH = 106;

    logic [COORD_WIDTH-1:0] src_x, src_y;
    logic [COORD_WIDTH-1:0] dest_x, dest_y;
    logic [FLAGS_WIDTH-1:0] flags;
    logic [PAYLOAD_WIDTH-1:0] payload;
    logic [1:0] packet_type;

    logic [127:0] flit;

    logic [COORD_WIDTH-1:0] parsed_src_x, parsed_src_y;
    logic [COORD_WIDTH-1:0] parsed_dest_x, parsed_dest_y;
    logic [FLAGS_WIDTH-1:0] parsed_flags;
    logic [127:0] parsed_payload;
    logic [1:0] parsed_type;

    integer errors;

    anoc_rv_packet #(
        .COORD_WIDTH(COORD_WIDTH),
        .FLIT_WIDTH(FLIT_WIDTH),
        .FLAGS_WIDTH(FLAGS_WIDTH)
    ) packet_gen (
        .src_x(src_x),
        .src_y(src_y),
        .dest_x(dest_x),
        .dest_y(dest_y),
        .flags(flags),
        .payload({22'b0, payload}),
        .packet_type(packet_type),
        .flit(flit)
    );

    anoc_rv_packet_parser #(
        .COORD_WIDTH(COORD_WIDTH),
        .FLIT_WIDTH(FLIT_WIDTH),
        .FLAGS_WIDTH(FLAGS_WIDTH)
    ) parser (
        .flit(flit),
        .src_x(parsed_src_x),
        .src_y(parsed_src_y),
        .dest_x(parsed_dest_x),
        .dest_y(parsed_dest_y),
        .flags(parsed_flags),
        .payload(parsed_payload),
        .packet_type(parsed_type)
    );

    task automatic check_roundtrip;
        begin
            #1;

            if (parsed_src_x !== src_x) errors = errors + 1;
            if (parsed_src_y !== src_y) errors = errors + 1;
            if (parsed_dest_x !== dest_x) errors = errors + 1;
            if (parsed_dest_y !== dest_y) errors = errors + 1;
            if (parsed_flags !== flags) errors = errors + 1;
            if (parsed_payload[105:0] !== payload) errors = errors + 1;
            if (parsed_type !== packet_type) errors = errors + 1;

            if ((parsed_src_x === src_x) &&
                (parsed_src_y === src_y) &&
                (parsed_dest_x === dest_x) &&
                (parsed_dest_y === dest_y) &&
                (parsed_flags === flags) &&
                (parsed_payload[105:0] === payload) &&
                (parsed_type === packet_type)) begin

                $display("PASS : src=(%0d,%0d) dest=(%0d,%0d) flags=%b type=%b",
                    src_x, src_y,
                    dest_x, dest_y,
                    flags, packet_type);
            end
            else begin
                $display("FAIL : FLIT=%032h", flit);
            end
        end
    endtask

    initial begin
        errors = 0;

        $dumpfile("results/simulation/packet_roundtrip.vcd");
        $dumpvars(0, tb_anoc_rv_packet_roundtrip);

        $display("");
        $display("========================================");
        $display("128-BIT PACKET/PARSER ROUND-TRIP TEST");
        $display("========================================");

        // TEST 1
        src_x = 0;
        src_y = 0;
        dest_x = 1;
        dest_y = 2;
        flags = 4'b0001;
        payload = 106'h1;
        packet_type = 2'b01;

        $display("");
        $display("TEST 1");
        check_roundtrip;

        // TEST 2
        src_x = 2;
        src_y = 3;
        dest_x = 7;
        dest_y = 5;
        flags = 4'b1010;
        payload = 106'h555555555555555555555555555;
        packet_type = 2'b10;

        $display("");
        $display("TEST 2");
        check_roundtrip;

        // TEST 3
        src_x = 15;
        src_y = 14;
        dest_x = 13;
        dest_y = 12;
        flags = 4'b1111;
        payload = {106{1'b1}};
        packet_type = 2'b11;

        $display("");
        $display("TEST 3: MAXIMUM");
        check_roundtrip;

        // TEST 4
        src_x = 4;
        src_y = 4;
        dest_x = 4;
        dest_y = 4;
        flags = 4'b0000;
        payload = 106'h2AAAAAAAAAAAAAAAAAAAAAAAAAA;
        packet_type = 2'b00;

        $display("");
        $display("TEST 4: LOCAL");
        check_roundtrip;

        $display("");
        $display("========================================");
        $display("ROUND-TRIP TEST SUMMARY");
        $display("========================================");
        $display("FLIT width : %0d bits", FLIT_WIDTH);
        $display("Errors     : %0d", errors);

        if (errors == 0) begin
            $display("");
            $display("***************************************");
            $display("* PACKET/PARSER ROUND-TRIP PASS      *");
            $display("***************************************");
        end
        else begin
            $display("");
            $display("***************************************");
            $display("* PACKET/PARSER ROUND-TRIP FAIL      *");
            $display("***************************************");
        end

        $finish;
    end

endmodule
