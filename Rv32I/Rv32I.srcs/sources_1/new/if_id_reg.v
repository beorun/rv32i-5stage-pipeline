`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/09/2026 05:30:16 PM
// Design Name: 
// Module Name: if_id_reg
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


module if_id_reg(
    input  wire        clk,
    input  wire        rst,
    input  wire        stall,       // 1 = hold current values
    input  wire        flush,       // 1 = insert NOP
    input  wire [31:0] pc_in,
    input  wire [31:0] instr_in,
    output reg  [31:0] pc_out,
    output reg  [31:0] instr_out
    );
    localparam NOP = 32'h0000_0013; // ADDI x0, x0, 0

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc_out    <= 32'b0;
            instr_out <= NOP;
        end else if (flush) begin
            pc_out    <= 32'b0;
            instr_out <= NOP;
        end else if (!stall) begin
            pc_out    <= pc_in;
            instr_out <= instr_in;
        end
        // stall: hold values
    end
    
endmodule
