module if_id_pipeline (
  input  logic        clk,
  input  logic        reset_n,
  input  logic [31:0] if_instr_in,    // instruction from fetch stage
  input  logic [31:0] if_pc_in,       // PC for jal/jalr
  output logic [31:0] id_instr_out,   // instruction to decode stage
  output logic [31:0] id_pc_out,      // PC to decode stage
  output logic        if_id_valid,    // valid signal to decode stage

  // Separate flush and freeze controls
  input  logic        if_pip_disable, // FLUSH signal (hazard | i_cache_busy | post_reset_flush)
  input  logic        d_cache_busy    // FREEZE signal (hold current value)
);

  always_ff @(posedge clk)
  begin
    if (!reset_n) begin
      // Reset — clear pipeline to NOP
      id_instr_out <= 32'h0;
      id_pc_out    <= 32'h0;
      if_id_valid  <= 1'b0;
    end
    else if (d_cache_busy) begin
      // FREEZE — d-cache miss, hold current pipeline values
      // Do not update — keep whatever is in the pipeline register
      id_instr_out <= id_instr_out;
      id_pc_out    <= id_pc_out;
      if_id_valid  <= if_id_valid;
    end
    else if (if_pip_disable) begin
      // FLUSH — i-cache busy / hazard / post_reset_flush
      // Insert NOP to prevent stale instruction from propagating
      id_instr_out <= 32'h0;
      id_pc_out    <= 32'h0;
      if_id_valid  <= 1'b0;
    end
    else begin
      // Normal operation — pass instruction through
      id_instr_out <= if_instr_in;
      id_pc_out    <= if_pc_in;
      if_id_valid  <= 1'b1;
    end
  end

endmodule
