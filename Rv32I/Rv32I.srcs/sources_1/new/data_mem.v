`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/09/2026 11:16:17 AM
// Design Name: 
// Module Name: data_mem
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


module data_mem #(parameter MEM_DEPTH = 256)(
    input wire clk,
    input wire mem_read,    //1 read enable
    input wire mem_write,   //1 write enable
    input wire [31:0] addr,
    input wire [31:0] write_data,
    output wire [31:0] read_data
    );
    reg [31:0] mem [0:MEM_DEPTH - 1];
    
    always @(posedge clk) begin
        if(mem_write)
            mem[addr[31:2]] <= write_data;
    end
    
    assign read_data = (mem_read) ? mem[addr[31:2]] : 32'd0;
    
endmodule
