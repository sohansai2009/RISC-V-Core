module cache_top(clk,reset_n,in_addr,in_req,stall,data_out_cache_top,cache_refill_complete_top,cache_miss,cache_hit);

//input signals
input logic clk,reset_n;
input logic [31:0] in_addr; //incoming address from CPU
input in_req;

output logic stall; //to stall the pc_address and the pipeline until stall is removed
output logic [31:0] data_out_cache_top;
output logic cache_refill_complete_top;
output logic cache_miss,cache_hit;

//internal reg for decoder
logic [27:0] tag_reg;
logic [1:0] lineid_reg;
logic [1:0] wordid_reg;
logic cpu_req;
logic mem_comp_in; //should come from the instruction memory
logic [127:0] mem_data_in; //should come from instruction memory
logic [7:0] mem_addr_out; //should go to instruction memory
logic mem_req_o;  //should go to instruction memory
logic [27:0] tag_array [3:0];
logic valid_array [3:0];

//internal reg for cache_lookup
logic [27:0] lu_tag_ctrl;
logic [1:0] lu_lineid_ctrl;
logic [1:0] lu_wordid_ctrl;

logic [31:0] data_out_cache_top_temp;
//instantiate the decoder module
cache_decode dut(
.clk (clk),
.reset_n (reset_n),
.in_req (in_req),
.in_addr (in_addr),
.tag (tag_reg),
.line_id (lineid_reg),
.word_id (wordid_reg),
.cpu_req (cpu_req));


//instantiate the cache_lookup
cache_lookup dut1(
.cpu_req_in (cpu_req),
.tag_in (tag_reg),
.lineid_in (lineid_reg),
.wordid_in (wordid_reg),
.tag_ctrl (tag_array),
.valid_ctrl (valid_array),
.hit(cache_hit),
.miss(cache_miss),
.tag_out (lu_tag_ctrl),
.lineid_out (lu_lineid_ctrl),
.wordid_out(lu_wordid_ctrl));

//instantiate the cache controller module
cache_controller dut2(
.clk (clk),
.reset_n (reset_n),
.hit_in (cache_hit),
.miss_in (cache_miss),
.tag_in (tag_reg),
.wordid_in (lu_wordid_ctrl),
.lineid_in (lu_lineid_ctrl),
.mem_data_in (mem_data_in),
.mem_comp (mem_comp_in),
.tagarray_out (tag_array),
.validarray_out (valid_array),
.data_out (data_out_cache_top_temp),
.mem_addr_out (mem_addr_out),
.mem_req_o (mem_req_o),
.stall_out (stall),
.cache_refill_complete (cache_refill_complete_top));

imem dut3(
.clk (clk),
.reset_n (reset_n),
.mem_req_in (mem_req_o),
.in_addr (mem_addr_out),
.data_out (mem_data_in),
.mem_done (mem_comp_in));


always_ff @(posedge clk)
begin
if(!reset_n)
begin
data_out_cache_top<=0;
end
else
begin
data_out_cache_top<=data_out_cache_top_temp;
end
end


endmodule









