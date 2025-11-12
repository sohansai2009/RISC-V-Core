// --------------------------------------------------------
// YARP: Package File
//
// The should contain all of the enums, structs or any other
// common functions used while designing the YARP core
// --------------------------------------------------------
// --------------------------------------------------------
// YARP Package
// --------------------------------------------------------

package yarp_pkg;
//define the typedef enum sattes
  typedef enum logic [6:0] {
    R_type=7'h33,
    I_type1=7'h67,
    I_type2=7'h03,
    I_type3=7'h13,
    S_type=7'h23,
    B_type=7'h63,
    U_type1=7'h37,
    U_type2=7'h17,
    J_type=7'h6F} OP_CODE;
  
  
  
  //ALU Operations
  //in this case, OP_add willt ake value of 0 and every state will take icnremented value from 1
  typedef enum logic [3:0] {
    OP_ADD,
    OP_SUB,
    OP_SLL,
    OP_SRL,
    OP_SRA,
    OP_OR,
    OP_AND,
    OP_XOR,
    OP_SLTU,
    OP_SLT 
  } alu_op;
  
  //define the encoidng of the 2 bit encoding signal, which indicates what type of data does the cpu want to read
  typedef enum logic [1:0]{
    Byte = 2'b00,
    Half = 2'b01,
    Word = 2'b11
  } data_access_size; //LW/LH/LB or SW/SH/SB
  
  
  
  //enum logic to identify among different I-type instr
  //for i-type, we need to consider {opcode[4],funct3}
  typedef enum logic [3:0] {
    Lb = 4'h0,
    Lh = 4'h1,
    Lw = 4'h2,
    Lbu = 4'h4,
    Lhu = 4'h5,
    Addi = 4'h8,
    Slti = 4'ha,
    Sltiu = 4'hb,
    Xori= 4'hc,
    Ori = 4'he,
    Andi = 4'hf,
    Slli = 4'h9,
    Srxi = 4'hd //for srli and srai
  } i_type;

  //typedef enum logic to identify between different r-type 
  //we need to consider {instr7[5], instr3} for differentiating between different r-type
  typedef enum logic [3:0] {
    Add = 4'h0,
    Sub = 4'h8,
    Sll = 4'h1,
    Slt = 4'h2,
    Sltu = 4'h3,
    Xor = 4'h4,
    Srl = 4'h5,
    Sra = 4'hd,
    Or = 4'h6,
    And = 4'h7
  } r_type;
  
  
  //group all the control sognals coming out from controlelr into a structure
  typedef struct packed {
   	logic         pc_sel;
  	logic         op1sel;
    logic         op2sel;
    logic [3:0]   alu_func_sel;
    logic [1:0]   rf_wr_data; //tells what data to write into the reg file
    logic         data_req;
    logic [1:0]   data_byte;
    logic         data_wr; //indicates whetehr we have to write to mem or not
    logic         zero_extnd;
    logic         rf_wr_en;
  } control_t;

  
  //typedef to tell the mux which data to write to the reg_file
  typedef enum logic [1:0] {
    Alu=2'b00,
    Mem=2'b01,
    Imm=2'b10,
    Pc=2'b11
  } rf_write_ctrl;

  
  //typedef for s-type
  typedef enum logic [2:0] {
    Sb=3'h0,
    Sh=3'h1,
    Sw=3'h2
  } s_type;
  
  
  //typedef enum for branch type
  typedef enum logic [2:0]{
    Beq=3'h0,
    Bne=3'h1,
    Blt=3'h4,
    Bge=3'h5,
    Bltu=3'h6,
    Bgeu=3'h7
  } b_type;
  
  
  //typedef enum for U-type
  typedef enum logic [6:0] {
    Utype1=7'b0110111,
    Utype2=7'b0010111
  } u_type;
  
endpackage

