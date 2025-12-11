module if_id_pipeline (
input logic clk,reset_n,
input logic [31:0] if_instr_in, //instruction from the instr_fetch 
input logic [31:0] if_pc_in, //for jal and jalr instructions
output logic [31:0] id_instr_out, //output instruction to the id_stage
output logic [31:0] id_pc_out,
input logic if_pip_disable); //pipeline enable signal


always_ff @(posedge clk)
begin
if(!reset_n)
begin
id_instr_out<=32'h0;
id_pc_out<=0;
end
else if(!if_pip_disable) //if no hazard, proceed normally, no need to stall the pipeline
begin
id_instr_out<=if_instr_in;
id_pc_out<=if_pc_in;
end
else if(if_pip_disable) //if hazard, stall the pipeline
begin
id_instr_out<=id_instr_out; 
id_pc_out<=id_pc_out;
end
end

endmodule


