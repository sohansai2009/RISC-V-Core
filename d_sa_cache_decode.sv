module d_sa_decode(in_addr,tag_id_out,set_id_out,block_offset_out);
input logic [31:0] in_addr;
output logic [27:0] tag_id_out;
output logic [1:0] set_id_out;
output logic [1:0] block_offset_out;

//define the outputs
assign tag_id_out=in_addr[31:4];
assign set_id_out=in_addr[3:2];
assign block_offset_out=in_addr[1:0];

endmodule
