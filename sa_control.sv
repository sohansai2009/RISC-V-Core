module sa_control (
  input logic clk, reset_n,
  input logic hit_in, miss_in,
  input logic [25:0] tag_id_in,
  input logic [3:0] set_cache_line_in,
  input logic [1:0] set_id_in,
  input logic [1:0] block_offset_in,
  input logic valid_array_in [15:0],

  output logic [25:0] tag_array_out [15:0],
  output logic valid_array_out [15:0],
  output logic mem_req_o,
  output logic [7:0] addr_mem_o,

  input logic mem_comp,
  input logic [127:0] mem_data_in,

  output logic [31:0] data_out,
  output logic i_cache_busy,
  output logic set_full,
  output logic [3:0] way_id_out,
  output logic wr_fif_en_o
);

logic [25:0] tag_array [15:0];
logic        valid_array [15:0];
logic [127:0] data_array [15:0];
logic        cache_refill_complete;

logic [3:0] miss_update_cache_line, miss_update_cache_line_q;
logic [25:0] tag_id_q;
logic [1:0]  set_id_q;
logic [1:0]  block_offset_q;

parameter S0 = 2'b00;
parameter S1 = 2'b01;
parameter S2 = 2'b10;
parameter S3 = 2'b11;

typedef enum logic [2:0] {Idle, Hit, Miss_Req, Miss_Wait, Miss_Refill} state;
state c_state, n_state;

always_ff @(posedge clk) begin
  if (!reset_n) begin
    tag_id_q       <= 0;
    set_id_q       <= 0;
    block_offset_q <= 0;
  end else begin
    tag_id_q  <= tag_id_in;
    set_id_q  <= set_id_in;
    block_offset_q <= (c_state == Idle && miss_in) ? block_offset_in : block_offset_q;
  end
end

always_ff @(posedge clk) begin
  if (!reset_n) begin
    tag_array   <= '{default:'0};
    data_array  <= '{default:'0};
    valid_array <= '{default:'0};
  end
end

always_ff @(posedge clk) begin
  if (!reset_n) c_state <= Idle;
  else          c_state <= n_state;
end

always_comb begin
  case (c_state)
    Idle       : n_state = (miss_in) ? Miss_Req : Idle;
    Miss_Req   : n_state = Miss_Wait;
    Miss_Wait  : n_state = Miss_Refill;
    Miss_Refill: n_state = (mem_comp) ? Idle : Miss_Refill;
    default    : n_state = Idle;
  endcase
end

always_ff @(posedge clk) begin
  if (!reset_n) miss_update_cache_line_q <= 4'b0000;
  else          miss_update_cache_line_q <= miss_update_cache_line;
end

always_ff @(posedge clk) begin
  case (c_state)
    Idle: begin
      mem_req_o              <= 0;
      addr_mem_o             <= 0;
      miss_update_cache_line <= miss_update_cache_line_q;
    end

    Miss_Req: begin
      case (set_id_q)
        S0: begin
          if      (valid_array[0]  == 0) miss_update_cache_line <= 0;
          else if (valid_array[1]  == 0) miss_update_cache_line <= 1;
          else if (valid_array[2]  == 0) miss_update_cache_line <= 2;
          else if (valid_array[3]  == 0) miss_update_cache_line <= 3;
          else begin
            if      (valid_array_in[0]) miss_update_cache_line <= 0;
            else if (valid_array_in[1]) miss_update_cache_line <= 1;
            else if (valid_array_in[2]) miss_update_cache_line <= 2;
            else                        miss_update_cache_line <= 3;
          end
        end
        S1: begin
          if      (valid_array[4]  == 0) miss_update_cache_line <= 4;
          else if (valid_array[5]  == 0) miss_update_cache_line <= 5;
          else if (valid_array[6]  == 0) miss_update_cache_line <= 6;
          else if (valid_array[7]  == 0) miss_update_cache_line <= 7;
          else begin
            if      (valid_array_in[4]) miss_update_cache_line <= 4;
            else if (valid_array_in[5]) miss_update_cache_line <= 5;
            else if (valid_array_in[6]) miss_update_cache_line <= 6;
            else                        miss_update_cache_line <= 7;
          end
        end
        S2: begin
          if      (valid_array[8]  == 0) miss_update_cache_line <= 8;
          else if (valid_array[9]  == 0) miss_update_cache_line <= 9;
          else if (valid_array[10] == 0) miss_update_cache_line <= 10;
          else if (valid_array[11] == 0) miss_update_cache_line <= 11;
          else begin
            if      (valid_array_in[8])  miss_update_cache_line <= 8;
            else if (valid_array_in[9])  miss_update_cache_line <= 9;
            else if (valid_array_in[10]) miss_update_cache_line <= 10;
            else                         miss_update_cache_line <= 11;
          end
        end
        S3: begin
          if      (valid_array[12] == 0) miss_update_cache_line <= 12;
          else if (valid_array[13] == 0) miss_update_cache_line <= 13;
          else if (valid_array[14] == 0) miss_update_cache_line <= 14;
          else if (valid_array[15] == 0) miss_update_cache_line <= 15;
          else begin
            if      (valid_array_in[12]) miss_update_cache_line <= 12;
            else if (valid_array_in[13]) miss_update_cache_line <= 13;
            else if (valid_array_in[14]) miss_update_cache_line <= 14;
            else                         miss_update_cache_line <= 15;
          end
        end
      endcase

      mem_req_o  <= 1;
      // FIX 1: Use {tag_id_q[5:0], set_id_q} instead of {tag_id_q[25:20], set_id_q}
      // This correctly maps PC addresses starting from 0x0000
      addr_mem_o <= {tag_id_q[5:0], set_id_q};
    end

    Miss_Wait: begin
      mem_req_o <= 1;
    end

    Miss_Refill: begin
      if (mem_comp) begin
        tag_array[miss_update_cache_line]   <= tag_id_q;
        data_array[miss_update_cache_line]  <= mem_data_in;
        valid_array[miss_update_cache_line] <= 1;
        way_id_out <= miss_update_cache_line;
        // FIX 2: Removed else branch that cleared valid_array[line] when
        // mem_comp=0. This was causing perpetual cache misses by
        // invalidating the line every cycle while waiting for mem_comp.
      end
    end

    default: begin
      mem_req_o              <= 0;
      addr_mem_o             <= 0;
      miss_update_cache_line <= miss_update_cache_line_q;
    end
  endcase
end

// Combinational data output
always_comb begin
  data_out = 32'h0;
  if (hit_in) begin
    case (block_offset_in)
      2'b00: data_out = data_array[set_cache_line_in][31:0];
      2'b01: data_out = data_array[set_cache_line_in][63:32];
      2'b10: data_out = data_array[set_cache_line_in][95:64];
      2'b11: data_out = data_array[set_cache_line_in][127:96];
    endcase
  end else if (c_state == Miss_Refill && mem_comp) begin
    case (block_offset_q)
      2'b00: data_out = mem_data_in[31:0];
      2'b01: data_out = mem_data_in[63:32];
      2'b10: data_out = mem_data_in[95:64];
      2'b11: data_out = mem_data_in[127:96];
    endcase
  end
end

// Set-full detection
always_ff @(posedge clk) begin
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

assign tag_array_out   = tag_array;
assign valid_array_out = valid_array;
assign i_cache_busy    = ((c_state == Miss_Req) ||
                          (c_state == Miss_Wait) ||
                          (c_state == Miss_Refill)) ? 1 : 0;
assign wr_fif_en_o     = (c_state == Miss_Refill && mem_comp) ? 1 : 0;
assign cache_refill_complete = (c_state == Miss_Refill && mem_comp) ? 1 : 0;

endmodule
