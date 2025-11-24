module yarp_tb;

//define the signals
logic  clk,reset_n;

//define clock signal
initial
begin
clk=0;
end

always #5 clk=~clk;

logic stall,cache_refill_complete_yarp;
logic [31:0] data_mem_rd_data_i;
//instantiate the top module
yarp_top dut(clk,reset_n,data_mem_rd_data_i);


initial
begin
reset_n=0;
#20;
reset_n=1;
end
endmodule










