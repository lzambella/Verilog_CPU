`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/15/2018 01:49:11 PM
// Design Name: 
// Module Name: REG_MEM
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

    Module containg each of the 32 registers and read/write enables

*/
module REG_MEM(
        input CLK,                  // System clock
        input ENABLE,               // enable
        input ENABLE_B,             // writeback enabler
        input  [4:0] READ_REG_A,    // read from registser A
        input  [4:0] READ_REG_B,    // read from register b
        input  [4:0] WRITE_REG,     // write WRITE_DATA to this register (if regwrite enabled)
        input  [63:0] WRITE_DATA,   // Data to write to register
        input  REG_WRITE_ENABLE,    // enable for writing to register
        output reg [63:0] DATA_OUT_A,   // data read from register input a
        output reg [63:0] DATA_OUT_B    // data read from register input b
    );
    
        reg [63:0] REGISTER [31:0];      // 32 general prupose registers holding 64 bits each
        always @ (posedge CLK) begin
            if (ENABLE) begin          
                DATA_OUT_B <= REGISTER[READ_REG_B];
                DATA_OUT_A <= REGISTER[READ_REG_A];
            end
            // writeback enabling
            if (ENABLE_B & REG_WRITE_ENABLE) begin
                REGISTER[WRITE_REG] <= WRITE_DATA;
            end 
        end
        
        // lets give some registers initial values
        initial begin
            REGISTER[0] = 'h0000;
            REGISTER[1] = 'h0005;
            REGISTER[2] = 'h0005;
            REGISTER[3] = 'hFFFF;
            REGISTER[4] = 'h0001;
            REGISTER[5] = 'h0000;
        end
endmodule
