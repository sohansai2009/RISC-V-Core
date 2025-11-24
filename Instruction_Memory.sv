module imem(clk,reset_n,mem_req_in,in_addr,data_out,mem_done);
input logic clk,reset_n;
input logic mem_req_in;
input logic [7:0] in_addr;
output logic [127:0] data_out;
output logic mem_done;


//declare memory
logic [127:0] i_mem [255:0];
//load the data into mem from .hex file
initial
begin
$readmemh("instr_mem.hex",i_mem);
end


//now, we need to produce the output only when cache requests data from main memory
always_ff @(posedge clk)
begin
if(reset_n)
begin
if(mem_req_in)
begin
data_out<=i_mem[in_addr];
mem_done<=1; //implies memory has successfully sent cache the data it asked for
end
end
else
begin
mem_done<=0;
data_out<=0;
end
end

endmodule


