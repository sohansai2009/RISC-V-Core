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
  input logic clk,reset_n,
  input   logic [31:0] opr_a_i,
  input   logic [31:0] opr_b_i,

  // contorl signal inputs, coming from id/ex pipeline
  input   logic [3:0]  op_sel_i,
  input logic [1:0] wb_rf_wr_data, //has to go to ex/mem pipeline
  input logic mem_data_req,
  input logic [1:0] mem_data_type,
  input logic mem_data_wr, //has to go to ex/mem pipeline
  input logic mem_zero_extnd,
  input logic wb_rf_wr_en,
  input logic [31:0] imm_in, //has to go to ex/mem pipeline -> mem/wb pipeline
  input logic [31:0] pc_in,
 input logic [4:0] rd_addr_in,
 input logic [31:0] rs2_mem_wr_data,
 input logic id_ex_l_type,
 input logic [31:0] id_ex_instr_in,

  //outputs, which have to go to ex/mem pipeline
  output logic [1:0] wb_rf_wr_data_o,
  output logic mem_data_req_o,
  output logic [1:0] mem_data_type_o,
  output logic mem_data_wr_o,
  output logic mem_zero_extnd_o,
  output logic wb_rf_wr_en_o,
  output logic [31:0] imm_o, 
  output logic [31:0] pc_o,
  output logic [4:0] rd_addr_out,
  output logic [31:0] ex_mem_rs2_wr_data,
  output logic ex_l_type_out,
  
  // ALU output
  output  logic [31:0] alu_res_o
);

  // Write your logic here...
  assign ex_l_type_out =(!reset_n)?0: id_ex_l_type;
  
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
  
  assign alu_res_o=temp;

  //assign outputs -> these will go into ex/mem pipeline
  assign wb_rf_wr_data_o=wb_rf_wr_data;
  assign mem_data_req_o=mem_data_req;
  assign mem_data_type_o=mem_data_type;
  assign mem_data_wr_o=mem_data_wr;
  assign mem_zero_extnd=mem_zero_extnd_o;
  assign wb_rf_wr_en_o=wb_rf_wr_en;
  assign imm_o=imm_in;
  assign pc_o=pc_in;
  assign rd_addr_out = rd_addr_in;
  assign ex_mem_rs2_wr_data=rs2_mem_wr_data;

endmodule

