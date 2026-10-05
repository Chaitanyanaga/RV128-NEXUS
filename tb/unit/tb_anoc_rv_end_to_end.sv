`timescale 1ns/1ps

module tb_anoc_rv_end_to_end;

    localparam int DATA_WIDTH = 128;
    localparam int COORD_WIDTH = 4;
    localparam int NUM_PORTS = 5;
    localparam int FLAGS_WIDTH = 4;
    localparam int PAYLOAD_WIDTH = 106;

    logic clk;
    logic rst_n;

    logic [COORD_WIDTH-1:0] current_x;
    logic [COORD_WIDTH-1:0] current_y;

    logic [DATA_WIDTH-1:0] data_in [0:NUM_PORTS-1];
    logic [COORD_WIDTH-1:0] dest_x [0:NUM_PORTS-1];
    logic [COORD_WIDTH-1:0] dest_y [0:NUM_PORTS-1];
    logic valid_in [0:NUM_PORTS-1];
    logic ready_in [0:NUM_PORTS-1];

    logic ready_out [0:NUM_PORTS-1];
    logic [DATA_WIDTH-1:0] data_out [0:NUM_PORTS-1];
    logic valid_out [0:NUM_PORTS-1];

    logic [COORD_WIDTH-1:0] src_x;
    logic [COORD_WIDTH-1:0] src_y;
    logic [COORD_WIDTH-1:0] packet_dest_x;
    logic [COORD_WIDTH-1:0] packet_dest_y;
    logic [FLAGS_WIDTH-1:0] flags;
    logic [DATA_WIDTH-1:0] payload;
    logic [1:0] packet_type;

    logic [DATA_WIDTH-1:0] encoded_flit;

    logic [COORD_WIDTH-1:0] parsed_src_x;
    logic [COORD_WIDTH-1:0] parsed_src_y;
    logic [COORD_WIDTH-1:0] parsed_dest_x;
    logic [COORD_WIDTH-1:0] parsed_dest_y;
    logic [FLAGS_WIDTH-1:0] parsed_flags;
    logic [DATA_WIDTH-1:0] parsed_payload;
    logic [1:0] parsed_packet_type;

    integer i;
    integer errors;

    anoc_rv_packet #(
        .COORD_WIDTH(COORD_WIDTH),
        .FLIT_WIDTH(DATA_WIDTH),
        .FLAGS_WIDTH(FLAGS_WIDTH)
    ) packet_encoder (
        .src_x(src_x),
        .src_y(src_y),
        .dest_x(packet_dest_x),
        .dest_y(packet_dest_y),
        .flags(flags),
        .payload(payload),
        .packet_type(packet_type),
        .flit(encoded_flit)
    );

    anoc_rv_router_buffered #(
        .DATA_WIDTH(DATA_WIDTH),
        .COORD_WIDTH(COORD_WIDTH),
        .NUM_PORTS(NUM_PORTS)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .current_x(current_x),
        .current_y(current_y),
        .data_in(data_in),
        .dest_x(dest_x),
        .dest_y(dest_y),
        .valid_in(valid_in),
        .ready_in(ready_in),
        .ready_out(ready_out),
        .data_out(data_out),
        .valid_out(valid_out)
    );

    anoc_rv_packet_parser #(
        .COORD_WIDTH(COORD_WIDTH),
        .FLIT_WIDTH(DATA_WIDTH),
        .FLAGS_WIDTH(FLAGS_WIDTH)
    ) packet_parser (
        .flit(data_out[3]),
        .src_x(parsed_src_x),
        .src_y(parsed_src_y),
        .dest_x(parsed_dest_x),
        .dest_y(parsed_dest_y),
        .flags(parsed_flags),
        .payload(parsed_payload),
        .packet_type(parsed_packet_type)
    );

    always #5 clk = ~clk;

    task clear_inputs;
        begin
            for (i = 0; i < NUM_PORTS; i = i + 1) begin
                data_in[i] = '0;
                dest_x[i] = '0;
                dest_y[i] = '0;
                valid_in[i] = 1'b0;
                ready_out[i] = 1'b0;
            end
        end
    endtask

    initial begin
        clk = 1'b0;
        rst_n = 1'b0;
        errors = 0;

        current_x = 4;
        current_y = 4;

        src_x = 2;
        src_y = 3;
        packet_dest_x = 7;
        packet_dest_y = 4;
        flags = 4'b1010;
        payload = '0;
        payload[105:0] = 106'h123456789ABCDEF123456789AB;
        packet_type = 2'b01;

        clear_inputs();

        repeat (2) @(posedge clk);
        rst_n = 1'b1;

        $display("");
        $display("==============================================");
        $display("ANOC-RV END-TO-END INTEGRATION TEST");
        $display("==============================================");

        // Input port 0 sends packet EAST.
        @(negedge clk);
        data_in[0] = encoded_flit;
        dest_x[0] = packet_dest_x;
        dest_y[0] = packet_dest_y;
        valid_in[0] = 1'b1;

        #1;

        if (!ready_in[0]) begin
            errors = errors + 1;
            $display("FAIL : input buffer was not ready");
        end
        else begin
            $display("PASS : input buffer ready to accept packet");
        end

        @(posedge clk);
        #1;

        $display("PASS : packet accepted into buffered router");

        @(negedge clk);
        valid_in[0] = 1'b0;
        ready_out[3] = 1'b1;

        #1;

        if (valid_out[3] !== 1'b1) begin
            errors = errors + 1;
            $display("FAIL : packet did not reach EAST output");
        end
        else begin
            $display("PASS : packet routed EAST");
        end

        if (data_out[3] !== encoded_flit) begin
            errors = errors + 1;
            $display("FAIL : FLIT corrupted during routing");
            $display("Expected : %032h", encoded_flit);
            $display("Actual   : %032h", data_out[3]);
        end
        else begin
            $display("PASS : 128-bit FLIT preserved");
        end

        // Verify parser output.
        if (parsed_src_x !== src_x ||
            parsed_src_y !== src_y ||
            parsed_dest_x !== packet_dest_x ||
            parsed_dest_y !== packet_dest_y ||
            parsed_flags !== flags ||
            parsed_packet_type !== packet_type ||
            parsed_payload[105:0] !== payload[105:0]) begin

            errors = errors + 1;
            $display("FAIL : parser decoded incorrect packet fields");
        end
        else begin
            $display("PASS : parser recovered all packet fields");
        end

        @(posedge clk);
        #1;

        if (valid_out[3] !== 1'b0) begin
            errors = errors + 1;
            $display("FAIL : packet was not consumed");
        end
        else begin
            $display("PASS : packet consumed successfully");
        end

        $display("");
        $display("==============================================");
        $display("END-TO-END TEST SUMMARY");
        $display("==============================================");
        $display("FLIT width      : %0d bits", DATA_WIDTH);
        $display("Payload width   : %0d bits", PAYLOAD_WIDTH);
        $display("Errors          : %0d", errors);

        if (errors == 0) begin
            $display("");
            $display("***************************************");
            $display("* ANOC-RV END-TO-END TEST PASS       *");
            $display("***************************************");
        end
        else begin
            $display("");
            $display("***************************************");
            $display("* ANOC-RV END-TO-END TEST FAIL       *");
            $display("***************************************");
        end

        $finish;
    end

endmodule
