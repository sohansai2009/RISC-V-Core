//pipeline between the execute and the execute stage. outputs of controller and register will be stored in this register and immediate from id
module id_ex_pipeline( 

input logic clk,reset_n,
//input logic ctrl_pc_sel, //used in computing the next_pc value
input logic ctrl_op1_sel, ctrl_op2_sel, //to execute stage
input logic [3:0] ctrl_alu_func, //to execute stage
input logic [1:0] ctrl_rf_wr_data, //to wb stage
input logic ctrl_data_req, //to mem stage -> requesting the memory to perform operation on it
input logic [1:0] ctrl_data_byte, //to mem stage
input logic [4:0] rd_addr,

input logic ctrl_data_wr, //to mem stage
input logic ctrl_zero_extnd, //to mem stage
input logic ctrl_rf_wr_en, //to wb stage
input logic [31:0] rf_rs1_data, //to ex stage
input logic [31:0] rf_rs2_data,  //to ex stage
input logic id_pip_disable,
input logic [31:0] imm,
input logic [31:0] pc_id, //to be written into rd (for j type)
input logic id_l_type_in,
input logic [31:0] id_instr_in,
input logic [5:0] rs1_l_dep,
input logic [5:0] rs2_l_dep,
input logic [4:0] id_rs1_in,
input logic [4:0] id_rs2_in,
input logic rs1_l_dep_in_hazard,rs2_l_dep_in_hazard, //will come from hazard and these will decide which input to send to the execute
input rs1_ex_dep,rs1_mem_dep, //forwarding control signals input coming from hazard detection module, these indicate which data to forward to the alu
input rs2_ex_dep,rs2_mem_dep,

//define the pipeline_reg outputs //will go as input to execute. some will come out as output and be stored in the ex_mem pipeline reg for next stage 
//output logic pc_sel_out, //no need to pipeline this
output logic ex_op1_sel,
output logic ex_op2_sel,
output logic [3:0] ex_alu_func,
output logic [1:0] wb_rf_wr_data,
output logic mem_data_req,
output logic [1:0] mem_data_byte,
output logic mem_data_wr,
output logic mem_zero_extnd,
output logic wb_rf_wr_en,
output logic [31:0] ex_rs1_data,
output logic [31:0] ex_rs2_data,
output logic [31:0] imm_o,
output logic [31:0] pc_ex,
output logic [4:0] rd_addr_out,
output logic ex_l_type_out,
output logic [31:0] id_ex_instr_out,
output logic [5:0] id_ex_rs1_l_dep_out,
output logic [5:0] id_ex_rs2_l_dep_out,
output logic [4:0] id_ex_rs1_out,
output logic [4:0] id_ex_rs2_out,
output logic ex_rs1_l_dep,ex_rs2_l_dep,
output logic forward_rs1_ex_mem,forward_rs1_mem_wb,
output logic forward_rs2_ex_mem,forward_rs2_mem_wb
);

//define the outputs
always_ff @(posedge clk)
begin
if(!reset_n || id_pip_disable) //when hazard detected, we need to flush the pipeline
begin
ex_rs1_l_dep<=0;
ex_rs2_l_dep<=0;
ex_op1_sel<=0;
ex_op2_sel<=0;
ex_alu_func<=0;
wb_rf_wr_data<=0;
mem_data_req<=0;
mem_data_byte<=0;
mem_data_wr<=0;
mem_zero_extnd<=0;
wb_rf_wr_en<=0;
ex_rs1_data<=0;
ex_rs2_data<=0;
imm_o<=0;
pc_ex<=0;
rd_addr_out<=0;
id_ex_instr_out<=0;
ex_l_type_out<=0;
id_ex_rs1_l_dep_out<=rs1_l_dep; //these will not go into execute stage, so, when pipeline flush, we can store the rs1_l_dep input and preserve it when pipeline not there
id_ex_rs2_l_dep_out<=rs2_l_dep;
id_ex_rs1_out<=0;
id_ex_rs2_out<=0;
forward_rs1_ex_mem<=0;
forward_rs1_mem_wb<=0;
forward_rs2_mem_wb<=0;
forward_rs2_ex_mem<=0;
end
else if(!id_pip_disable) //when hazard not detected
begin
ex_rs1_l_dep<=rs1_l_dep_in_hazard;
ex_rs2_l_dep<=rs2_l_dep_in_hazard;
ex_op1_sel<=ctrl_op1_sel;
ex_op2_sel<=ctrl_op2_sel;
ex_alu_func<=ctrl_alu_func;
wb_rf_wr_data<=ctrl_rf_wr_data;
mem_data_req<=ctrl_data_req;
mem_data_byte<=ctrl_data_byte;
mem_data_wr<=ctrl_data_wr;
mem_zero_extnd<=ctrl_zero_extnd;
wb_rf_wr_en<=ctrl_rf_wr_en;
ex_rs1_data<=rf_rs1_data;
ex_rs2_data<=rf_rs2_data;
imm_o<=imm;
pc_ex<=pc_id;
rd_addr_out<=rd_addr;
ex_l_type_out<=id_l_type_in;
id_ex_instr_out<=id_instr_in;
ex_l_type_out<=id_l_type_in;
id_ex_rs1_l_dep_out<=id_ex_rs1_l_dep_out;
id_ex_rs1_l_dep_out<=id_ex_rs2_l_dep_out;
id_ex_rs1_out<=id_rs1_in;
id_ex_rs2_out<=id_rs2_in;
forward_rs1_ex_mem<=rs1_ex_dep;
forward_rs1_mem_wb<=rs1_mem_dep;
forward_rs2_mem_wb<=rs2_mem_dep;
forward_rs2_ex_mem<=rs2_ex_dep;
end
end

endmodule



