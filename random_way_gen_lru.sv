module random_way_gen (clk,reset_n,way1_in,way2_in,valid_lru_in,valid_out);

input logic clk,reset_n;
input logic [4:0] way1_in,way2_in;
input logic valid_lru_in [15:0];
output logic valid_out[15:0];

logic valid_temp[15:0];
logic [3:0] way_id1,way_id2;

assign way_id1=way1_in[4:1]; //define the way_id's
assign way_id2=way2_in[4:1];

always_comb begin //logic for valid_bit
valid_temp=valid_lru_in;
if(way1_in[0]==0)
valid_temp[way_id1]=0;
else if(way2_in[0]==0)
valid_temp[way_id2]=0;
end

always_ff @(posedge clk)
begin
if(!reset_n)
valid_out<='{default:'0};
else
valid_out<=valid_temp;
end

endmodule

