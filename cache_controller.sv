module cache_controller (clk,reset_n,hit_in,miss_in,wordid_in,tag_in,lineid_in,mem_data_in,mem_comp,tagarray_out,validarray_out,data_out,mem_addr_out,mem_req_o,stall_out,cache_refill_complete);

input logic clk,reset_n; //active low reset
input logic hit_in,miss_in;
input logic [1:0] wordid_in;
input logic [27:0] tag_in;
input logic [1:0] lineid_in;
input logic [127:0] mem_data_in; //we will get the data of all blocks from mem
input logic mem_comp; //indicates that memory has completed the operation which cache has requested it

output logic [27:0] tagarray_out [3:0];
output logic validarray_out [3:0]; //will go to cache_lookup
output logic [31:0] data_out; //will go to cpu
output logic [7:0] mem_addr_out; //mem_addr = {tag_in,lineid_in} -> because we want to bring data associated with entire tag_id and lineid_in
output logic mem_req_o; //requesting the memory for data
output logic stall_out;
output logic cache_refill_complete;


//define values for array outputs
//have the data array declared
logic [127:0] data_array [3:0];
logic [27:0] tag_array [3:0];
logic valid_array [3:0];
logic refill_complete;

//use flops to store the input values(except for mem)data_in) as well, as we need to use them some cycles after we have received them.
logic [1:0]wordid_q;
logic [27:0] tag_q;
logic [1:0] lineid_q;

always_ff @(posedge clk)
begin
if(!reset_n)
begin
wordid_q<=0;
tag_q<=0;
lineid_q<=0;
stall_out<=0;
refill_complete<=0;
end
else
begin
wordid_q<=wordid_in;
tag_q<=tag_in;
lineid_q<=lineid_in;
end
end

always_ff @(posedge clk)
begin
if(!reset_n)
mem_addr_out<=0;
else
mem_addr_out<={tag_q[27:22],lineid_q};
end

//fsms
typedef enum logic [2:0] {Idle,Hit,Miss_Req,Miss_Wait,Miss_Refill} cond;
cond current_cond;
cond next_cond;


//define states
always_ff @(posedge clk)
begin
if(!reset_n)
begin
current_cond<=Idle;
//reset the cache to zero
tag_array<='{default:'0};
data_array<='{default:'0};
valid_array<='{default:'0};
end 
else
current_cond<=next_cond;
end
//define state transition
always_comb begin
case(current_cond)
Idle: next_cond=(hit_in)?Hit:(miss_in)?Miss_Req:Idle;
Hit: next_cond=Idle;
Miss_Req: next_cond=Miss_Wait;
Miss_Wait: next_cond=Miss_Refill;
Miss_Refill: next_cond=(refill_complete & !miss_in)?Idle:Miss_Refill;
default: next_cond=Idle;
endcase
end


//define the state operations
//note, we need to use sequential logic here as we need to store the results in flops, as these will be used across different cycles
logic refill_complete_q;

always_ff @(posedge clk)
begin
if(!reset_n)
begin
refill_complete_q<=0;
end
else
begin
refill_complete_q<=refill_complete;
end
end


always_ff @(posedge clk)
begin
case(current_cond)
Idle: begin 
mem_req_o<=0;
refill_complete<=refill_complete_q;
stall_out<=0;
end

Hit : begin
case(wordid_q)
2'b00: data_out<=data_array[lineid_q][31:0];
2'b01: data_out<=data_array[lineid_q][63:32];
2'b10: data_out<=data_array[lineid_q][95:64];
2'b11: data_out<=data_array[lineid_q][127:96];
endcase
mem_req_o<=0;
refill_complete<=0;
stall_out<=0;
end

//we need to request the memory to send us data
Miss_Req: begin 
mem_req_o<=1;
refill_complete<=0;
stall_out<=1;
end

Miss_Wait: begin 
mem_req_o<=1;
refill_complete<=0;
stall_out<=1;
end

Miss_Refill: begin
//proceed with updating the tag_array, data_array and output only if memory has completed the operation
if(mem_comp)
begin
tag_array[lineid_q]<=tag_q;
data_array[lineid_q]<=mem_data_in;
case(wordid_q)
2'b00: data_out<=mem_data_in[31:0];
2'b01: data_out<=mem_data_in[63:32];
2'b10: data_out<=mem_data_in[95:64];
2'b11: data_out<=mem_data_in[127:96];
endcase
valid_array[lineid_q]<=1;
refill_complete<=1;
stall_out<=0;
end
else if(!mem_comp)
begin
//if not completed, retain the old values
tag_array[lineid_q]<=tag_array[lineid_q];
data_array[lineid_q]<=data_array[lineid_q];
refill_complete<=0;
stall_out<=1;
end
end
endcase
end
//assign the tag_array and valid_array outputs
assign tagarray_out=tag_array;
assign validarray_out=valid_array;
assign cache_refill_complete=refill_complete;
endmodule


