`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/09/2026 05:11:04 PM
// Design Name: 
// Module Name: alu
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


module alu(
    input  wire [31:0] a,         // operand A
    input  wire [31:0] b,         // operand B
    input  wire [3:0]  alu_ctrl,  // operation select
    output reg  [31:0] result,
    output wire        zero         // 1 when result == 0 (BEQ/BNE)
    );
    
    assign zero = (result == 32'b0);
    
     always @(*) begin
        case (alu_ctrl)
            4'b0000: result = a + b;                          // ADD
            4'b0001: result = a - b;                          // SUB
            4'b0010: result = a & b;                          // AND
            4'b0011: result = a | b;                          // OR
            4'b0100: result = a ^ b;                          // XOR
            4'b0101: result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0; // SLT
            4'b0110: result = (a < b)            ? 32'd1 : 32'd0;        // SLTU
            4'b0111: result = a << b[4:0];                    // SLL
            4'b1000: result = a >> b[4:0];                    // SRL
            4'b1001: result = $signed(a) >>> b[4:0];          // SRA
            4'b1010: result = b;                              // PASS_B (LUI)
            default: result = 32'b0;
        endcase
    end
    
endmodule
