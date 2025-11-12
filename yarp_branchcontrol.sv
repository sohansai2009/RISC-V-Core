// --------------------------------------------------------
// YARP: Branch Control
//
// Designing the branch control unit for YARP core
//
// The unit should be able to decide if the branch is taken
// or not based on the branch instruction
// --------------------------------------------------------

module yarp_branch_control import yarp_pkg::*; (
  // Source operands
  input  logic [31:0] opr_a_i,
  input  logic [31:0] opr_b_i,

  // Branch Type
  input  logic        is_b_type_ctl_i,
  input  logic [2:0]  instr_func3_ctl_i,

  // Branch outcome
  output logic        branch_taken_o
);

  // Write your logic here...
  
  //reg to store signed rep of the two numbers
  logic [31:0] twos_comp_a,twos_comp_b;
  assign twos_comp_a=(opr_a_i[31])? ~(opr_a_i) + 32'h1: opr_a_i; //need to convert to 2's complement only if msb is 1 (which implies negative number), else, keep the same val
  assign twos_comp_b = (opr_b_i[31])?~(opr_b_i) + 32'h1: opr_b_i;
  
  
  //reg to store the output
  logic branch_taken_temp;
  //case statement to calculate the value of different branches
  always_comb begin
    case(instr_func3_ctl_i)
      Beq: branch_taken_temp=(opr_a_i==opr_b_i)?1:0;
      Bne: branch_taken_temp=(opr_a_i!=opr_b_i)?1:0;
      Blt: branch_taken_temp=(opr_a_i[31]==opr_b_i[31])?((opr_a_i[31]==0)?(opr_a_i<opr_b_i):(twos_comp_a<twos_comp_b)):opr_a_i[31];
      Bge: branch_taken_temp=(opr_a_i[31]==opr_b_i[31])?((opr_a_i[31]==0)?(opr_a_i>=opr_b_i):(twos_comp_a>=twos_comp_b)):opr_a_i[31];
      Bltu: branch_taken_temp=(opr_a_i<opr_b_i)?1:0;
      Bgeu: branch_taken_temp=(opr_a_i >= opr_b_i)?1:0;
      default: branch_taken_temp=32'h0;
    endcase
  end
  
  assign branch_taken_o=(is_b_type_ctl_i)?branch_taken_temp:0;
      

endmodule


