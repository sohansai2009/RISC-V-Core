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
  input logic [31:0] instr_fetch_i,
  // Source registers
  input   logic [4:0]    rs1_addr_i,
  input   logic [4:0]    rs2_addr_i,

  // Destination register
  input   logic [4:0]    rd_addr_i,
  //below two signals are needed during write back stage
  input   logic          wr_en_i,
  input   logic [31:0]   wr_data_i,
  input logic ready_retire,
  output logic retire,

  // Register Data
  output  logic [31:0]   rs1_data_o,
  output  logic [31:0]   rs2_data_o,
  output logic [4:0] wb_rd,
  output logic [31:0] regfile_out [31:0],
  output logic write_to_text
);

logic write_perm_q;
always_ff @(posedge clk)
begin
if(!reset_n)
write_perm_q<=0;
else
write_perm_q<=write_to_text;
end
  // --------------------------------------------------------
  // Implement register file as an 2D array
  // Register file should:
  // - Contain the 32 architectural registers
  // - Each register should be 32-bit wide
  // - Register X0 should always return 0
  // --------------------------------------------------------
  logic [31:0] regfile [31:0];
  
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
            regfile[i]<=0;
          else begin
            if(wr_per_en)
              regfile[i]<=wr_data_i;
          end
        end
    end
  
  //define output for rs1 and rs2
  assign rs1_data_o=(wb_rd==rs1_addr_i)?wr_data_i:regfile[rs1_addr_i] ; //if we are writing back to the reg which is currently being read, we can directly send the wbr esult to the id/ex pipeline
  assign rs2_data_o=(wb_rd==rs2_addr_i)?wr_data_i:regfile[rs2_addr_i];
  assign retire=ready_retire;
  assign wb_rd=rd_addr_i;
  assign write_to_text=(instr_fetch_i==32'h83220100) ? 1 : write_to_text;
  assign regfile_out = regfile;
endmodule
