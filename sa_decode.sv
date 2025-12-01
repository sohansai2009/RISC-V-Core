module sa_decode (in_addr,tag_id,set_id,block_offset);
input logic [31:0] in_addr;
output logic [25:0] tag_id;
output logic [1:0] set_id;
output logic [1:0] block_offset;


//in your core, the address as word addressable, so addr[1:0] = 2'b00 at all times.
//define the outputs
assign tag_id = in_addr[31:6];
assign set_id = in_addr[5:4];
assign block_offset = in_addr[3:2];

endmodule
