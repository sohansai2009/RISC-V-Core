module ex_mem_pipeline
( input logic clk,reset_n,
  input logic [31:0] ex_result, //execute result (will go to mem (for lw/sw) or reg_file (for wb)
  input logic [1:0] ex_wb_rf_wr_data,
  input logic mem_data_req,
  input logic [1:0] mem_data_type, //will tell whether to load hw, word or byte
  input logic mem_data_wr,
  input logic mem_zero_extnd,
  input logic wb_rf_wr_en,
  input logic ex_mem_en, //pipeline enable signal
  input logic [31:0] imm_dec_in,
  input logic [31:0] pc_ex,
  input logic [4:0] ex_rd_addr,
  input logic [31:0] ex_mem_wr_data, //rs2 value
  input logic ex_l_type,

  output logic [31:0] ex_result_o, //address for lw/sw operations , this can also be result of r,i type instr, need to send this to mem/wb pipeline from memory module
  output logic [1:0] mem_wb_rf_wr_data, //control signal indicating which dtaa to write back in reg_file. this control signal has to go to wb stage from mem/wb pipeline
  output logic mem_data_req_o, //to memory
  output logic [1:0] mem_data_type_o, //to memory
  output logic mem_data_wr_o, //to memory
  output logic mem_zero_extnd_o, //to memory
  output logic wb_rf_wr_en_o, //to write-back stage (has to go from mem/wb stage)
  output logic [31:0] imm_dec_out, //need to send this mem/wb pipeline reg from memory module
  output logic [31:0] pc_mem, //has to go to mem/wb pipeline,
  output logic [4:0] ex_rd_addr_out,
  output logic [31:0] mem_wr_data,
  output logic ex_mem_l_type_out
);

  assign ex_mem_l_type_out = (!reset_n)?0:ex_l_type;;

  //define outputs
  always_ff @(posedge clk)
  begin
  if(!reset_n)
  begin
  ex_result_o<=0;
  mem_wb_rf_wr_data<=0;
  mem_data_req_o<=0;
  mem_data_type_o<=0;
  mem_data_wr_o<=0;
  mem_zero_extnd_o<=0;
  wb_rf_wr_en_o<=0;
  imm_dec_out<=0;
  ex_result_o<=0;
  pc_mem<=0;
  ex_rd_addr_out<=0;
  mem_wr_data<=0;
  end
  else if(ex_mem_en)
  begin
  ex_result_o<=ex_result;
  mem_wb_rf_wr_data<=ex_wb_rf_wr_data;
  mem_data_req_o<=mem_data_req;
  mem_data_type_o<=mem_data_type;
  mem_data_wr_o<=mem_data_wr;
  mem_zero_extnd_o<=mem_zero_extnd;
  wb_rf_wr_en_o<=wb_rf_wr_en;
  imm_dec_out<=imm_dec_in;
  ex_result_o<=ex_result;
  pc_mem<=pc_ex;
  ex_rd_addr_out<=ex_rd_addr;
  mem_wr_data<=ex_mem_wr_data;
  end
  end
  endmodule
  
  
