`timescale 1ns / 1ps
module CPU(

    );
    reg  [31:0] PC;
    wire [31:0] INSTR;
    reg clk;
    reg [9:0] CTRL_OUT;
    
    wire [4:0] mux_a_pass;              // Reg 2 Location mux on datasheet
    wire [63:0] mux_alusrc_pass;
    
    wire [63:0] reg_data_a, reg_data_b; // Register[n] contents
    
    wire [63:0] alu_res;
    
    wire [63:0] writeback_res;
    reg write_enable;
    wire [1:0] alu_ctrl;
    wire [63:0] read_data;
    wire [63:0] sign_extension;
    
    wire conditional_zero;
    
    wire [31:0] cbz_addr;
    wire [31:0] b_addr;
    
    `define STATE_INSTR_LOAD    'b000
    `define STATE_INSTR_DECODE  'b001
    `define STATE_INSTR_EXEC    'b010
    `define STATE_MEM_RW        'b011
    `define STATE_REG_WRITEBACK 'b100
    `define STATE_BUFFER        'b101
    // Current State
    reg [2:0] STATE = `STATE_INSTR_LOAD;
    
    // Enables for the components
    // [4] -> Writeback enable
    // [3] -> instr mem
    // [2] -> regmem
    // [1] -> alu and alu ctrl 
    // [0] -> data mem
    reg [4:0] enables;
    
    assign cbz_addr = $signed(INSTR[23:5]);
    assign b_addr = $signed(INSTR[25:0]);
    assign alu_ctrl = CTRL_OUT[6:5];

    /* Control Logic */
    
    
    /* Opcode macros */
    `define OPERATION_ADD               'b10001011000
    `define OPERATION_SUB               'b11001011000
    `define OPERATION_AND               'b10001010000
    `define OPERATION_ORR               'b10101010000
    
    `define OPERATION_LDUR              'b11111000010
    `define OPERATION_STUR              'b11111000000
    
    `define OPERATION_CBZ               'b10110100
    `define OPERATION_B                 'b000101
    
    
    always @ (posedge clk) begin
        // Send control lines if in instruction decode state
        if (`STATE_INSTR_DECODE) begin
            /* Bit descriptions are at bottom of source code */
            // Check if B-type instr first
            if (INSTR[31:26] == 'b000101) begin
                CTRL_OUT = 'b0000000010;    // Unconditional branch
            // Then check if CB type
            end else if (INSTR[31:24] == 'b10110100) begin
                CTRL_OUT <= 'b0000100101;   // Conditional branch zero
            // else its A D/R type (not implementing I types)
            end else begin
                case (INSTR[31:21]) // opcode
                    /* R-Type instructions have the same controls */
                    `OPERATION_ADD: CTRL_OUT <= 'b1001000000;
                    `OPERATION_SUB: CTRL_OUT <= 'b1001000000;
                    `OPERATION_AND: CTRL_OUT <= 'b1001000000;
                    `OPERATION_ORR: CTRL_OUT <= 'b1001000000;
                    
                    /* D-Type instructions */
                    `OPERATION_LDUR: CTRL_OUT <= 'b1100011001;
                    `OPERATION_STUR: CTRL_OUT <= 'b0110000001;
                    
                    default: CTRL_OUT <= 'b0000000000;
                endcase
            end
        end
    end
    /* End control logic*/
    
    
    /* When instruction is branch */
    always @ (posedge clk) begin
        if(CTRL_OUT[1] & STATE == `STATE_INSTR_EXEC) begin        // Unconditional branch
            PC <= PC + b_addr - 1;  // Set the PC. the extra minus is to set up for that addr
            
        end else if (CTRL_OUT[2] & STATE == `STATE_MEM_RW) begin     // Conditional branch zero
            if (conditional_zero) begin
                PC <= PC + cbz_addr - 1;
            end
        end
    end
    
    
    INSTR_MEM INSTRUCTION_MEMORY(
                                 .CLK(clk),
                                 .ENABLE(enables[3]),
                                 .ADDR_IN(PC),
                                 .INSTR_OUT(INSTR)
                                 );

    REGLOC_MUX MUX_A(.SELECTOR(CTRL_OUT[0]),        // REG_2_LOC (if 1, pass Rt as input B instead of Rd as WRITE_REG)
                      .DATA_A(INSTR[20:16]),
                      .DATA_B(INSTR[4:0]),
                      .OUTPUT(mux_a_pass));
                      
    REG_MEM REGISTERS(.CLK(clk),
                      .ENABLE(enables[2]),
                      .ENABLE_B(enables[0]),
                      .READ_REG_A(INSTR[9:5]),
                      .READ_REG_B(mux_a_pass),  // MUX_A selects a conditional registor location
                      .WRITE_REG(INSTR[4:0]),
                      .WRITE_DATA(writeback_res),
                      .REG_WRITE_ENABLE(CTRL_OUT[9]),
                      .DATA_OUT_A(reg_data_a),
                      .DATA_OUT_B(reg_data_b));
                      
    DATA_MUX ALU_SRC(.SELECTOR(CTRL_OUT[8]),
                     .DATA_A(reg_data_b),
                     .DATA_B(sign_extension),        // immediate data
                     .OUT(mux_alusrc_pass));
                     
    DATA_MUX MEM_2_REG(.SELECTOR(CTRL_OUT[4]),
                       .DATA_A(alu_res),            // 0 if storing ALU result
                       .DATA_B(read_data),          // 1 if reading from memory
                       .OUT(writeback_res));
                       
    ALU A(.CLK(clk),
          .ENABLE(enables[1]),
          .in_a(reg_data_a),            // Rn
          .in_b(mux_alusrc_pass),       // either Rm or Sign extend
          .out(alu_res),
          .ALU_OP(CTRL_OUT[6:5]),       // ALU opcode from Control lines
          .INSTR_OP(INSTR[31:21]),      // Opcode parsed from the instruction
          .zero(conditional_zero));
          
    
    DATA_MEM MEMORY(.CLK(clk),
                    .ENABLE(enables[0]),
                    .MEM_WRITE(CTRL_OUT[7]),
                    .MEM_READ(CTRL_OUT[3]),
                    .MEM_ADDR_IN(alu_res),
                    .WRITE_DATA(reg_data_b),
                    .DATA_OUT(read_data));
                    
    SIGN_EXTEND SIGN_EXTENDER(.CLK(clk),
                              .INSTR_IN(INSTR),
                              .OUT(sign_extension));
    always begin
        #5
        clk <= ~clk;
    end
    
    /* Finite state machine logic */
    always @ (posedge clk) begin
        case (STATE)
            `STATE_INSTR_LOAD: begin
                enables = 'b01000;
                STATE <= `STATE_INSTR_DECODE;
             end
             `STATE_INSTR_DECODE: begin
                enables <= 'b00100;
                STATE <= `STATE_INSTR_EXEC;
             end
             `STATE_INSTR_EXEC: begin
                enables <= 'b00010;
                STATE <= `STATE_MEM_RW;            
             end
             `STATE_MEM_RW: begin
                enables <= 'b00001;
                STATE <= `STATE_REG_WRITEBACK;              
             end
             `STATE_REG_WRITEBACK: begin
                enables <= 'b00001;                
                PC <= PC + 1;
                STATE <= `STATE_INSTR_LOAD;            
             end
        endcase      
    end
    initial begin
        clk = 0;
        PC = 0;
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