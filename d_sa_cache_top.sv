module d_cache_top (
  input   logic           clk,
  input   logic           reset_n,

  // Data request from current instruction
//these inputs will be received from the yarp_controller, yarp_alu and yarp_rf
  input   logic           data_req_i, //from control unit
  input   logic [31:0]    data_addr_i, //will come fro alu
  input   logic [1:0]     data_byte_en_i, //from control unit
  input   logic           data_wr_i, //from control unit
  input   logic [31:0]    data_wr_data_i, //rs2

  input   logic           data_zero_extnd_i, //from control unit

  // Data output
  output  logic [31:0]    data_mem_rd_data_o, //from cache_control, has to go to cpu (rf stage) //need to flop as this data has to be written to reg_file (wb_stage)
  output logic d_cache_busy
);


logic [27:0] dec_lu_tag;
logic [1:0] dec_lu_set;
logic [1:0] dec_lu_block_offset;

d_sa_decode d_sa_1(
.in_addr (data_addr_i),
.tag_id_out (dec_lu_tag),
.set_id_out (dec_lu_set),
.block_offset_out (dec_lu_block_offset));

logic [27:0] ctrl_lu_tag_array [15:0];
logic ctrl_lu_lru_valid_array [15:0];
logic lu_ctrl_hit;
logic lu_ctrl_miss;
logic [27:0] lu_ctrl_tagid;
logic [1:0] lu_ctrl_setid,lu_ctrl_blockoffset;
logic [3:0] lu_ctrl_way_no;

d_sa_lookup d_sa_2(
.in_req (data_req_i),
.tag_id_in (dec_lu_tag),
.set_id_in (dec_lu_set),
.block_offset_in (dec_lu_block_offset),
.tag_array_in (ctrl_lu_tag_array),
.valid_array_in (ctrl_lu_lru_valid_array),
.hit (lu_ctrl_hit),
.miss (lu_ctrl_miss),
.tag_id_out (lu_ctrl_tagid),
.set_id_out (lu_ctrl_setid),
.block_offset_out (lu_ctrl_blockoffset),
.set_cache_line_no (lu_ctrl_way_no));

logic rg_ctrl_valid_array [15:0];
logic ctrl_mem_req;
logic mem_ctrl_comp;
logic [7:0] ctrl_mem_addr;
logic [127:0] mem_ctrl_data;
logic [31:0] ctrl_data_out;
logic [3:0] ctrl_lru_wayid;
logic ctrl_lru_wr_en;
logic ctrl_lru_full;
logic ctrl_mem_r_req;
logic [1:0] ctrl_mem_blockoffset;
logic [1:0] byte_ctrl;
logic ctrl_zero_extnd;

d_sa_control d_sa_3(
.clk (clk),
.reset_n (reset_n),
.wr_en (data_wr_i),
.wdata_in (data_wr_data_i),
.byte_id (data_byte_en_i),
.zero_ext (data_zero_extnd_i),
.valid_array_in (rg_ctrl_valid_array),
.set_cache_line_in(lu_ctrl_way_no),
.hit (lu_ctrl_hit),
.miss(lu_ctrl_miss),
.tag_id_in(lu_ctrl_tagid),
.set_id_in (lu_ctrl_setid),
.block_offset_in (lu_ctrl_blockoffset),
.mem_req_o(ctrl_mem_req),
.mem_comp (mem_ctrl_comp),
.mem_addr_o(ctrl_mem_addr),
.mem_data_in (mem_ctrl_data),
.data_out (ctrl_data_out),
.tag_array_out (ctrl_lu_tag_array),
.valid_array_out (ctrl_lu_lru_valid_array),
.d_cache_busy (d_cache_busy),
.way_id_out (ctrl_lru_wayid),
.wr_en_fifo(ctrl_lru_wr_en),
.set_full (ctrl_lru_full),
.r_req(ctrl_mem_r_req),
.w_req(ctrl_mem_w_req),
.block_offset_out(ctrl_mem_blockoffset),
.byte_id_out (byte_ctrl),
.zero_extnd_out (ctrl_zero_extnd));

//instantiate the memory
d_sa_mem d_sa_4(
.clk (clk),
.reset_n (reset_n),
.r_mem_req_in (ctrl_mem_r_req),
.w_mem_req_in (ctrl_mem_w_req),
.mem_addr_in (ctrl_mem_addr),
.data_mem_wr_data (data_wr_i), //data to be written to the data_mem
.blockoffset_in (ctrl_mem_blockoffset),
.mem_comp_out (mem_ctrl_comp),
.mem_data_out (mem_ctrl_data));

//lru replacement
logic [3:0] lru_rg_way1,lru_rg_way2;
logic lru_rg_valid [15:0];
lru_d d_sa_5(
.clk (clk),
.reset_n(reset_n),
.wr_en (ctrl_lru_wr_en),
.way_id_in (ctrl_lru_wayid),
.valid_in (ctrl_lu_lru_valid_array),
.full (ctrl_lru_full),
.way1 (lru_rg_way1),
.way2 (lru_rg_way2),
.valid_out_rg (lru_rg_valid));


//random generator
random_way_gen_data_mem d_sa_6(
.clk (clk),
.reset_n(reset_n),
.way1_in (lru_rg_way1),
.way2_in (lru_rg_way2),
.valid_out (rg_ctrl_valid_array));

logic [31:0] data_zero_extnd;
logic [31:0] data_no_zero_extnd;

assign data_zero_extnd = (byte_ctrl==2'b00)?{24'b0,ctrl_data_out[7:0]} : (byte_ctrl==2'b01) ? {16'b0,ctrl_data_out[15:0]} : (byte_ctrl==2'b10) ? (ctrl_data_out) : 32'b0;
assign data_no_zero_extnd = (byte_ctrl==2'b00)?{{24{ctrl_data_out[31]}},ctrl_data_out[7:0]} : (byte_ctrl==2'b01) ? {{16{ctrl_data_out[31]}},ctrl_data_out[15:0]} : (byte_ctrl==2'b10) ?  (ctrl_data_out) : 32'b0;
assign data_out_temp = (ctrl_zero_extnd)?(data_zero_extnd):(data_no_zero_extnd);

//define the output which goes to the cpu
always_ff @(posedge clk)
begin
if(!reset_n)
data_mem_rd_data_o<=0;
else
data_mem_rd_data_o<=data_out_temp;
end

endmodule


