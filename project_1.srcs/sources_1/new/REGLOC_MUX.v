`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/15/2018 02:58:05 PM
// Design Name: 
// Module Name: REGLOC_MUX
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

/*
    MUX for Reg2Loc
    DATA_A -> instr[20:16]
    DATA_B -> instr[4:0]
    SELECTOR assigns from control Reg2Loc
*/
module REGLOC_MUX(
        input SELECTOR,
        input [4:0]DATA_A,
        input [4:0]DATA_B,
        output [4:0] OUTPUT
    );
    
    assign OUTPUT = (SELECTOR == 0) ? DATA_A : DATA_B;
endmodule
