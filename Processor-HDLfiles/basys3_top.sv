module basys3_top(
  input  logic        clk,
  input  logic        btnC,
  input  logic        btnR,
  input  logic        btnL,
  output logic [6:0]  seg,
  output logic        dp,
  output logic [3:0]  an,
  output logic [15:0] led
);

  logic        reset;
  logic [31:0] dbg_PCF;
  logic [31:0] dbg_InstrD;
  logic [31:0] dbg_ALUResultE;
  logic        dbg_RegWriteW;
  logic [4:0]  dbg_RdW;
  logic [31:0] dbg_ResultW;
  logic        dbg_MemWriteM;
  logic [31:0] dbg_MemAddrM;
  logic [31:0] dbg_MemDataM;

  localparam int MAX_OUTPUTS = 20;
  logic [8:0] outputs [0:MAX_OUTPUTS-1];
  int unsigned output_cnt;

  int unsigned view_idx;
  logic [8:0] current_val;

  logic [3:0] hundreds, tens, ones;

  localparam int DEBOUNCE_MAX = 5_000_000;
  int unsigned btnR_cnt, btnL_cnt;
  logic        btnR_db, btnL_db;
  logic        btnR_prev, btnL_prev;
  logic        btnR_edge, btnL_edge;

  logic [31:0] prev_PC;
  int unsigned halt_cnt;
  logic        halted;

  logic [3:0] digit3, digit2, digit1, digit0;
  logic [3:0] dp_en;

  assign reset = btnC;

  localparam string CPU_PROGRAM = "C:/Users/dawso/VivadoFiles/Risc-V_Pipelined/program.hex";
  riscv_pipelined #(.PROGRAM(CPU_PROGRAM)) cpu(
    .clk(clk),
    .reset(reset),
    .dbg_PCF(dbg_PCF),
    .dbg_InstrD(dbg_InstrD),
    .dbg_ALUResultE(dbg_ALUResultE),
    .dbg_RegWriteW(dbg_RegWriteW),
    .dbg_RdW(dbg_RdW),
    .dbg_ResultW(dbg_ResultW),
    .dbg_MemWriteM(dbg_MemWriteM),
    .dbg_MemAddrM(dbg_MemAddrM),
    .dbg_MemDataM(dbg_MemDataM)
  );

  always_ff @(posedge clk or posedge reset) begin
    int unsigned addr_int;
    if (reset) begin
      output_cnt <= 0;
      for (int i = 0; i < MAX_OUTPUTS; i++) outputs[i] <= 9'b0;
    end else begin
      if (dbg_MemWriteM) begin
        addr_int = dbg_MemAddrM[7:0];
        if ((addr_int >= 64) && (output_cnt < MAX_OUTPUTS)) begin
          outputs[output_cnt] <= dbg_MemDataM[8:0];
          output_cnt <= output_cnt + 1;
        end
      end
    end
  end

  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      halted   <= 1'b0;
      halt_cnt <= 0;
      prev_PC  <= 32'hFFFFFFFF;
    end else begin
      if (dbg_PCF == prev_PC) begin
        if (halt_cnt < 15) halt_cnt <= halt_cnt + 1;
        if (halt_cnt >= 10) halted <= 1'b1;
      end else begin
        halt_cnt <= 0;
      end
      prev_PC <= dbg_PCF;
    end
  end

  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      btnR_cnt  <= 0;  btnL_cnt  <= 0;
      btnR_db   <= 1'b0; btnL_db <= 1'b0;
      btnR_prev <= 1'b0; btnL_prev <= 1'b0;
      btnR_edge <= 1'b0; btnL_edge <= 1'b0;
    end else begin
      if (btnR == btnR_db) begin
        btnR_cnt <= 0;
      end else if (btnR_cnt == DEBOUNCE_MAX) begin
        btnR_db  <= btnR;
        btnR_cnt <= 0;
      end else begin
        btnR_cnt <= btnR_cnt + 1;
      end

      if (btnL == btnL_db) begin
        btnL_cnt <= 0;
      end else if (btnL_cnt == DEBOUNCE_MAX) begin
        btnL_db  <= btnL;
        btnL_cnt <= 0;
      end else begin
        btnL_cnt <= btnL_cnt + 1;
      end

      btnR_edge <= btnR_db & ~btnR_prev;
      btnL_edge <= btnL_db & ~btnL_prev;
      btnR_prev <= btnR_db;
      btnL_prev <= btnL_db;
    end
  end

  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      view_idx <= 0;
    end else begin
      if (btnR_edge) begin
        if ((output_cnt > 0) && (view_idx < (output_cnt - 1)))
          view_idx <= view_idx + 1;
      end else if (btnL_edge) begin
        if (view_idx > 0) view_idx <= view_idx - 1;
      end
    end
  end

  always_comb begin
    if (output_cnt > 0) current_val = outputs[view_idx];
    else                current_val = 9'b0;
  end

  always_comb begin
    logic [8:0] val;
    val = current_val;

    if (val >= 9'd200) begin
      hundreds = 4'b0010;
      val = val - 9'd200;
    end else if (val >= 9'd100) begin
      hundreds = 4'b0001;
      val = val - 9'd100;
    end else begin
      hundreds = 4'b0000;
    end

    if (val >= 9'd90) begin tens = 4'b1001; val = val - 9'd90;
    end else if (val >= 9'd80) begin tens = 4'b1000; val = val - 9'd80;
    end else if (val >= 9'd70) begin tens = 4'b0111; val = val - 9'd70;
    end else if (val >= 9'd60) begin tens = 4'b0110; val = val - 9'd60;
    end else if (val >= 9'd50) begin tens = 4'b0101; val = val - 9'd50;
    end else if (val >= 9'd40) begin tens = 4'b0100; val = val - 9'd40;
    end else if (val >= 9'd30) begin tens = 4'b0011; val = val - 9'd30;
    end else if (val >= 9'd20) begin tens = 4'b0010; val = val - 9'd20;
    end else if (val >= 9'd10) begin tens = 4'b0001; val = val - 9'd10;
    end else begin tens = 4'b0000;
    end

    ones = val[3:0];
  end

  assign digit3 = 4'hF;
  assign digit2 = (hundreds != 4'd0) ? hundreds : 4'hF;
  assign digit1 = ((hundreds != 4'd0) || (tens != 4'd0)) ? tens : 4'hF;
  assign digit0 = ones;
  assign dp_en  = 4'b0000;

  seg7_driver disp(
    .clk(clk),
    .reset(reset),
    .digit3(digit3),
    .digit2(digit2),
    .digit1(digit1),
    .digit0(digit0),
    .dp_en(dp_en),
    .seg(seg),
    .dp(dp),
    .an(an)
  );

  always_comb begin
    led = 16'b0;
    led[4:0]  = view_idx[4:0];
    led[14]   = (output_cnt > 0);
    led[15]   = halted;
    led[13:5] = 9'b0;
  end

endmodule
