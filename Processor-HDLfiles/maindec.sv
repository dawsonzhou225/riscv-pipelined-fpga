module maindec(
  input  logic [6:0] op,
  input  logic [2:0] funct3,
  output logic [1:0] PCSrc,
  output logic [1:0] ResultSrc,
  output logic       MemWrite,
  output logic       ALUSrc,
  output logic       RegWrite,
  output logic [2:0] ImmSrc,
  output logic [1:0] PCTargetSel,
  output logic [1:0] MemSel,
  output logic       SignExtEn,
  output logic [1:0] ALUOp
);
  logic [16:0] controls;
  logic        Branch, BranchEq, Jump;

  always_comb begin
    unique case (op)
      7'b0000011: begin
        if      (funct3 == 3'b000) controls = 17'b10100000000110000;
        else if (funct3 == 3'b100) controls = 17'b10000000000110000;
        else if (funct3 == 3'b001) controls = 17'b10101000000110000;
        else if (funct3 == 3'b101) controls = 17'b10001000000110000;
        else if (funct3 == 3'b010) controls = 17'b10010000000110000;
        else                       controls = 17'bxxxxxxxxxxxxxxxxx;
      end
      7'b0100011: begin
        if      (funct3 == 3'b000) controls = 17'b01000000010010000;
        else if (funct3 == 3'b001) controls = 17'b01001000010010000;
        else if (funct3 == 3'b010) controls = 17'b01010000010010000;
        else                       controls = 17'bxxxxxxxxxxxxxxxxx;
      end
      7'b0110011: controls = 17'b10000000000001000;
      7'b1100011: controls = 17'b00000000100000110;
      7'b0010011: begin
        if ((funct3 == 3'b001) || (funct3 == 3'b101))
          controls = 17'b10000001010011000;
        else
          controls = 17'b10000000000011000;
      end
      7'b1101111: controls = 17'b10000000111000001;
      7'b1100111: begin
        if (funct3 == 3'b000) controls = 17'b10000010001000001;
        else                  controls = 17'b00000000000000000;
      end
      7'b0110111: controls = 17'b10000101001100000;
      7'b0010111: controls = 17'b10000001001100000;
      default:    controls = 17'b00000000000000000;
    endcase
  end

  always_comb begin
    unique case (funct3)
      3'd0: BranchEq = 1'b1;
      3'd1: BranchEq = 1'b0;
      3'd4: BranchEq = 1'b0;
      3'd5: BranchEq = 1'b1;
      3'd6: BranchEq = 1'b0;
      3'd7: BranchEq = 1'b1;
      default: BranchEq = 1'b0;
    endcase
  end

  assign RegWrite    = controls[16];
  assign MemWrite    = controls[15];
  assign SignExtEn   = controls[14];
  assign MemSel      = controls[13:12];
  assign PCTargetSel = controls[11:10];
  assign ImmSrc      = controls[9:7];
  assign ResultSrc   = controls[6:5];
  assign ALUSrc      = controls[4];
  assign ALUOp       = controls[3:2];
  assign Branch      = controls[1];
  assign Jump        = controls[0];

  assign PCSrc = { (Jump | (BranchEq & Branch)),
                   (Jump | (~BranchEq & Branch)) };
endmodule
