// EX/MEM Pipeline Register
// Flush on: reset
// Freeze on: d_cache_busy (~ex_mem_en)
// Normal:    latch all inputs

module ex_mem_pipeline (
  input  logic        clk, reset_n,
  input  logic [31:0] ex_result,        // ALU result
  input  logic [1:0]  ex_wb_rf_wr_data,
  input  logic        mem_data_req,
  input  logic [1:0]  mem_data_type,
  input  logic        mem_data_wr,
  input  logic        mem_zero_extnd,
  input  logic        wb_rf_wr_en,
  input  logic        ex_mem_en,        // FREEZE when LOW (d_cache_busy)
  input  logic [31:0] imm_dec_in,
  input  logic [31:0] pc_ex,
  input  logic [4:0]  ex_rd_addr,
  input  logic [31:0] ex_mem_wr_data,   // rs2 value for sw
  input  logic        ex_l_type,
  input  logic        ex_mem_instr_valid_in,  // valid from execute stage

  output logic [31:0] ex_result_o,
  output logic [1:0]  mem_wb_rf_wr_data,
  output logic        mem_data_req_o,
  output logic [1:0]  mem_data_type_o,
  output logic        mem_data_wr_o,
  output logic        mem_zero_extnd_o,
  output logic        wb_rf_wr_en_o,
  output logic [31:0] imm_dec_out,
  output logic [31:0] pc_mem,
  output logic [4:0]  ex_rd_addr_out,
  output logic [31:0] mem_wr_data,
  output logic        ex_mem_l_type_out,
  output logic        ex_mem_instr_valid_out  // valid to mem stage
);

  // l_type is combinational — reset to 0 when reset asserted
  assign ex_mem_l_type_out = (!reset_n) ? 0 : ex_l_type;

  always_ff @(posedge clk)
  begin
    if (!reset_n) begin
      // FLUSH — clear all pipeline registers
      ex_result_o             <= 0;
      mem_wb_rf_wr_data       <= 0;
      mem_data_req_o          <= 0;
      mem_data_type_o         <= 0;
      mem_data_wr_o           <= 0;
      mem_zero_extnd_o        <= 0;
      wb_rf_wr_en_o           <= 0;
      imm_dec_out             <= 0;
      pc_mem                  <= 0;
      ex_rd_addr_out          <= 0;
      mem_wr_data             <= 0;
      ex_mem_instr_valid_out  <= 0;
    end
    else if (!ex_mem_en) begin
      // FREEZE — d_cache_busy, hold all pipeline register values
      ex_result_o             <= ex_result_o;
      mem_wb_rf_wr_data       <= mem_wb_rf_wr_data;
      mem_data_req_o          <= mem_data_req_o;
      mem_data_type_o         <= mem_data_type_o;
      mem_data_wr_o           <= mem_data_wr_o;
      mem_zero_extnd_o        <= mem_zero_extnd_o;
      wb_rf_wr_en_o           <= wb_rf_wr_en_o;
      imm_dec_out             <= imm_dec_out;
      pc_mem                  <= pc_mem;
      ex_rd_addr_out          <= ex_rd_addr_out;
      mem_wr_data             <= mem_wr_data;
      ex_mem_instr_valid_out  <= ex_mem_instr_valid_out;
    end
    else begin
      // Normal operation — latch all inputs
      ex_result_o             <= ex_result;
      mem_wb_rf_wr_data       <= ex_wb_rf_wr_data;
      mem_data_req_o          <= mem_data_req;
      mem_data_type_o         <= mem_data_type;
      mem_data_wr_o           <= mem_data_wr;
      mem_zero_extnd_o        <= mem_zero_extnd;
      wb_rf_wr_en_o           <= wb_rf_wr_en;
      imm_dec_out             <= imm_dec_in;
      pc_mem                  <= pc_ex;
      ex_rd_addr_out          <= ex_rd_addr;
      mem_wr_data             <= ex_mem_wr_data;
      ex_mem_instr_valid_out  <= ex_mem_instr_valid_in;
    end
  end

endmodule
