module hazardunit(
  input  logic [4:0] Rs1D,
  input  logic [4:0] Rs2D,
  input  logic       PCSrc,
  input  logic [4:0] Rs1E,
  input  logic [4:0] Rs2E,
  input  logic [4:0] RdE,
  input  logic       ResultSrcE0,
  input  logic [4:0] RdM,
  input  logic       RegWriteM,
  input  logic [4:0] RdW,
  input  logic       RegWriteW,
  output logic       StallF,
  output logic       StallD,
  output logic       FlushD,
  output logic       FlushE,
  output logic [1:0] ForwardAE,
  output logic [1:0] ForwardBE
);
  logic lwStall;

  always_comb begin
    if ((Rs1E == RdM) && (RegWriteM == 1'b1) && (Rs1E != 5'b00000))
      ForwardAE = 2'b10;
    else if ((Rs1E == RdW) && (RegWriteW == 1'b1) && (Rs1E != 5'b00000))
      ForwardAE = 2'b01;
    else
      ForwardAE = 2'b00;

    if ((Rs2E == RdM) && (RegWriteM == 1'b1) && (Rs2E != 5'b00000))
      ForwardBE = 2'b10;
    else if ((Rs2E == RdW) && (RegWriteW == 1'b1) && (Rs2E != 5'b00000))
      ForwardBE = 2'b01;
    else
      ForwardBE = 2'b00;
  end

  assign lwStall = (ResultSrcE0 == 1'b1) && ((Rs1D == RdE) || (Rs2D == RdE));
  assign StallF = lwStall;
  assign StallD = lwStall;
  assign FlushD = PCSrc;
  assign FlushE = lwStall | PCSrc;
endmodule
