// --------------------------------------------------------
// YARP: Data Memory
//
// Designing the data memory unit for the YARP core which
// implements the interface to the data memory used for
// reading and writing data
// --------------------------------------------------------

// --------------------------------------------------------
// Data Memory
// --------------------------------------------------------

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


//reg for decode
logic [27:0] tag_id_reg;
logic [1:0] lineid_reg,wordid_reg;
//reg for lookup
logic [27:0] tag_lu_in [3:0];
logic valid_lu_in [3:0];
logic hit_ctrl_in;
logic miss_ctrl_in;
logic [27:0] tagid_ctrl_in;
logic [1:0] lineid_ctrl_in,wordid_ctrl_in;
//reg for control
logic [127:0] ctrl_mem_data_in;
logic ctrl_mem_r_req_o;
logic ctrl_mem_w_req_o;
logic [7:0] data_mem_addr_in;
logic mem_wr_en_in;
logic [31:0] dmem_data_in;
logic mem_comp_ctrl_in;
logic [1:0] mem_wordid;

logic [31:0] ctrl_data_out_cpu;
logic [1:0] byte_ctrl;
logic zeroext;
logic [31:0] data_zero_extnd,data_no_zero_extnd;
logic [31:0] data_out_temp;

d_cache_decode d_cache_dut1(
.in_addr (data_addr_i),
.tag_id (tag_id_reg),
.line_id (lineid_reg),
.word_id (wordid_reg));


d_cache_lookup d_cache_dut2 (
.in_req (data_req_i),
.tagid_in (tag_id_reg),
.lineid_in (lineid_reg),
.wordid_in (wordid_reg),
.tag_array_ctrl (tag_lu_in),
.valid_array_ctrl (valid_lu_in),
.hit_o (hit_ctrl_in),
.miss_o (miss_ctrl_in),
.tagid_o (tagid_ctrl_in),
.lineid_o (lineid_ctrl_in),
.wordid_o (wordid_ctrl_in));


d_cache_control d_cache_dut3(
.clk (clk),
.reset_n (reset_n),
.hit_in (hit_ctrl_in),
.miss_in (miss_ctrl_in),
.tagid_in (tagid_ctrl_in),
.lineid_in (lineid_ctrl_in),
.wordid_in (wordid_ctrl_in),
.mem_data_in (ctrl_mem_data_in),
.wren_in (data_wr_i),
.byte_in (data_byte_en_i),
.wdata_in (data_wr_data_i),
.zeroext_in (data_zero_extnd_i),
.r_mem_req (ctrl_mem_r_req_o),
.w_mem_req (ctrl_mem_w_req_o),
.tag_array_out (tag_lu_in),
.valid_array_out (valid_lu_in),
.mem_addr_out (data_mem_addr_in),
.data_out_data_cache (ctrl_data_out_cpu),  //data to be sent to the cpu
.mem_wr_en (mem_wr_en_in),
.mem_wr_data (dmem_data_in),
.mem_comp (mem_comp_ctrl_in),
.word_id_out (mem_wordid),
.byte_out (byte_ctrl),
.zeroext_out (zeroext),
.d_cache_busy (d_cache_busy));


//
data_mem d_cache_dut4(
.clk (clk),
.reset_n (reset_n),
.r_mem_req_in (ctrl_mem_r_req_o),
.w_mem_req_in (ctrl_mem_w_req_o),
.mem_addr_in (data_mem_addr_in),
.mem_wr_en (mem_wr_en_in),
.data_mem_wr_data (dmem_data_in),
.word_id_in (mem_wordid),
.mem_comp_out (mem_comp_ctrl_in),
.mem_data_out (ctrl_mem_data_in));


//now, based on the value of data (from cache) and the byte and zero_ext values, we need too produce the output 'data_out' which we are gonna send to cpu
assign data_zero_extnd = (byte_ctrl==2'b00)?{24'b0,ctrl_data_out_cpu[7:0]} : (byte_ctrl==2'b01) ? {16'b0,ctrl_data_out_cpu[15:0]} : (byte_ctrl==2'b10) ? (ctrl_data_out_cpu) : 32'b0;
assign data_no_zero_extnd = (byte_ctrl==2'b00)?{{24{ctrl_data_out_cpu[31]}},ctrl_data_out_cpu[7:0]} : (byte_ctrl==2'b01) ? {{16{ctrl_data_out_cpu[31]}},ctrl_data_out_cpu[15:0]} : (byte_ctrl==2'b10) ?  (ctrl_data_out_cpu) : 32'b0;
assign data_out_temp = (zeroext)?(data_zero_extnd):(data_no_zero_extnd);

//define the output which goes to the cpu
always_ff @(posedge clk)
begin
if(!reset_n)
data_mem_rd_data_o<=0;
else
data_mem_rd_data_o<=data_out_temp;
end

endmodule


