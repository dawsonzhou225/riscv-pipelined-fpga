module mux2 #(parameter int WIDTH = 8)(
  input  logic [WIDTH-1:0] d0,
  input  logic [WIDTH-1:0] d1,
  input  logic             s,
  output logic [WIDTH-1:0] y
);
  always_comb begin
    if      (s == 1'b1) y = d1;
    else if (s == 1'b0) y = d0;
    else                y = {WIDTH{1'bx}};
  end
endmodule
