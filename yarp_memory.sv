 module data_mem (

input logic clk,reset_n,
input logic [31:0] ex_res_in,
input logic [1:0] mem_wb_rf_wr_data,
input logic mem_data_req,
input logic [1:0] mem_data_type, //need to produce the output data based on this value, still pending (need to implement)
input logic mem_data_wr,
input logic mem_zero_extnd,
input logic wb_rf_wr_en,
input logic [31:0] imm_dec_in,
input logic [31:0] pc_in,
input logic [4:0] mem_rd_addr_in,
input logic [31:0] data_mem_wr_data,
input logic mem_l_type_in,

//output signals
output logic [1:0] mem_wb_rf_wr_data_o,
output logic wb_rf_wr_en_o,
output logic [31:0] imm_dec_o,
output logic [31:0] pc_o,
output logic [31:0] mem_data_out,
output logic mem_comp_out,
output logic [31:0] ex_out,
output logic [4:0] mem_rd_addr_out,
output logic mem_wb_l_type_out);

logic [31:0] mem_addr_in;
assign mem_addr_in = (mem_data_req)?ex_res_in : 0;
logic [31:0] mem_data_temp, mem_data_zero_extnd, mem_data_no_zero_extnd;
logic r_mem_req_in,w_mem_req_in;

assign r_mem_req_in = (mem_data_req)?(!mem_data_wr) : 0;
assign w_mem_req_in = (mem_data_req)?(mem_data_wr) : 0;

assign mem_wb_l_type_out = (!reset_n)?0:mem_l_type_in;
logic [7:0] addr_decode; 
logic [1:0] block_offset; //in my memory, data stored per rwo is 128 bits
assign addr_decode=mem_addr_in[31:24];
assign block_offset=mem_addr_in[3:2];
//create memory unit
logic [127:0] d_mem [255:0];

initial
begin
$readmemh("data.hex",d_mem);
end

always_comb begin
if(r_mem_req_in)
begin
case(block_offset)
2'b00 : mem_data_temp=d_mem[addr_decode][31:0];
2'b01 : mem_data_temp=d_mem[addr_decode][63:32];
2'b10 : mem_data_temp=d_mem[addr_decode][95:64];
2'b11 : mem_data_temp=d_mem[addr_decode][127:96];
endcase
mem_comp_out=1;
end
else if(w_mem_req_in)
begin
case(block_offset)
2'b00 : d_mem[addr_decode][31:0]=data_mem_wr_data;
2'b01 : d_mem[addr_decode][63:32]=data_mem_wr_data;
2'b10 : d_mem[addr_decode][95:64]=data_mem_wr_data;
2'b11 : d_mem[addr_decode][127:96]=data_mem_wr_data;
endcase
mem_comp_out=1;
end
end

//define outputs
assign mem_wb_rf_wr_data_o=mem_wb_rf_wr_data;
assign wb_rf_wr_en_o = wb_rf_wr_en;
assign imm_dec_o=imm_dec_in;
assign pc_o=pc_in;
assign ex_out=ex_res_in; //

//define the output data
assign mem_data_no_zero_extnd = (mem_data_type==2'b00) ? {{24{mem_data_temp[31]}},mem_data_temp[7:0]} : (mem_data_type == 2'b01) ? {{16{mem_data_temp[31]}},mem_data_temp[15:0]} : (mem_data_type==2'b11) ? mem_data_temp : 32'h0;

assign mem_data_zero_extnd = (mem_data_type==2'b00) ? {{24{1'b0}},mem_data_temp[7:0]} : (mem_data_type == 2'b01) ? {{16{1'b0}},mem_data_temp[15:0]} : (mem_data_type==2'b11) ? mem_data_temp : 32'h0;

assign mem_data_out = mem_zero_extnd ? mem_data_zero_extnd : mem_data_no_zero_extnd;

assign mem_rd_addr_out = mem_rd_addr_in;

endmodule





