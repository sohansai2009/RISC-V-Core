
module sa_control (clk,reset_n,hit_in,miss_in,tag_id_in,set_cache_line_in,set_id_in,block_offset_in,valid_array_in,tag_array_out,valid_array_out,mem_req_o,addr_mem_o,mem_comp,mem_data_in,data_out,i_cache_busy,cache_refill_complete,set_full,way_id_out,wr_fif_en_o);

input logic clk,reset_n;
input logic hit_in,miss_in;
input logic [25:0] tag_id_in;
input logic [3:0] set_cache_line_in;
input logic [1:0] set_id_in;
input logic [1:0] block_offset_in;
input logic valid_array_in [15:0];

output logic [25:0] tag_array_out [15:0];
output logic valid_array_out [15:0]; //will go to lru and lookup
output logic mem_req_o;
output logic [7:0] addr_mem_o;

input logic mem_comp;
input logic [127:0] mem_data_in;

output logic [31:0] data_out; //will go the cpu
output logic i_cache_busy;
output logic cache_refill_complete;
output logic set_full;
output logic [3:0] way_id_out;
output logic wr_fif_en_o; //enable signal to fifo indicating when to write and when not to write

//declare internal registers
logic [25:0] tag_array [15:0];
logic valid_array [15:0];
logic [127:0] data_array [15:0];
logic refill_complete;
//reg to identify which cache line to update in case of a cache miss
logic [3:0] miss_update_cache_line;
logic wr_fif_en;

logic [25:0] tag_array_q;
logic [1:0] set_id_q;
logic [1:0] block_offset_q;

parameter S0=2'b00;
parameter S1=2'b01;
parameter S2=2'b10;
parameter S3=2'b11;
//define the states
typedef enum logic [2:0] {Idle,Hit,Miss_Req,Miss_Wait,Miss_Refill} state;
state c_state;
state n_state;

logic [3:0] miss_update_cache_line_q;
logic refill_complete_q;

always_ff @(posedge clk)
begin
if(!reset_n)
refill_complete_q<=0;
else
refill_complete_q<=(c_state==Miss_Refill)?refill_complete:refill_complete_q;
end

always_ff @(posedge clk)
begin
if(!reset_n)
begin
tag_array_q<=0;
set_id_q<=0;
block_offset_q<=0;
end
else
begin
tag_array_q<=tag_id_in;
set_id_q<=set_id_in;
block_offset_q<=(refill_complete)?block_offset_in:block_offset_q;
end
end

//define the default values
always_ff @(posedge clk)
begin
if(!reset_n)
begin
tag_array<='{default:'0};
data_array<='{default:'0};
valid_array<='{default:'0};
end
end

//define the state values
always_ff @(posedge clk)
begin
if(!reset_n)
c_state<=Idle;
else
c_state<=n_state;
end

//define state transition
always_comb begin
case(c_state)
Idle : n_state = (hit_in) ? Hit : (miss_in) ? Miss_Req : Idle;
Hit : n_state=Idle; 
Miss_Req : n_state=Miss_Wait;
Miss_Wait: n_state=Miss_Refill;
Miss_Refill : n_state=(refill_complete_q)?Idle:Miss_Refill;
default : n_state=Idle;
endcase
end

always_ff @(posedge clk)
begin
if(!reset_n)
miss_update_cache_line_q<=4'b0000;
else
miss_update_cache_line_q<=miss_update_cache_line;
end
//define the state operations
always_ff @(posedge clk)
begin
case(c_state)
Idle : begin
refill_complete<=0;
mem_req_o<=0;
addr_mem_o<=0;
miss_update_cache_line<=miss_update_cache_line_q;
end

Hit: begin
case(block_offset_q)
2'b00 : data_out <= data_array[set_cache_line_in][31:0];
2'b01 : data_out <= data_array[set_cache_line_in][63:32];
2'b10 : data_out <= data_array[set_cache_line_in][95:64];
2'b11 : data_out <= data_array[set_cache_line_in][127:96];
endcase
end

Miss_Req: begin
//determine the cache line to be updated (which ever is line free as denoted by the valid_bit for each line)
case(set_id_q)

S0:begin
if(valid_array_in[0]==0)
miss_update_cache_line<=0;
else if(valid_array_in[1]==0)
miss_update_cache_line<=1;
else if(valid_array_in[2]==0)
miss_update_cache_line<=2;
else if(valid_array_in[3]==0)
miss_update_cache_line<=3;
end

S1: begin
if(valid_array_in[4]==0)
miss_update_cache_line<=4;
else if(valid_array_in[5]==0)
miss_update_cache_line<=5;
else if(valid_array_in[6]==0)
miss_update_cache_line<=6;
else if(valid_array_in[7]==0)
miss_update_cache_line<=7;
end

S2: begin
if(valid_array_in[8]==0)
miss_update_cache_line<=8;
else if(valid_array_in[9]==0)
miss_update_cache_line<=9;
else if(valid_array_in[10]==0)
miss_update_cache_line<=10;
else if(valid_array_in[11]==0)
miss_update_cache_line<=11;
end

S3: begin
if(valid_array_in[12]==0)
miss_update_cache_line<=12;
else if(valid_array_in[13]==0)
miss_update_cache_line<=13;
else if(valid_array_in[14]==0)
miss_update_cache_line<=14;
else if(valid_array_in[15]==0)
miss_update_cache_line<=15;
end
endcase

mem_req_o<=1;
refill_complete<=0;
addr_mem_o<={tag_array_q[25:20],set_id_q};
end

Miss_Wait: begin
mem_req_o<=1;
refill_complete<=0;
end

Miss_Refill: begin
if(mem_comp)
begin
//update the tag and the instructions(data of each cache line) of a parcitular line in a set
tag_array[miss_update_cache_line]<=tag_array_q;
data_array[miss_update_cache_line]<=mem_data_in;
valid_array[miss_update_cache_line]<=1;
//after you have filled the particular cache_block in a set, you need to send it's details(line_id and valid_bit) to the lru to keep track of the recently filled
way_id_out<=miss_update_cache_line;
wr_fif_en<=1;
//produce output
case(block_offset_q)
2'b00 : data_out<=mem_data_in[31:0];
2'b01 : data_out<=mem_data_in[63:32];
2'b10 : data_out<=mem_data_in[95:64];
2'b11 : data_out<=mem_data_in[127:96];
endcase
refill_complete<=1;
end
else
begin
valid_array[miss_update_cache_line]<=0;
end
end
endcase
end



//define the logic for detecting when set is full
always_ff @(posedge clk)
begin
if(!reset_n)
set_full<=0;
else
begin
case(set_id_q)
S0 : set_full <= (valid_array[0] && valid_array[1] && valid_array[2] && valid_array[3]); //full has to be calculated on when miss detected, during hit, we need not replace the cache block
S1 : set_full <= (valid_array[4] && valid_array[5] && valid_array[6] && valid_array[7]);
S2: set_full <=  (valid_array[8] && valid_array[9] && valid_array[10] && valid_array[11]);
S3: set_full <=  (valid_array[12] && valid_array[13] && valid_array[14] && valid_array[15]);
endcase
end
end

//define the outputs
assign tag_array_out=tag_array;
assign valid_array_out=valid_array;
assign i_cache_busy = ((c_state==Miss_Req)||(c_state==Miss_Wait) || (c_state==Miss_Refill))?1:0;
assign wr_fif_en_o=(n_state==Idle) ? 0 :(c_state==Miss_Refill)?1 : 0;
endmodule




