module cache_tb;
logic clk,reset_n;
logic [31:0] in_addr; //incoming address from CPU

//output signals
logic [27:0] tagarray_out [3:0];
logic validarray_out [3:0];
logic [31:0] data_out;


//instantiate the top module
cache_top dut(clk,reset_n,in_addr,tagarray_out,validarray_out,data_out);

//define the clock signal
initial begin
clk=0;
end

always #5 clk=~clk;


//define the signals
initial
begin
reset_n=0;
#20;
reset_n=1;
in_addr=32'hF9A7C1F0;
end
endmodule


