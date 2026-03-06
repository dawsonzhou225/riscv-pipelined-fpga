module regfile(
  input  logic        clk,
  input  logic        reset,
  input  logic        we3,
  input  logic [4:0]  a1,
  input  logic [4:0]  a2,
  input  logic [4:0]  a3,
  input  logic [31:0] wd3,
  output logic [31:0] rd1,
  output logic [31:0] rd2
);
  logic [31:0] mem [31:0];
  integer i;

  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      for (i = 0; i < 32; i++) mem[i] <= 32'b0;
    end else begin
      if (we3) mem[a3] <= wd3;
    end
  end

  always_comb begin
    if (a1 == 5'd0) rd1 = 32'h00000000;
    else if (we3 && (a1 == a3)) rd1 = wd3;
    else rd1 = mem[a1];

    if (a2 == 5'd0) rd2 = 32'h00000000;
    else if (we3 && (a2 == a3)) rd2 = wd3;
    else rd2 = mem[a2];
  end
endmodule
