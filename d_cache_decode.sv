module d_cache_decode (in_addr,tag_id,line_id,word_id);

input logic [31:0] in_addr;
output logic [27:0] tag_id;
output logic [1:0] line_id;
output logic [1:0] word_id;


//define the outputs
assign tag_id=in_addr[31:4];
assign line_id=in_addr[3:2];
assign word_id=in_addr[1:0];

endmodule
