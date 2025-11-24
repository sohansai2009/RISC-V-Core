
//in 32 bit address, 26 bits -> tag, 3 bits-> line_id, 2 bits -> word_id, 1 bit-> byte_offset(2 byte addressable cpu)
module cache_lookup (cpu_req_in,tag_in,lineid_in,wordid_in,tag_ctrl,valid_ctrl,hit,miss,tag_out,lineid_out,wordid_out);
//inputs from decoder
input logic cpu_req_in;
input logic [27:0] tag_in;
input logic [1:0] lineid_in;
input logic [1:0] wordid_in;

//inputs from cache controlelr
input logic [27:0] tag_ctrl [3:0];
input logic valid_ctrl [3:0];

//outputs
output logic hit,miss;
output logic [27:0] tag_out;
output logic [1:0] lineid_out;
output logic [1:0] wordid_out;


assign hit=(cpu_req_in)?((valid_ctrl[lineid_in] && (tag_in==tag_ctrl[lineid_in]))):0;
assign miss=(cpu_req_in)?!hit:0;
assign tag_out=tag_in;
assign lineid_out=lineid_in;
assign wordid_out=wordid_in;
endmodule


