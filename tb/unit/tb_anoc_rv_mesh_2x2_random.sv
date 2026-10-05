`timescale 1ns/1ps

module tb_anoc_rv_mesh_2x2_random;

    localparam int DATA_WIDTH  = 128;
    localparam int COORD_WIDTH = 4;
    localparam int NUM_TESTS   = 100;

    logic clk;
    logic rst_n;

    logic [DATA_WIDTH-1:0] r0_data_in, r1_data_in, r2_data_in, r3_data_in;
    logic [COORD_WIDTH-1:0] r0_dest_x, r0_dest_y;
    logic [COORD_WIDTH-1:0] r1_dest_x, r1_dest_y;
    logic [COORD_WIDTH-1:0] r2_dest_x, r2_dest_y;
    logic [COORD_WIDTH-1:0] r3_dest_x, r3_dest_y;

    logic r0_valid_in, r1_valid_in, r2_valid_in, r3_valid_in;
    logic r0_ready_in, r1_ready_in, r2_ready_in, r3_ready_in;

    logic [DATA_WIDTH-1:0] r0_data_out, r1_data_out;
    logic [DATA_WIDTH-1:0] r2_data_out, r3_data_out;

    logic r0_valid_out, r1_valid_out;
    logic r2_valid_out, r3_valid_out;

    integer test_num;
    integer src;
    integer dst;
    integer src_x;
    integer src_y;
    integer dst_x;
    integer dst_y;
    integer errors;
    integer timeout;

    reg [DATA_WIDTH-1:0] expected_data;

    anoc_rv_mesh_2x2 #(
        .DATA_WIDTH(DATA_WIDTH),
        .COORD_WIDTH(COORD_WIDTH),
        .NUM_PORTS(5)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),

        .r0_data_in(r0_data_in),
        .r0_dest_x(r0_dest_x),
        .r0_dest_y(r0_dest_y),
        .r0_valid_in(r0_valid_in),
        .r0_ready_in(r0_ready_in),

        .r1_data_in(r1_data_in),
        .r1_dest_x(r1_dest_x),
        .r1_dest_y(r1_dest_y),
        .r1_valid_in(r1_valid_in),
        .r1_ready_in(r1_ready_in),

        .r2_data_in(r2_data_in),
        .r2_dest_x(r2_dest_x),
        .r2_dest_y(r2_dest_y),
        .r2_valid_in(r2_valid_in),
        .r2_ready_in(r2_ready_in),

        .r3_data_in(r3_data_in),
        .r3_dest_x(r3_dest_x),
        .r3_dest_y(r3_dest_y),
        .r3_valid_in(r3_valid_in),
        .r3_ready_in(r3_ready_in),

        .r0_data_out(r0_data_out),
        .r0_valid_out(r0_valid_out),

        .r1_data_out(r1_data_out),
        .r1_valid_out(r1_valid_out),

        .r2_data_out(r2_data_out),
        .r2_valid_out(r2_valid_out),

        .r3_data_out(r3_data_out),
        .r3_valid_out(r3_valid_out)
    );

    always #5 clk = ~clk;

    task clear_inputs;
        begin
            r0_valid_in = 0;
            r1_valid_in = 0;
            r2_valid_in = 0;
            r3_valid_in = 0;

            r0_data_in = '0;
            r1_data_in = '0;
            r2_data_in = '0;
            r3_data_in = '0;

            r0_dest_x = 0;
            r0_dest_y = 0;
            r1_dest_x = 0;
            r1_dest_y = 0;
            r2_dest_x = 0;
            r2_dest_y = 0;
            r3_dest_x = 0;
            r3_dest_y = 0;
        end
    endtask

    task check_destination;
        begin
            timeout = 0;

            case (dst)

                0: begin
                    while (!r0_valid_out && timeout < 30) begin
                        @(posedge clk);
                        #1;
                        timeout = timeout + 1;
                    end

                    if (!r0_valid_out || r0_data_out !== expected_data) begin
                        errors = errors + 1;
                        $display("FAIL TEST %0d : R%0d -> R%0d",
                                 test_num, src, dst);
                    end
                end

                1: begin
                    while (!r1_valid_out && timeout < 30) begin
                        @(posedge clk);
                        #1;
                        timeout = timeout + 1;
                    end

                    if (!r1_valid_out || r1_data_out !== expected_data) begin
                        errors = errors + 1;
                        $display("FAIL TEST %0d : R%0d -> R%0d",
                                 test_num, src, dst);
                    end
                end

                2: begin
                    while (!r2_valid_out && timeout < 30) begin
                        @(posedge clk);
                        #1;
                        timeout = timeout + 1;
                    end

                    if (!r2_valid_out || r2_data_out !== expected_data) begin
                        errors = errors + 1;
                        $display("FAIL TEST %0d : R%0d -> R%0d",
                                 test_num, src, dst);
                    end
                end

                3: begin
                    while (!r3_valid_out && timeout < 30) begin
                        @(posedge clk);
                        #1;
                        timeout = timeout + 1;
                    end

                    if (!r3_valid_out || r3_data_out !== expected_data) begin
                        errors = errors + 1;
                        $display("FAIL TEST %0d : R%0d -> R%0d",
                                 test_num, src, dst);
                    end
                end

            endcase
        end
    endtask

    initial begin

        clk = 0;
        rst_n = 0;
        errors = 0;

        clear_inputs();

        repeat (3) @(posedge clk);
        rst_n = 1;

        @(posedge clk);
        #1;

        $display("");
        $display("==============================================");
        $display("ANOC-RV RANDOM 2x2 MESH TEST");
        $display("==============================================");
        $display("Tests : %0d", NUM_TESTS);
        $display("FLIT  : %0d bits", DATA_WIDTH);

        for (test_num = 1; test_num <= NUM_TESTS; test_num = test_num + 1) begin

            // Random source and destination.
            src = $urandom % 4;
            dst = $urandom % 4;

            // Avoid same-router traffic.
            while (dst == src)
                dst = $urandom % 4;

            // Router coordinates.
            case (src)
                0: begin src_x = 0; src_y = 0; end
                1: begin src_x = 1; src_y = 0; end
                2: begin src_x = 0; src_y = 1; end
                3: begin src_x = 1; src_y = 1; end
            endcase

            case (dst)
                0: begin dst_x = 0; dst_y = 0; end
                1: begin dst_x = 1; dst_y = 0; end
                2: begin dst_x = 0; dst_y = 1; end
                3: begin dst_x = 1; dst_y = 1; end
            endcase

            expected_data = {
                $urandom,
                $urandom,
                $urandom,
                $urandom
            };

            case (src)

                0: begin
                    r0_data_in = expected_data;
                    r0_dest_x = dst_x;
                    r0_dest_y = dst_y;
                    r0_valid_in = 1;
                    while (!r0_ready_in)
                        @(posedge clk);
                    @(posedge clk);
                    #1;
                    r0_valid_in = 0;
                end

                1: begin
                    r1_data_in = expected_data;
                    r1_dest_x = dst_x;
                    r1_dest_y = dst_y;
                    r1_valid_in = 1;
                    while (!r1_ready_in)
                        @(posedge clk);
                    @(posedge clk);
                    #1;
                    r1_valid_in = 0;
                end

                2: begin
                    r2_data_in = expected_data;
                    r2_dest_x = dst_x;
                    r2_dest_y = dst_y;
                    r2_valid_in = 1;
                    while (!r2_ready_in)
                        @(posedge clk);
                    @(posedge clk);
                    #1;
                    r2_valid_in = 0;
                end

                3: begin
                    r3_data_in = expected_data;
                    r3_dest_x = dst_x;
                    r3_dest_y = dst_y;
                    r3_valid_in = 1;
                    while (!r3_ready_in)
                        @(posedge clk);
                    @(posedge clk);
                    #1;
                    r3_valid_in = 0;
                end

            endcase

            check_destination();

            if ((test_num <= 10) || (test_num % 25 == 0)) begin
                if (errors == 0)
                    $display("PASS TEST %0d : R%0d -> R%0d",
                             test_num, src, dst);
            end

            clear_inputs();

            @(posedge clk);
            #1;
        end

        $display("");
        $display("==============================================");
        $display("RANDOM 2x2 MESH TEST SUMMARY");
        $display("==============================================");
        $display("Tests  : %0d", NUM_TESTS);
        $display("Errors : %0d", errors);

        if (errors == 0) begin
            $display("");
            $display("***************************************");
            $display("* RANDOM 2x2 MESH TEST PASS          *");
            $display("***************************************");
        end
        else begin
            $display("");
            $display("***************************************");
            $display("* RANDOM 2x2 MESH TEST FAIL          *");
            $display("***************************************");
        end

        $finish;
    end

endmodule
