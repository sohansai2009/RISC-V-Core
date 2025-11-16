module cache_top(clk,reset_n,in_addr,tagarray_out,validarray_out,data_out);

//input signals
input logic clk,reset_n;
input logic [31:0] in_addr; //incoming address from CPU

//output signals
output logic [27:0] tagarray_out [3:0];
output logic validarray_out [3:0];
output logic [31:0] data_out;

//internal reg for decoder
logic [27:0] tag_reg;
logic [1:0] lineid_reg;
logic [1:0] wordid_reg;

//instantiate the decoder module
cache_decode dut(
.in_addr (in_addr),
.tag (tag_reg),
.line_id (lineid_reg),
.word_id (wordid_reg));


//internal reg for cache_lookup
logic hit_reg,miss_reg;

logic [27:0] tagarray_reg [3:0];
logic valid_reg [3:0];
logic [27:0] lu_tag_ctrl;
logic [1:0] lu_lineid_ctrl;
logic [1:0] lu_wordid_ctrl;

//instantiate the cache_lookup
cache_lookup dut1(
.tag_in (tag_reg),
.lineid_in (lineid_reg),
.wordid_in (wordid_reg),
.tag_ctrl (tagarray_out),
.valid_ctrl (validarray_out),
.hit(hit_reg),
.miss(miss_reg),
.tag_out (lu_tag_ctrl),
.lineid_out (lu_lineid_ctrl),
.wordid_out(lu_wordid_ctrl));


logic mem_comp_in; //should come from the instruction memory
logic [127:0] mem_data_in; //should come from instruction memory
logic [7:0] mem_addr_out; //should go to instruction memory
logic mem_req_o;  //should go to instruction memory
//instantiate the cache controller module
cache_controller dut2(
.clk (clk),
.reset_n (reset_n),
.hit_in (hit_reg),
.miss_in (miss_reg),
.tag_in (tag_reg),
.wordid_in (lu_wordid_ctrl),
.lineid_in (lu_lineid_ctrl),
.mem_data_in (mem_data_in),
.mem_comp (mem_comp_in),
.tagarray_out (tagarray_out),
.validarray_out (validarray_out),
.data_out (data_out),
.mem_addr_out (mem_addr_out),
.mem_req_o (mem_req_o));

imem dut3(
.mem_req_in (mem_req_o),
.in_addr (mem_addr_out),
.data_out (mem_data_in),
.mem_done (mem_comp_in));





endmodule









