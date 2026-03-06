module extend(
  input  logic [31:7] instr,
  input  logic [2:0]  immsrc,
  output logic [31:0] immext
);
  always_comb begin
    unique case (immsrc)
      3'b000: immext = {{20{instr[31]}}, instr[31:20]};
      3'b001: immext = {{20{instr[31]}}, instr[31:25], instr[11:7]};
      3'b010: immext = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
      3'b011: immext = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
      3'b100: immext = {instr[31:12], 12'b0};
      3'b101: immext = {27'b0, instr[24:20]};
      default: immext = 32'hxxxxxxxx;
    endcase
  end
endmodule
