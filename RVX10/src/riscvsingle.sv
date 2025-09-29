
module testbench();
  logic        clk;
  logic        reset;
  logic [31:0] WriteData, DataAdr;
  logic        MemWrite;

 
  top dut(clk, reset, WriteData, DataAdr, MemWrite);

  
  initial begin
    reset <= 1; # 22; reset <= 0;
  end

 
  always begin
    clk <= 1; # 5; clk <= 0; # 5;
  end

 
  always @(negedge clk) begin
    if(MemWrite) begin
      if(DataAdr === 100 & WriteData === 25) begin
        $display("Simulation succeeded");
        $stop;
      end else if (DataAdr !== 96) begin
        $display("Simulation failed");
        $stop;
      end
    end
  end
endmodule

module top(input  logic        clk, reset, 
           output logic [31:0] WriteData, DataAdr, 
           output logic        MemWrite);

  logic [31:0] PC, Instr, ReadData;
  

  riscvsingle rvsingle(clk, reset, PC, Instr, MemWrite, DataAdr, 
                       WriteData, ReadData);
  imem imem(PC, Instr);
  dmem dmem(clk, MemWrite, DataAdr, WriteData, ReadData);
endmodule

module riscvsingle(input  logic        clk, reset,
                   output logic [31:0] PC,
                   input  logic [31:0] Instr,
                   output logic        MemWrite,
                   output logic [31:0] ALUResult, WriteData,
                   input  logic [31:0] ReadData);

  logic       PCSrc, ALUSrc, RegWrite, Jump, Zero;
  logic [1:0] ResultSrc, ImmSrc;
  logic [3:0] ALUControl;

  controller c(Instr[6:0], Instr[14:12], Instr[31:25], Zero,
               ResultSrc, MemWrite, PCSrc,
               ALUSrc, RegWrite, Jump,
               ImmSrc, ALUControl);
  
  datapath dp(clk, reset, ResultSrc, PCSrc,
              ALUSrc, RegWrite,
              ImmSrc, ALUControl,
              Zero, PC, Instr,
              ALUResult, WriteData, ReadData);
endmodule

module controller(input  logic [6:0] op,
                  input  logic [2:0] funct3,
                  input  logic [6:0] funct7,
                  input  logic       Zero,
                  output logic [1:0] ResultSrc,
                  output logic       MemWrite,
                  output logic       PCSrc, ALUSrc,
                  output logic       RegWrite, Jump,
                  output logic [1:0] ImmSrc,
                  output logic [3:0] ALUControl);

  logic [1:0] ALUOp;
  logic       Branch;

  maindec md(op, ResultSrc, MemWrite, Branch,
             ALUSrc, RegWrite, Jump, ImmSrc, ALUOp);
             
  aludec  ad(op[5], funct3, funct7, ALUOp, ALUControl);

  assign PCSrc = Branch & Zero | Jump;
endmodule

module maindec(input  logic [6:0] op,
               output logic [1:0] ResultSrc,
               output logic       MemWrite,
               output logic       Branch, ALUSrc,
               output logic       RegWrite, Jump,
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
      default:    controls = 11'bx_xx_x_x_xx_x_xx_x;
    endcase
endmodule

module aludec(input  logic       opb5,
              input  logic [2:0] funct3,
              input  logic [6:0] funct7,
              input  logic [1:0] ALUOp,
              output logic [3:0] ALUControl);

  logic RtypeSub;
  assign RtypeSub = funct7[5] & opb5;

  always_comb
    case(ALUOp)
      2'b00: ALUControl = 4'b0000; // addition (lw/sw)
      2'b01: ALUControl = 4'b0001; // subtraction (beq)
      2'b10:
        case(funct3)
          3'b000: ALUControl = RtypeSub ? 4'b0001 : 4'b0000; // sub/add
          3'b010: ALUControl = 4'b0101; // slt/slti
          3'b110: ALUControl = 4'b0011; // or/ori
          3'b111: ALUControl = 4'b0010; // and/andi
          default: ALUControl = 4'bxxxx;
        endcase
      2'b11: // RVX10
        case(funct7)
          7'b0000000:
            case(funct3)
              3'b000: ALUControl = 4'b1000; // ANDN
              3'b001: ALUControl = 4'b1001; // ORN
              3'b010: ALUControl = 4'b1010; // XNOR
              default: ALUControl = 4'bxxxx;
            endcase
          7'b0000001:
            case(funct3)
              3'b000: ALUControl = 4'b1011; // MIN
              3'b001: ALUControl = 4'b1100; // MAX
              3'b010: ALUControl = 4'b1101; // MINU
              3'b011: ALUControl = 4'b1110; // MAXU
              default: ALUControl = 4'bxxxx;
            endcase
          7'b0000010:
            case(funct3)
              3'b000: ALUControl = 4'b1111; // ROL
              3'b001: ALUControl = 4'b0110; // ROR
              default: ALUControl = 4'bxxxx;
            endcase
          7'b0000011:
            case(funct3)
              3'b000: ALUControl = 4'b0111; // ABS
              default: ALUControl = 4'bxxxx;
            endcase
          default: ALUControl = 4'bxxxx;
        endcase
      default: ALUControl = 4'bxxxx;
    endcase
endmodule

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

  flopr #(32) pcreg(clk, reset, PCNext, PC);
  adder       pcadd4(PC, 32'd4, PCPlus4);
  adder       pcaddbranch(PC, ImmExt, PCTarget);
  mux2 #(32)  pcmux(PCPlus4, PCTarget, PCSrc, PCNext);
 
  regfile     rf(clk, RegWrite, Instr[19:15], Instr[24:20], 
                 Instr[11:7], Result, SrcA, WriteData);
  extend      ext(Instr[31:7], ImmSrc, ImmExt);

  mux2 #(32)  srcbmux(WriteData, ImmExt, ALUSrc, SrcB);
  alu         alu(SrcA, SrcB, ALUControl, ALUResult, Zero);
  mux3 #(32)  resultmux(ALUResult, ReadData, PCPlus4, ResultSrc, Result);
endmodule

module regfile(input  logic        clk, 
               input  logic        we3, 
               input  logic [ 4:0] a1, a2, a3, 
               input  logic [31:0] wd3, 
               output logic [31:0] rd1, rd2);

  logic [31:0] rf[31:0];

  always_ff @(posedge clk)
    if (we3 & (a3 != 0)) rf[a3] <= wd3;

  assign rd1 = (a1 != 0) ? rf[a1] : 0;
  assign rd2 = (a2 != 0) ? rf[a2] : 0;
endmodule

module adder(input  [31:0] a, b,
             output [31:0] y);
  assign y = a + b;
endmodule

module extend(input  logic [31:7] instr,
              input  logic [1:0]  immsrc,
              output logic [31:0] immext);
  always_comb
    case(immsrc) 
      2'b00:   immext = {{20{instr[31]}}, instr[31:20]}; // I-type
      2'b01:   immext = {{20{instr[31]}}, instr[31:25], instr[11:7]}; // S-type
      2'b10:   immext = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0}; // B-type
      2'b11:   immext = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0}; // J-type
      default: immext = 32'bx;
    endcase             
endmodule

module flopr #(parameter WIDTH = 8)
              (input  logic             clk, reset,
               input  logic [WIDTH-1:0] d, 
               output logic [WIDTH-1:0] q);
  always_ff @(posedge clk, posedge reset)
    if (reset) q <= 0;
    else       q <= d;
endmodule

module mux2 #(parameter WIDTH = 8)
             (input  logic [WIDTH-1:0] d0, d1, 
              input  logic             s, 
              output logic [WIDTH-1:0] y);
  assign y = s ? d1 : d0; 
endmodule

module mux3 #(parameter WIDTH = 8)
             (input  logic [WIDTH-1:0] d0, d1, d2,
              input  logic [1:0]       s, 
              output logic [WIDTH-1:0] y);
  assign y = s[1] ? d2 : (s[0] ? d1 : d0);
endmodule

module imem(input  logic [31:0] a,
            output logic [31:0] rd);
  logic [31:0] RAM[255:0];

  initial
      $readmemh("tests/rvx10.hex", RAM);

  assign rd = RAM[a[31:2]];
endmodule

module dmem(input  logic        clk, we,
            input  logic [31:0] a, wd,
            output logic [31:0] rd);
  logic [31:0] RAM[255:0];

  assign rd = RAM[a[31:2]];

  always_ff @(posedge clk)
    if (we) RAM[a[31:2]] <= wd;
endmodule

module alu(input  logic [31:0] a, b,
           input  logic [3:0]  alucontrol,
           output logic [31:0] result,
           output logic        zero);
           
  logic [4:0] shamt = b[4:0];

  always_comb
    case (alucontrol)
      4'b0000: result = a + b;                                      // add
      4'b0001: result = a - b;                                      // sub
      4'b0010: result = a & b;                                      // and
      4'b0011: result = a | b;                                      // or
      4'b0101: result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0; // slt
      4'b1000: result = a & ~b;                                     // ANDN
      4'b1001: result = a | ~b;                                     // ORN
      4'b1010: result = ~(a ^ b);                                   // XNOR
      4'b1011: result = ($signed(a) < $signed(b)) ? a : b;          // MIN
      4'b1100: result = ($signed(a) > $signed(b)) ? a : b;          // MAX
      4'b1101: result = (a < b) ? a : b;                             // MINU
      4'b1110: result = (a > b) ? a : b;                             // MAXU
      4'b1111: result = (shamt == 0) ? a : ((a << shamt) | (a >> (32 - shamt))); // ROL
      4'b0110: result = (shamt == 0) ? a : ((a >> shamt) | (a << (32 - shamt))); // ROR
      4'b0111: result = a[31] ? -a : a;                             // ABS
      default: result = 32'bx;
    endcase

  assign zero = (result == 32'b0);
endmodule
