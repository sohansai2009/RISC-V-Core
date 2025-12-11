module mem_wb_pipeline(
input logic clk,
input logic reset_n,
input logic [31:0] mem_data, //for load operation
input logic mem_rf_wr_en, //reg_file write enable
input logic [1:0] mem_rf_wr_data, //what data to write to 
input logic [31:0] ex_result_in, //from memory(result of r,i type)
input logic [31:0] imm_in, //imm value, decoded in id stage
input logic [31:0] pc_mem,
input logic mem_wb_en,
input logic [4:0] wb_rd_addr_in,

//output signals
output logic [31:0] wb_mem_data_out,
output logic wb_rf_wr_en,
output logic [1:0] wb_rf_wr_data,
output logic [31:0] wb_ex_result_in,
output logic [31:0] wb_imm,
output logic [31:0] wb_pc,
output logic [4:0] wb_rd_addr_out,
output logic instr_ready_to_retire);


always_ff @(posedge clk)
begin
if(!reset_n)
begin
wb_mem_data_out<=0;
wb_rf_wr_en<=0;
wb_rf_wr_data<=0;
wb_ex_result_in<=0;
wb_imm<=0;
wb_pc<=0;
wb_rd_addr_out<=0;
instr_ready_to_retire<=0;
end
else if(mem_wb_en)
begin
wb_mem_data_out<=mem_data;
wb_rf_wr_en<=mem_rf_wr_en;
wb_rf_wr_data<=mem_rf_wr_data;
wb_ex_result_in<=ex_result_in;
wb_imm<=imm_in;
wb_pc<=pc_mem;
wb_rd_addr_out<=wb_rd_addr_in;
instr_ready_to_retire<=1;
end
end

endmodule




