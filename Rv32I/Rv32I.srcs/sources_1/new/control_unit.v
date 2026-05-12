`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/09/2026 05:15:49 PM
// Design Name: 
// Module Name: control_unit
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


module control_unit(
    input  wire [6:0] opcode,
    output reg        reg_write,
    output reg        mem_read,
    output reg        mem_write,
    output reg [1:0]  mem_to_reg,
    output reg        alu_src,     // 0=reg, 1=immediate
    output reg [1:0]  alu_op,
    output reg        branch,      // B-type instructions
    output reg        jump         // JAL / JALR
    );
    
    always @(*) begin
        // Safe defaults
        reg_write  = 1'b0;
        mem_read   = 1'b0;
        mem_write  = 1'b0;
        mem_to_reg = 2'b00;
        alu_src    = 1'b0;
        alu_op     = 2'b00;
        branch     = 1'b0;
        jump       = 1'b0;

        case (opcode)
            7'b0110011: begin // R-type
                reg_write  = 1'b1;
                alu_op     = 2'b10;
            end
            7'b0010011: begin // I-type ALU (ADDI, ANDI, ORI, XORI, SLTI...)
                reg_write  = 1'b1;
                alu_src    = 1'b1;
                alu_op     = 2'b10;
            end
            7'b0000011: begin // LOAD (LW)
                reg_write  = 1'b1;
                mem_read   = 1'b1;
                alu_src    = 1'b1;
                mem_to_reg = 2'b01;
                alu_op     = 2'b00;
            end
            7'b0100011: begin // STORE (SW)
                mem_write  = 1'b1;
                alu_src    = 1'b1;
                alu_op     = 2'b00;
            end
            7'b1100011: begin // BRANCH (BEQ, BNE)
                branch     = 1'b1;
                alu_op     = 2'b01; // SUB for comparison
            end
            7'b0110111: begin // LUI
                reg_write  = 1'b1;
                alu_src    = 1'b1;
                mem_to_reg = 2'b11; // pass immediate
                alu_op     = 2'b11;
            end
            7'b1101111: begin // JAL
                reg_write  = 1'b1;
                mem_to_reg = 2'b10; // PC+4 as link
                jump       = 1'b1;
            end
            7'b1100111: begin // JALR
                reg_write  = 1'b1;
                alu_src    = 1'b1;
                mem_to_reg = 2'b10;
                jump       = 1'b1;
                alu_op     = 2'b00; // ADD for target address
            end
            default: ; // NOP / unknown — all signals 0
        endcase
    end
endmodule
