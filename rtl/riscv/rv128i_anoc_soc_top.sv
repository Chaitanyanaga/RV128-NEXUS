`timescale 1ns/1ps

module rv128i_anoc_soc_top (
    input  logic clk,
    input logic rst,
    output logic halted
);

    logic [127:0] imem_addr;
    logic [31:0]  imem_rdata;

    logic         dmem_valid;
    logic         dmem_ready;
    logic         dmem_we;
    logic [127:0] dmem_addr;
    logic [127:0] dmem_wdata;
    logic [127:0] dmem_rdata;

    logic         noc_req_ready;
    logic [127:0] noc_resp_data;
    logic         noc_resp_valid;

    // Fixed instruction ROM for synthesis integration.
    always_comb begin
        case (imem_addr[7:2])
            6'd0: imem_rdata = 32'h00A00093; // ADDI x1,x0,10
            6'd1: imem_rdata = 32'h00500113; // ADDI x2,x0,5
            6'd2: imem_rdata = 32'h002081B3; // ADD x3,x1,x2
            6'd3: imem_rdata = 32'h00100073; // EBREAK
            default: imem_rdata = 32'h00000013;
        endcase
    end

    rv128i_cpu u_cpu (
        .clk        (clk),
        .rst        (rst),

        .imem_addr  (imem_addr),
        .imem_rdata (imem_rdata),

        .dmem_valid (dmem_valid),
        .dmem_ready (dmem_ready),
        .dmem_we    (dmem_we),
        .dmem_addr  (dmem_addr),
        .dmem_wdata (dmem_wdata),
        .dmem_rdata (dmem_rdata),

        .halted     (halted)
    );

    rv128i_anoc_mesh_top u_anoc (
        .clk                (clk),
        .rst                (rst),

        .req_valid          (dmem_valid),
        .req_ready          (dmem_ready),
        .req_write          (dmem_we),
        .req_addr           (dmem_addr),
        .req_wdata          (dmem_wdata),

        .dest_x             (4'd3),
        .dest_y             (4'd3),

        .resp_rdata         (noc_resp_data),
        .resp_valid         (noc_resp_valid),

        .mem_write_complete (),
        .mem_write_addr     (),
        .mem_write_data     ()
    );

    assign dmem_rdata = noc_resp_data;

endmodule
