//cache decoder
//your risc-v cpu is 2-byte word addressable, which means, addr[0] =0;
module cache_decode
(clk,reset_n,in_req,in_addr,tag,line_id,word_id,cpu_req);


//in_addr[0] = byte_offset
//define input signal
input logic clk,reset_n;
input logic in_req;
input logic [31:0] in_addr;
output logic [27:0] tag;
output logic [1:0] line_id;
output logic [1:0] word_id;
output logic cpu_req;



//we should not accept any address until the miss has finished evaluating


//define output
assign word_id=in_addr[1:0]; //in_addr[1:0]
assign line_id=in_addr[3:2]; //in_addr[4:2]
assign tag=in_addr[31:4];
assign cpu_req=in_req;

endmodule
