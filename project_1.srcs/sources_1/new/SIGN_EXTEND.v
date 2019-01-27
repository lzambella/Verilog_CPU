`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/06/2018 01:32:18 PM
// Design Name: 
// Module Name: SIGN_EXTEND
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


module SIGN_EXTEND(
    input CLK,
    input [31:0] INSTR_IN,
    output wire [63:0] OUT
    );
    
    assign OUT = $signed(INSTR_IN[20:12]);
endmodule
