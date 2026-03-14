// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Primary design header
//
// This header should be included by all source files instantiating the design.
// The class here is then constructed to instantiate the design.
// See the Verilator manual for examples.

#ifndef _VYARP_TOP_CACHED_H_
#define _VYARP_TOP_CACHED_H_  // guard

#include "verilated_heavy.h"

//==========

class Vyarp_top_cached__Syms;

//----------

VL_MODULE(Vyarp_top_cached) {
  public:
    
    // PORTS
    // The application code writes and reads these signals to
    // propagate new values into/out from the Verilated model.
    VL_IN8(clk,0,0);
    VL_IN8(reset_n,0,0);
    VL_OUT8(ext_imem_req_o,0,0);
    VL_OUT8(ext_imem_addr_o,7,0);
    VL_IN8(ext_imem_comp_i,0,0);
    VL_OUT8(ext_dmem_r_req_o,0,0);
    VL_OUT8(ext_dmem_w_req_o,0,0);
    VL_OUT8(ext_dmem_addr_o,7,0);
    VL_OUT8(ext_dmem_blockoffset_o,1,0);
    VL_IN8(ext_dmem_comp_i,0,0);
    VL_OUT8(retire_done,0,0);
    VL_OUT16(retire_count,8,0);
    VL_INW(ext_imem_data_i,127,0,4);
    VL_OUT(ext_dmem_wr_data_o,31,0);
    VL_INW(ext_dmem_data_i,127,0,4);
    
    // LOCAL SIGNALS
    // Internals; generally not touched by application code
    // Anonymous structures to workaround compiler member-count bugs
    struct {
        CData/*0:0*/ yarp_top__DOT__id_ex_rf_wr_en;
        CData/*0:0*/ yarp_top__DOT__id_ex_mem_zero_extnd;
        CData/*0:0*/ yarp_top__DOT__id_ex_mem_data_wr;
        CData/*1:0*/ yarp_top__DOT__id_ex_mem_data_type;
        CData/*0:0*/ yarp_top__DOT__id_ex_mem_req;
        CData/*1:0*/ yarp_top__DOT__id_ex_rf_wr_data;
        CData/*3:0*/ yarp_top__DOT__id_ex_alu_func_o;
        CData/*0:0*/ yarp_top__DOT__id_ex_op1_sel;
        CData/*0:0*/ yarp_top__DOT__id_ex_op2_sel;
        CData/*4:0*/ yarp_top__DOT__id_ex_rd_addr_out;
        CData/*0:0*/ yarp_top__DOT__ex_l_type_in;
        CData/*5:0*/ yarp_top__DOT__ex_rs1_l_dep_in;
        CData/*5:0*/ yarp_top__DOT__ex_rs2_l_dep_in;
        CData/*4:0*/ yarp_top__DOT__ex_rs1_in;
        CData/*4:0*/ yarp_top__DOT__ex_rs2_in;
        CData/*0:0*/ yarp_top__DOT__ex_decide_rs1_l_dep;
        CData/*0:0*/ yarp_top__DOT__ex_decide_rs2_l_dep;
        CData/*0:0*/ yarp_top__DOT__forward_rs1_ex_dep_id_ex;
        CData/*0:0*/ yarp_top__DOT__forward_rs1_mem_dep_id_ex;
        CData/*0:0*/ yarp_top__DOT__forward_rs2_ex_dep_id_ex;
        CData/*0:0*/ yarp_top__DOT__forward_rs2_mem_dep_id_ex;
        CData/*0:0*/ yarp_top__DOT__ex_mem_l_type;
        CData/*1:0*/ yarp_top__DOT__mem_wb_rf_wr_data;
        CData/*0:0*/ yarp_top__DOT__mem_data_req;
        CData/*1:0*/ yarp_top__DOT__mem_data_type;
        CData/*0:0*/ yarp_top__DOT__mem_data_wr;
        CData/*0:0*/ yarp_top__DOT__mem_zero_extnd;
        CData/*0:0*/ yarp_top__DOT__mem_wb_rf_wr_en;
        CData/*4:0*/ yarp_top__DOT__ex_mem_rd_addr;
        CData/*0:0*/ yarp_top__DOT__hazard_l_type;
        CData/*0:0*/ yarp_top__DOT__rf_wr_en;
        CData/*1:0*/ yarp_top__DOT__rf_wr_data;
        CData/*4:0*/ yarp_top__DOT__rf_rd_addr_in;
        CData/*0:0*/ yarp_top__DOT__retire_rf;
        CData/*3:0*/ yarp_top__DOT__flush_counter;
        CData/*0:0*/ yarp_top__DOT__i_cache_busy;
        CData/*0:0*/ yarp_top__DOT__d_cache_busy;
        CData/*0:0*/ yarp_top__DOT__u_yarp_instr_mem__DOT__instr_mem_req_q;
        CData/*0:0*/ yarp_top__DOT__u_yarp_sa_cache__DOT__lu_ctrl_hit;
        CData/*0:0*/ yarp_top__DOT__u_yarp_sa_cache__DOT__lu_ctrl_miss;
        CData/*3:0*/ yarp_top__DOT__u_yarp_sa_cache__DOT__lu_ctrl_cachelineno;
        CData/*0:0*/ yarp_top__DOT__u_yarp_sa_cache__DOT__set_full_out;
        CData/*3:0*/ yarp_top__DOT__u_yarp_sa_cache__DOT__way_id_ctrl_lru;
        CData/*0:0*/ yarp_top__DOT__u_yarp_sa_cache__DOT__ctrl_lru_wr_en;
        CData/*4:0*/ yarp_top__DOT__u_yarp_sa_cache__DOT__way1_lru_rg;
        CData/*4:0*/ yarp_top__DOT__u_yarp_sa_cache__DOT__way2_lru_rg;
        CData/*3:0*/ yarp_top__DOT__u_yarp_sa_cache__DOT__sa_3__DOT__miss_update_cache_line;
        CData/*3:0*/ yarp_top__DOT__u_yarp_sa_cache__DOT__sa_3__DOT__miss_update_cache_line_q;
        CData/*1:0*/ yarp_top__DOT__u_yarp_sa_cache__DOT__sa_3__DOT__set_id_q;
        CData/*1:0*/ yarp_top__DOT__u_yarp_sa_cache__DOT__sa_3__DOT__block_offset_q;
        CData/*2:0*/ yarp_top__DOT__u_yarp_sa_cache__DOT__sa_3__DOT__c_state;
        CData/*2:0*/ yarp_top__DOT__u_yarp_sa_cache__DOT__sa_3__DOT__n_state;
        CData/*1:0*/ yarp_top__DOT__u_yarp_sa_cache__DOT__sa_5__DOT__set_id;
        CData/*1:0*/ yarp_top__DOT__u_yarp_sa_cache__DOT__sa_5__DOT__wptr_s0;
        CData/*1:0*/ yarp_top__DOT__u_yarp_sa_cache__DOT__sa_5__DOT__wptr_s1;
        CData/*1:0*/ yarp_top__DOT__u_yarp_sa_cache__DOT__sa_5__DOT__wptr_s2;
        CData/*1:0*/ yarp_top__DOT__u_yarp_sa_cache__DOT__sa_5__DOT__wptr_s3;
        CData/*0:0*/ yarp_top__DOT__u_yarp_decode__DOT__r_type_decode;
        CData/*0:0*/ yarp_top__DOT__u_yarp_decode__DOT__i_type_decode;
        CData/*0:0*/ yarp_top__DOT__u_yarp_decode__DOT__s_type_decode;
        CData/*0:0*/ yarp_top__DOT__u_yarp_decode__DOT__b_type_decode;
        CData/*0:0*/ yarp_top__DOT__u_yarp_decode__DOT__u_type_decode;
        CData/*0:0*/ yarp_top__DOT__u_yarp_decode__DOT__j_type_decode;
        CData/*3:0*/ yarp_top__DOT__u_yarp_control__DOT__diff_rtype;
    };
    struct {
        CData/*3:0*/ yarp_top__DOT__u_yarp_control__DOT__diff_itype;
        CData/*0:0*/ yarp_top__DOT__u_yarp_branch_control__DOT__branch_taken_temp;
        CData/*0:0*/ yarp_top__DOT__u_yarp_hazard_detection__DOT__rs1_ex_dep;
        CData/*0:0*/ yarp_top__DOT__u_yarp_hazard_detection__DOT__rs2_ex_dep;
        CData/*0:0*/ yarp_top__DOT__u_yarp_hazard_detection__DOT__stall;
        CData/*0:0*/ yarp_top__DOT__u_yarp_d_cache__DOT__lu_ctrl_hit;
        CData/*0:0*/ yarp_top__DOT__u_yarp_d_cache__DOT__lu_ctrl_miss;
        CData/*3:0*/ yarp_top__DOT__u_yarp_d_cache__DOT__lu_ctrl_way_no;
        CData/*3:0*/ yarp_top__DOT__u_yarp_d_cache__DOT__ctrl_lru_wayid;
        CData/*0:0*/ yarp_top__DOT__u_yarp_d_cache__DOT__ctrl_lru_wr_en;
        CData/*0:0*/ yarp_top__DOT__u_yarp_d_cache__DOT__ctrl_lru_full;
        CData/*1:0*/ yarp_top__DOT__u_yarp_d_cache__DOT__byte_ctrl;
        CData/*0:0*/ yarp_top__DOT__u_yarp_d_cache__DOT__ctrl_zero_extnd;
        CData/*4:0*/ yarp_top__DOT__u_yarp_d_cache__DOT__lru_rg_way1;
        CData/*4:0*/ yarp_top__DOT__u_yarp_d_cache__DOT__lru_rg_way2;
        CData/*0:0*/ yarp_top__DOT__u_yarp_d_cache__DOT__d_sa_3__DOT__r_hit;
        CData/*0:0*/ yarp_top__DOT__u_yarp_d_cache__DOT__d_sa_3__DOT__refill_complete;
        CData/*3:0*/ yarp_top__DOT__u_yarp_d_cache__DOT__d_sa_3__DOT__miss_update_cache_line;
        CData/*3:0*/ yarp_top__DOT__u_yarp_d_cache__DOT__d_sa_3__DOT__miss_update_cache_line_q;
        CData/*1:0*/ yarp_top__DOT__u_yarp_d_cache__DOT__d_sa_3__DOT__block_offset_q;
        CData/*1:0*/ yarp_top__DOT__u_yarp_d_cache__DOT__d_sa_3__DOT__set_id_q;
        CData/*2:0*/ yarp_top__DOT__u_yarp_d_cache__DOT__d_sa_3__DOT__r_c_state;
        CData/*2:0*/ yarp_top__DOT__u_yarp_d_cache__DOT__d_sa_3__DOT__r_n_state;
        CData/*1:0*/ yarp_top__DOT__u_yarp_d_cache__DOT__d_sa_3__DOT__w_c_state;
        CData/*1:0*/ yarp_top__DOT__u_yarp_d_cache__DOT__d_sa_3__DOT__w_n_state;
        CData/*1:0*/ yarp_top__DOT__u_yarp_d_cache__DOT__d_sa_5__DOT__set_id;
        CData/*1:0*/ yarp_top__DOT__u_yarp_d_cache__DOT__d_sa_5__DOT__wptr_s0;
        CData/*1:0*/ yarp_top__DOT__u_yarp_d_cache__DOT__d_sa_5__DOT__wptr_s1;
        CData/*1:0*/ yarp_top__DOT__u_yarp_d_cache__DOT__d_sa_5__DOT__wptr_s2;
        CData/*1:0*/ yarp_top__DOT__u_yarp_d_cache__DOT__d_sa_5__DOT__wptr_s3;
        SData/*14:0*/ yarp_top__DOT__u_yarp_control__DOT__reg_control;
        SData/*14:0*/ yarp_top__DOT__u_yarp_control__DOT__i_control;
        SData/*14:0*/ yarp_top__DOT__u_yarp_control__DOT__s_control;
        SData/*14:0*/ yarp_top__DOT__u_yarp_control__DOT__b_control;
        SData/*14:0*/ yarp_top__DOT__u_yarp_control__DOT__u_control;
        SData/*14:0*/ yarp_top__DOT__u_yarp_control__DOT__j_control;
        SData/*14:0*/ yarp_top__DOT__u_yarp_control__DOT__control;
        IData/*31:0*/ yarp_top__DOT__pc_q;
        IData/*31:0*/ yarp_top__DOT__next_pc;
        IData/*31:0*/ yarp_top__DOT__rf_rs1_data;
        IData/*31:0*/ yarp_top__DOT__rf_rs2_data;
        IData/*31:0*/ yarp_top__DOT__opr_a_sel;
        IData/*31:0*/ yarp_top__DOT__opr_b_sel;
        IData/*31:0*/ yarp_top__DOT__id_instr_i;
        IData/*31:0*/ yarp_top__DOT__id_pc_in;
        IData/*31:0*/ yarp_top__DOT__id_ex_pc;
        IData/*31:0*/ yarp_top__DOT__id_ex_imm;
        IData/*31:0*/ yarp_top__DOT__id_ex_rs2_data;
        IData/*31:0*/ yarp_top__DOT__id_ex_rs1_data;
        IData/*31:0*/ yarp_top__DOT__execute_o;
        IData/*31:0*/ yarp_top__DOT__mem_imm_in;
        IData/*31:0*/ yarp_top__DOT__mem_pc_in;
        IData/*31:0*/ yarp_top__DOT__mem_wr_data;
        IData/*31:0*/ yarp_top__DOT__rf_data_in;
        IData/*31:0*/ yarp_top__DOT__mem_wb_alu_op;
        IData/*31:0*/ yarp_top__DOT__rf_imm;
        IData/*31:0*/ yarp_top__DOT__rf_pc;
        IData/*31:0*/ yarp_top__DOT__reg_file_data_in;
        IData/*31:0*/ yarp_top__DOT__instr_mem_rd_data_i;
        IData/*31:0*/ yarp_top__DOT__d_cache_mem_rd_data;
        IData/*25:0*/ yarp_top__DOT__u_yarp_sa_cache__DOT__sa_3__DOT__tag_id_q;
        IData/*31:0*/ yarp_top__DOT__u_yarp_branch_control__DOT__twos_comp_a;
        IData/*31:0*/ yarp_top__DOT__u_yarp_branch_control__DOT__twos_comp_b;
        IData/*31:0*/ yarp_top__DOT__u_yarp_execute__DOT__temp;
    };
    struct {
        IData/*31:0*/ yarp_top__DOT__u_yarp_d_cache__DOT__ctrl_data_out;
        IData/*27:0*/ yarp_top__DOT__u_yarp_d_cache__DOT__d_sa_3__DOT__tag_id_q;
        IData/*31:0*/ yarp_top__DOT__u_yarp_d_cache__DOT__d_sa_3__DOT__wdata_q;
        IData/*25:0*/ yarp_top__DOT__u_yarp_sa_cache__DOT__ctrl_lu_tag_array[16];
        CData/*0:0*/ yarp_top__DOT__u_yarp_sa_cache__DOT__ctrl_lu_lru_valid_array[16];
        CData/*0:0*/ yarp_top__DOT__u_yarp_sa_cache__DOT__valid_rg_ctrl[16];
        CData/*0:0*/ yarp_top__DOT__u_yarp_sa_cache__DOT__valid_out_lru_rg[16];
        IData/*25:0*/ yarp_top__DOT__u_yarp_sa_cache__DOT__sa_3__DOT__tag_array[16];
        CData/*0:0*/ yarp_top__DOT__u_yarp_sa_cache__DOT__sa_3__DOT__valid_array[16];
        WData/*127:0*/ yarp_top__DOT__u_yarp_sa_cache__DOT__sa_3__DOT__data_array[16][4];
        CData/*4:0*/ yarp_top__DOT__u_yarp_sa_cache__DOT__sa_5__DOT__fifo_s0[4];
        CData/*4:0*/ yarp_top__DOT__u_yarp_sa_cache__DOT__sa_5__DOT__fifo_s1[4];
        CData/*4:0*/ yarp_top__DOT__u_yarp_sa_cache__DOT__sa_5__DOT__fifo_s2[4];
        CData/*4:0*/ yarp_top__DOT__u_yarp_sa_cache__DOT__sa_5__DOT__fifo_s3[4];
        CData/*0:0*/ yarp_top__DOT__u_yarp_sa_cache__DOT__sa_6__DOT__valid_temp[16];
        IData/*27:0*/ yarp_top__DOT__u_yarp_d_cache__DOT__ctrl_lu_tag_array[16];
        CData/*0:0*/ yarp_top__DOT__u_yarp_d_cache__DOT__ctrl_lu_lru_valid_array[16];
        CData/*0:0*/ yarp_top__DOT__u_yarp_d_cache__DOT__rg_ctrl_valid_array[16];
        CData/*0:0*/ yarp_top__DOT__u_yarp_d_cache__DOT__lru_rg_valid[16];
        IData/*27:0*/ yarp_top__DOT__u_yarp_d_cache__DOT__d_sa_3__DOT__tag_array[16];
        CData/*0:0*/ yarp_top__DOT__u_yarp_d_cache__DOT__d_sa_3__DOT__valid_array[16];
        WData/*127:0*/ yarp_top__DOT__u_yarp_d_cache__DOT__d_sa_3__DOT__data_array[16][4];
        CData/*4:0*/ yarp_top__DOT__u_yarp_d_cache__DOT__d_sa_5__DOT__fifo_s0[4];
        CData/*4:0*/ yarp_top__DOT__u_yarp_d_cache__DOT__d_sa_5__DOT__fifo_s1[4];
        CData/*4:0*/ yarp_top__DOT__u_yarp_d_cache__DOT__d_sa_5__DOT__fifo_s2[4];
        CData/*4:0*/ yarp_top__DOT__u_yarp_d_cache__DOT__d_sa_5__DOT__fifo_s3[4];
        CData/*0:0*/ yarp_top__DOT__u_yarp_d_cache__DOT__d_sa_6__DOT__valid_temp[16];
        IData/*31:0*/ yarp_top__DOT__u_yarp_regfile__DOT__regfile[32];
    };
    
    // LOCAL VARIABLES
    // Internals; generally not touched by application code
    CData/*0:0*/ yarp_top__DOT____Vcellinp__u_yarp_if_id__if_pip_disable;
    CData/*0:0*/ yarp_top__DOT____Vcellinp__u_yarp_id_ex_pipeline__id_pip_disable;
    CData/*4:0*/ __Vtableidx1;
    CData/*6:0*/ __Vtableidx2;
    CData/*5:0*/ __Vtableidx3;
    CData/*4:0*/ __Vtableidx4;
    CData/*0:0*/ __Vclklast__TOP__clk;
    CData/*0:0*/ yarp_top__DOT__u_yarp_sa_cache__DOT____Vcellinp__sa_2__valid_array_in[16];
    IData/*25:0*/ yarp_top__DOT__u_yarp_sa_cache__DOT____Vcellinp__sa_2__tag_array_in[16];
    CData/*0:0*/ yarp_top__DOT__u_yarp_sa_cache__DOT____Vcellout__sa_3__valid_array_out[16];
    IData/*25:0*/ yarp_top__DOT__u_yarp_sa_cache__DOT____Vcellout__sa_3__tag_array_out[16];
    CData/*0:0*/ yarp_top__DOT__u_yarp_sa_cache__DOT____Vcellinp__sa_3__valid_array_in[16];
    CData/*0:0*/ yarp_top__DOT__u_yarp_sa_cache__DOT____Vcellout__sa_5__valid_out_rg[16];
    CData/*0:0*/ yarp_top__DOT__u_yarp_sa_cache__DOT____Vcellinp__sa_5__valid_in[16];
    CData/*0:0*/ yarp_top__DOT__u_yarp_sa_cache__DOT____Vcellout__sa_6__valid_out[16];
    CData/*0:0*/ yarp_top__DOT__u_yarp_sa_cache__DOT____Vcellinp__sa_6__valid_lru_in[16];
    CData/*0:0*/ yarp_top__DOT__u_yarp_d_cache__DOT____Vcellinp__d_sa_2__valid_array_in[16];
    IData/*27:0*/ yarp_top__DOT__u_yarp_d_cache__DOT____Vcellinp__d_sa_2__tag_array_in[16];
    CData/*0:0*/ yarp_top__DOT__u_yarp_d_cache__DOT____Vcellout__d_sa_3__valid_array_out[16];
    IData/*27:0*/ yarp_top__DOT__u_yarp_d_cache__DOT____Vcellout__d_sa_3__tag_array_out[16];
    CData/*0:0*/ yarp_top__DOT__u_yarp_d_cache__DOT____Vcellinp__d_sa_3__valid_array_in[16];
    CData/*0:0*/ yarp_top__DOT__u_yarp_d_cache__DOT____Vcellout__d_sa_5__valid_out_rg[16];
    CData/*0:0*/ yarp_top__DOT__u_yarp_d_cache__DOT____Vcellinp__d_sa_5__valid_in[16];
    CData/*0:0*/ yarp_top__DOT__u_yarp_d_cache__DOT____Vcellout__d_sa_6__valid_out[16];
    CData/*0:0*/ yarp_top__DOT__u_yarp_d_cache__DOT____Vcellinp__d_sa_6__valid_lru_in[16];
    static CData/*2:0*/ __Vtable1_yarp_top__DOT__u_yarp_sa_cache__DOT__sa_3__DOT__n_state[32];
    static CData/*0:0*/ __Vtable2_yarp_top__DOT__u_yarp_decode__DOT__r_type_decode[128];
    static CData/*0:0*/ __Vtable2_yarp_top__DOT__u_yarp_decode__DOT__i_type_decode[128];
    static CData/*0:0*/ __Vtable2_yarp_top__DOT__u_yarp_decode__DOT__s_type_decode[128];
    static CData/*0:0*/ __Vtable2_yarp_top__DOT__u_yarp_decode__DOT__b_type_decode[128];
    static CData/*0:0*/ __Vtable2_yarp_top__DOT__u_yarp_decode__DOT__u_type_decode[128];
    static CData/*0:0*/ __Vtable2_yarp_top__DOT__u_yarp_decode__DOT__j_type_decode[128];
    static CData/*2:0*/ __Vtable3_yarp_top__DOT__u_yarp_d_cache__DOT__d_sa_3__DOT__r_n_state[64];
    static CData/*1:0*/ __Vtable4_yarp_top__DOT__u_yarp_d_cache__DOT__d_sa_3__DOT__w_n_state[32];
    
    // INTERNAL VARIABLES
    // Internals; generally not touched by application code
    Vyarp_top_cached__Syms* __VlSymsp;  // Symbol table
    
    // CONSTRUCTORS
  private:
    VL_UNCOPYABLE(Vyarp_top_cached);  ///< Copying not allowed
  public:
    /// Construct the model; called by application code
    /// The special name  may be used to make a wrapper with a
    /// single model invisible with respect to DPI scope names.
    Vyarp_top_cached(const char* name = "TOP");
    /// Destroy the model; called (often implicitly) by application code
    ~Vyarp_top_cached();
    
    // API METHODS
    /// Evaluate the model.  Application must call when inputs change.
    void eval();
    /// Simulation complete, run final blocks.  Application must call on completion.
    void final();
    
    // INTERNAL METHODS
  private:
    static void _eval_initial_loop(Vyarp_top_cached__Syms* __restrict vlSymsp);
  public:
    void __Vconfigure(Vyarp_top_cached__Syms* symsp, bool first);
  private:
    static QData _change_request(Vyarp_top_cached__Syms* __restrict vlSymsp);
  public:
    static void _combo__TOP__5(Vyarp_top_cached__Syms* __restrict vlSymsp);
  private:
    void _ctor_var_reset() VL_ATTR_COLD;
  public:
    static void _eval(Vyarp_top_cached__Syms* __restrict vlSymsp);
  private:
#ifdef VL_DEBUG
    void _eval_debug_assertions();
#endif  // VL_DEBUG
  public:
    static void _eval_initial(Vyarp_top_cached__Syms* __restrict vlSymsp) VL_ATTR_COLD;
    static void _eval_settle(Vyarp_top_cached__Syms* __restrict vlSymsp) VL_ATTR_COLD;
    static void _initial__TOP__2(Vyarp_top_cached__Syms* __restrict vlSymsp) VL_ATTR_COLD;
    static void _sequent__TOP__3(Vyarp_top_cached__Syms* __restrict vlSymsp);
    static void _settle__TOP__1(Vyarp_top_cached__Syms* __restrict vlSymsp) VL_ATTR_COLD;
    static void _settle__TOP__4(Vyarp_top_cached__Syms* __restrict vlSymsp) VL_ATTR_COLD;
} VL_ATTR_ALIGNED(VL_CACHE_LINE_BYTES);

//----------


#endif  // guard
