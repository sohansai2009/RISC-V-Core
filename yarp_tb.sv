module yarp_tb;

//define the signals
logic  clk,reset_n;
logic instr_mem_req; //output of the top module which requests instruction memory access
logic [31:0] instr_mem_addr; //pc_q -> address from which processor wants to take the next instruction
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
$readmemh("./instruction.hex",imem); //store the contents of add.hex in imem
//example: instr_mem_addr = pc_q = 0x00001004 -> in bin: 0000 0000 0000 0000 0001 00[00 0000 01]00 -> implies imm[1]
//example: instr_mem_addr = pc_q = 0x00001008 -> in bin: 0000 0000 0000 0000 0001 00[00 0000 10]00 -> implies imm[2]
//example: instr_mem_addr = pc_q = 0x0000100c -> in bin: 0000 0000 0000 0000 0001 00[00 0000 11]00 -> implies imm[3]
end

assign instr_mem_rd_data=imem[instr_mem_addr[9:2]];


//logic for dmem
logic [31:0] d_cache [255:0]; //this d_cache will come before the memory, if the daddr is within the cache limit, then cpu can directly access the data from the cache
logic data_mem_req;
logic [31:0] data_mem_addr; //data mem addrs on which cpu wants to operate
logic [1:0] data_mem_byte_en; //for lh,lb,lw instructions
logic data_mem_wr; //if enabled, cpu wants to write data to spec address
logic [31:0] data_mem_wr_data; //data written into data_mem by cpu
logic [31:0] data_mem_rd_data; //data sent from data mem to cpu for load instr

initial
begin
//read the .hex file (which contains the data)
$readmemh("./data.hex",d_cache);
//logic:
//data mem can only be accessed by lw/sw instructions
//data_mem_req_o -> output request from cpu which indicates it requires access to the data mem
//reading data from the cache
data_mem_rd_data=(data_mem_req)?d_cache[data_mem_addr[9:2]]:0;
$display("data read %4h which is present at location %0d in cache and is %4h",data_mem_rd_data,data_mem_addr[9:2],d_cache[data_mem_addr[9:2]]);
end


always_ff @(posedge clk)
begin
if(!reset_n)
d_cache[data_mem_addr[9:2]]<=d_cache[data_mem_addr[9:2]]; //restore the value during reset
else
d_cache[data_mem_addr[9:2]]<=(data_mem_wr)?data_mem_wr_data:d_cache[data_mem_addr[9:2]]; //if write is enabled, store the incoming data to d_cache else retain the prev value
end


//instantiate the top module
yarp_top dut(clk,reset_n,instr_mem_req,instr_mem_addr,instr_mem_rd_data,data_mem_req,data_mem_addr,data_mem_byte_en,data_mem_wr,data_mem_wr_data,data_mem_rd_data);


initial
begin
reset_n=0;
#20;
reset_n=1;
#100;
$finish;
end
endmodule










