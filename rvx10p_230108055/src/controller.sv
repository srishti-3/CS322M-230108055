
module controller(input logic [6:0] opcode,
                  output logic RegWrite, MemWrite, MemToReg, ALUSrc, Branch, Jump,
                  output logic [1:0] ALUOp, ImmSrc, ResultSrc);
  always_comb begin
    // defaults
    RegWrite = 0; MemWrite = 0; MemToReg = 0; ALUSrc = 0; Branch = 0; Jump = 0;
    ALUOp = 2'b00; ImmSrc = 2'b00; ResultSrc = 2'b00;
    case (opcode)
      7'b0000011: begin 
        RegWrite = 1; ALUSrc = 1; MemToReg = 1; ResultSrc = 2'b01; ImmSrc = 2'b00; ALUOp = 2'b00;
      end
      7'b0100011: begin 
        MemWrite = 1; ALUSrc = 1; ImmSrc = 2'b01; ALUOp = 2'b00;
      end
      7'b0110011: begin 
        RegWrite = 1; ALUSrc = 0; ALUOp = 2'b10; ImmSrc = 2'b00; ResultSrc = 2'b00;
      end
      7'b0010011: begin 
        RegWrite = 1; ALUSrc = 1; ALUOp = 2'b10; ImmSrc = 2'b00; ResultSrc = 2'b00;
      end
      7'b1100011: begin 
        Branch = 1; ALUOp = 2'b01; ImmSrc = 2'b10;
      end
      7'b1101111: begin 
        RegWrite = 1; Jump = 1; ResultSrc = 2'b10; ImmSrc = 2'b11;
      end
      7'b1100111: begin 
        RegWrite = 1; Jump = 1; ALUSrc = 1; ResultSrc = 2'b10; ImmSrc = 2'b00; ALUOp = 2'b00;
      end
      7'b0001011: begin 
        RegWrite = 1; ALUSrc = 0; ALUOp = 2'b10; ImmSrc = 2'b00;
      end
      default: ;
    endcase
  end
endmodule
