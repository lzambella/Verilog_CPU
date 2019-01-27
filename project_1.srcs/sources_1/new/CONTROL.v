`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/15/2018 02:05:31 PM
// Design Name: 
// Module Name: CONTROL
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


module CONTROL(
        input            CLK,                       // System clk
        input      [10:0] INSTR_INPUT,               // 10 bit opcode input
        output reg [9:0] CTRL_OUT                   // Enable outputs (check bottom for description of each bit)
    );
    /** This can probably be turned into combinatorial logic */
    /* Opcode macros */
    `define OPERATION_ADD               'b10001011000
    `define OPERATION_SUB               'b11001011000
    `define OPERATION_AND               'b10001010000
    `define OPERATION_ORR               'b10101010000
    
    `define OPERATION_LDUR              'b11111000010
    `define OPERATION_STUR              'b11111000000
    
    `define OPERATION_CBZ               'b00101101000
    `define OPERATION_B                 'b00000000101
    
    always @ (posedge CLK) begin
        case (INSTR_INPUT)
            /* R-Type instructions have the same controls */
            `OPERATION_ADD: CTRL_OUT = 'b1001000000;
            `OPERATION_SUB: CTRL_OUT = 'b1001000000;
            `OPERATION_AND: CTRL_OUT = 'b1001000000;
            `OPERATION_ORR: CTRL_OUT = 'b1001000000;
            
            /* D-Type instructions */
            `OPERATION_LDUR: CTRL_OUT = 'b1100011001;
            `OPERATION_STUR: CTRL_OUT = 'b0110000001;
            
            /* Branch Instructions */
            default: CTRL_OUT = 'b0000000000;
        endcase
    end
    
    
    
    
endmodule

    /*
    CONTROL LINE OUTPUT
     0  0  0  0  0  0  0  0  0  0
    [9][8][7][6][5][4][3][2][1][0]
    9 -> REG WRITE
    8 -> ALU_SRC    (mux control)
    7 -> MEM_WRITE
    6 -> ALUOP[1]
    5 -> ALUOP[0]
    4 -> MEM_TO_REG (mux control)
    3 -> MEM_READ
    2 -> BRANCH
    1 -> UNCOND_BRANCH
    0 -> REG_2_LOCATION
    
    */