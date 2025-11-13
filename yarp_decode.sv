// --------------------------------------------------------
// YARP: Instruction Decode
//
// Designing the instruction decode unit for YARP core
// capable of decoding all the six types of instructions:
//    - R Type
//    - I Type
//    - S Type
//    - B Type
//    - U Type
//    - J Type
//
// The decode should be able to decode and return needed
// information about the instruction in the same cycle
// --------------------------------------------------------


//imp-> decode unit, controller module and reg_file will be executed within the same cycle
module yarp_decode import yarp_pkg::*; (
  input logic clk,
  input logic reset_n,
  input   logic [31:0]  instr_i,
  output  logic [4:0]   rs1_o,//will go to reg file, so no need to pipeline 
  output  logic [4:0]   rs2_o,//will go to reg file 
  output  logic [4:0]   rd_o, //will go to reg file
  output  logic [6:0]   op_o, //will go to controller
  output  logic [2:0]   funct3_o,//will go to controller
  output  logic [6:0]   funct7_o, //will go to controller
  output  logic         r_type_instr_o, //will go to controller
  output  logic         i_type_instr_o, //will go to controller
  output  logic         s_type_instr_o, //will go to controller
  output  logic         b_type_instr_o, //will go to controller
  output  logic         u_type_instr_o, //will go to controller
  output  logic         j_type_instr_o, //will go to controller
  output  logic [31:0]  instr_imm_o //will go to alu, or be written to reg file(after few cycles), so need to flop only this
);
  
  // Write your logic here...
  
  //define reg (source and dest reg)
  logic [4:0] rs1,rs2,rd;
  logic [6:0] op_code;
  logic [2:0] funct3;
  logic [6:0] funct7;
  
  
  //assign the value for source and dest reg
  
  assign op_code=instr_i[6:0];
  assign rs1=instr_i[19:15];
  assign rs2=instr_i[24:20];
  assign rd=instr_i[11:7];
  //values for funct3 and funct7
  assign funct3=instr_i[14:12];
  assign funct7=instr_i[31:25];
  
  assign rs1_o=rs1;
  assign rs2_o=rs2;
  assign rd_o=rd;
  assign op_o=op_code;
  assign funct3_o=funct3;
  assign funct7_o=funct7;
  
  
  //define immediate values(these should also be 32 bits)
  logic [31:0] imm_i,imm_s,imm_b,imm_u,imm_j;
  
  
  //assign the immediate values
  assign imm_i={{20{instr_i[31]}},instr_i[31:20]};
  assign imm_s={{21{instr_i[31]}},instr_i[30:25],instr_i[11:7]};
  assign imm_b={{20{instr_i[31]}},instr_i[7],instr_i[30:25],instr_i[11:8],1'b0};
  assign imm_u={instr_i[31:12],12'h0}; //unsigned instruction
  assign imm_j={{13{instr_i[31]}},instr_i[19:12],instr_i[20],instr_i[30:21]};

  
  //declare reg for finding type of instr
  logic r_type_decode;
  logic i_type_decode;
  logic s_type_decode;
  logic b_type_decode;
  logic u_type_decode;
  logic j_type_decode;
  
  
  
    /*typedef enum logic [6:0] {
    R_type=7'h33,
    I_type1=7'h67,
    I_type2=7'h03,
    I_type3=7'h13,
    S_type=7'h23,
    B_type=7'h63,
    U_type1=7'h37,
    U_type2=7'h17
    J_type=7'h6F} OP_CODE;*/
  //assign the values
  always_comb begin
    r_type_decode=0;
    i_type_decode=0;
    s_type_decode=0;
    b_type_decode=0;
    u_type_decode=0;
    j_type_decode=0;
    case(op_code)
      R_type: r_type_decode=1'b1;
      I_type1,
      I_type2,
      I_type3: i_type_decode=1'b1;
      S_type: s_type_decode=1;
      B_type: b_type_decode=1;
      U_type1,
      U_type2: u_type_decode=1;
      J_type: j_type_decode=1;
    endcase
  end
  
  
  assign r_type_instr_o=r_type_decode;
  assign i_type_instr_o=i_type_decode;
  assign s_type_instr_o=s_type_decode;
  assign b_type_instr_o=b_type_decode;
  assign u_type_instr_o=u_type_decode;
  assign j_type_instr_o=j_type_decode;


  
  //when to pass the immediate value (only when r type instr not requested)

  logic [31:0] imm;
  assign imm=(r_type_decode)?0:
    (i_type_decode)?imm_i:
    (s_type_decode)?imm_s:
    (b_type_decode)?imm_b:
    (u_type_decode)?imm_u:
    (j_type_decode)?imm_j: 0;


  always_ff @(posedge clk)
  begin
  if(!reset_n)
  begin
  instr_imm_o<=0;
  end
  else
  begin
  instr_imm_o<=imm;
  end
  end
  
endmodule
