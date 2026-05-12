`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/09/2026 05:22:22 PM
// Design Name: 
// Module Name: hazard_unit
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


module hazard_unit(
    // Load-use detection inputs
    input  wire       id_ex_mem_read,  // EX stage is a LOAD
    input  wire [4:0] id_ex_rd,        // EX stage destination register
    input  wire [4:0] if_id_rs1,       // ID stage source register 1
    input  wire [4:0] if_id_rs2,       // ID stage source register 2

    // Branch/jump flush inputs
    input  wire       branch_taken,    // from EX stage: branch/jump resolved

    // Outputs
    output wire       stall,           // 1 = stall IF and ID, insert NOP into EX
    output wire       flush_if_id,     // 1 = flush IF/ID register
    output wire       flush_id_ex      // 1 = flush ID/EX register
    );
    
    wire load_use_hazard;
    assign load_use_hazard = id_ex_mem_read &&
                            ((id_ex_rd == if_id_rs1) || (id_ex_rd == if_id_rs2)) &&
                            (id_ex_rd != 5'b0);

    assign stall        = load_use_hazard;
    
    assign flush_if_id  = branch_taken;
    assign flush_id_ex  = branch_taken | load_use_hazard;
endmodule
