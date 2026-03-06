module alu(
  input  logic [31:0] a,
  input  logic [31:0] b,
  input  logic [3:0]  ALUControl,
  output logic [31:0] ALUResult,
  output logic        Zero,
  output logic        Less
);
  logic [31:0] sum;
  logic [31:0] ALUResultInt;
  logic        lt;

  assign sum = (ALUControl[0] == 1'b0) ? (a + b) : (a + (~b) + 32'd1);

  assign lt = (ALUControl[1] == 1'b0)
                ? ((a[31] & ~b[31]) | (a[31] & sum[31]) | (~b[31] & sum[31]))
                : (sum[31]);

  always_comb begin
    unique case (ALUControl)
      4'b0000, 4'b0001: ALUResultInt = sum;
      4'b0010:          ALUResultInt = a << b[4:0];
      4'b0101, 4'b0111: ALUResultInt = {31'b0, lt};
      4'b1000:          ALUResultInt = a ^ b;
      4'b1010:          ALUResultInt = a >> b[4:0];
      4'b1011:          ALUResultInt = $signed(a) >>> b[4:0];
      4'b1100:          ALUResultInt = a | b;
      4'b1110:          ALUResultInt = a & b;
      default:          ALUResultInt = 32'hxxxxxxxx;
    endcase
  end

  assign Zero      = (ALUResultInt == 32'h00000000);
  assign Less      = lt;
  assign ALUResult = ALUResultInt;
endmodule
