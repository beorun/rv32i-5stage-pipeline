`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/09/2026 11:09:27 AM
// Design Name: 
// Module Name: instruction_mem
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


module instr_mem #(parameter MEM_DEPTH = 256)(
    input wire [31:0] addr,
    output wire [31:0] instr
    );
    
    reg [31:0] mem [0:MEM_DEPTH - 1];
    
    //initial begin
    //    $readmemh("program.hex", mem);
    //end
    
    assign instr = mem[addr[9:2]];
endmodule
