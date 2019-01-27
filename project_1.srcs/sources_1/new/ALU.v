`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/15/2018 01:37:39 PM
// Design Name: 
// Module Name: ALU
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

module ALU(
    input CLK,              // System clock
    input ENABLE,           // module enable
    input [1:0] ALU_OP,     // ALU control Opcode
    input [63:0] in_a,      // Input A
    input [63:0] in_b,      // Input B
    input [10:0] INSTR_OP,  // Opcode from instruction
    output reg [63:0] out,  // 64 bit output
    output wire zero        // if in_a is zero
    );
    
    `define OPERATION_ADD               'b10001011000
    `define OPERATION_SUB               'b11001011000
    `define OPERATION_AND               'b10001010000
    `define OPERATION_ORR               'b10101010000
    
    always @ (posedge CLK) begin
       if (ENABLE) begin
       /*
            case (ALU_OP)
                'b0000: out <= in_a & in_b;
                'b0001: out <= in_a | in_b;
                'b0010: out <= in_a + in_b;
                'b0110: out <= in_a - in_b;
                'b0111: out <= in_b;
                'b1100: out <= !(in_a | in_b);
                default: out <= 'hFFFF; // easily find errors
            endcase
         */   
         
         /* Simplified combined ALU Control and ALU */
            case (ALU_OP)   
                'b00: out <= in_a + in_b;     // D instructions always get add
                'b01: out <= in_b;            // B instructions always pass in-b
                'b10: begin                  // R type have different operations
                    case (INSTR_OP)          // Test the instruction from the instruction opcode
                        `OPERATION_ADD: out <= in_a + in_b;
                        `OPERATION_SUB: out <= in_a - in_b;
                        `OPERATION_AND: out <= in_a & in_b;
                        `OPERATION_ORR: out <= in_a | in_b;
                    endcase
                end
                default: out <= 'hFFFF;  // detect error easily
            endcase
        end
    end
    
    // If the result is zero, set the wire to 1
    assign zero = (in_b == 'h00) ? 'b1 : 'b0;
endmodule
