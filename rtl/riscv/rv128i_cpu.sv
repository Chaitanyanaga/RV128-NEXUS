`timescale 1ns/1ps

module rv128i_cpu (
    input  logic         clk,
    input  logic         rst,

    // Instruction memory
    output logic [127:0] imem_addr,
    input  logic [31:0]  imem_rdata,

    // 128-bit data / NoC interface
    output logic         dmem_valid,
    input  logic         dmem_ready,
    output logic         dmem_we,
    output logic [127:0] dmem_addr,
    output logic [127:0] dmem_wdata,
    input  logic [127:0] dmem_rdata,

    output logic         halted
);

    // ------------------------------------------------------------
    // PC / Fetch
    // ------------------------------------------------------------
    logic [127:0] pc;
    logic         branch_taken;
    logic [127:0] branch_target;

    rv128i_pc u_pc (
        .clk           (clk),
        .rst           (rst),
        .enable        (!halted),
        .branch_taken  (branch_taken),
        .branch_target (branch_target),
        .pc            (pc)
    );

    assign imem_addr = pc;

    // ------------------------------------------------------------
    // Instruction fields
    // ------------------------------------------------------------
    logic [31:0] instr;

    logic [6:0] opcode;
    logic [4:0] rd;
    logic [4:0] rs1;
    logic [4:0] rs2;
    logic [2:0] funct3;
    logic [6:0] funct7;

    logic [3:0] alu_op;
    logic       reg_write;
    logic       mem_read;
    logic       mem_write;
    logic       branch;
    logic       jump;

    assign instr = imem_rdata;

    rv128i_decoder u_decoder (
        .instr      (instr),
        .opcode     (opcode),
        .rd         (rd),
        .rs1        (rs1),
        .rs2        (rs2),
        .funct3     (funct3),
        .funct7     (funct7),
        .alu_op     (alu_op),
        .reg_write  (reg_write),
        .mem_read   (mem_read),
        .mem_write  (mem_write),
        .branch     (branch),
        .jump       (jump)
    );

    // ------------------------------------------------------------
    // Register file
    // ------------------------------------------------------------
    logic [127:0] rs1_data;
    logic [127:0] rs2_data;

    logic [127:0] writeback_data;

    rv128i_regfile u_regfile (
        .clk        (clk),
        .rst        (rst),
        .rs1_addr   (rs1),
        .rs2_addr   (rs2),
        .rs1_data   (rs1_data),
        .rs2_data   (rs2_data),
        .wr_en      (reg_write && !mem_read && !halted),
        .rd_addr    (rd),
        .rd_data    (writeback_data)
    );

    // ------------------------------------------------------------
    // Immediate generation
    // ------------------------------------------------------------
    logic [127:0] imm_i;
    logic [127:0] imm_s;
    logic [127:0] imm_b;
    logic [127:0] imm_u;
    logic [127:0] imm_j;

    always_comb begin
        imm_i = {{116{instr[31]}}, instr[31:20]};

        imm_s = {{116{instr[31]}},
                 instr[31:25],
                 instr[11:7]};

        imm_b = {{115{instr[31]}},
                 instr[31],
                 instr[7],
                 instr[30:25],
                 instr[11:8],
                 1'b0};

        imm_u = {{96{instr[31]}}, instr[31:12], 12'b0};

        imm_j = {{108{instr[31]}},
                 instr[31],
                 instr[19:12],
                 instr[20],
                 instr[30:21],
                 1'b0};
    end

    // ------------------------------------------------------------
    // ALU
    // ------------------------------------------------------------
    logic [127:0] alu_a;
    logic [127:0] alu_b;
    logic [127:0] alu_result;
    logic         alu_zero;

    always_comb begin
        alu_a = rs1_data;
        alu_b = rs2_data;

        if (mem_read)
            alu_b = imm_i;
        else if (mem_write)
            alu_b = imm_s;
        else if (opcode == 7'b0010011)
            alu_b = imm_i;

        if (opcode == 7'b0110111)
            alu_a = 128'd0;

        if (opcode == 7'b0010111)
            alu_a = pc;
    end

    rv128i_alu u_alu (
        .a    (alu_a),
        .b    (alu_b),
        .op   (alu_op),
        .y    (alu_result),
        .zero (alu_zero)
    );

    // ------------------------------------------------------------
    // Data / NoC interface
    // ------------------------------------------------------------
    always_comb begin
        dmem_valid = 1'b0;
        dmem_we    = 1'b0;
        dmem_addr  = 128'd0;
        dmem_wdata = 128'd0;

        if (!halted && (mem_read || mem_write)) begin
            dmem_valid = 1'b1;
            dmem_we    = mem_write;
            dmem_addr  = alu_result;
            dmem_wdata = rs2_data;
        end
    end

    // ------------------------------------------------------------
    // Writeback
    // ------------------------------------------------------------
    always_comb begin
        writeback_data = alu_result;

        if (mem_read)
            writeback_data = dmem_rdata;

        if (opcode == 7'b1101111 || opcode == 7'b1100111)
            writeback_data = pc + 128'd4;

        if (opcode == 7'b0110111)
            writeback_data = imm_u;

        if (opcode == 7'b0010111)
            writeback_data = pc + imm_u;
    end

    // ------------------------------------------------------------
    // Branch / jump control
    // ------------------------------------------------------------
    always_comb begin
        branch_taken = 1'b0;
        branch_target = pc + 128'd4;

        if (branch) begin
            case (funct3)
                3'b000: branch_taken = (rs1_data == rs2_data); // BEQ
                3'b001: branch_taken = (rs1_data != rs2_data); // BNE
                default: branch_taken = 1'b0;
            endcase

            branch_target = pc + imm_b;
        end

        if (jump) begin
            branch_taken = 1'b1;

            if (opcode == 7'b1101111)
                branch_target = pc + imm_j;
            else
                branch_target = (rs1_data + imm_i) & ~128'd1;
        end
    end

    // ------------------------------------------------------------
    // Halt
    // ------------------------------------------------------------
    logic halt_reg;

    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            halt_reg <= 1'b0;
        else if (instr == 32'h00100073)
            halt_reg <= 1'b1;
    end

    assign halted = halt_reg;

endmodule
