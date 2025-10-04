// riscvsingle.sv

// RISC-V single-cycle processor
// From Section 7.6 of Digital Design & Computer Architecture
// 27 April 2020
// David_Harris@hmc.edu 
// Sarah.Harris@unlv.edu

// MODIFIED TO INCLUDE RVX10 INSTRUCTIONS FOR ASSIGNMENT

// run 210
// Expect simulator to print "Simulation succeeded"
// when the value 25 (0x19) is written to address 100 (0x64)

// Single-cycle implementation of RISC-V (RV32I)
// User-level Instruction Set Architecture V2.2 (May 7, 2017)
// Implements a subset of the base integer instructions:
//    lw, sw
//    add, sub, and, or, slt, 
//    addi, andi, ori, slti
//    beq
//    jal
// Implements the RVX10 custom instruction set extension:
//    ANDN, ORN, XNOR, MIN, MAX, MINU, MAXU, ROL, ROR, ABS
// Exceptions, traps, and interrupts not implemented
// little-endian memory

// 31 32-bit registers x1-x31, x0 hardwired to 0
// R-Type instructions
//   add, sub, and, or, slt
//   INSTR rd, rs1, rs2
//   Instr[31:25] = funct7 (funct7b5 & opb5 = 1 for sub, 0 for others)
//   Instr[24:20] = rs2
//   Instr[19:15] = rs1
//   Instr[14:12] = funct3
//   Instr[11:7]  = rd
//   Instr[6:0]   = opcode
// I-Type Instructions
//   lw, I-type ALU (addi, andi, ori, slti)
//   lw:         INSTR rd, imm(rs1)
//   I-type ALU: INSTR rd, rs1, imm (12-bit signed)
//   Instr[31:20] = imm[11:0]
//   Instr[24:20] = rs2
//   Instr[19:15] = rs1
//   Instr[14:12] = funct3
//   Instr[11:7]  = rd
//   Instr[6:0]   = opcode
// S-Type Instruction
//   sw rs2, imm(rs1) (store rs2 into address specified by rs1 + immm)
//   Instr[31:25] = imm[11:5] (offset[11:5])
//   Instr[24:20] = rs2 (src)
//   Instr[19:15] = rs1 (base)
//   Instr[14:12] = funct3
//   Instr[11:7]  = imm[4:0]  (offset[4:0])
//   Instr[6:0]   = opcode
// B-Type Instruction
//   beq rs1, rs2, imm (PCTarget = PC + (signed imm x 2))
//   Instr[31:25] = imm[12], imm[10:5]
//   Instr[24:20] = rs2
//   Instr[19:15] = rs1
//   Instr[14:12] = funct3
//   Instr[11:7]  = imm[4:1], imm[11]
//   Instr[6:0]   = opcode
// J-Type Instruction
//   jal rd, imm  (signed imm is multiplied by 2 and added to PC, rd = PC+4)
//   Instr[31:12] = imm[20], imm[10:1], imm[11], imm[19:12]
//   Instr[11:7]  = rd
//   Instr[6:0]   = opcode

//   Instruction  opcode    funct3    funct7
//   add          0110011   000       0000000
//   sub          0110011   000       0100000
//   and          0110011   111       0000000
//   or           0110011   110       0000000
//   slt          0110011   010       0000000
//   addi         0010011   000       immediate
//   andi         0010011   111       immediate
//   ori          0010011   110       immediate
//   slti         0010011   010       immediate
//   beq          1100011   000       immediate
//   lw	          0000011   010       immediate
//   sw           0100011   010       immediate
//   jal          1101111   immediate immediate


// Testbench for Single-Cycle RISC-V Processor (RV32I + RVX10)
// Monitors memory writes and validates output at address 100

module testbench();

  logic        clk;
  logic        reset;
  logic [31:0] WriteData, DataAdr;
  logic        MemWrite;

  // Instantiate top-level system (processor + memories)
  top dut(clk, reset, WriteData, DataAdr, MemWrite);
  
  // Initialize system with reset pulse
  initial begin
      reset <= 1; #22; reset <= 0;
  end

  // Generate a 10-time unit clock
  always begin
      clk <= 1; #5; clk <= 0; #5;
  end

  // Monitor memory writes to detect success or failure
  

  always @(negedge clk) begin
    if (MemWrite && DataAdr === 32'd100) begin
        if (WriteData === 32'd25)
            $display("Simulation succeeded");
        else
            $display("Simulation failed");
        $stop;
    end
end


endmodule


// Top-Level Module
// Connects processor, instruction memory, and data memory

module top(input  logic        clk, reset, 
           output logic [31:0] WriteData, DataAdr, 
           output logic        MemWrite);

  logic [31:0] PC, Instr, ReadData;
  
  // Instantiate processor core
  riscvsingle rvsingle(clk, reset, PC, Instr, MemWrite, DataAdr, WriteData, ReadData);
  
  // Instruction memory (ROM)
  imem imem(PC, Instr);
  
  // Data memory (RAM)
  dmem dmem(clk, MemWrite, DataAdr, WriteData, ReadData);
endmodule


// 32-bit Adder
// Computes sum of two inputs

module adder(input [31:0] a, b,
             output [31:0] y);
  assign y = a + b;
endmodule


// Arithmetic Logic Unit (ALU)
// Performs arithmetic, logical, and RVX10 custom operations

module alu(input  logic [31:0] a, b,
           input  logic [3:0]  alucontrol,
           output logic [31:0] result,
           output logic        zero);

  logic [31:0] condinvb, sum;
  logic        v;        // overflow flag
  logic        isAddSub; // identifies add/sub operations

  assign condinvb = alucontrol[0] ? ~b : b;
  assign sum      = a + condinvb + alucontrol[0];
  assign isAddSub = ~alucontrol[2] & ~alucontrol[1] | ~alucontrol[1] & alucontrol[0];

  wire signed [31:0] s1 = a;
  wire signed [31:0] s2 = b;

  always_comb
    case (alucontrol)
      4'b0000:  result = sum;                // ADD
      4'b0001:  result = sum;                // SUB
      4'b0010:  result = a & b;              // AND
      4'b0011:  result = a | b;              // OR
      4'b0100:  result = a ^ b;              // XOR
      4'b0101:  result = sum[31] ^ v;        // SLT (signed)

      // RVX10 Extensions
      4'b0110:  result = a & ~b;             // ANDN
      4'b0111:  result = a | ~b;             // ORN
      4'b1000:  result = ~(a ^ b);           // XNOR
      4'b1001:  result = (s1 < s2) ? a : b;  // MIN (signed)
      4'b1010:  result = (s1 > s2) ? a : b;  // MAX (signed)
      4'b1011:  result = (a  < b)  ? a : b;  // MINU (unsigned)
      4'b1100:  result = (a  > b)  ? a : b;  // MAXU (unsigned)
      4'b1101: begin                          // ROL (rotate left)
                  logic [4:0] sh = b[4:0];
                  result = (sh == 0) ? a : ((a << sh) | (a >> (32 - sh)));
               end
      4'b1110: begin                          // ROR (rotate right)
                  logic [4:0] sh = b[4:0];
                  result = (sh == 0) ? a : ((a >> sh) | (a << (32 - sh)));
               end
      4'b1111:  result = (s1 >= 0) ? a : -a;  // ABS (absolute value)
      default:  result = 32'bx;
    endcase

  assign zero = (result == 32'b0);
  assign v    = ~(alucontrol[0] ^ a[31] ^ b[31]) & (a[31] ^ sum[31]) & isAddSub;
endmodule


// ALU Control Decoder
// Maps instruction fields to ALU operations

module aludec(input  logic       opb5,
              input  logic [2:0] funct3,
              input  logic       funct7b5, 
              input  logic [1:0] funct7_2b,
              input  logic [1:0] ALUOp,
              output logic [3:0] ALUControl);

  logic RtypeSub;
  assign RtypeSub = funct7b5 & opb5;

  always_comb
    case(ALUOp)
      2'b00: ALUControl = 4'b0000; // ADD (load/store)
      2'b01: ALUControl = 4'b0001; // SUB (branch)
      2'b10: // standard R/I-type instructions
        case(funct3)
          3'b000: ALUControl = RtypeSub ? 4'b0001 : 4'b0000;
          3'b010: ALUControl = 4'b0101;
          3'b110: ALUControl = 4'b0011;
          3'b111: ALUControl = 4'b0010;
          default: ALUControl = 4'bxxxx;
        endcase
      2'b11: // RVX10 custom instructions
        case(funct7_2b)
          2'b00: case(funct3) 
          3'b000: ALUControl=4'b0110;
          3'b001: ALUControl=4'b0111; 
          3'b010: ALUControl=4'b1000;
           default: ALUControl=4'bxxxx; 
           endcase
          2'b01: case(funct3)
           3'b000: ALUControl=4'b1001;
            3'b001: ALUControl=4'b1010;
             3'b010: ALUControl=4'b1011; 
             3'b011: ALUControl=4'b1100; 
             default: ALUControl=4'bxxxx; 
             endcase
          2'b10: case(funct3) 3'b000: ALUControl=4'b1101;
           3'b001: ALUControl=4'b1110; 
           default: ALUControl=4'bxxxx; 
           endcase
          2'b11: ALUControl = 4'b1111;
          default: ALUControl = 4'bxxxx;
        endcase
      default: ALUControl = 4'bxxxx;
    endcase
endmodule


// Controller
// Generates datapath control signals from opcode, funct fields

module controller(input  logic [6:0] op,
                  input  logic [2:0] funct3,
                  input  logic       funct7b5,
                  input  logic [1:0] funct7_2b,
                  input  logic       Zero,
                  output logic [1:0] ResultSrc,
                  output logic       MemWrite,
                  output logic       PCSrc, ALUSrc,
                  output logic       RegWrite, Jump,
                  output logic [1:0] ImmSrc,
                  output logic [3:0] ALUControl);

  logic [1:0] ALUOp;
  logic       Branch;

  // High-level control signal generator
  maindec md(op, ResultSrc, MemWrite, Branch, ALUSrc, RegWrite, Jump, ImmSrc, ALUOp);
  
  // ALU control logic
  aludec ad(op[5], funct3, funct7b5, funct7_2b, ALUOp, ALUControl);

  assign PCSrc = Branch & Zero | Jump;
endmodule


// Datapath
// Connects PC, register file, ALU, and memory

module datapath(input  logic        clk, reset,
                input  logic [1:0]  ResultSrc, 
                input  logic        PCSrc, ALUSrc,
                input  logic        RegWrite,
                input  logic [1:0]  ImmSrc,
                input  logic [3:0]  ALUControl,
                output logic        Zero,
                output logic [31:0] PC,
                input  logic [31:0] Instr,
                output logic [31:0] ALUResult, WriteData,
                input  logic [31:0] ReadData);

  logic [31:0] PCNext, PCPlus4, PCTarget;
  logic [31:0] ImmExt;
  logic [31:0] SrcA, SrcB;
  logic [31:0] Result;

  // Program counter and next-PC logic
  flopr #(32) pcreg(clk, reset, PCNext, PC);
  adder pcadd4(PC, 32'd4, PCPlus4);
  adder pcaddbranch(PC, ImmExt, PCTarget);
  mux2 #(32) pcmux(PCPlus4, PCTarget, PCSrc, PCNext);

  // Register file reads and writes
  regfile rf(clk, RegWrite, Instr[19:15], Instr[24:20], Instr[11:7], Result, SrcA, WriteData);

  // Immediate value extraction
  extend ext(Instr[31:7], ImmSrc, ImmExt);

  // ALU input selection
  mux2 #(32) srcbmux(WriteData, ImmExt, ALUSrc, SrcB);

  // ALU computation
  alu alu(SrcA, SrcB, ALUControl, ALUResult, Zero);

  // Select value to write back to register file
  mux3 #(32) resultmux(ALUResult, ReadData, PCPlus4, ResultSrc, Result);
endmodule


// Data Memory (RAM)

module dmem(input logic clk, we,
            input logic [31:0] a, wd,
            output logic [31:0] rd);
    
   logic [31:0] RAM [63:0];
   
   assign rd = RAM[a[31:2]]; // word-aligned read
   
   always_ff @(posedge clk)
       if(we) RAM[a[31:2]] <= wd; // write on clock edge
endmodule


// Instruction Memory (ROM)
// Loads instructions from hex file

module imem(input logic [31:0] a,
            output logic [31:0] rd);
    logic [31:0] RAM [63:0];
    
    initial $readmemh("../tests/rvx10.hex", RAM);
    
    assign rd = RAM[a[31:2]]; // word-aligned access
endmodule


// Immediate Extension Unit
// Converts instruction fields to 32-bit immediate

module extend(input logic [31:7] instr,
              input logic [1:0] immsrc,
              output logic [31:0] immext);
 
  always_comb
    case(immsrc) 
      2'b00: immext = {{20{instr[31]}}, instr[31:20]};            // I-type
      2'b01: immext = {{20{instr[31]}}, instr[31:25], instr[11:7]}; // S-type
      2'b10: immext = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0}; // B-type
      2'b11: immext = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0}; // J-type
      default: immext = 32'bx;
    endcase             
endmodule


// Parameterized Flip-Flop with Asynchronous Reset

module flopr #(parameter WIDTH=8)(
        input logic clk, reset,
        input logic [WIDTH-1:0] d,
        output logic [WIDTH-1:0] q);
    
    always_ff @(posedge clk, posedge reset)
        if(reset) q <= 0;
        else q <= d;
endmodule


// 2-to-1 Multiplexer

module mux2 #(parameter WIDTH=8)(
        input logic [WIDTH-1:0] d0,d1,
        input logic s,
        output logic [WIDTH-1:0] y);
    
    assign y = s ? d1 : d0;
endmodule


// 3-to-1 Multiplexer

module mux3 #(parameter WIDTH=8)(
        input logic [WIDTH-1:0] d0,d1,d2,
        input logic [1:0] s,
        output logic [WIDTH-1:0] y);
    
    assign y = s[1] ? d2 : (s[0] ? d1 : d0);
endmodule


// Register File

module regfile(input logic clk, 
               input logic we3, 
               input logic [4:0] a1, a2, a3, 
               input logic [31:0] wd3, 
               output logic [31:0] rd1, rd2);

  logic [31:0] rf[31:0];

  always_ff @(posedge clk)
    if (we3 & a3 != 0) rf[a3] <= wd3; // write, except x0

  assign rd1 = (a1 != 0) ? rf[a1] : 0;
  assign rd2 = (a2 != 0) ? rf[a2] : 0;
endmodule


// Single-Cycle RISC-V Processor

module riscvsingle(input logic clk, reset,
                   output logic [31:0] PC,
                   input logic [31:0] Instr,
                   output logic MemWrite,
                   output logic [31:0] ALUResult, WriteData,
                   input logic [31:0] ReadData);

  logic ALUSrc, RegWrite, Jump, Zero;
  logic [1:0] ResultSrc, ImmSrc; 
  logic [3:0] ALUControl; 
  logic PCSrc;

  // Controller: generates control signals
  controller c(Instr[6:0], Instr[14:12], Instr[30], Instr[26:25], Zero,
               ResultSrc, MemWrite, PCSrc,
               ALUSrc, RegWrite, Jump,
               ImmSrc, ALUControl);

  // Datapath: executes instructions
  datapath dp(clk, reset, ResultSrc, PCSrc,
              ALUSrc, RegWrite, ImmSrc, ALUControl,
              Zero, PC, Instr,
              ALUResult, WriteData, ReadData);
endmodule


// Main Decoder

module maindec(input logic [6:0] op,
               output logic [1:0] ResultSrc,
               output logic MemWrite,
               output logic Branch, ALUSrc,
               output logic RegWrite, Jump,
               output logic [1:0] ImmSrc,
               output logic [1:0] ALUOp);

  logic [10:0] controls;

  assign {RegWrite, ImmSrc, ALUSrc, MemWrite,
          ResultSrc, Branch, ALUOp, Jump} = controls;

  always_comb
    case(op)
      7'b0000011: controls = 11'b1_00_1_0_01_0_00_0; // lw
      7'b0100011: controls = 11'b0_01_1_1_00_0_00_0; // sw
      7'b0110011: controls = 11'b1_xx_0_0_00_0_10_0; // R-type
      7'b1100011: controls = 11'b0_10_0_0_00_1_01_0; // beq
      7'b0010011: controls = 11'b1_00_1_0_00_0_10_0; // I-type ALU
      7'b1101111: controls = 11'b1_11_0_0_10_0_00_1; // jal
      7'b0001011: controls = 11'b1_xx_0_0_00_0_11_0; // RVX10
      default:    controls = 11'bx_xx_x_x_xx_x_xx_x; // unsupported
    endcase
endmodule
