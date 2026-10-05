`timescale 1ns/1ps

module rv128i_decoder (
    input  logic [31:0] instr,

    output logic [6:0]  opcode,
    output logic [4:0]  rd,
    output logic [4:0]  rs1,
    output logic [4:0]  rs2,
    output logic [2:0]  funct3,
    output logic [6:0]  funct7,

    output logic [3:0]  alu_op,
    output logic        reg_write,
    output logic        mem_read,
    output logic        mem_write,
    output logic        branch,
    output logic        jump
);

    localparam ALU_ADD = 4'd0;
    localparam ALU_SUB = 4'd1;
    localparam ALU_AND = 4'd2;
    localparam ALU_OR  = 4'd3;
    localparam ALU_XOR = 4'd4;

    always_comb begin
        opcode    = instr[6:0];
        rd        = instr[11:7];
        funct3    = instr[14:12];
        rs1       = instr[19:15];
        rs2       = instr[24:20];
        funct7    = instr[31:25];

        alu_op    = ALU_ADD;
        reg_write = 1'b0;
        mem_read  = 1'b0;
        mem_write = 1'b0;
        branch    = 1'b0;
        jump      = 1'b0;

        case (opcode)

            // OP-IMM
            7'b0010011: begin
                reg_write = 1'b1;
                case (funct3)
                    3'b000: alu_op = ALU_ADD; // ADDI
                    3'b111: alu_op = ALU_AND; // ANDI
                    3'b110: alu_op = ALU_OR;  // ORI
                    3'b100: alu_op = ALU_XOR; // XORI
                    default: reg_write = 1'b0;
                endcase
            end

            // OP
            7'b0110011: begin
                reg_write = 1'b1;
                case ({funct7, funct3})
                    10'b0000000_000: alu_op = ALU_ADD; // ADD
                    10'b0100000_000: alu_op = ALU_SUB; // SUB
                    10'b0000000_111: alu_op = ALU_AND; // AND
                    10'b0000000_110: alu_op = ALU_OR;  // OR
                    10'b0000000_100: alu_op = ALU_XOR; // XOR
                    default: reg_write = 1'b0;
                endcase
            end

            // LOAD
            7'b0000011: begin
                mem_read  = 1'b1;
                reg_write = 1'b1;
                alu_op    = ALU_ADD;
            end

            // STORE
            7'b0100011: begin
                mem_write = 1'b1;
                alu_op    = ALU_ADD;
            end

            // BRANCH
            7'b1100011: begin
                branch = 1'b1;
                alu_op = ALU_SUB;
            end

            // JAL
            7'b1101111: begin
                jump      = 1'b1;
                reg_write = 1'b1;
            end

            // JALR
            7'b1100111: begin
                jump      = 1'b1;
                reg_write = 1'b1;
                alu_op    = ALU_ADD;
            end

            // LUI
            7'b0110111: begin
                reg_write = 1'b1;
            end

            // AUIPC
            7'b0010111: begin
                reg_write = 1'b1;
                alu_op    = ALU_ADD;
            end

            default: begin
                alu_op = ALU_ADD;
            end
        endcase
    end

endmodule
