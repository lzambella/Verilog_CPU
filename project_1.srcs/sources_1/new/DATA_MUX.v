`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/15/2018 08:13:46 PM
// Design Name: 
// Module Name: DATA_MUX
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


module DATA_MUX(
        input SELECTOR,
        input [63:0] DATA_A,
        input [63:0] DATA_B,
        output [63:0] OUT
    );
    
    assign OUT = (SELECTOR == 0) ? DATA_A : DATA_B;
    
endmodule
