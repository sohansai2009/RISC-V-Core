// --------------------------------------------------------
// YARP: Top
//
// Designing the top module for the YARP core. This would
// instantiate and connect all the sub-modules together
// completing the entire processor.
// --------------------------------------------------------

// --------------------------------------------------------
// Yet Another RISC-V Processor - Top
// --------------------------------------------------------

module yarp_top import yarp_pkg::*; #(
  parameter RESET_PC = 32'h1000
)(
  input   logic          clk,
  input   logic          reset_n,

  input   logic [31:0]   data_mem_rd_data_i, //load data
  input logic d_cache_busy_in

);

  // Write your logic here...
	//temp reg

  //these should go to the cache_mem
  logic          instr_mem_req_o;
  logic [31:0]   instr_mem_addr_o;
  logic [31:0]   instr_mem_rd_data_i;
  logic [31:0] alu_op1;
  logic [31:0] imem_dec_instr1;
  logic reset_q; //flop to store the first reset
  logic [31:0] pc_q,next_pc,next_pc_seq;
  logic stall_complete;
  logic cache_refill_complete_yarp;
  logic stall;
  logic cache_miss,cache_hit;
  logic [4:0] dec_rf_rs1;
  logic [4:0] dec_rf_rs2;
  logic [4:0] dec_rf_rd;
  logic [6:0] dec_ctrl_op;
  logic [2:0] dec_ctrl_funct3;
  logic [6:0] dec_ctrl_funct7;
  logic dec_ctrl_r;
  logic dec_ctrl_i;
  logic dec_ctrl_s;
  logic dec_ctrl_b;
  logic dec_ctrl_u;
  logic dec_ctrl_j;
  logic [31:0] dec_imm;
  logic [31:0] rf_rs1_data,rf_rs2_data;
  logic [31:0] rf_wr_data;
  logic [31:0] data_mem_rd_data;
  logic ctrl_pc_sel;
  logic ctrl_op1_sel;
  logic ctrl_op2_sel;
  logic ctrl_data_req;
  logic ctrl_data_wr;
  logic [1:0] ctrl_data_byte;
  logic ctrl_zero_extnd;
  logic ctrl_wr_en;
  logic [1:0] ctrl_rf_wr_data;
  logic [3:0] ctrl_alu_func;
  logic b_branch_taken;
  logic [31:0] opr_a_sel;
  logic [31:0] opr_b_sel;
  
  always_ff @(posedge clk or negedge reset_n)
    begin
      if(!reset_n)
        reset_q <= 0;
      else
        reset_q <= 1;
    end
  assign stall_complete = (!stall & cache_refill_complete_yarp);
  
  //value for seq_pc
  assign next_pc_seq=pc_q+32'h4;  //update pc_addr only when stall is completed
  assign next_pc = (!reset_n)?pc_q : ((stall_complete & !d_cache_busy_in)?((ctrl_pc_sel | b_branch_taken)?{alu_op1[31:1],1'b0}:next_pc_seq):pc_q);  //you need to update to next_pc only when the stall signals from instr_mem and data_mem are de-asserted. // assign next_pc = (!reset_n)?pc_q : (((i_stall_complete & d_stall_complete)?((ctrl_pc_sel | b_branch_taken)?{alu_op1[31:1],1'b0}:next_pc_seq):pc_q); 
  
  always_ff @(posedge clk)
    begin
      if(!reset_q)
        pc_q <= RESET_PC;
      else if(reset_q) //if first reset is captured, update the  value
        pc_q<=next_pc;
    end
  // --------------------------------------------------------
  // Instruction Memory
  // --------------------------------------------------------
  yarp_instr_mem u_yarp_instr_mem (
    .clk                      (clk),
    .reset_n                  (reset_n),
    .instr_mem_pc_i           (next_pc),  //pc_address
    .instr_mem_req_o          (instr_mem_req_o),
    .instr_mem_addr_o         (instr_mem_addr_o),
    .mem_rd_data_i            (instr_mem_rd_data_i),
    .instr_mem_instr_o        (imem_dec_instr1),  //instruction which goes to the decode stage
    .fetch_d_cache_busy       (d_cache_busy_in)  //send the d_cache status to fetch module,to stall the
  );


  //instantiate the cache_top module
  cache_top u_cache_top(
  .clk (clk),
  .reset_n (reset_n),
  .in_addr (instr_mem_addr_o),
  .in_req (instr_mem_req_o),
  .stall(stall),
  .data_out_cache_top (instr_mem_rd_data_i),
  .cache_refill_complete_top (cache_refill_complete_yarp),
  .cache_miss (cache_miss),
  .cache_hit  (cache_hit) );
  
  // --------------------------------------------------------
  // Instruction Decode
  // --------------------------------------------------------
  yarp_decode u_yarp_decode (
    .clk                      (clk),
    .reset_n                  (reset_n),
    .instr_i                  (imem_dec_instr1),
    .rs1_o                    (dec_rf_rs1), //decode -> rf(we will take the data present at the rs1 loc in rf
    .rs2_o                    (dec_rf_rs2),
    .rd_o                     (dec_rf_rd),
    .op_o                     (dec_ctrl_op),  //opcode goes from decode to control
    .funct3_o                 (dec_ctrl_funct3),
    .funct7_o                 (dec_ctrl_funct7),
    .r_type_instr_o           (dec_ctrl_r),
    .i_type_instr_o           (dec_ctrl_i),
    .s_type_instr_o           (dec_ctrl_s),
    .b_type_instr_o           (dec_ctrl_b),
    .u_type_instr_o           (dec_ctrl_u),
    .j_type_instr_o           (dec_ctrl_j),
    .instr_imm_o              (dec_imm),
    .decode_d_cache_busy      (d_cache_busy_in)
  );

  // --------------------------------------------------------
  // Register File
  // --------------------------------------------------------
  
  //for reg_file, wr_en_i will come from the control unit
  //wr_data_i (data to be written will come from the 4:1 mux, which will decide what type of data to be written)
  //wr_data_i can be any value from alu,mem,updated_pc,imm
  assign rf_wr_data = (ctrl_rf_wr_data==Alu) ? alu_op1:
    (ctrl_rf_wr_data==Mem)?data_mem_rd_data_i:
    (ctrl_rf_wr_data==Imm)?dec_imm:
    next_pc_seq;
  yarp_regfile u_yarp_regfile (
    .clk                      (clk),
    .reset_n                  (reset_n),
    .rs1_addr_i               (dec_rf_rs1),
    .rs2_addr_i               (dec_rf_rs2),
    .rd_addr_i                (dec_rf_rd),
    .wr_en_i                  (ctrl_wr_en),
    .wr_data_i                (rf_wr_data),
    .rs1_data_o               (rf_rs1_data),
    .rs2_data_o               (rf_rs2_data),
    .regfile_d_cache_busy_in  (d_cache_busy_in)
  );

  // --------------------------------------------------------
  // Control Unit
  // -------------------------------------------------------- 
  
  //logic to decide the pc_sel signal
  yarp_control u_yarp_control (
    .clk (clk),
    .reset_n (reset_n),
    .instr_funct3_i           (dec_ctrl_funct3),
    .instr_funct7_bit5_i      (dec_ctrl_funct7[5]),
    .instr_opcode_i           (dec_ctrl_op),
    .is_r_type_i              (dec_ctrl_r),
    .is_i_type_i              (dec_ctrl_i),
    .is_s_type_i              (dec_ctrl_s),
    .is_b_type_i              (dec_ctrl_b),
    .is_u_type_i              (dec_ctrl_u),
    .is_j_type_i              (dec_ctrl_j),
    .pc_sel_o                 (ctrl_pc_sel),
    .op1sel_o                 (ctrl_op1_sel),
    .op2sel_o                 (ctrl_op2_sel),
    .data_req_o               (ctrl_data_req),
    .data_wr_o                (ctrl_data_wr),
    .data_byte_o              (ctrl_data_byte),
    .zero_extnd_o             (ctrl_zero_extnd),
    .rf_wr_en_o               (ctrl_wr_en),
    .rf_wr_data_o             (ctrl_rf_wr_data),  //decides what data to write to rf
    .alu_func_o               (ctrl_alu_func),
    .control_d_cache_busy_in  (d_cache_busy_in)
  );

  // --------------------------------------------------------
  // Branch Control
  // --------------------------------------------------------
  yarp_branch_control u_yarp_branch_control (
    .clk                      (clk),
    .reset_n                  (reset_n),
    .opr_a_i                  (rf_rs1_data),
    .opr_b_i                  (rf_rs2_data),
    .is_b_type_ctl_i          (dec_ctrl_b),
    .instr_func3_ctl_i       (dec_ctrl_funct3),
    .branch_taken_o           (b_branch_taken),
    .branch_d_cache_busy_in   (d_cache_busy_in)
  );

  // --------------------------------------------------------
  // Execute Unit
  // --------------------------------------------------------
  
  //we need muxes to implement
  //opr_a_i will be pc if branch type instr else it will be rs1_data
  assign opr_a_sel= (ctrl_op1_sel)?pc_q:rf_rs1_data; //if b_type, need to select pc_q, else, rf_rs1_data

  assign opr_b_sel=(ctrl_op2_sel)?dec_imm:rf_rs2_data;
  
  yarp_execute u_yarp_execute (
    .clk                      (clk),
    .reset_n                  (reset_n),
    .opr_a_i                  (opr_a_sel),
    .opr_b_i                  (opr_b_sel),
    .op_sel_i                 (ctrl_alu_func),
    .alu_res_o                (alu_op1),
    .execute_cache_busy_in    (d_cache_busy_in)
    
  );

  // --------------------------------------------------------
  // Data Memory
  // --------------------------------------------------------
  d_cache_top dut4 (
    .clk                      (clk),
    .reset_n                  (reset_n),
    .data_req_i               (ctrl_data_req),
    .data_addr_i              (alu_op1),
    .data_byte_en_i           (ctrl_data_byte),
    .data_wr_i                (ctrl_data_wr),
    .data_wr_data_i           (rf_rs2_data), //only store can write data to data memory
    .data_zero_extnd_i        (ctrl_zero_extnd),
    .data_mem_rd_data_o       (data_mem_rd_data_i), ///load data
    .d_cache_busy   (d_cache_busy_in)
  );

endmodule

