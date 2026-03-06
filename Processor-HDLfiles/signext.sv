module signext(
  input  logic [31:0] DataIn,
  input  logic [1:0]  MemSel,
  input  logic        SignExtEn,
  output logic [31:0] DataOut
);
  always_comb begin
    if (SignExtEn) begin
      unique case (MemSel)
        2'b00: DataOut = {{24{DataIn[7]}},  DataIn[7:0]};
        2'b01: DataOut = {{16{DataIn[15]}}, DataIn[15:0]};
        2'b10: DataOut = DataIn;
        default: DataOut = 32'hxxxxxxxx;
      endcase
    end else begin
      unique case (MemSel)
        2'b00, 2'b01, 2'b10: DataOut = DataIn;
        default: DataOut = 32'hxxxxxxxx;
      endcase
    end
  end
endmodule
