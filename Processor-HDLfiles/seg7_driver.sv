module seg7_driver #(parameter int CLK_FREQ = 100_000_000)(
  input  logic       clk,
  input  logic       reset,
  input  logic [3:0] digit3,
  input  logic [3:0] digit2,
  input  logic [3:0] digit1,
  input  logic [3:0] digit0,
  input  logic [3:0] dp_en,
  output logic [6:0] seg,
  output logic       dp,
  output logic [3:0] an
);
  localparam int REFRESH_MAX = CLK_FREQ / 4000;
  int unsigned refresh_cnt;
  logic [1:0]  digit_sel;
  logic [3:0]  current_digit;
  logic        current_dp;

  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      refresh_cnt <= 0;
      digit_sel   <= 2'b00;
    end else begin
      if (refresh_cnt == REFRESH_MAX) begin
        refresh_cnt <= 0;
        digit_sel   <= digit_sel + 2'd1;
      end else begin
        refresh_cnt <= refresh_cnt + 1;
      end
    end
  end

  always_comb begin
    unique case (digit_sel)
      2'b00: begin an = 4'b1110; current_digit = digit0; current_dp = dp_en[0]; end
      2'b01: begin an = 4'b1101; current_digit = digit1; current_dp = dp_en[1]; end
      2'b10: begin an = 4'b1011; current_digit = digit2; current_dp = dp_en[2]; end
      default: begin an = 4'b0111; current_digit = digit3; current_dp = dp_en[3]; end
    endcase
  end

  always_comb begin
    unique case (current_digit)
      4'b0000: seg = 7'b1000000;
      4'b0001: seg = 7'b1111001;
      4'b0010: seg = 7'b0100100;
      4'b0011: seg = 7'b0110000;
      4'b0100: seg = 7'b0011001;
      4'b0101: seg = 7'b0010010;
      4'b0110: seg = 7'b0000010;
      4'b0111: seg = 7'b1111000;
      4'b1000: seg = 7'b0000000;
      4'b1001: seg = 7'b0010000;
      4'b1111: seg = 7'b1111111;
      default: seg = 7'b1111111;
    endcase
  end

  assign dp = ~current_dp;
endmodule
