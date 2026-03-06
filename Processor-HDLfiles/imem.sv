module imem #(parameter string PROGRAM = "program.hex")(
  input  logic [31:0] a,
  output logic [31:0] rd
);
  logic [31:0] imem_s [0:127];

  initial begin
    $readmemh(PROGRAM, imem_s);
  end

  always_comb rd = imem_s[a[8:2]];
endmodule
