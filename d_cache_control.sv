module d_cache_control (clk,reset_n,hit_in,miss_in,tagid_in,lineid_in,wordid_in,mem_data_in,wren_in,byte_in,wdata_in,zeroext_in,r_mem_req,w_mem_req,tag_array_out,valid_array_out,mem_addr_out,data_out_data_cache,mem_wr_en,mem_wr_data,mem_comp,word_id_out,byte_out,zeroext_out,d_cache_busy);
input logic clk,reset_n;

//inputs from cache_lookup
input logic hit_in,miss_in;
input logic [27:0] tagid_in;
input logic [1:0] lineid_in,wordid_in;
input logic [127:0] mem_data_in;

//inputs from the risc-v core
input logic wren_in;
input logic [1:0] byte_in;
input logic [31:0] wdata_in; //store operation -> data to be written to the memory
input logic zeroext_in;
                                                                                                     
//outputs 
output logic r_mem_req;
output logic w_mem_req; //will go to memory
output logic [27:0] tag_array_out [3:0]; //will go to cache_lookup
output logic valid_array_out [3:0]; //will go to cache_lookup
output logic [7:0]mem_addr_out; //mem_addr_out={tagid_in,lineid_in} //to memory
output logic [31:0] data_out_data_cache; //data to be send to the risc-v core (for load operations) //to cpu
output logic mem_wr_en; //to memory -> indicating what operation (lw/sw)
output logic [31:0] mem_wr_data;//data to be written into the memory

input logic mem_comp; //will come from memory
output logic [1:0] word_id_out; //to send to the memory (for store operation)
output logic [1:0] byte_out;
output logic zeroext_out;
output logic d_cache_busy;
//for registers to identify read/write hit/miss
logic r_hit,r_miss,w_hit,w_miss;

//use flops to store the values of tag_id, lineid and wordid
logic [27:0] tagid_q;
logic [1:0] lineid_q,wordid_q;

//create the tag,data and valid arrays
logic [127:0] data_array [3:0];
logic [27:0] tag_array [3:0];
logic valid_array [3:0];

always_ff @(posedge clk)
begin
if(!reset_n)
begin
byte_out<=0;
zeroext_out<=0;
end
else
begin
byte_out<=byte_in;
zeroext_out <= zeroext_in;
end
end
 
//assign the values
assign r_hit = (wren_in)?0:hit_in; //wren_in = 1 -> store operation (write to the memory)
assign r_miss = (wren_in)?0:miss_in;

assign w_hit = (wren_in)?hit_in:0;
assign w_miss = (wren_in)?miss_in:0;

always_ff @(posedge clk)
begin
if(!reset_n)
begin
tagid_q<=0;
lineid_q<=0;
wordid_q<=0;
end
else
begin
tagid_q<=tagid_in;
lineid_q<=lineid_in;
wordid_q<=(r_next_state==R_Miss_Refill)?wordid_q:wordid_in; //if we are refilling the cache, we need to preserve the word_id
end
end

//***************Logic for Read******************

//logic states for read hit
typedef enum logic [3:0] {R_Idle,R_Hit,R_Miss_Req,R_Miss_Wait,R_Miss_Refill} r_state;
r_state r_current_state;
r_state r_next_state;

//define the state values
always_ff @(posedge clk)
begin
if(!reset_n)
begin
r_current_state<=R_Idle;
//define the default values for the arrays
data_array <= '{default:'0};
tag_array <= '{default:'0};
valid_array <= '{default: '0};
end
else
begin
r_current_state<=r_next_state;
end
end

logic refill_complete;
//define the state transitions
always_comb begin
case(r_current_state)
R_Idle:r_next_state=(r_hit)?R_Hit:(r_miss)?R_Miss_Req:R_Idle;
R_Hit:r_next_state=R_Idle;
R_Miss_Req: r_next_state=R_Miss_Wait;
R_Miss_Wait: r_next_state=R_Miss_Refill;
R_Miss_Refill: r_next_state=(refill_complete & !miss_in)?R_Idle:R_Miss_Refill;
default: r_next_state=R_Idle;
endcase
end


//use flop to store mem_data_in;
logic [127:0] mem_data_q;
always_ff @(posedge clk)
begin
if(!reset_n)
begin
mem_data_q<=0;
end
else
begin
mem_data_q<=mem_data_in;
end
end

//define the state operations
always_ff @(posedge clk)
begin
case(r_current_state)
R_Idle:begin
refill_complete<=0;
r_mem_req<=0;
end

R_Hit:begin
case(wordid_q)
2'b00: data_out_data_cache <= data_array[lineid_q][31:0];
2'b01: data_out_data_cache<=data_array[lineid_q][63:32];
2'b10: data_out_data_cache<=data_array[lineid_q][95:64];
2'b11: data_out_data_cache<=data_array[lineid_q][127:96];
endcase
end

R_Miss_Req: begin
mem_addr_out<={tagid_q[27:22],lineid_q};
r_mem_req<=1;
end

R_Miss_Wait: begin
r_mem_req<=1;
end

R_Miss_Refill: begin
if(mem_comp)
begin
tag_array[lineid_q]<=tagid_q;
valid_array[lineid_q]<=lineid_q;
data_array[lineid_q]<=mem_data_in; //pre-fetch -> we are updating the other words in the cache line as well
//output
case(wordid_q)
2'b00: data_out_data_cache <= mem_data_in[31:0];
2'b01: data_out_data_cache<=mem_data_in[63:32];
2'b10: data_out_data_cache<=mem_data_in[95:64];
2'b11: data_out_data_cache<=mem_data_in[127:96];
endcase
refill_complete<=1;
end
else
begin
tag_array[lineid_q]<=tag_array[lineid_q];
valid_array[lineid_q]<=valid_array[lineid_q];
data_array[lineid_q]<=data_array[lineid_q];
refill_complete<=0;
end
end
endcase
end

//********Logic for Write*********
//logic states
typedef enum logic [1:0] {W_Idle,W_Hit,W_Miss} w_state;
w_state w_current_state;
w_state w_next_state;


//define state values
always_ff @(posedge clk)
begin
if(!reset_n)
begin
w_current_state<=W_Idle;
end
else
begin
w_current_state<=w_next_state;
end
end

//define state transitions
always_comb begin
case(w_current_state)
W_Idle:w_next_state=(w_hit)?W_Hit:(w_miss)?W_Miss:W_Idle;
W_Hit: w_next_state=W_Idle;
W_Miss: w_next_state=W_Idle;
default: w_next_state=W_Idle;
endcase
end

logic [31:0] wdata_q;
always_ff @(posedge clk)
begin
if(!reset_n)
wdata_q<=0;
else
wdata_q<=wdata_in;
end

//define state operations
always_ff @(posedge clk)
begin
case(w_current_state)
W_Idle:begin
mem_wr_en<=0;
mem_wr_data<=0;
mem_addr_out<=0;
w_mem_req<=0;
end

W_Hit:begin
w_mem_req<=1;  //always has to be one as we are requesting the memory to perform operation on it
mem_wr_en<=wren_in;
//first, update the block in the cache line with the correct data
case(wordid_q)
2'b00:data_array[lineid_q][31:0]<=wdata_q;
2'b01:data_array[lineid_q][63:32]<=wdata_q;
2'b10:data_array[lineid_q][95:64]<=wdata_q;
2'b11:data_array[lineid_q][127:96]<=wdata_q;
endcase
mem_wr_data<=wdata_q; //this is to update the block in the main memory
mem_addr_out<={tag_array[lineid_q][27:22],lineid_q};
word_id_out<=wordid_q;
end

W_Miss:begin
w_mem_req<=1;  //always has to be one as we are requesting the memory to perform operation on it
mem_wr_en<=wren_in;
mem_wr_data<=wdata_q;
mem_addr_out<={tagid_q[27:22],lineid_q};
word_id_out<=wordid_q;
end
endcase
end


assign tag_array_out=tag_array;
assign valid_array_out=valid_array;


assign d_cache_busy=(r_next_state!=R_Idle || w_next_state!=W_Idle);
endmodule










 
