`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/09/2026 12:06:22 PM
// Design Name: 
// Module Name: reg_file
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


module reg_file(
    input  wire        clk,
    input  wire        reg_write,    // WB write enable
    input  wire [4:0]  rs1, rs2,     // source register addresses
    input  wire [4:0]  rd,           // destination register address
    input  wire [31:0] write_data,   // data to write
    output wire [31:0] read_data1,   // rs1 value
    output wire [31:0] read_data2    // rs2 value
    );
    
    reg [31:0] regs [0:31];
    
    integer i;
    initial begin
    for(i =0; i< 32 ; i = i+1) 
        regs[i] = 32'd0;
    end
    
    always @(posedge clk) begin
        if(reg_write && rd != 5'd0)
            regs[rd] <= write_data;
    end
    
    assign read_data1 = (rs1 == 5'b0) ? 32'b0 : ((reg_write && (rs1 == rd)) ? write_data : regs[rs1]);                 
    assign read_data2 = (rs2 == 5'b0) ? 32'b0 : ((reg_write && (rs2 == rd)) ? write_data : regs[rs2]);
endmodule
