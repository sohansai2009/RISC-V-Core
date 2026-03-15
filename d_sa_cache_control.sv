module d_sa_control (clk,reset_n,wr_en,wdata_in,byte_id,zero_ext,valid_array_in,set_cache_line_in,hit,miss,tag_id_in,set_id_in,block_offset_in,mem_req_o,mem_comp,mem_addr_o,mem_w_data,mem_data_in,data_out,tag_array_out,valid_array_out,d_cache_busy,way_id_out,wr_en_fifo,set_full,r_req,w_req,block_offset_out,byte_id_out,zero_extnd_out);

input logic clk,reset_n;
input logic wr_en;
input logic [31:0] wdata_in;
input logic [1:0] byte_id;
input logic zero_ext;
input logic valid_array_in[15:0];
input logic [15:0] set_cache_line_in;

input logic hit,miss;
input logic [27:0] tag_id_in;
input logic [1:0] set_id_in;
input logic [1:0] block_offset_in;

output logic mem_req_o;
input  logic mem_comp;

// FIX 1: Widened from 8-bit to 12-bit to correctly address data memory
output logic [11:0] mem_addr_o;

output logic [31:0] mem_w_data;
input  logic [127:0] mem_data_in;
output logic [31:0] data_out;

output logic [27:0] tag_array_out [15:0];
output logic valid_array_out [15:0];
output logic d_cache_busy;
output logic [3:0] way_id_out;
output logic wr_en_fifo;
output logic set_full;
output logic r_req, w_req;
output logic [1:0] block_offset_out;
output logic [1:0] byte_id_out;
output logic zero_extnd_out;

always_ff @(posedge clk)
begin
  if (!reset_n) begin
    byte_id_out   <= 0;
    zero_extnd_out <= 0;
  end else begin
    byte_id_out   <= byte_id;
    zero_extnd_out <= zero_ext;
  end
end

parameter S0 = 2'b00;
parameter S1 = 2'b01;
parameter S2 = 2'b10;
parameter S3 = 2'b11;

logic r_hit, r_miss, w_hit, w_miss;
logic refill_complete;
logic [1:0]  block_offset_q;
logic [1:0]  set_id_q;
logic [27:0] tag_id_q;

logic [27:0]  tag_array  [15:0];
logic         valid_array[15:0];
logic [127:0] data_array [15:0];
logic [3:0]   miss_update_cache_line, miss_update_cache_line_q;

always_ff @(posedge clk)
begin
  if (!reset_n) begin
    block_offset_q <= 0;
    set_id_q       <= 0;
    tag_id_q       <= 0;
    tag_array      <= '{default:'0};
    valid_array    <= '{default:'0};
    data_array     <= '{default:'0};
  end else begin
    block_offset_q <= block_offset_in;
    tag_id_q       <= tag_id_in;
    set_id_q       <= set_id_in;
  end
end

assign r_hit  = (wr_en) ? 0 : hit;
assign r_miss = (wr_en) ? 0 : miss;
assign w_hit  = (wr_en) ? hit  : 0;
assign w_miss = (wr_en) ? !hit : 0;

// ── Read state machine ──────────────────────────────────────────────
typedef enum logic [2:0] {R_Idle, R_Hit, R_Miss_Req, R_Miss_Wait, R_Miss_Refill} r_state;
r_state r_c_state, r_n_state;

always_ff @(posedge clk)
begin
  if (!reset_n) r_c_state <= R_Idle;
  else          r_c_state <= r_n_state;
end

always_comb begin
  case (r_c_state)
    R_Idle       : r_n_state = (r_hit)  ? R_Hit      :
                               (r_miss) ? R_Miss_Req : R_Idle;
    R_Hit        : r_n_state = R_Idle;
    R_Miss_Req   : r_n_state = R_Miss_Wait;
    R_Miss_Wait  : r_n_state = R_Miss_Refill;
    R_Miss_Refill: r_n_state = (refill_complete) ? R_Idle : R_Miss_Refill;
    default      : r_n_state = R_Idle;
  endcase
end

always_ff @(posedge clk)
begin
  if (!reset_n) miss_update_cache_line_q <= 4'b0000;
  else          miss_update_cache_line_q <= miss_update_cache_line;
end

always_ff @(posedge clk)
begin
  case (r_c_state)
    R_Idle: begin
      refill_complete          <= 0;
      mem_req_o                <= 0;
      mem_addr_o               <= 0;
      miss_update_cache_line   <= miss_update_cache_line_q;
      r_req                    <= 0;
    end

    R_Hit: begin
      case (block_offset_q)
        2'b00: data_out <= data_array[set_cache_line_in][31:0];
        2'b01: data_out <= data_array[set_cache_line_in][63:32];
        2'b10: data_out <= data_array[set_cache_line_in][95:64];
        2'b11: data_out <= data_array[set_cache_line_in][127:96];
      endcase
    end

    R_Miss_Req: begin
      r_req           <= 1;
      refill_complete <= 0;
      mem_req_o       <= 1;

      // FIX 2: Use tag_id_q[11:0] instead of {tag_id_q[27:22], set_id_q}
      // This correctly maps data addresses up to 0x1FFF
      mem_addr_o <= tag_id_q[11:0];

      case (set_id_q)
        S0: begin
          if      (valid_array[0]  == 0) miss_update_cache_line <= 0;
          else if (valid_array[1]  == 0) miss_update_cache_line <= 1;
          else if (valid_array[2]  == 0) miss_update_cache_line <= 2;
          else if (valid_array[3]  == 0) miss_update_cache_line <= 3;
        end
        S1: begin
          if      (valid_array[4]  == 0) miss_update_cache_line <= 4;
          else if (valid_array[5]  == 0) miss_update_cache_line <= 5;
          else if (valid_array[6]  == 0) miss_update_cache_line <= 6;
          else if (valid_array[7]  == 0) miss_update_cache_line <= 7;
        end
        S2: begin
          if      (valid_array[8]  == 0) miss_update_cache_line <= 8;
          else if (valid_array[9]  == 0) miss_update_cache_line <= 9;
          else if (valid_array[10] == 0) miss_update_cache_line <= 10;
          else if (valid_array[11] == 0) miss_update_cache_line <= 11;
        end
        S3: begin
          if      (valid_array[12] == 0) miss_update_cache_line <= 12;
          else if (valid_array[13] == 0) miss_update_cache_line <= 13;
          else if (valid_array[14] == 0) miss_update_cache_line <= 14;
          else if (valid_array[15] == 0) miss_update_cache_line <= 15;
        end
      endcase
    end

    R_Miss_Wait: begin
      mem_req_o       <= 1;
      refill_complete <= 0;
      r_req           <= 1;
    end

    R_Miss_Refill: begin
      if (mem_comp) begin
        tag_array[miss_update_cache_line]  <= tag_id_q;
        data_array[miss_update_cache_line] <= mem_data_in;
        valid_array[miss_update_cache_line] <= 1;
        way_id_out <= miss_update_cache_line;
        case (block_offset_q)
          2'b00: data_out <= mem_data_in[31:0];
          2'b01: data_out <= mem_data_in[63:32];
          2'b10: data_out <= mem_data_in[95:64];
          2'b11: data_out <= mem_data_in[127:96];
        endcase
        refill_complete <= 1;
        // FIX 3: Removed else branch that cleared valid_array[line] when
        // mem_comp=0. This was incorrectly invalidating the line every cycle
        // while waiting in Miss_Refill, causing perpetual cache misses.
      end
    end
  endcase
end

// ── Set-full detection ───────────────────────────────────────────────
always_ff @(posedge clk)
begin
  if (!reset_n) set_full <= 0;
  else begin
    case (set_id_q)
      S0: set_full <= (valid_array[0]  && valid_array[1]  && valid_array[2]  && valid_array[3]);
      S1: set_full <= (valid_array[4]  && valid_array[5]  && valid_array[6]  && valid_array[7]);
      S2: set_full <= (valid_array[8]  && valid_array[9]  && valid_array[10] && valid_array[11]);
      S3: set_full <= (valid_array[12] && valid_array[13] && valid_array[14] && valid_array[15]);
    endcase
  end
end

// ── Write state machine ──────────────────────────────────────────────
typedef enum logic [1:0] {W_Idle, W_Hit, W_Miss} w_state;
w_state w_c_state, w_n_state;

always_ff @(posedge clk)
begin
  if (!reset_n) w_c_state <= W_Idle;
  else          w_c_state <= w_n_state;
end

always_comb begin
  case (w_c_state)
    W_Idle: w_n_state = (w_hit) ? W_Hit : (w_miss) ? W_Miss : W_Idle;
    W_Hit : w_n_state = W_Idle;
    W_Miss: w_n_state = W_Idle;
    default: w_n_state = W_Idle;
  endcase
end

logic [31:0] wdata_q;
always_ff @(posedge clk)
begin
  if (!reset_n) wdata_q <= 0;
  else          wdata_q <= wdata_in;
end

always_ff @(posedge clk)
begin
  case (w_c_state)
    W_Idle: begin
      mem_w_data <= 0;
      mem_addr_o <= 0;
      w_req      <= 0;
    end

    W_Hit: begin
      w_req <= 1;
      case (block_offset_q)
        2'b00: data_array[set_cache_line_in][31:0]   <= wdata_q;
        2'b01: data_array[set_cache_line_in][63:32]  <= wdata_q;
        2'b10: data_array[set_cache_line_in][95:64]  <= wdata_q;
        2'b11: data_array[set_cache_line_in][127:96] <= wdata_q;
      endcase
      mem_w_data <= wdata_q;
      // FIX 4: Use tag_id_q[11:0] for write address too
      mem_addr_o     <= tag_array[set_cache_line_in][11:0];
      block_offset_out <= block_offset_q;
    end

    W_Miss: begin
      w_req            <= 1;
      mem_w_data       <= wdata_q;
      // FIX 5: Use tag_id_q[11:0] for write-miss address
      mem_addr_o       <= tag_id_q[11:0];
      block_offset_out <= block_offset_q;
    end
  endcase
end

assign tag_array_out  = tag_array;
assign valid_array_out = valid_array;

logic r_busy, w_busy;
assign r_busy     = (r_c_state == R_Miss_Req ||
                     r_c_state == R_Miss_Wait ||
                     r_c_state == R_Miss_Refill);
assign w_busy     = (w_c_state == W_Miss);
assign d_cache_busy = r_busy;
assign wr_en_fifo = (r_c_state == R_Miss_Refill) ? 1 : 0;

endmodule
