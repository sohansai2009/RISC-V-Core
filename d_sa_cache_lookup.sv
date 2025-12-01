module d_sa_lookup(in_req,tag_id_in,set_id_in,block_offset_in,tag_array_in,valid_array_in,hit,miss,tag_id_out,set_id_out,block_offset_out,set_cache_line_no);

input logic in_req; //from cpu_controller 
input logic [27:0] tag_id_in; //from decode
input logic [1:0] set_id_in,block_offset_in;

input logic [27:0] tag_array_in [15:0];
input logic valid_array_in [15:0];

output logic hit,miss;
output logic [27:0] tag_id_out;
output logic [1:0] set_id_out,block_offset_out;
output logic [3:0] set_cache_line_no; //tells in which cache line was hit detected



//define parameters for sets
parameter S0=2'b00;
parameter S1=2'b01;
parameter S2=2'b10;
parameter S3=2'b11;

//define tag_id_out, set_id_out and block_offset
assign tag_id_out=tag_id_in;
assign set_id_out=set_id_in;
assign block_offset_out=block_offset_in;

//define hit or miss
always_comb begin
case(set_id_in)
S0: begin
hit=(in_req)?(( valid_array_in[0] && (tag_id_in==tag_array_in[0])) || ( valid_array_in[1] && (tag_id_in==tag_array_in[1])) || ( valid_array_in[2] && (tag_id_in==tag_array_in[2])) || ( valid_array_in[3] && (tag_id_in==tag_array_in[3]))) : 0;
miss=(in_req)?!hit:0;
set_cache_line_no=(tag_id_in==tag_array_in[0])?4'b0000 : (tag_id_in==tag_array_in[1])?4'b0001 : (tag_id_in==tag_array_in[2])?4'b0010 : (tag_id_in==tag_array_in[3])?4'b0011 : 4'b0000;
end

S1: begin
hit = (in_req)? (((valid_array_in[4]&&tag_id_in==tag_array_in[4]) || (valid_array_in[5]&&tag_id_in==tag_array_in[5]) || (valid_array_in[6] && tag_id_in==tag_array_in[6]) || (valid_array_in[7] && tag_id_in ==tag_array_in[7])) ? 1:0) : 0;
miss = (in_req) ? !hit : 0;
set_cache_line_no=(tag_id_in==tag_array_in[4])?4'b0100 : (tag_id_in==tag_array_in[5])?4'b0101 : (tag_id_in==tag_array_in[6])?4'b0110 : (tag_id_in==tag_array_in[7])?4'b0111 : 4'b0000;
end

S2: begin
hit = (in_req)? (((valid_array_in[8]&&tag_id_in==tag_array_in[8]) || (valid_array_in[9]&&tag_id_in==tag_array_in[9]) || (valid_array_in[10] && tag_id_in==tag_array_in[10]) || (valid_array_in[11] && tag_id_in ==tag_array_in[11])) ? 1:0) : 0;miss = (in_req) ? !hit:0;
set_cache_line_no=(tag_id_in==tag_array_in[8])?4'b1000 : (tag_id_in==tag_array_in[9])?4'b1001 : (tag_id_in==tag_array_in[10])?4'b1010 : (tag_id_in==tag_array_in[11])?4'b1011 : 4'b0000;
end

S3: begin
hit = (in_req)? (((valid_array_in[12]&&tag_id_in==tag_array_in[12]) || (valid_array_in[13]&&tag_id_in==tag_array_in[13]) || (valid_array_in[14] && tag_id_in==tag_array_in[14]) || (valid_array_in[15] && tag_id_in ==tag_array_in[15])) ? 1:0) : 0;miss=(in_req)?!hit:0;
set_cache_line_no=(tag_id_in==tag_array_in[12])?4'b1100 : (tag_id_in==tag_array_in[13])?4'b1101 : (tag_id_in==tag_array_in[14])?4'b1110 : (tag_id_in==tag_array_in[15])?4'b1111 : 4'b0000;
end

default: begin
set_cache_line_no=4'b0000;
end
endcase
end

endmodule
