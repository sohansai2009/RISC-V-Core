module hazard_detection (
input logic clk,reset_n,
input logic is_l_type, //hazard /
input logic [4:0] ex_rd, //rd output from ex_mem (rd value of instr in cycle x-1)
input logic [4:0] mem_rd, //rd output from mem_wb
input logic [4:0] id_rs1,id_rs2, //rs1 and rs2 output from id in cycle x
input logic ex_rf_wr_en, //rf_wr_en output from ex (goes to wb stage)
input logic [5:0] hazard_rs1_dep_l_in, //from id_ex pipeline
input logic [5:0] hazard_rs2_dep_l_in, //from id_ex pipeline
output logic hazard,
output logic [5:0] id_ex_rs1_l_dep,id_ex_rs2_l_dep,
output logic rs1_l_dep_ex_in,rs2_l_dep_ex_in, //control signals which determine which data to send to the execute input, will go into id/ex pipeline
output logic rs1_mem_dep_o,rs1_ex_dep_o,
output logic rs2_mem_dep_o,rs2_ex_dep_o
);

logic hazard_q;
logic [5:0] rs1_load_dep,rs2_load_dep;
always_ff @(posedge clk)
begin
if(!reset_n)
hazard_q<=0;
else
hazard_q<=stall;
end

logic rs1_mem_dep, rs1_ex_dep, rs2_mem_dep, rs2_ex_dep;
logic stall;
logic forward_rs1, forward_rs2;
//logic for neg edge
//by the time negedge detected on hazard, we can transfer the output of memory (load value) to the id_ex pipeline stage

assign rs1_mem_dep = (!reset_n)?0: (ex_rf_wr_en)?(id_rs1==mem_rd):0; //rs1 dependent on instr in cycle x-2
assign rs1_ex_dep = (!reset_n)?0:(ex_rf_wr_en)?(id_rs1==ex_rd):0; //rs1 dependent on instr in cycle x-1
assign rs2_mem_dep = (!reset_n)?0:(ex_rf_wr_en)?(id_rs2==mem_rd):0;
assign rs2_ex_dep = (!reset_n)?0:(ex_rf_wr_en)?(id_rs2==ex_rd):0;


assign stall=(!reset_n)?0:(ex_rf_wr_en)?(is_l_type && (rs1_ex_dep || rs2_ex_dep)): 0; //stall the pipeline only when instr (in cycle x-1) is load and dependency exists
assign hazard = stall; //stall=0 -> not l-type and no need to stall (as we have forwarding) //if fprwarding also zero, then we can send the normal rs1 and rs2 from decode stage

//logic for load_dep
assign rs1_load_dep = (is_l_type && rs1_ex_dep)?{id_rs1,is_l_type} : 6'b0;   //if rs1 is dependent on load reg of instr in cycle x-1, then, we need to store id_rs1 and l_type. this will be a control signal for a mux before the ex, to decide whetehr to send reg_rs1 data or forward data form emm
assign rs2_load_dep = (is_l_type && rs2_ex_dep)?{id_rs2,is_l_type} : 6'b0;

assign id_ex_rs1_l_dep = rs1_load_dep;
assign id_ex_rs2_l_dep = rs2_load_dep;

//control signals which indicate load_data from mem has to be sent to the execute module
assign rs1_l_dep_ex_in=(hazard_rs1_dep_l_in[5:1]==id_rs1) && (hazard_rs1_dep_l_in[0]);
assign rs2_l_dep_ex_in = (hazard_rs2_dep_l_in[5:1]==id_rs2) && (hazard_rs2_dep_l_in[0]);

//control signals which indicate either ex_mem (rd data) / mem_wb (rd_data) should be sent to the execute
assign rs1_mem_dep_o=rs1_mem_dep;
assign rs1_ex_dep_o=rs1_ex_dep;
assign rs2_mem_dep_o=rs2_mem_dep;
assign rs2_ex_dep_o=rs2_ex_dep;
endmodule
