//cache decoder
//your risc-v cpu is 2-byte word addressable, which means, addr[0] =0;
module cache_decode
(in_addr,tag,line_id,word_id);


//in_addr[0] = byte_offset
//define input signal
input logic [31:0] in_addr;
output logic [27:0] tag;
output logic [2:0] line_id;
output logic [1:0] word_id;

//define output
assign word_id=in_addr[3:1]; //in_addr[1:0]
assign line_id=in_addr[6:4]; //in_addr[4:2]
assign tag=in_addr[31:7];

endmodule
