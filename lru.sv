module lru(clk,reset_n,wr_en,way_id_in,valid_in,full,way1,way2,way3,valid_out_rg);

input logic clk,reset_n;
input logic wr_en;
input logic [3:0] way_id_in ; //from cache controller
input logic valid_in [15:0]; //one hot encoded array which tells which block in set has data -> from cache_controller
input logic full; //full=1 -> all ways in a set are full
output logic [4:0] way1,way2,way3;  //will combine the way_id and the valid bit for that particular way
output logic valid_out_rg [15:0];

logic [1:0] set_id;
//declare four fifos, for four sets
logic [4:0] fifo_s0 [3:0];
logic [4:0] fifo_s1 [3:0];
logic [4:0] fifo_s2 [3:0];
logic [4:0] fifo_s3 [3:0];

//paremetrize the sets
parameter S0=2'b00;
parameter S1=2'b01;
parameter S2=2'b10;
parameter S3=2'b11;

//based on the incoming way_id_in, identify the set
always_comb begin
case(way_id_in)
4'b0000,
4'b0001,
4'b0010,
4'b0011 : set_id=S0;

4'b0100,
4'b0101,
4'b0110,
4'b0111 : set_id=S1;

4'b1000,
4'b1001,
4'b1010,
4'b1011 : set_id=S2;

4'b1100,
4'b1101,
4'b1110,
4'b1111 : set_id=S3;

endcase
end

//write pointer
logic [1:0] wptr_s0,wptr_s1,wptr_s2,wptr_s3;
//write the data to the corresponding fifos if set is not full (as indicated by full)
always_ff @(posedge clk)
begin
if(!reset_n)
begin
fifo_s0 <= '{default:'0};
fifo_s1 <= '{default:'0};
fifo_s2 <= '{default:'0};
fifo_s3 <= '{default:'0};
wptr_s0<=0;
wptr_s1<=0;
wptr_s2<=0;
wptr_s3<=0;
end
else
begin
case(set_id)

S0 : begin
if(!full & wr_en) //if not full, we need to write
begin
fifo_s0[wptr_s0]<={way_id_in,valid_in[way_id_in]}; //if not full, we store the way_id to which data was written(during cache_miss) (if valid_in[way_id]==1 -> data written to that particular way_id)
wptr_s0<=wptr_s0+1;
end
else if(full) //if full, we need to send the least recently used way_id's (the way_id's in the bottom three locations in our case)
begin
way1<={fifo_s0[0][4:1],1'b0};
way2<={fifo_s0[1][4:1],1'b0};
//now, you need to shift fifo_s0[3] to fifo_s0[0] and all three locations to zero and wptr to 1, so that next data can be filled starting from pos1 in the fifo
fifo_s0[0]<=fifo_s0[2];
fifo_s0[1]<=fifo_s0[3];
fifo_s0[2]<=0;
fifo_s0[3]<=0;
wptr_s0<=2;
end
end

S1 : begin
if(!full & wr_en) //if not full, we need to write
begin
fifo_s1[wptr_s1]<={way_id_in,valid_in[way_id_in]}; //if not full, we store the way_id to which data was written(during cache_miss) (if valid_in[way_id]==1 -> data written to that particular way_id)
wptr_s1<=wptr_s1+1;
end
else if(full) //if full, we need to send the least recently used way_id's (the way_id's in the bottom three locations in our case)
begin
way1<={fifo_s1[0][4:1],1'b0};
way2<={fifo_s1[1][4:1],1'b0};
//now, you need to shift fifo_s0[3] to fifo_s0[0] and all three locations to zero and wptr to 1, so that next data can be filled starting from pos1 in the fifo
fifo_s1[0]<=fifo_s1[2];
fifo_s1[1]<=fifo_s1[3];
fifo_s1[2]<=0;
fifo_s1[3]<=0;
wptr_s1<=2;
end
end

S2 : begin
if(!full & wr_en) //if not full, we need to write
begin
fifo_s2[wptr_s2]<={way_id_in,valid_in[way_id_in]}; //if not full, we store the way_id to which data was written(during cache_miss) (if valid_in[way_id]==1 -> data written to that particular way_id)
wptr_s2<=wptr_s2+1;
end
else if(full) //if full, we need to send the least recently used way_id's (the way_id's in the bottom three locations in our case)
begin
way1<={fifo_s2[0][4:1],1'b0};
way2<={fifo_s2[1][4:1],1'b0};
//now, you need to shift fifo_s0[3] to fifo_s0[0] and all three locations to zero and wptr to 1, so that next data can be filled starting from pos1 in the fifo
fifo_s2[0]<=fifo_s2[2];
fifo_s2[1]<=fifo_s2[3];
fifo_s2[2]<=0;
fifo_s2[3]<=0;
wptr_s2<=2;
end
end

S3 : begin
if(!full & wr_en) //if not full, we need to write
begin
fifo_s3[wptr_s3]<={way_id_in,valid_in[way_id_in]}; //if not full, we store the way_id to which data was written(during cache_miss) (if valid_in[way_id]==1 -> data written to that particular way_id)
wptr_s3<=wptr_s3+1;
end
else if(full) //if full, we need to send the least recently used way_id's (the way_id's in the bottom three locations in our case)
begin
way1<={fifo_s3[0][4:1],1'b0}; //1'b0 implies valid bit will be zero
way2<={fifo_s3[1][4:1],1'b0};
//now, you need to shift fifo_s0[3] to fifo_s0[0] and all three locations to zero and wptr to 1, so that next data can be filled starting from pos1 in the fifo
fifo_s3[0]<=fifo_s3[2];
fifo_s3[1]<=fifo_s3[3];
fifo_s3[2]<=0;
fifo_s3[3]<=0;
wptr_s3<=2;
end
end

endcase
end
end

assign valid_out_rg=valid_in;

endmodule






