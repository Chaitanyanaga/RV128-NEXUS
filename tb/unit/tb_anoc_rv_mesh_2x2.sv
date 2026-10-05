`timescale 1ns/1ps

module tb_anoc_rv_mesh_2x2;

    localparam int DATA_WIDTH  = 128;
    localparam int COORD_WIDTH = 4;

    logic clk;
    logic rst_n;

    logic [DATA_WIDTH-1:0] r0_data_in;
    logic [COORD_WIDTH-1:0] r0_dest_x, r0_dest_y;
    logic r0_valid_in, r0_ready_in;

    logic [DATA_WIDTH-1:0] r1_data_in;
    logic [COORD_WIDTH-1:0] r1_dest_x, r1_dest_y;
    logic r1_valid_in, r1_ready_in;

    logic [DATA_WIDTH-1:0] r2_data_in;
    logic [COORD_WIDTH-1:0] r2_dest_x, r2_dest_y;
    logic r2_valid_in, r2_ready_in;

    logic [DATA_WIDTH-1:0] r3_data_in;
    logic [COORD_WIDTH-1:0] r3_dest_x, r3_dest_y;
    logic r3_valid_in, r3_ready_in;

    logic [DATA_WIDTH-1:0] r0_data_out;
    logic r0_valid_out;

    logic [DATA_WIDTH-1:0] r1_data_out;
    logic r1_valid_out;

    logic [DATA_WIDTH-1:0] r2_data_out;
    logic r2_valid_out;

    logic [DATA_WIDTH-1:0] r3_data_out;
    logic r3_valid_out;

    integer errors;
    integer tests;
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
            r0_data_in = '0;
            r0_dest_x = 0;
            r0_dest_y = 0;
            r0_valid_in = 0;

            r1_data_in = '0;
            r1_dest_x = 0;
            r1_dest_y = 0;
            r1_valid_in = 0;

            r2_data_in = '0;
            r2_dest_x = 0;
            r2_dest_y = 0;
            r2_valid_in = 0;

            r3_data_in = '0;
            r3_dest_x = 0;
            r3_dest_y = 0;
            r3_valid_in = 0;
        end
    endtask

    task send_r0_to_r1;
        begin
            expected_data = 128'h11112222333344445555666677778888;

            r0_data_in = expected_data;
            r0_dest_x = 1;
            r0_dest_y = 0;
            r0_valid_in = 1;

            while (!r0_ready_in)
                @(posedge clk);

            @(posedge clk);
            #1;
            r0_valid_in = 0;

            timeout = 0;

            while (!r1_valid_out && timeout < 20) begin
                @(posedge clk);
                #1;
                timeout = timeout + 1;
            end

            tests = tests + 1;

            if (r1_valid_out && r1_data_out === expected_data) begin
                $display("PASS : R0 -> R1 one-hop EAST");
            end
            else begin
                $display("FAIL : R0 -> R1 one-hop EAST");
                errors = errors + 1;
            end

            @(posedge clk);
        end
    endtask

    task send_r0_to_r2;
        begin
            expected_data = 128'hAAAABBBBCCCCDDDDEEEEFFFF00001111;

            r0_data_in = expected_data;
            r0_dest_x = 0;
            r0_dest_y = 1;
            r0_valid_in = 1;

            while (!r0_ready_in)
                @(posedge clk);

            @(posedge clk);
            #1;
            r0_valid_in = 0;

            timeout = 0;

            while (!r2_valid_out && timeout < 20) begin
                @(posedge clk);
                #1;
                timeout = timeout + 1;
            end

            tests = tests + 1;

            if (r2_valid_out && r2_data_out === expected_data) begin
                $display("PASS : R0 -> R2 one-hop SOUTH");
            end
            else begin
                $display("FAIL : R0 -> R2 one-hop SOUTH");
                errors = errors + 1;
            end

            @(posedge clk);
        end
    endtask

    task send_r0_to_r3;
        begin
            expected_data = 128'h123456789ABCDEF0FEDCBA9876543210;

            r0_data_in = expected_data;
            r0_dest_x = 1;
            r0_dest_y = 1;
            r0_valid_in = 1;

            while (!r0_ready_in)
                @(posedge clk);

            @(posedge clk);
            #1;
            r0_valid_in = 0;

            timeout = 0;

            while (!r3_valid_out && timeout < 30) begin
                @(posedge clk);
                #1;
                timeout = timeout + 1;
            end

            tests = tests + 1;

            if (r3_valid_out && r3_data_out === expected_data) begin
                $display("PASS : R0 -> R3 two-hop EAST + SOUTH");
            end
            else begin
                $display("FAIL : R0 -> R3 two-hop EAST + SOUTH");
                errors = errors + 1;
            end

            @(posedge clk);
        end
    endtask

    task send_r3_to_r0;
        begin
            expected_data = 128'hCAFEBABE0123456789ABCDEF13572468;

            r3_data_in = expected_data;
            r3_dest_x = 0;
            r3_dest_y = 0;
            r3_valid_in = 1;

            while (!r3_ready_in)
                @(posedge clk);

            @(posedge clk);
            #1;
            r3_valid_in = 0;

            timeout = 0;

            while (!r0_valid_out && timeout < 30) begin
                @(posedge clk);
                #1;
                timeout = timeout + 1;
            end

            tests = tests + 1;

            if (r0_valid_out && r0_data_out === expected_data) begin
                $display("PASS : R3 -> R0 two-hop WEST + NORTH");
            end
            else begin
                $display("FAIL : R3 -> R0 two-hop WEST + NORTH");
                errors = errors + 1;
            end

            @(posedge clk);
        end
    endtask

    task send_r1_to_r2;
        begin
            expected_data = 128'hDEADBEEF00112233445566778899AABB;

            r1_data_in = expected_data;
            r1_dest_x = 0;
            r1_dest_y = 1;
            r1_valid_in = 1;

            while (!r1_ready_in)
                @(posedge clk);

            @(posedge clk);
            #1;
            r1_valid_in = 0;

            timeout = 0;

            while (!r2_valid_out && timeout < 30) begin
                @(posedge clk);
                #1;
                timeout = timeout + 1;
            end

            tests = tests + 1;

            if (r2_valid_out && r2_data_out === expected_data) begin
                $display("PASS : R1 -> R2 two-hop WEST + SOUTH");
            end
            else begin
                $display("FAIL : R1 -> R2 two-hop WEST + SOUTH");
                errors = errors + 1;
            end

            @(posedge clk);
        end
    endtask

    initial begin

        clk = 0;
        rst_n = 0;

        errors = 0;
        tests = 0;
        timeout = 0;

        clear_inputs();

        repeat (3) @(posedge clk);
        rst_n = 1;

        @(posedge clk);
        #1;

        $display("");
        $display("==============================================");
        $display("ANOC-RV 2x2 MESH FUNCTIONAL TEST");
        $display("==============================================");

        send_r0_to_r1();
        clear_inputs();

        send_r0_to_r2();
        clear_inputs();

        send_r0_to_r3();
        clear_inputs();

        send_r3_to_r0();
        clear_inputs();

        send_r1_to_r2();
        clear_inputs();

        $display("");
        $display("==============================================");
        $display("2x2 MESH TEST SUMMARY");
        $display("==============================================");
        $display("Tests  : %0d", tests);
        $display("Errors : %0d", errors);

        if (errors == 0) begin
            $display("");
            $display("***************************************");
            $display("* 2x2 MESH TEST PASS                 *");
            $display("***************************************");
        end
        else begin
            $display("");
            $display("***************************************");
            $display("* 2x2 MESH TEST FAIL                 *");
            $display("***************************************");
        end

        $finish;
    end

endmodule
