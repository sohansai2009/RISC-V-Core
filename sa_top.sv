module sa_top (clk,reset_n,cpu_req_in,cpu_addr_in,i_cache_busy_out,data_out);

input logic clk,reset_n;
input logic cpu_req_in;
input logic [31:0] cpu_addr_in;

output logic i_cache_busy_out;
output logic [31:0] data_out;

logic [25:0] dec_lu_tag_id;
logic [1:0] dec_lu_set_id;
logic [1:0] dec_lu_block_offset;
//instantiate the decode module
sa_decode sa_1(
.in_addr (cpu_addr_in),
.tag_id (dec_lu_tag_id),
.set_id (dec_lu_set_id),
.block_offset (dec_lu_block_offset));

//instantiate the lookup module

logic [25:0] ctrl_lu_tag_array [15:0];
logic ctrl_lu_lru_valid_array [15:0];
logic lu_ctrl_hit;
logic lu_ctrl_miss;
logic [25:0] lu_ctrl_tagid;
logic [1:0] lu_ctrl_setid;
logic [1:0] lu_ctrl_blockoffset;
logic [3:0] lu_ctrl_cachelineno;

sa_lookup sa_2(
.in_req (cpu_req_in),
.tag_id_in (dec_lu_tag_id),
.set_id_in (dec_lu_set_id),
.block_offset_in (dec_lu_block_offset),
.tag_array_in (ctrl_lu_tag_array),
.valid_array_in (ctrl_lu_lru_valid_array),
.hit (lu_ctrl_hit),
.miss (lu_ctrl_miss),
.tag_id_out (lu_ctrl_tagid),
.set_id_out (lu_ctrl_setid),
.block_offset_out (lu_ctrl_blockoffset),
.set_cache_line_no (lu_ctrl_cachelineno));

//instantiate the controller module
logic ctrl_mem_req;
logic [7:0] ctrl_mem_addr;
logic mem_ctrl_comp;
logic [127:0] mem_ctrl_data;
logic set_full_out;
logic [3:0] way_id_ctrl_lru;
logic valid_rg_ctrl [15:0];
logic ctrl_lru_wr_en;
sa_control sa_3 (
.clk (clk),
.reset_n (reset_n),
.hit_in (lu_ctrl_hit),
.miss_in (lu_ctrl_miss),
.tag_id_in (lu_ctrl_tagid),
.set_cache_line_in (lu_ctrl_cachelineno),
.set_id_in (lu_ctrl_setid),
.block_offset_in (lu_ctrl_blockoffset),
.valid_array_in (valid_rg_ctrl),
.tag_array_out (ctrl_lu_tag_array),
.valid_array_out (ctrl_lu_lru_valid_array),
.mem_req_o (ctrl_mem_req),
.addr_mem_o (ctrl_mem_addr),
.mem_comp (mem_ctrl_comp),
.mem_data_in (mem_ctrl_data),
.data_out (data_out),
.i_cache_busy (i_cache_busy_out),
.set_full (set_full_out),
.way_id_out(way_id_ctrl_lru),
.wr_fif_en_o (ctrl_lru_wr_en));

//instantiate the memory
sa_mem sa_4(
.clk (clk),
.reset_n (reset_n),
.mem_req_in (ctrl_mem_req),
.mem_addr_in (ctrl_mem_addr),
.mem_data_out (mem_ctrl_data),
.mem_comp_out (mem_ctrl_comp));

//instantiate the lru module
logic [4:0] way1_lru_rg,way2_lru_rg,way3_lru_rg;
logic valid_out_lru_rg [15:0];
lru sa_5 (
.clk(clk),
.reset_n(reset_n),
.wr_en (ctrl_lru_wr_en),
.way_id_in (way_id_ctrl_lru),
.valid_in (ctrl_lu_lru_valid_array),
.full (set_full_out),
.way1 (way1_lru_rg),
.way2 (way2_lru_rg),
.valid_out_rg (valid_out_lru_rg));

//instantiate the random generator module
random_way_gen sa_6(
.clk (clk),
.reset_n (reset_n),
.way1_in (way1_lru_rg),
.way2_in (way2_lru_rg),
.valid_lru_in (valid_out_lru_rg),
.valid_out (valid_rg_ctrl));

endmodule



