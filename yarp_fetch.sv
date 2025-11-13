// // --------------------------------------------------------
// // Instruction Memory - RTL
// // --------------------------------------------------------
//
module yarp_instr_mem (
  input    logic          clk,
  input    logic          reset_n,

  input    logic [31:0]   instr_mem_pc_i,

  // Output read request to memory
  output   logic          instr_mem_req_o,
  output   logic [31:0]   instr_mem_addr_o,

  // Read data from memory
  input    logic [31:0]   mem_rd_data_i,

  // Instruction output
  output   logic [31:0]   instr_mem_instr_o //for pipelining, need to use this as a flop
);

  //req_o has to be asserted every cycle as the processor will send a req signal to the memory at every clock cycle
  //use flop to store req_o signal
  logic instr_mem_req_q;
  
  always_ff @(posedge clk or negedge reset_n)
    begin
      if(!reset_n)
        instr_mem_req_q<=0;
      else
        instr_mem_req_q<=1;
    end
  
  
  //define the output values, since singl-cycle processor
  //instr will finish executing in the current cycle and not need to store the addr,instr(from memory) in flops
  assign instr_mem_req_o=instr_mem_req_q;
  assign instr_mem_addr_o=instr_mem_pc_i;
  
  
  always_ff @(posedge clk)
  begin
  if(!reset_n)
  instr_mem_instr_o<=0;
  else
  instr_mem_instr_o<=mem_rd_data_i;
  end

endmodule

