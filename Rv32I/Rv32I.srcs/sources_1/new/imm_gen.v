`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/09/2026 12:19:47 PM
// Design Name: 
// Module Name: imm_gen
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module imm_gen(
    input  wire [31:0] instr,
    output reg  [31:0] imm_out
    );
    wire [6:0] opcode = instr[6:0];

    always @(*) begin
        case (opcode)
            // I-type: ADDI, ANDI, ORI, LW, JALR
            7'b0010011,   // OP-IMM
            7'b0000011,   // LOAD
            7'b1100111:   // JALR
                imm_out = {{20{instr[31]}}, instr[31:20]};

            // S-type: SW
            7'b0100011:
                imm_out = {{20{instr[31]}}, instr[31:25], instr[11:7]};

            // B-type: BEQ, BNE
            7'b1100011:
                imm_out = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};

            // U-type: LUI
            7'b0110111, 7'b0010111:
                imm_out = {instr[31:12], 12'b0};

            // J-type: JAL
            7'b1101111:
                imm_out = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};

            default: imm_out = 32'b0;
        endcase
    end
endmodule
