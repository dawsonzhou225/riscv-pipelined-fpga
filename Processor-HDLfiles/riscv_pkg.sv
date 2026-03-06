// Auto-translated from VHDL to SystemVerilog (1:1 functionality)
// ============================================================================

package riscv_pkg;
  typedef logic [31:0] word_t;
  typedef word_t ram_type [];

  function automatic logic [3:0] hex_char_to_bits(input byte c);
    unique case (c)
      "0": hex_char_to_bits = 4'h0;
      "1": hex_char_to_bits = 4'h1;
      "2": hex_char_to_bits = 4'h2;
      "3": hex_char_to_bits = 4'h3;
      "4": hex_char_to_bits = 4'h4;
      "5": hex_char_to_bits = 4'h5;
      "6": hex_char_to_bits = 4'h6;
      "7": hex_char_to_bits = 4'h7;
      "8": hex_char_to_bits = 4'h8;
      "9": hex_char_to_bits = 4'h9;
      "a","A": hex_char_to_bits = 4'hA;
      "b","B": hex_char_to_bits = 4'hB;
      "c","C": hex_char_to_bits = 4'hC;
      "d","D": hex_char_to_bits = 4'hD;
      "e","E": hex_char_to_bits = 4'hE;
      "f","F": hex_char_to_bits = 4'hF;
      default: hex_char_to_bits = 4'h0;
    endcase
  endfunction

  function automatic logic [31:0] hex_to_sulv(input string s);
    logic [31:0] v;
    int j;
    v = 32'b0;
    for (j = 0; j < 8; j++) begin
      v[31 - j*4 -: 4] = hex_char_to_bits(s.getc(j));
    end
    return v;
  endfunction
endpackage
