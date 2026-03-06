module mux3 #(parameter int WIDTH = 8)(
  input  logic [WIDTH-1:0] d0,
  input  logic [WIDTH-1:0] d1,
  input  logic [WIDTH-1:0] d2,
  input  logic [1:0]       s,
  output logic [WIDTH-1:0] y
);
  always_comb begin
    if      (s == 2'b00) y = d0;
    else if (s == 2'b01) y = d1;
    else if (s == 2'b10) y = d2;
    else                 y = {WIDTH{1'b0}};
  end
endmodule
