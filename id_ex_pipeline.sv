// ID/EX Pipeline Register
// Flush on: reset | hazard | i_cache_busy | post_reset_flush  (id_pip_disable)
// Freeze on: d_cache_busy (hold all values)

module id_ex_pipeline(
  input  logic        clk, reset_n,
  input  logic        ctrl_op1_sel, ctrl_op2_sel,
  input  logic [3:0]  ctrl_alu_func,
  input  logic [1:0]  ctrl_rf_wr_data,
  input  logic        ctrl_data_req,
  input  logic [1:0]  ctrl_data_byte,
  input  logic [4:0]  rd_addr,
  input  logic        ctrl_data_wr,
  input  logic        ctrl_zero_extnd,
  input  logic        ctrl_rf_wr_en,
  input  logic [31:0] rf_rs1_data,
  input  logic [31:0] rf_rs2_data,
  input  logic        id_pip_disable,   // FLUSH: hazard | i_cache_busy | post_reset_flush
  input  logic        d_cache_busy,     // FREEZE: hold pipeline values
  input  logic [31:0] imm,
  input  logic [31:0] pc_id,
  input  logic        id_l_type_in,
  input  logic [31:0] id_instr_in,
  input  logic [5:0]  rs1_l_dep,
  input  logic [5:0]  rs2_l_dep,
  input  logic [4:0]  id_rs1_in,
  input  logic [4:0]  id_rs2_in,
  input  logic        rs1_l_dep_in_hazard, rs2_l_dep_in_hazard,
  input  logic        rs1_ex_dep, rs1_mem_dep,
  input  logic        rs2_ex_dep, rs2_mem_dep,
  input  logic        id_ex_instr_valid_in,   // valid from hazard detection

  output logic        ex_op1_sel,
  output logic        ex_op2_sel,
  output logic [3:0]  ex_alu_func,
  output logic [1:0]  wb_rf_wr_data,
  output logic        mem_data_req,
  output logic [1:0]  mem_data_byte,
  output logic        mem_data_wr,
  output logic        mem_zero_extnd,
  output logic        wb_rf_wr_en,
  output logic [31:0] ex_rs1_data,
  output logic [31:0] ex_rs2_data,
  output logic [31:0] imm_o,
  output logic [31:0] pc_ex,
  output logic [4:0]  rd_addr_out,
  output logic        ex_l_type_out,
  output logic [31:0] id_ex_instr_out,
  output logic [5:0]  id_ex_rs1_l_dep_out,
  output logic [5:0]  id_ex_rs2_l_dep_out,
  output logic [4:0]  id_ex_rs1_out,
  output logic [4:0]  id_ex_rs2_out,
  output logic        ex_rs1_l_dep, ex_rs2_l_dep,
  output logic        forward_rs1_ex_mem, forward_rs1_mem_wb,
  output logic        forward_rs2_ex_mem, forward_rs2_mem_wb,
  output logic        id_ex_instr_valid_out  // valid to execute stage
);

  always_ff @(posedge clk)
  begin
    if (!reset_n || id_pip_disable) begin
      // FLUSH — insert NOP / clear all control signals
      ex_op1_sel           <= 0;
      ex_op2_sel           <= 0;
      ex_alu_func          <= 0;
      wb_rf_wr_data        <= 0;
      mem_data_req         <= 0;
      mem_data_byte        <= 0;
      mem_data_wr          <= 0;
      mem_zero_extnd       <= 0;
      wb_rf_wr_en          <= 0;
      ex_rs1_data          <= 0;
      ex_rs2_data          <= 0;
      imm_o                <= 0;
      pc_ex                <= 0;
      rd_addr_out          <= 0;
      ex_l_type_out        <= 0;
      id_ex_instr_out      <= 0;
      ex_rs1_l_dep         <= 0;
      ex_rs2_l_dep         <= 0;
      id_ex_rs1_l_dep_out  <= rs1_l_dep;  // preserve for hazard tracking
      id_ex_rs2_l_dep_out  <= rs2_l_dep;
      id_ex_rs1_out        <= 0;
      id_ex_rs2_out        <= 0;
      forward_rs1_ex_mem   <= 0;
      forward_rs1_mem_wb   <= 0;
      forward_rs2_ex_mem   <= 0;
      forward_rs2_mem_wb   <= 0;
      id_ex_instr_valid_out <= 0;
    end
    else if (d_cache_busy) begin
      // FREEZE — d-cache miss, hold all pipeline register values
      ex_op1_sel            <= ex_op1_sel;
      ex_op2_sel            <= ex_op2_sel;
      ex_alu_func           <= ex_alu_func;
      wb_rf_wr_data         <= wb_rf_wr_data;
      mem_data_req          <= mem_data_req;
      mem_data_byte         <= mem_data_byte;
      mem_data_wr           <= mem_data_wr;
      mem_zero_extnd        <= mem_zero_extnd;
      wb_rf_wr_en           <= wb_rf_wr_en;
      ex_rs1_data           <= ex_rs1_data;
      ex_rs2_data           <= ex_rs2_data;
      imm_o                 <= imm_o;
      pc_ex                 <= pc_ex;
      rd_addr_out           <= rd_addr_out;
      ex_l_type_out         <= ex_l_type_out;
      id_ex_instr_out       <= id_ex_instr_out;
      ex_rs1_l_dep          <= ex_rs1_l_dep;
      ex_rs2_l_dep          <= ex_rs2_l_dep;
      id_ex_rs1_l_dep_out   <= id_ex_rs1_l_dep_out;
      id_ex_rs2_l_dep_out   <= id_ex_rs2_l_dep_out;
      id_ex_rs1_out         <= id_ex_rs1_out;
      id_ex_rs2_out         <= id_ex_rs2_out;
      forward_rs1_ex_mem    <= forward_rs1_ex_mem;
      forward_rs1_mem_wb    <= forward_rs1_mem_wb;
      forward_rs2_ex_mem    <= forward_rs2_ex_mem;
      forward_rs2_mem_wb    <= forward_rs2_mem_wb;
      id_ex_instr_valid_out <= id_ex_instr_valid_out;
    end
    else begin
      // Normal operation — latch all inputs
      ex_op1_sel            <= ctrl_op1_sel;
      ex_op2_sel            <= ctrl_op2_sel;
      ex_alu_func           <= ctrl_alu_func;
      wb_rf_wr_data         <= ctrl_rf_wr_data;
      mem_data_req          <= ctrl_data_req;
      mem_data_byte         <= ctrl_data_byte;
      mem_data_wr           <= ctrl_data_wr;
      mem_zero_extnd        <= ctrl_zero_extnd;
      wb_rf_wr_en           <= ctrl_rf_wr_en;
      ex_rs1_data           <= rf_rs1_data;
      ex_rs2_data           <= rf_rs2_data;
      imm_o                 <= imm;
      pc_ex                 <= pc_id;
      rd_addr_out           <= rd_addr;
      ex_l_type_out         <= id_l_type_in;
      id_ex_instr_out       <= id_instr_in;
      ex_rs1_l_dep          <= rs1_l_dep_in_hazard;
      ex_rs2_l_dep          <= rs2_l_dep_in_hazard;
      id_ex_rs1_l_dep_out   <= rs1_l_dep;
      id_ex_rs2_l_dep_out   <= rs2_l_dep;
      id_ex_rs1_out         <= id_rs1_in;
      id_ex_rs2_out         <= id_rs2_in;
      forward_rs1_ex_mem    <= rs1_ex_dep;
      forward_rs1_mem_wb    <= rs1_mem_dep;
      forward_rs2_ex_mem    <= rs2_ex_dep;
      forward_rs2_mem_wb    <= rs2_mem_dep;
      id_ex_instr_valid_out <= id_ex_instr_valid_in;
    end
  end

endmodule
