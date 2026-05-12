`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/09/2026 04:41:57 PM
// Design Name: 
// Module Name: alu_control
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


module alu_control(
    input  wire [1:0] alu_op,    // from main control
    input  wire       opcode_b5,
    input  wire [2:0] funct3,
    input  wire [6:0] funct7,
    output reg  [3:0] alu_ctrl
    );
    always @(*) begin
        case (alu_op)
            2'b00: alu_ctrl = 4'b0000; // ADD (memory ops)
            2'b01: alu_ctrl = 4'b0001; // SUB (branch)
            2'b10: begin               // R-type / I-type
                case (funct3)
                    3'b000: alu_ctrl = (funct7[5] & opcode_b5) ? 4'b0001 : 4'b0000; // SUB : ADD
                    
                    3'b001: alu_ctrl = 4'b0111; // SLL
                    3'b010: alu_ctrl = 4'b0101; // SLT
                    3'b011: alu_ctrl = 4'b0110; // SLTU
                    3'b100: alu_ctrl = 4'b0100; // XOR
                    
                    3'b101: alu_ctrl = (funct7[5]) ? 4'b1001 : 4'b1000; // SRA : SRL
                    3'b110: alu_ctrl = 4'b0011; // OR
                    3'b111: alu_ctrl = 4'b0010; // AND
                    default: alu_ctrl = 4'b0000;
                endcase
            end
            2'b11: alu_ctrl = 4'b1010; // PASS_B (LUI)
            default: alu_ctrl = 4'b0000;
        endcase
    end
    
endmodule
