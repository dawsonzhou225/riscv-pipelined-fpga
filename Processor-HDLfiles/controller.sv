module controller(
  input  logic [6:0] op,
  input  logic [2:0] funct3,
  input  logic       funct7b5,
  output logic [1:0] ResultSrc,
  output logic       MemWrite,
  output logic [1:0] PCSrc,
  output logic       ALUSrc,
  output logic       RegWrite,
  output logic [2:0] ImmSrc,
  output logic [1:0] PCTargetSel,
  output logic [1:0] MemSel,
  output logic       SignExtEn,
  output logic [3:0] ALUControl
);
  logic [1:0] ALUOp;

  maindec md(
    .op(op), .funct3(funct3), .PCSrc(PCSrc), .ResultSrc(ResultSrc),
    .MemWrite(MemWrite), .ALUSrc(ALUSrc), .RegWrite(RegWrite), .ImmSrc(ImmSrc),
    .PCTargetSel(PCTargetSel), .MemSel(MemSel), .SignExtEn(SignExtEn), .ALUOp(ALUOp)
  );

  aludec ad(
    .opb5(op[5]), .funct3(funct3), .funct7b5(funct7b5), .ALUOp(ALUOp), .ALUControl(ALUControl)
  );
endmodule
