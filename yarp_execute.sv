// --------------------------------------------------------
// RISC-V: Arithmetic Logical Unit
//
// Designing the ALU for the YARP Core supporting RV32I.
// The ALU should be able to perform all the arithmetic
// operations necessary to execute the RV32I subset of the
// instructions.
// --------------------------------------------------------

// --------------------------------------------------------
// Arithmetic Logical Unit (ALU)
// --------------------------------------------------------

module yarp_execute import yarp_pkg::*; (
  // Source operands
  input clk,
  input reset_n,
  input   logic [31:0] opr_a_i,
  input   logic [31:0] opr_b_i,

  // ALU Operation
  input   logic [3:0]  op_sel_i,

  // ALU output
  output  logic [31:0] alu_res_o,
  input logic execute_cache_busy_in
);

  // Write your logic here...
  
  //reg to calculate twos cmplement (for signed comparison)
  logic [31:0] twos_comp_a,twos_comp_b;
  //calculate two_comp only if number is negative
  assign twos_comp_a=(opr_a_i[31])? ~(opr_a_i) + 32'h1 : opr_a_i;
  assign twos_comp_b=(opr_b_i[31])? ~(opr_b_i) + 32'h1 : opr_b_i;
  
  //tempr eg to calculate the value
  logic [31:0] temp;
  //define the operations
  //single cycle output, so purely combinational logic
  always_comb begin
    case(op_sel_i)
      OP_ADD : temp=opr_a_i+opr_b_i;
      OP_SUB: temp=opr_a_i-opr_b_i;
      OP_SLL: temp=opr_a_i << opr_b_i [4:0];
      OP_SRL: temp=opr_a_i >> opr_b_i[4:0];
      OP_SRA: temp= $signed(opr_a_i) >> opr_b_i[4:0];
      OP_OR: temp=opr_a_i | opr_b_i;
      OP_AND: temp=opr_a_i & opr_b_i;
      OP_XOR: temp=opr_a_i ^ opr_b_i;
      OP_SLTU: temp={31'h1,opr_a_i<opr_b_i};
      OP_SLT: temp={31'h1,twos_comp_a<twos_comp_b};
      default: temp=32'h0;
    endcase
  end
  
  

  always_ff @(posedge clk)
  begin
  if(!reset_n)
  alu_res_o<=0;
  else if(!execute_cache_busy_in) //if no stall, send the correct value
  alu_res_o<=temp;
  else if(execute_cache_busy_in) //if stall, restore the prev value
  alu_res_o<=alu_res_o;
  end

endmodule

