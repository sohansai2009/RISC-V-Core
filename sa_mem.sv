module sa_mem(clk,reset_n,mem_req_in,mem_addr_in,mem_data_out,mem_comp_out);
input logic clk,reset_n;
input logic mem_req_in;
input logic [7:0] mem_addr_in;
output logic [127:0] mem_data_out;
output logic mem_comp_out;

//memory unit
logic [127:0] mem [255:0];

initial
begin
$readmemh("instr_mem.hex",mem);
end

always_ff @(posedge clk)
begin
if(!reset_n)
begin
mem_data_out<=0;
mem_comp_out<=0;
end
else if(mem_req_in)
begin
mem_data_out<=mem[mem_addr_in];
mem_comp_out<=1;
end
else if(!mem_req_in)
begin
mem_data_out<=0;
mem_comp_out<=0;
end
end
endmodule

