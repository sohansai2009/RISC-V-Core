module d_cache_top (
  input   logic           clk,
  input   logic           reset_n,

  // --- CPU Core Interface ---
  input   logic           data_req_i,
  input   logic [31:0]    data_addr_i,
  input   logic [1:0]     data_byte_en_i,
  input   logic           data_wr_i,
  input   logic [31:0]    data_wr_data_i,
  input   logic           data_zero_extnd_i,
  output  logic [31:0]    data_mem_rd_data_o,
  output  logic           d_cache_busy,

  // --- GEM5 External Memory Bus Interface ---
  output  logic           ext_mem_r_req_o,
  output  logic           ext_mem_w_req_o,
  // FIX: Widened from 8-bit to 12-bit to correctly address data memory
  output  logic [11:0]    ext_mem_addr_o,
  output  logic [1:0]     ext_mem_blockoffset_o,
  output  logic [31:0]    ext_mem_wr_data_o,
  input   logic           ext_mem_comp_i,
  input   logic [127:0]   ext_mem_data_i,
  output  logic           mem_wb_instr_valid_in
);

logic [27:0] dec_lu_tag;
logic [1:0]  dec_lu_set;
logic [1:0]  dec_lu_block_offset;

d_sa_decode d_sa_1 (
  .in_addr          (data_addr_i),
  .tag_id_out       (dec_lu_tag),
  .set_id_out       (dec_lu_set),
  .block_offset_out (dec_lu_block_offset)
);

logic [27:0] ctrl_lu_tag_array [15:0];
logic        ctrl_lu_lru_valid_array [15:0];
logic        lu_ctrl_hit, lu_ctrl_miss;
logic [27:0] lu_ctrl_tagid;
logic [1:0]  lu_ctrl_setid, lu_ctrl_blockoffset;
logic [3:0]  lu_ctrl_way_no;

d_sa_lookup d_sa_2 (
  .in_req           (data_req_i),
  .tag_id_in        (dec_lu_tag),
  .set_id_in        (dec_lu_set),
  .block_offset_in  (dec_lu_block_offset),
  .tag_array_in     (ctrl_lu_tag_array),
  .valid_array_in   (ctrl_lu_lru_valid_array),
  .hit              (lu_ctrl_hit),
  .miss             (lu_ctrl_miss),
  .tag_id_out       (lu_ctrl_tagid),
  .set_id_out       (lu_ctrl_setid),
  .block_offset_out (lu_ctrl_blockoffset),
  .set_cache_line_no(lu_ctrl_way_no)
);

logic        rg_ctrl_valid_array [15:0];
logic [31:0] ctrl_data_out;
logic [3:0]  ctrl_lru_wayid;
logic        ctrl_lru_wr_en;
logic        ctrl_lru_full;
logic [1:0]  byte_ctrl;
logic        ctrl_zero_extnd;
logic        mem_req_o_sa;

d_sa_control d_sa_3 (
  .clk              (clk),
  .reset_n          (reset_n),
  .wr_en            (data_wr_i),
  .wdata_in         (data_wr_data_i),
  .byte_id          (data_byte_en_i),
  .zero_ext         (data_zero_extnd_i),
  .valid_array_in   (rg_ctrl_valid_array),
  .set_cache_line_in(lu_ctrl_way_no),
  .hit              (lu_ctrl_hit),
  .miss             (lu_ctrl_miss),
  .tag_id_in        (lu_ctrl_tagid),
  .set_id_in        (lu_ctrl_setid),
  .block_offset_in  (lu_ctrl_blockoffset),
  .mem_req_o        (mem_req_o_sa),
  .mem_comp         (ext_mem_comp_i),
  .mem_addr_o       (ext_mem_addr_o),      // 12-bit ✅
  .mem_data_in      (ext_mem_data_i),
  .r_req            (ext_mem_r_req_o),
  .w_req            (ext_mem_w_req_o),
  .block_offset_out (ext_mem_blockoffset_o),
  .mem_w_data       (ext_mem_wr_data_o),
  .data_out         (ctrl_data_out),
  .tag_array_out    (ctrl_lu_tag_array),
  .valid_array_out  (ctrl_lu_lru_valid_array),
  .d_cache_busy     (d_cache_busy),
  .way_id_out       (ctrl_lru_wayid),
  .wr_en_fifo       (ctrl_lru_wr_en),
  .set_full         (ctrl_lru_full),
  .byte_id_out      (byte_ctrl),
  .zero_extnd_out   (ctrl_zero_extnd)
);

logic [4:0] lru_rg_way1, lru_rg_way2;
logic       lru_rg_valid [15:0];

lru_d d_sa_5 (
  .clk          (clk),
  .reset_n      (reset_n),
  .wr_en        (ctrl_lru_wr_en),
  .way_id_in    (ctrl_lru_wayid),
  .valid_in     (ctrl_lu_lru_valid_array),
  .full         (ctrl_lru_full),
  .way1         (lru_rg_way1),
  .way2         (lru_rg_way2),
  .valid_out_rg (lru_rg_valid)
);

random_way_gen_data_mem d_sa_6 (
  .clk          (clk),
  .reset_n      (reset_n),
  .way1_in      (lru_rg_way1),
  .way2_in      (lru_rg_way2),
  .valid_lru_in (lru_rg_valid),
  .valid_out    (rg_ctrl_valid_array)
);

logic [31:0] data_zero_extnd;
logic [31:0] data_no_zero_extnd;
logic [31:0] data_out_temp;

assign data_zero_extnd    = (byte_ctrl == 2'b00) ? {24'b0, ctrl_data_out[7:0]}   :
                            (byte_ctrl == 2'b01) ? {16'b0, ctrl_data_out[15:0]}  :
                            (byte_ctrl == 2'b10) ?  ctrl_data_out                : 32'b0;

assign data_no_zero_extnd = (byte_ctrl == 2'b00) ? {{24{ctrl_data_out[31]}}, ctrl_data_out[7:0]}  :
                            (byte_ctrl == 2'b01) ? {{16{ctrl_data_out[31]}}, ctrl_data_out[15:0]} :
                            (byte_ctrl == 2'b10) ?  ctrl_data_out                                  : 32'b0;

assign data_out_temp = (ctrl_zero_extnd) ? data_zero_extnd : data_no_zero_extnd;

always_ff @(posedge clk)
begin
  if (!reset_n) data_mem_rd_data_o <= 0;
  else          data_mem_rd_data_o <= data_out_temp;
end

assign mem_wb_instr_valid_in = !d_cache_busy;

endmodule
