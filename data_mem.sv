module data_mem (clk,reset_n,r_mem_req_in,w_mem_req_in,mem_addr_in,mem_wr_en,data_mem_wr_data,word_id_in,mem_comp_out,mem_data_out);

input logic clk,reset_n;
input logic r_mem_req_in;
input logic w_mem_req_in;
input logic [7:0] mem_addr_in; //{tagid,lineid}
input logic mem_wr_en; //mem_wr_en==0 -> read operation else, write operation
input logic [31:0] data_mem_wr_data;
input logic [1:0] word_id_in;
output logic mem_comp_out;
output logic [127:0] mem_data_out;


//create memory unit
logic [127:0] d_mem [255:0];

initial
begin
$readmemh("data_mem.hex",d_mem);
end

//logic for memory operation
always_ff @(posedge clk)
begin
if(!reset_n)
begin
mem_data_out<=0;
mem_comp_out<=0;
end
else
begin
if(r_mem_req_in) begin
mem_data_out<=d_mem[mem_addr_in];
mem_comp_out<=1;
end
//write
if(w_mem_req_in)
begin
//we need to write to the block corresponding to the {tag_id,lineid}
case(word_id_in)
2'b00: d_mem[mem_addr_in][31:0] <= data_mem_wr_data;
2'b01: d_mem[mem_addr_in][63:32] <= data_mem_wr_data;
2'b10: d_mem[mem_addr_in][95:64] <= data_mem_wr_data;
2'b11: d_mem[mem_addr_in][127:96] <= data_mem_wr_data;
endcase
mem_comp_out<=1;
end
end
end

endmodule





