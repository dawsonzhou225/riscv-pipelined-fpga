module riscv_pipelined #(
  parameter string PROGRAM = "program.hex"
)(
  input  logic        clk,
  input  logic        reset,
  output logic [31:0] dbg_PCF,
  output logic [31:0] dbg_InstrD,
  output logic [31:0] dbg_ALUResultE,
  output logic        dbg_RegWriteW,
  output logic [4:0]  dbg_RdW,
  output logic [31:0] dbg_ResultW,
  output logic        dbg_MemWriteM,
  output logic [31:0] dbg_MemAddrM,
  output logic [31:0] dbg_MemDataM
);

  logic [31:0] PCF, PCFprime;
  logic [31:0] PCPlus4F, InstrF;
  logic [31:0] InstrD, PCD;
  logic [31:0] PCPlus4D;
  logic [31:0] RD1D, RD2D;
  logic [31:0] ImmExtD;
  logic [4:0] Rs1D, Rs2D, RdD;
  logic RegWriteD;
  logic [1:0] ResultSrcD;
  logic MemWriteD;
  logic ALUSrcD;
  logic [3:0] ALUControlD;
  logic [2:0] ImmSrcD;
  logic [1:0] PCSrcD;
  logic [1:0] PCTargetSelD;
  logic [1:0] MemSelD;
  logic SignExtEnD;
  logic [31:0] RD1E, RD2E;
  logic [31:0] PCE, PCPlus4E;
  logic [31:0] ImmExtE;
  logic [31:0] SrcAE, SrcBE;
  logic [31:0] WriteDataE;
  logic [31:0] ALUResultE;
  logic [31:0] PCTargetE;
  logic [31:0] PCTargetLeftE;
  logic [4:0] Rs1E, Rs2E, RdE;
  logic ZeroE, LessE;
  logic PCSrcBranch;
  logic RegWriteE;
  logic [1:0] ResultSrcE;
  logic MemWriteE;
  logic ALUSrcE;
  logic [3:0] ALUControlE;
  logic [1:0] PCSrcE;
  logic [1:0] PCTargetSelE;
  logic [1:0] MemSelE;
  logic SignExtEnE;
  logic [31:0] ALUResultM;
  logic [31:0] WriteDataM;
  logic [31:0] PCPlus4M;
  logic [31:0] PCTargetM;
  logic [31:0] ReadDataM_raw;
  logic [31:0] ReadDataM;
  logic [4:0] RdM;
  logic RegWriteM;
  logic [1:0] ResultSrcM;
  logic MemWriteM;
  logic [1:0] MemSelM;
  logic SignExtEnM;
  logic [31:0] ALUResultW;
  logic [31:0] ReadDataW;
  logic [31:0] PCPlus4W;
  logic [31:0] PCTargetW;
  logic [4:0] RdW;
  logic [31:0] ResultW;
  logic RegWriteW;
  logic [1:0] ResultSrcW;
  logic StallF, StallD;
  logic FlushD, FlushE;
  logic [1:0] ForwardAE;
  logic [1:0] ForwardBE;
  logic NotStallF;
  logic NotStallD;
  logic [15:0] CtrlD_pack, CtrlE_pack;
  logic [6:0] CtrlEM_in, CtrlEM_out;
  logic [2:0] CtrlMW_in, CtrlMW_out;

  assign NotStallF = ~StallF;
  assign NotStallD = ~StallD;
  assign Rs1D = InstrD[19:15];
  assign Rs2D = InstrD[24:20];
  assign RdD  = InstrD[11:7];
  assign CtrlD_pack = {RegWriteD, ResultSrcD, MemWriteD, ALUSrcD, ALUControlD, PCSrcD, PCTargetSelD, MemSelD, SignExtEnD};
  assign RegWriteE    = CtrlE_pack[15];
  assign ResultSrcE   = CtrlE_pack[14:13];
  assign MemWriteE    = CtrlE_pack[12];
  assign ALUSrcE      = CtrlE_pack[11];
  assign ALUControlE  = CtrlE_pack[10:7];
  assign PCSrcE       = CtrlE_pack[6:5];
  assign PCTargetSelE = CtrlE_pack[4:3];
  assign MemSelE      = CtrlE_pack[2:1];
  assign SignExtEnE   = CtrlE_pack[0];
  assign CtrlEM_in = {RegWriteE, ResultSrcE, MemWriteE, MemSelE, SignExtEnE};
  assign RegWriteM  = CtrlEM_out[6];
  assign ResultSrcM = CtrlEM_out[5:4];
  assign MemWriteM  = CtrlEM_out[3];
  assign MemSelM    = CtrlEM_out[2:1];
  assign SignExtEnM = CtrlEM_out[0];
  assign CtrlMW_in = {RegWriteM, ResultSrcM};
  assign RegWriteW  = CtrlMW_out[2];
  assign ResultSrcW = CtrlMW_out[1:0];
  assign dbg_PCF        = PCF;
  assign dbg_InstrD     = InstrD;
  assign dbg_ALUResultE = ALUResultE;
  assign dbg_RegWriteW  = RegWriteW;
  assign dbg_RdW        = RdW;
  assign dbg_ResultW    = ResultW;
  assign dbg_MemWriteM  = MemWriteM;
  assign dbg_MemAddrM   = ALUResultM;
  assign dbg_MemDataM   = WriteDataM;

  mux2 #(.WIDTH(32)) pc_mux ( .d0(PCPlus4F), .d1(PCTargetE), .s(PCSrcBranch), .y(PCFprime) );
  enflopr #(.WIDTH(32)) pc_reg ( .clk(clk), .reset(reset), .clr(1'b0), .en(NotStallF), .d(PCFprime), .q(PCF) );
  imem #(.PROGRAM(PROGRAM)) i_mem ( .a(PCF), .rd(InstrF) );
  adder pc_add4 ( .a(PCF), .b(32'h00000004), .y(PCPlus4F) );
  enflopr #(.WIDTH(32)) fd_instr ( .clk(clk), .reset(reset), .clr(FlushD), .en(NotStallD), .d(InstrF), .q(InstrD) );
  enflopr #(.WIDTH(32)) fd_pc ( .clk(clk), .reset(reset), .clr(FlushD), .en(NotStallD), .d(PCF), .q(PCD) );
  enflopr #(.WIDTH(32)) fd_pcp4 ( .clk(clk), .reset(reset), .clr(FlushD), .en(NotStallD), .d(PCPlus4F), .q(PCPlus4D) );
  regfile rf ( .clk(clk), .reset(reset), .we3(RegWriteW), .a1(Rs1D), .a2(Rs2D), .a3(RdW), .wd3(ResultW), .rd1(RD1D), .rd2(RD2D) );
  controller ctrl ( .op(InstrD[6:0]), .funct3(InstrD[14:12]), .funct7b5(InstrD[30]), .ResultSrc(ResultSrcD), .MemWrite(MemWriteD), .PCSrc(PCSrcD), .ALUSrc(ALUSrcD), .RegWrite(RegWriteD), .ImmSrc(ImmSrcD), .PCTargetSel(PCTargetSelD), .MemSel(MemSelD), .SignExtEn(SignExtEnD), .ALUControl(ALUControlD) );
  extend ext ( .instr(InstrD[31:7]), .immsrc(ImmSrcD), .immext(ImmExtD) );

  // D->E pipeline registers (data)
  enflopr #(.WIDTH(32)) de_rd1    ( .clk(clk), .reset(reset), .clr(FlushE), .en(1'b1), .d(RD1D),      .q(RD1E) );
  enflopr #(.WIDTH(32)) de_rd2    ( .clk(clk), .reset(reset), .clr(FlushE), .en(1'b1), .d(RD2D),      .q(RD2E) );
  enflopr #(.WIDTH(32)) de_pc     ( .clk(clk), .reset(reset), .clr(FlushE), .en(1'b1), .d(PCD),       .q(PCE) );
  enflopr #(.WIDTH(32)) de_immext ( .clk(clk), .reset(reset), .clr(FlushE), .en(1'b1), .d(ImmExtD),   .q(ImmExtE) );
  enflopr #(.WIDTH(32)) de_pcp4   ( .clk(clk), .reset(reset), .clr(FlushE), .en(1'b1), .d(PCPlus4D),  .q(PCPlus4E) );
  enflopr #(.WIDTH(5))  de_rs1    ( .clk(clk), .reset(reset), .clr(FlushE), .en(1'b1), .d(Rs1D),      .q(Rs1E) );
  enflopr #(.WIDTH(5))  de_rs2    ( .clk(clk), .reset(reset), .clr(FlushE), .en(1'b1), .d(Rs2D),      .q(Rs2E) );
  enflopr #(.WIDTH(5))  de_rd     ( .clk(clk), .reset(reset), .clr(FlushE), .en(1'b1), .d(RdD),       .q(RdE) );

  // D->E pipeline register (control)
  enflopr #(.WIDTH(16)) de_ctrl   ( .clk(clk), .reset(reset), .clr(FlushE), .en(1'b1), .d(CtrlD_pack), .q(CtrlE_pack) );

  mux3 #(.WIDTH(32)) fwd_mux_a ( .d0(RD1E), .d1(ResultW), .d2(ALUResultM), .s(ForwardAE), .y(SrcAE) );
  mux3 #(.WIDTH(32)) fwd_mux_b ( .d0(RD2E), .d1(ResultW), .d2(ALUResultM), .s(ForwardBE), .y(WriteDataE) );
  mux2 #(.WIDTH(32)) alusrc_mux ( .d0(WriteDataE), .d1(ImmExtE), .s(ALUSrcE), .y(SrcBE) );
  alu alu_unit ( .a(SrcAE), .b(SrcBE), .ALUControl(ALUControlE), .ALUResult(ALUResultE), .Zero(ZeroE), .Less(LessE) );
  mux3 #(.WIDTH(32)) pctarget_mux ( .d0(PCE), .d1(SrcAE), .d2(32'h00000000), .s(PCTargetSelE), .y(PCTargetLeftE) );
  adder pctarget_add ( .a(PCTargetLeftE), .b(ImmExtE), .y(PCTargetE) );
  branchunit branch_unit ( .PCSrcE(PCSrcE), .zero(ZeroE), .less(LessE), .PCSrc(PCSrcBranch) );

  // E->M pipeline registers (data)
  flopr #(.WIDTH(32)) em_aluresult ( .clk(clk), .reset(reset), .d(ALUResultE), .q(ALUResultM) );
  flopr #(.WIDTH(32)) em_writedata ( .clk(clk), .reset(reset), .d(WriteDataE), .q(WriteDataM) );
  flopr #(.WIDTH(32)) em_pcp4      ( .clk(clk), .reset(reset), .d(PCPlus4E),   .q(PCPlus4M) );
  flopr #(.WIDTH(32)) em_pctarget  ( .clk(clk), .reset(reset), .d(PCTargetE),  .q(PCTargetM) );
  flopr #(.WIDTH(5))  em_rd        ( .clk(clk), .reset(reset), .d(RdE),        .q(RdM) );

  // E->M pipeline register (control)
  flopr #(.WIDTH(7))  em_ctrl      ( .clk(clk), .reset(reset), .d(CtrlEM_in),  .q(CtrlEM_out) );

  dmem d_mem ( .clk(clk), .we(MemWriteM), .sel(MemSelM), .a(ALUResultM), .wd(WriteDataM), .rd(ReadDataM_raw) );
  signext sext ( .DataIn(ReadDataM_raw), .MemSel(MemSelM), .SignExtEn(SignExtEnM), .DataOut(ReadDataM) );

  // M->W pipeline registers (data)
  flopr #(.WIDTH(32)) mw_aluresult ( .clk(clk), .reset(reset), .d(ALUResultM), .q(ALUResultW) );
  flopr #(.WIDTH(32)) mw_readdata  ( .clk(clk), .reset(reset), .d(ReadDataM),  .q(ReadDataW) );
  flopr #(.WIDTH(32)) mw_pcp4      ( .clk(clk), .reset(reset), .d(PCPlus4M),   .q(PCPlus4W) );
  flopr #(.WIDTH(32)) mw_pctarget  ( .clk(clk), .reset(reset), .d(PCTargetM),  .q(PCTargetW) );
  flopr #(.WIDTH(5))  mw_rd        ( .clk(clk), .reset(reset), .d(RdM),        .q(RdW) );

  // M->W pipeline register (control)
  flopr #(.WIDTH(3))  mw_ctrl      ( .clk(clk), .reset(reset), .d(CtrlMW_in),  .q(CtrlMW_out) );

  mux4 #(.WIDTH(32)) result_mux ( .d0(ALUResultW), .d1(ReadDataW), .d2(PCPlus4W), .d3(PCTargetW), .s(ResultSrcW), .y(ResultW) );
  hazardunit hu ( .Rs1D(Rs1D), .Rs2D(Rs2D), .PCSrc(PCSrcBranch), .Rs1E(Rs1E), .Rs2E(Rs2E), .RdE(RdE), .ResultSrcE0(ResultSrcE[0]), .RdM(RdM), .RegWriteM(RegWriteM), .RdW(RdW), .RegWriteW(RegWriteW), .StallF(StallF), .StallD(StallD), .FlushD(FlushD), .FlushE(FlushE), .ForwardAE(ForwardAE), .ForwardBE(ForwardBE) );

endmodule
