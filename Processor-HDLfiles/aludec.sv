module aludec(
  input  logic       opb5,
  input  logic [2:0] funct3,
  input  logic       funct7b5,
  input  logic [1:0] ALUOp,
  output logic [3:0] ALUControl
);
  always_comb begin
    unique case (ALUOp)
      2'b00: ALUControl = 4'b0000;
      2'b01: begin
        unique case (funct3)
          3'b000: ALUControl = 4'b0001;
          3'b001: ALUControl = 4'b0001;
          3'b100: ALUControl = 4'b0101;
          3'b101: ALUControl = 4'b0101;
          3'b110: ALUControl = 4'b0111;
          3'b111: ALUControl = 4'b0111;
          default: ALUControl = 4'bxxxx;
        endcase
      end
      2'b10: begin
        unique case (funct3)
          3'b000: ALUControl = (funct7b5 && opb5) ? 4'b0001 : 4'b0000;
          3'b001: ALUControl = 4'b0010;
          3'b010: ALUControl = 4'b0101;
          3'b011: ALUControl = 4'b0111;
          3'b100: ALUControl = 4'b1000;
          3'b101: ALUControl = (funct7b5 == 1'b0) ? 4'b1010 : 4'b1011;
          3'b110: ALUControl = 4'b1100;
          3'b111: ALUControl = 4'b1110;
          default: ALUControl = 4'bxxxx;
        endcase
      end
      default: ALUControl = 4'bxxxx;
    endcase
  end
endmodule
