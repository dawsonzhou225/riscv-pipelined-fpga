module branchunit(
  input  logic [1:0] PCSrcE,
  input  logic       zero,
  input  logic       less,
  output logic       PCSrc
);
  always_comb begin
    if ((PCSrcE == 2'b11) ||
        (PCSrcE == 2'b10 && zero == 1'b1) ||
        (PCSrcE == 2'b01 && less == 1'b1))
      PCSrc = 1'b1;
    else
      PCSrc = 1'b0;
  end
endmodule
