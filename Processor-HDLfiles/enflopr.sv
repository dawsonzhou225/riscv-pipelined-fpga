module enflopr #(parameter int WIDTH = 1)(
  input  logic             clk,
  input  logic             reset,
  input  logic             clr,
  input  logic             en,
  input  logic [WIDTH-1:0] d,
  output logic [WIDTH-1:0] q
);
  always_ff @(posedge clk or posedge reset) begin
    if (reset)       q <= '0;
    else if (clr)    q <= '0;
    else if (en)     q <= d;
    else             q <= q;
  end
endmodule
