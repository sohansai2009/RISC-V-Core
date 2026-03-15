// MEM/WB Pipeline Register
// Flush on: reset
// Freeze on: d_cache_busy
// Normal:    latch all inputs

module mem_wb_pipeline (
  input  logic        clk,
  input  logic        reset_n,
  input  logic [31:0] mem_data,             // load data from d-cache
  input  logic        mem_rf_wr_en,         // reg file write enable
  input  logic [1:0]  mem_rf_wr_data,       // what data to write back
  input  logic        mem_wb_instr_valid_in, // valid from mem stage
  input  logic [31:0] ex_result_in,         // ALU result
  input  logic [31:0] imm_in,               // immediate value
  input  logic [31:0] pc_mem,               // PC value
  input  logic [4:0]  wb_rd_addr_in,        // destination register
  input  logic        d_cache_busy,         // FREEZE signal

  output logic [31:0] wb_mem_data_out,      // load data to reg file
  output logic        wb_rf_wr_en,
  output logic [1:0]  wb_rf_wr_data,
  output logic [31:0] wb_ex_result_in,      // ALU result to reg file
  output logic [31:0] wb_imm,
  output logic [31:0] wb_pc,
  output logic [4:0]  wb_rd_addr_out,
  output logic        instr_ready_to_retire  // retire signal to reg file
);

  always_ff @(posedge clk)
  begin
    if (!reset_n) begin
      // FLUSH — clear all pipeline registers
      wb_mem_data_out        <= 0;
      wb_rf_wr_en            <= 0;
      wb_rf_wr_data          <= 0;
      wb_ex_result_in        <= 0;
      wb_imm                 <= 0;
      wb_pc                  <= 0;
      wb_rd_addr_out         <= 0;
      instr_ready_to_retire  <= 0;
    end
    else if (d_cache_busy) begin
      // FLUSH — d-cache miss, insert NOP into WB stage
      // The instruction is still in the MEM stage waiting for d-cache.
      // We must NOT commit it here — flush WB to prevent false retirement.
      // IF/ID, ID/EX, EX/MEM are all FROZEN upstream to preserve the
      // in-flight instruction. Only MEM/WB is flushed.
      wb_mem_data_out        <= 0;
      wb_rf_wr_en            <= 0;
      wb_rf_wr_data          <= 0;
      wb_ex_result_in        <= 0;
      wb_imm                 <= 0;
      wb_pc                  <= 0;
      wb_rd_addr_out         <= 0;
      instr_ready_to_retire  <= 0;  // do NOT retire while cache is busy
    end
    else begin
      // Normal operation — latch all inputs
      wb_mem_data_out        <= mem_data;
      wb_rf_wr_en            <= mem_rf_wr_en;
      wb_rf_wr_data          <= mem_rf_wr_data;
      wb_ex_result_in        <= ex_result_in;
      wb_imm                 <= imm_in;
      wb_pc                  <= pc_mem;
      wb_rd_addr_out         <= wb_rd_addr_in;
      instr_ready_to_retire  <= mem_wb_instr_valid_in;
    end
  end

endmodule
