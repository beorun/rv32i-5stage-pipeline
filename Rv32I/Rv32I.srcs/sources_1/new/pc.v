`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/09/2026 10:36:44 AM
// Design Name: 
// Module Name: pc
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


module pc(
    input  wire        clk,
    input  wire        rst,
    input  wire        stall,      // 1 = freeze PC (load-use stall)
    input  wire        pc_src,     // 1 = load pc_target (branch/jump taken)
    input  wire [31:0] pc_target,  // branch/jump target address
    output reg  [31:0] pc_out      // current PC value
    
    );
    always @(posedge clk or posedge rst) begin
        if (rst)
            pc_out <= 32'h0000_0000;
        else if (!stall) begin
            if (pc_src)
                pc_out <= pc_target;
            else
                pc_out <= pc_out + 32'd4;
        end
    end
endmodule
