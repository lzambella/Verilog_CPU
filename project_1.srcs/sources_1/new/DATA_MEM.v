`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/15/2018 01:10:31 PM
// Design Name: 
// Module Name: DATA_MEM
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


module DATA_MEM(
        input CLK,                          // system clock
        input ENABLE,
        input MEM_WRITE,                    // memory write enable
        input MEM_READ,                     // memory read enable
        input [63:0] MEM_ADDR_IN,           // Memory address input
        input [63:0] WRITE_DATA,            // Memory write data
        output reg [63:0] DATA_OUT          // Memory data output (if read enabled)        
    );
    
        reg [63:0] DATA_MEMORY [15:0];    // 2^16 blocks of 64 bit memory (128 KB of data)
        
        always @ (posedge CLK) begin
            if (ENABLE) begin
                if (MEM_WRITE) begin
                    DATA_MEMORY[MEM_ADDR_IN] <= WRITE_DATA;
                end else if (MEM_READ) begin
                    DATA_OUT <= DATA_MEMORY[MEM_ADDR_IN];
                end
            end
        end
        
        initial begin 
            DATA_MEMORY[0] = 'hAAAA;
            DATA_MEMORY[1] = 'hBBBB;
            
            
        end
endmodule
