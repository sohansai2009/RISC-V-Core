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

module yarp_data_mem import yarp_pkg::*; (
  input   logic           clk,
  input   logic           reset_n,

  // Data request from current instruction
  input   logic           data_req_i,
  input   logic [31:0]    data_addr_i,
  input   logic [1:0]     data_byte_en_i,
  input   logic           data_wr_i,
  input   logic [31:0]    data_wr_data_i,

  input   logic           data_zero_extnd_i,

  // Read/Write request to memory
  output  logic           data_mem_req_o,
  output  logic  [31:0]   data_mem_addr_o,
  output  logic  [1:0]    data_mem_byte_en_o,
  output  logic           data_mem_wr_o,
  output  logic  [31:0]	  data_mem_wr_data_o,
  // Read data from memory
  input   logic [31:0]    mem_rd_data_i,

  // Data output
  output  logic [31:0]    data_mem_rd_data_o //need to flop as this data has to be written to reg_file (wb_stage)
);

  // Write your logic here...
  
  
  //define the output values for read/write request signals
  assign data_mem_req_o=data_req_i;
  assign data_mem_addr_o=data_addr_i;
  assign data_mem_byte_en_o=data_byte_en_i;
  assign data_mem_wr_o=data_wr_i;
  assign data_mem_wr_data_o=data_wr_data_i;
  
  
  //now, we need to send the output of the read-request (based on mem_rd_data_i) value and the data_byte_en value and whether or not to zero extend it
  logic [31:0] data_mem_rd_data;
  logic [31:0] rd_data_sign_extend,rd_data_zero_extend;
  
  
  assign rd_data_sign_extend=(data_byte_en_i==Half)?{{16{mem_rd_data_i[15]}},mem_rd_data_i[15:0]}:(data_byte_en_i==Byte)?{{24{mem_rd_data_i[7]}},mem_rd_data_i[7:0]}:mem_rd_data_i;
  assign rd_data_zero_extend=(data_byte_en_i==Half)?{{16{1'b0}},mem_rd_data_i[15:0]}:(data_byte_en_i==Byte)?{{24{1'b0}},mem_rd_data_i[7:0]}:mem_rd_data_i;

  assign data_mem_rd_data=(data_zero_extnd_i)?rd_data_zero_extend:rd_data_sign_extend;

  always_ff @(posedge clk)
  begin
  if(!reset_n)
  begin
  data_mem_rd_data_o<=0;
  end
  else
  begin
  data_mem_rd_data_o<=data_mem_rd_data;
  end
  end
endmodule

