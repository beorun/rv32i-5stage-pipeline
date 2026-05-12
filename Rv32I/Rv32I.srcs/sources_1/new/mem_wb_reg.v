`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/09/2026 05:33:48 PM
// Design Name: 
// Module Name: mem_wb_reg
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


module mem_wb_reg(
    input  wire        clk,
    input  wire        rst,

    // Data inputs
    input  wire [31:0] alu_result_in,
    input  wire [31:0] mem_data_in,
    input  wire [4:0]  rd_in,
    input  wire [31:0] pc_plus4_in,
    input  wire [31:0] imm_in,          // for LUI passthrough
    input  wire [2:0]  funct3_in,
    
    // Control inputs
    input  wire        reg_write_in,
    input  wire [1:0]  mem_to_reg_in,

    // Data outputs
    output reg  [31:0] alu_result_out,
    output reg  [31:0] mem_data_out,
    output reg  [4:0]  rd_out,
    output reg  [31:0] pc_plus4_out,
    output reg  [31:0] imm_out,
    output reg  [2:0]  funct3_out,

    // Control outputs
    output reg         reg_write_out,
    output reg  [1:0]  mem_to_reg_out
    );
     always @(posedge clk or posedge rst) begin
        if (rst) begin
            alu_result_out  <= 32'b0;
            mem_data_out    <= 32'b0;
            rd_out          <= 5'b0;
            pc_plus4_out    <= 32'b0;
            imm_out         <= 32'b0;
            reg_write_out   <= 1'b0;
            mem_to_reg_out  <= 2'b0;
            funct3_out <= 3'b0;
        end else begin
            alu_result_out  <= alu_result_in;
            mem_data_out    <= mem_data_in;
            rd_out          <= rd_in;
            pc_plus4_out    <= pc_plus4_in;
            imm_out         <= imm_in;
            reg_write_out   <= reg_write_in;
            mem_to_reg_out  <= mem_to_reg_in;
            funct3_out <= funct3_in;
        end
    end
endmodule
