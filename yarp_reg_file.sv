// --------------------------------------------------------
// RISC-V: Register File
//
// Designing the register file for YARP core.
// The register file would implement the 32 architectural
// registers, each being XLEN wide. For YARP core each of
// the register would be 32-bit wide i.e. XLEN=32
// --------------------------------------------------------

// --------------------------------------------------------
// Register File
// --------------------------------------------------------

module yarp_regfile (
  input   logic          clk,
  input   logic          reset_n,

  // Source registers
  input   logic [4:0]    rs1_addr_i,
  input   logic [4:0]    rs2_addr_i,

  // Destination register
  input   logic [4:0]    rd_addr_i,
  input   logic          wr_en_i,
  input   logic [31:0]   wr_data_i,

  // Register Data
  output  logic [31:0]   rs1_data_o,
  output  logic [31:0]   rs2_data_o,
  input regfile_d_cache_busy_in
);

  logic [31:0] regfile [31:0];
  


//read the reg file.hex file and store the contents in rgfile
initial
begin
$readmemh("reg_file.hex",regfile);
end
  
  //define the write logic
  //we need to store the write data in a flop so that it can be used by next instructions in the next cycles
  //we can use genvar loop(create 32 combinational blocks), each block will represen logic for a particular reg in the memory)
  genvar i;
  for(i=0;i<32;i++)
    begin
      //wr_perm_i signal should be created for every reg
      logic wr_per_en;
      assign wr_per_en = (wr_en_i==1) & (rd_addr_i==i);  //wite permisson will be enbaled to a particular reg only if wr_en is high and the instructiona ctually wants to that particular reg as depicted by rd_addr_i
      always_ff @(posedge clk)
        begin
          if(i==0)
            //according to spec, reg x0 should always be 1'b0
            regfile[i]<=0;
          else begin
            if(wr_per_en)
              regfile[i]<=wr_data_i;
          end
        end
    end
  
  //define output for rs1 and rs2
  //use pipeline registers
  always_ff @(posedge clk)
  begin
  if(!reset_n)
  begin
  rs1_data_o<=0;
  rs2_data_o<=0;
  end
  else if(!regfile_d_cache_busy_in) //if no stall, send the correct value
  begin
  rs1_data_o<=regfile[rs1_addr_i];
  rs2_data_o<=regfile[rs2_addr_i];
  end
  else if(regfile_d_cache_busy_in)
  begin
  rs1_data_o<=rs1_data_o; //if stall, restore the prev value
  rs2_data_o<=rs2_data_o;
  end
  end
      

endmodule

