// --------------------------------------------------------
// YARP: Control Unit
//
// Designing the instruction control unit for YARP core
//
// The control signals should be generated for every
// supported instruction
// --------------------------------------------------------

module yarp_control import yarp_pkg::*; (
  // Instruction type
  input logic clk,
  input logic reset_n,
  input   logic         is_r_type_i,
  input   logic         is_i_type_i,
  input   logic         is_s_type_i,
  input   logic         is_b_type_i,
  input   logic         is_u_type_i,
  input   logic         is_j_type_i,

  // Instruction opcode/funct fields
  input   logic [2:0]   instr_funct3_i,
  input   logic         instr_funct7_bit5_i,
  input   logic [6:0]   instr_opcode_i,

  // Control signals
  output  logic         pc_sel_o, //after alu_stage (in same stage where branch is evaluateed) -. two flops
  output  logic         op1sel_o,  //source 1 to alu (rs1 or pc(for branch))-> need to flop
  output  logic         op2sel_o,  //source 2 to alu (rs2 or imm (for i,s and b)) -> need to flop
  output  logic [3:0]   alu_func_o, //tells the alu, what function should it perform -> need to flop
  output  logic [1:0]   rf_wr_data_o, //decides what data has to be sent to the reg_file -> will be used in write back stage, so need to use two flops
  output  logic         data_req_o, //has to go to the data_mem in the same cycle when alu finishes calculating the address (after two cycles)
  output  logic [1:0]   data_byte_o,
  output  logic         data_wr_o,//decides whether or not write to mem or not-> has to go to the data_mem after two cycles, after ex stage 
  output  logic         zero_extnd_o, //after two cycles (has to go to write mem)
  output  logic         rf_wr_en_o //has to reach wb stage, need to use three flops (after three cycles)
);
 
  // Write your logic here...
  
  //logic for r-type
  //declare reg to identify the r-type {instr7[5], instr3}
  logic [3:0] diff_rtype;
  assign diff_rtype={instr_funct7_bit5_i,instr_funct3_i};
  
  //we declared all the output signals to belong to a structure called control_t
  //we need to declate an object for the structure to access an reg present in that structure
  control_t reg_control;
  
  //case statement to generate the alu_func_o
  //to declare the control signals for the r_type (control signal for alu(to determine what type of op to perform) and reg_file)
  always_comb begin
    reg_control = 'h0;
    //for r_type, we always need to write to reg file
    reg_control.rf_wr_en=1'b1;
    reg_control.rf_wr_data=Alu;
    reg_control.pc_sel=0; //the next instruction should be from pc_q+4
    case(diff_rtype)
      Add: reg_control.alu_func_sel=OP_ADD; //the alu will perform Add (OP_ADD) is a contorl input to the ALU
      Sub: reg_control.alu_func_sel=OP_SUB;
      Sll: reg_control.alu_func_sel=OP_SLL;
      Slt: reg_control.alu_func_sel=OP_SLT;
      Sltu: reg_control.alu_func_sel=OP_SLTU;
      Xor: reg_control.alu_func_sel=OP_XOR;
      Srl: reg_control.alu_func_sel=OP_SRL;
      Sra: reg_control.alu_func_sel=OP_SRA;
      Or: reg_control.alu_func_sel=OP_OR;
      default:reg_control.alu_func_sel = OP_ADD;
    endcase
  end
  
  
  //to differentiate between different i-type
  logic [3:0] diff_itype;
  assign diff_itype = {instr_opcode_i[4],instr_funct3_i};
  
  //object of struct specific to i-type 
  control_t i_control;
  
  //now, we need to drive all the possible control signals for i_type
    always_comb begin
    i_control = 'h0;
    //for i-type, op2_sel should always be 1, the second operand to i type is always immediate val
    i_control .op2sel= 1'b1;
    //for i_type, we always need to write to reg file
    i_control.rf_wr_en=1'b1;
    i_control.pc_sel=0; 
      case(diff_itype)
        Addi :{i_control.rf_wr_data,i_control.alu_func_sel}={Alu,OP_ADD};
        Slli: {i_control.rf_wr_data,i_control.alu_func_sel}={Alu,OP_SLL};
        Slti: {i_control.rf_wr_data,i_control.alu_func_sel}={Alu,OP_SLT};
        Sltiu:{i_control.rf_wr_data,i_control.alu_func_sel}={Alu,OP_SLTU};
        Xori: {i_control.rf_wr_data,i_control.alu_func_sel}={Alu,OP_XOR};
        Srxi: {i_control.rf_wr_data,i_control.alu_func_sel}={Alu,((instr_funct7_bit5_i)?OP_SRA:OP_SRL)};
        Ori:  {i_control.rf_wr_data,i_control.alu_func_sel}={Alu,OP_OR};
      Lb: {i_control.data_req, i_control.data_byte, i_control.rf_wr_data}={1'b1,Byte,Mem}; //Mem =1 implies data is coming from memory
      Lh: {i_control.data_req, i_control.data_byte, i_control.rf_wr_data}={1'b1,Half,Mem}; //Mem =1 implies data is coming from memory
      Lw: {i_control.data_req, i_control.data_byte, i_control.rf_wr_data}={1'b1,Word,Mem}; //Mem =1 implies data is coming from memory
        Lbu: {i_control.data_req, i_control.data_byte, i_control.rf_wr_data,i_control.zero_extnd}={1'b1,Byte,Mem,1'b1}; //Mem =1 implies data is coming from memory
        Lhu: {i_control.data_req, i_control.data_byte, i_control.rf_wr_data,i_control.zero_extnd}={1'b1,Half,Mem,1'b1}; //Mem =1 implies data is coming from memory
    	default: i_control='h0;
    endcase
    
      //for jalr instr
      if(instr_opcode_i==7'b1100111)
        begin
          i_control.rf_wr_data=Pc;
          i_control.pc_sel=1;
          i_control.alu_func_sel=OP_ADD;
        end       
  end
  
  
  
  //for s-type
  control_t s_control;
  
  
  always_comb begin
    //define default contorl signals
    s_control='h0;
    s_control.data_req=1'b1;
    s_control.data_wr=1'b1;
    s_control.op2sel=1'b1;//select the immediate value
    //data_byte information
    case(instr_funct3_i)
      Sb: s_control.data_byte=Byte;
      Sh: s_control.data_byte=Half;
      Sw: s_control.data_byte=Word;
      default: s_control='h0;
    endcase
  end
    
  
  //for branching //for branching, we need alu to compute addition of pc+target addr(specified by immediate)
  control_t b_control;
  
  always_comb begin
    b_control='h0;
    b_control.op1sel=1'b1; //we need to take pc value
    b_control.op2sel=1'b1;
    b_control.alu_func_sel=OP_ADD;
  end
  
  //control signals for u-type
  control_t u_control;
  always_comb begin
    u_control='h0;
    u_control.rf_wr_en=1'b1;
    u_control.rf_wr_data=Imm;
    case(instr_opcode_i)
      Utype1: u_control.rf_wr_data=Pc;
      Utype2: {u_control.op1sel,u_control.op2sel}={1'b1,1'b1}; //for auipc, we need to send pc and immediate value to alu and the alu output has to be written to regfile
			default: u_control='h0;    
    endcase
  end
  
  
  //control signals for j-type
  control_t j_control;
  always_comb begin
    j_control='h0;
    j_control.rf_wr_data=Pc;
    j_control.op1sel=1'b1;
    j_control.op2sel=1'b1;
    j_control.pc_sel=1'b1; //select the target address
  end
  
  
  
  //declarte signal controls to store the result of the control output signals according to the instr
  control_t control;
  
  assign control=(is_r_type_i)?reg_control:
    (is_i_type_i)?i_control:
    (is_s_type_i)?s_control:
    (is_b_type_i)?b_control:
    (is_u_type_i)?u_control:
    (is_j_type_i)?j_control:0;
  
  
  //define the outputs

logic [1:0] rf_wr_data_q;
logic data_req_q;
logic [1:0] data_byte_q;
logic data_wr_q;
logic zero_extnd_q;
logic rf_wr_en_q1;
logic rf_wr_en_q2;
logic pc_sel_q;
/*assign pc_sel_o = control.pc_sel;
assign op1sel_o = control.op1sel;
assign op2sel_o = control.op2sel;
assign alu_func_o = control.alu_func_sel;
assign rf_wr_data_o = control.rf_wr_data;
assign data_req_o = control.data_req;
  assign data_byte_o = control.data_byte;
assign data_wr_o = control.data_wr;
assign zero_extnd_o = control.zero_extnd;
assign rf_wr_en_o = control.rf_wr_en;*/
always_ff @(posedge clk)
begin
if(!reset_n)
begin
rf_wr_data_q<=0;
data_req_q<=0;
data_byte_q<=0;
data_wr_q<=0;
zero_extnd_q<=0;
rf_wr_en_q1<=0;
rf_wr_en_q2<=0;
pc_sel_q<=0;
end
else
begin
//define values for flops
rf_wr_data_q<=control.rf_wr_data;
data_req_q<=control.data_req;
data_byte_q<=control.data_byte;
data_wr_q<=control.data_wr;
zero_extnd_q<=control.zero_extnd;
rf_wr_en_q1<=control.rf_wr_en;
rf_wr_en_q2<=rf_wr_en_q1;
pc_sel_q<=control.pc_sel;
//define the output signals
pc_sel_o<=pc_sel_q;
op1sel_o<=control.op1sel;
op2sel_o<=control.op2sel;
alu_func_o<=control.alu_func_sel;
rf_wr_data_o<=rf_wr_data_q;
data_req_o<=data_req_q;
data_byte_o<=data_byte_q;
data_wr_o<=data_wr_q;
zero_extnd_o<=zero_extnd_q;
rf_wr_en_o<=rf_wr_en_q2;
end
end  
  
  
  
  

endmodule

