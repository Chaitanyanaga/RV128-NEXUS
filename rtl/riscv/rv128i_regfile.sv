`timescale 1ns/1ps

module rv128i_regfile (
    input  logic         clk,
    input  logic         rst,

    input  logic [4:0]   rs1_addr,
    input  logic [4:0]   rs2_addr,
    output logic [127:0] rs1_data,
    output logic [127:0] rs2_data,

    input  logic         wr_en,
    input  logic [4:0]   rd_addr,
    input  logic [127:0] rd_data
);

    logic [127:0] regs [0:31];

    assign rs1_data = (rs1_addr == 5'd0) ? 128'd0 : regs[rs1_addr];
    assign rs2_data = (rs2_addr == 5'd0) ? 128'd0 : regs[rs2_addr];

    integer i;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1)
                regs[i] <= 128'd0;
        end
        else begin
            regs[0] <= 128'd0;

            if (wr_en && (rd_addr != 5'd0))
                regs[rd_addr] <= rd_data;
        end
    end

endmodule
