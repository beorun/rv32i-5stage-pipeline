`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/09/2026 05:28:47 PM
// Design Name: 
// Module Name: forwarding_unit
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


module forwarding_unit(
    input  wire [4:0] id_ex_rs1,
    input  wire [4:0] id_ex_rs2,

    input  wire [4:0] ex_mem_rd,
    input  wire       ex_mem_reg_write,

    input  wire [4:0] mem_wb_rd,
    input  wire       mem_wb_reg_write,

    output reg  [1:0] forward_a,   // mux select for ALU operand A
    output reg  [1:0] forward_b    // mux select for ALU operand B
    );
    always @(*) begin
        // --- Forward A ---
        // Priority: EX/MEM forwarding takes precedence over MEM/WB
        if (ex_mem_reg_write && (ex_mem_rd != 5'b0) && (ex_mem_rd == id_ex_rs1))
            forward_a = 2'b10;   // forward from EX/MEM
        else if (mem_wb_reg_write && (mem_wb_rd != 5'b0) && (mem_wb_rd == id_ex_rs1))
            forward_a = 2'b01;   // forward from MEM/WB
        else
            forward_a = 2'b00;   // no forwarding

        // --- Forward B ---
        if (ex_mem_reg_write && (ex_mem_rd != 5'b0) && (ex_mem_rd == id_ex_rs2))
            forward_b = 2'b10;
        else if (mem_wb_reg_write && (mem_wb_rd != 5'b0) && (mem_wb_rd == id_ex_rs2))
            forward_b = 2'b01;
        else
            forward_b = 2'b00;
    end
endmodule
