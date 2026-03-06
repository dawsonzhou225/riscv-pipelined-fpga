module dmem #(parameter int ADDR_WIDTH = 8)(
  input  logic        clk,
  input  logic        we,
  input  logic [1:0]  sel,
  input  logic [31:0] a,
  input  logic [31:0] wd,
  output logic [31:0] rd
);
  logic [7:0] dmem_s [0:(1<<ADDR_WIDTH)-1];
  int unsigned addr;

  always_ff @(posedge clk) begin
    addr = a[ADDR_WIDTH-1:0];
    if (we) begin
      if (sel == 2'b00) begin
        dmem_s[addr] <= wd[7:0];
      end else if (sel == 2'b01) begin
        dmem_s[addr]     <= wd[7:0];
        dmem_s[addr + 1] <= wd[15:8];
      end else begin
        dmem_s[addr]     <= wd[7:0];
        dmem_s[addr + 1] <= wd[15:8];
        dmem_s[addr + 2] <= wd[23:16];
        dmem_s[addr + 3] <= wd[31:24];
      end
    end
  end

  always_comb begin
    addr = a[ADDR_WIDTH-1:0];
    rd = 32'b0;
    if (sel == 2'b00) begin
      rd[7:0] = dmem_s[addr];
    end else if (sel == 2'b01) begin
      rd[7:0]  = dmem_s[addr];
      rd[15:8] = dmem_s[addr + 1];
    end else begin
      rd[7:0]   = dmem_s[addr];
      rd[15:8]  = dmem_s[addr + 1];
      rd[23:16] = dmem_s[addr + 2];
      rd[31:24] = dmem_s[addr + 3];
    end
  end
endmodule
