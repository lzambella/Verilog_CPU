`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/15/2018 12:58:43 PM
// Design Name: 
// Module Name: INSTR_MEM
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


module INSTR_MEM(
        input CLK,
        input ENABLE,
        input wire[15:0] ADDR_IN,   // 16 bit mem address input (program counter)
        output reg[31:0] INSTR_OUT // 32 bit instruction output 
    );
    reg [31:0] MEM [15:0];            // 1024 blocks of 32-bit instructions   
    always @ (posedge CLK) begin
        if (ENABLE) begin
            INSTR_OUT <= MEM[ADDR_IN];    // always get instruction at program counter
        end
    end
    
    // Initial instructions
    initial begin
        MEM[0] = 'b10001011000_00000_000000_00001_00011;    // ADD X3, X1, X0
        MEM[1] = 'b10001011000_00011_000000_00000_00000;    // ADD X0, X0, X3
        MEM[2] = 'b11001011000_00100_000000_00010_00010;    // SUB X2, X2, X4
        MEM[3] = 'b10110100_0000000000000000010_00010;      // CBZ X2, #2
        MEM[4] = 'b000101_11111111111111111111111101;       // B #-3  branch to second add instruction
        MEM[5] = 'b10001011000_00101_000000_00000_00101;    // ADD X5, X0, X5   X5 should end up being 25d
    end
endmodule
