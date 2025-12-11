module yarp_tb;

//define the signals
logic  clk,reset_n;
logic instr_mem_req; //output of the top module which requests instruction memory access
logic [31:0] instr_addr; //pc_q -> address from which processor wants to take the next instruction
logic [31:0] instr_mem_rd_data; //instr sent out by the instr_memory

//create imem 
logic [31:0] imem [31:0] ; //imem can store 256 instr each of 32 bits in length


//define clock signal
initial
begin
clk=0;
end

always #5 clk=~clk;
//read the .hex file

//logic for imem

initial
begin
$readmemh("instr_mem.hex",imem); //store the contents of add.hex in imem
//example: instr_mem_addr = pc_q = 0x00001004 -> in bin: 0000 0000 0000 0000 0001 00[00 0000 01]00 -> implies imm[1]
//example: instr_mem_addr = pc_q = 0x00001008 -> in bin: 0000 0000 0000 0000 0001 00[00 0000 10]00 -> implies imm[2]
//example: instr_mem_addr = pc_q = 0x0000100c -> in bin: 0000 0000 0000 0000 0001 00[00 0000 11]00 -> implies imm[3]
end
assign instr_mem_rd_data = imem[instr_addr[9:2]];

yarp_top dut(clk,reset_n,instr_mem_req,instr_addr,instr_mem_rd_data);

initial
begin
reset_n=0;
#20;
reset_n=1;
end
endmodule










