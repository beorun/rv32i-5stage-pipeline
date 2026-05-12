`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/09/2026 05:31:26 PM
// Design Name: 
// Module Name: id_ex_reg
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


module id_ex_reg(
    input  wire        clk,
    input  wire        rst,
    input  wire        flush,          // 1 = insert bubble

    // Data inputs
    input  wire [31:0]  pc_in,
    input  wire [31:0]  read_data1_in,
    input  wire [31:0]  read_data2_in,
    input  wire [31:0]  imm_in,
    input  wire [4:0]   rs1_in,
    input  wire [4:0]   rs2_in,
    input  wire [4:0]   rd_in,
    input  wire [2:0]   funct3_in,
    input  wire [6:0]   funct7_in,
    input  wire         opcode_b5_in,

    // Control signal inputs
    input  wire        reg_write_in,
    input  wire        mem_read_in,
    input  wire        mem_write_in,
    input  wire [1:0]  mem_to_reg_in,
    input  wire        alu_src_in,
    input  wire [1:0]  alu_op_in,
    input  wire        branch_in,
    input  wire        jump_in,

    // Data outputs
    output reg  [31:0] pc_out,
    output reg  [31:0] read_data1_out,
    output reg  [31:0] read_data2_out,
    output reg  [31:0] imm_out,
    output reg  [4:0]  rs1_out,
    output reg  [4:0]  rs2_out,
    output reg  [4:0]  rd_out,
    output reg  [2:0]  funct3_out,
    output reg  [6:0]  funct7_out,

    // Control signal outputs
    output reg         reg_write_out,
    output reg         mem_read_out,
    output reg         mem_write_out,
    output reg  [1:0]  mem_to_reg_out,
    output reg         alu_src_out,
    output reg  [1:0]  alu_op_out,
    output reg         branch_out,
    output reg         jump_out,
    output reg         opcode_b5_out
    );
     always @(posedge clk or posedge rst) begin
        if (rst || flush) begin
            // Insert NOP bubble: zero all control signals
            pc_out          <= 32'b0;
            read_data1_out  <= 32'b0;
            read_data2_out  <= 32'b0;
            imm_out         <= 32'b0;
            rs1_out         <= 5'b0;
            rs2_out         <= 5'b0;
            rd_out          <= 5'b0;
            funct3_out      <= 3'b0;
            funct7_out      <= 7'b0;
            reg_write_out   <= 1'b0;
            mem_read_out    <= 1'b0;
            mem_write_out   <= 1'b0;
            mem_to_reg_out  <= 2'b0;
            alu_src_out     <= 1'b0;
            alu_op_out      <= 2'b0;
            branch_out      <= 1'b0;
            jump_out        <= 1'b0;
            opcode_b5_out   <= 1'b0; // dùng để phân biệt Itype và Rtype trong ALUcontrol
        end else begin
            pc_out          <= pc_in;
            read_data1_out  <= read_data1_in;
            read_data2_out  <= read_data2_in;
            imm_out         <= imm_in;
            rs1_out         <= rs1_in;
            rs2_out         <= rs2_in;
            rd_out          <= rd_in;
            funct3_out      <= funct3_in;
            funct7_out      <= funct7_in;
            reg_write_out   <= reg_write_in;
            mem_read_out    <= mem_read_in;
            mem_write_out   <= mem_write_in;
            mem_to_reg_out  <= mem_to_reg_in;
            alu_src_out     <= alu_src_in;
            alu_op_out      <= alu_op_in;
            branch_out      <= branch_in;
            jump_out        <= jump_in;
            opcode_b5_out   <= opcode_b5_in;
        end
    end
endmodule
