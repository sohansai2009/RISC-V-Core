module d_cache_lookup (in_req,tagid_in,lineid_in,wordid_in,tag_array_ctrl,valid_array_ctrl,hit_o,miss_o,tagid_o,lineid_o,wordid_o);

input logic in_req;
input logic [27:0] tagid_in;
input logic [1:0] lineid_in;
input logic [1:0] wordid_in;
input logic [27:0] tag_array_ctrl [3:0]; //from controller
input logic valid_array_ctrl [3:0];

output logic hit_o,miss_o;
output logic [27:0] tagid_o;
output logic [1:0] lineid_o,wordid_o;



//define outputs
assign hit_o = (in_req) ? ((tag_array_ctrl[lineid_in]==tagid_in)?1:0) : 0;
assign miss_o = (in_req) ? !hit_o : 0;
assign tagid_o=tagid_in;
assign lineid_o=lineid_in;
assign wordid_o=wordid_in;

endmodule
