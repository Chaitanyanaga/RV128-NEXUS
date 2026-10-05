`timescale 1ns/1ps

module tb_anoc_rv_packet;

    localparam int FLIT_WIDTH    = 128;
    localparam int COORD_WIDTH   = 4;
    localparam int FLAGS_WIDTH   = 4;
    localparam int PAYLOAD_WIDTH = 106;

    logic [COORD_WIDTH-1:0] src_x, src_y;
    logic [COORD_WIDTH-1:0] dest_x, dest_y;
    logic [FLAGS_WIDTH-1:0] flags;
    logic [127:0] payload;
    logic [1:0] packet_type;

    logic [FLIT_WIDTH-1:0] flit;

    integer errors;

    anoc_rv_packet #(
        .COORD_WIDTH(COORD_WIDTH),
        .FLIT_WIDTH(FLIT_WIDTH),
        .FLAGS_WIDTH(FLAGS_WIDTH)
    ) dut (
        .src_x(src_x),
        .src_y(src_y),
        .dest_x(dest_x),
        .dest_y(dest_y),
        .flags(flags),
        .payload(payload),
        .packet_type(packet_type),
        .flit(flit)
    );

    task automatic check_flit;
        logic [127:0] expected;
        begin
            expected = {
                packet_type,
                flags,
                dest_y,
                dest_x,
                src_y,
                src_x,
                payload[PAYLOAD_WIDTH-1:0]
            };

            #1;

            if (flit !== expected) begin
                $display("ERROR: FLIT mismatch");
                $display("       expected=%032h", expected);
                $display("       got     =%032h", flit);
                errors = errors + 1;
            end
            else begin
                $display("PASS : FLIT=%032h", flit);
            end
        end
    endtask

    initial begin
        errors = 0;

        $dumpfile("results/simulation/packet.vcd");
        $dumpvars(0, tb_anoc_rv_packet);

        $display("");
        $display("========================================");
        $display("128-BIT FLIT PACKET TEST");
        $display("========================================");

        // TEST 1
        src_x = 4'd0;
        src_y = 4'd0;
        dest_x = 4'd1;
        dest_y = 4'd2;
        flags = 4'b0001;
        payload = 128'h00000000000000000000000000000001;
        packet_type = 2'b01;

        $display("");
        $display("TEST 1: HEAD FLIT");
        check_flit;

        // TEST 2
        src_x = 4'd2;
        src_y = 4'd3;
        dest_x = 4'd7;
        dest_y = 4'd5;
        flags = 4'b1010;
        payload = 128'h00000000000000000000000055555555;
        packet_type = 2'b10;

        $display("");
        $display("TEST 2: BODY FLIT");
        check_flit;

        // TEST 3
        src_x = 4'd15;
        src_y = 4'd14;
        dest_x = 4'd13;
        dest_y = 4'd12;
        flags = 4'b1111;
        payload = {22'b0, {106{1'b1}}};
        packet_type = 2'b11;

        $display("");
        $display("TEST 3: MAXIMUM VALUES");
        check_flit;

        // TEST 4
        src_x = 4'd4;
        src_y = 4'd4;
        dest_x = 4'd4;
        dest_y = 4'd4;
        flags = 4'b0000;
        payload = 128'h0000000000000000000000002AAAAAAA;
        packet_type = 2'b00;

        $display("");
        $display("TEST 4: LOCAL FLIT");
        check_flit;

        $display("");
        $display("========================================");
        $display("128-BIT FLIT TEST SUMMARY");
        $display("========================================");
        $display("FLIT width : %0d bits", FLIT_WIDTH);
        $display("Payload    : %0d bits", PAYLOAD_WIDTH);
        $display("Errors     : %0d", errors);

        if (errors == 0) begin
            $display("");
            $display("***************************************");
            $display("* 128-BIT FLIT PACKET TEST PASS      *");
            $display("***************************************");
        end
        else begin
            $display("");
            $display("***************************************");
            $display("* 128-BIT FLIT PACKET TEST FAIL      *");
            $display("***************************************");
        end

        $finish;
    end

endmodule
