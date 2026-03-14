// gem5 v25.1  Verilated wrapper implementation — YARP RISC-V core
// Full-System mode: real gem5 RequestPorts connected to memory bus.
//
// File: src/cpu/riscv_cached/yarp_core_wrapper.cc
//
// Memory handshake (verified against yarp_top RTL):
//
//  I-mem (read-only, 128-bit cache line):
//    RTL asserts ext_imem_req_o + ext_imem_addr_o (8-bit LINE address)
//    Wrapper sends ReadReq packet to gem5 memory bus (16-byte size)
//    gem5 returns packet via recvTimingResp()
//    Wrapper loads ext_imem_data_i[3:0] and asserts ext_imem_comp_i
//    for exactly ONE RTL clock cycle
//
//  D-mem read (128-bit cache line):
//    RTL asserts ext_dmem_r_req_o + ext_dmem_addr_o + blockoffset_o
//    Wrapper sends ReadReq (16-byte)
//    On response: load ext_dmem_data_i[3:0], assert ext_dmem_comp_i
//
//  D-mem write (32-bit word):
//    RTL asserts ext_dmem_w_req_o + addr + blockoffset_o + wr_data_o
//    blockoffset_o [0-3] = word index within 128-bit line
//    Wrapper sends WriteReq (4-byte) to the exact word address
//    On ack: assert ext_dmem_comp_i for one cycle
//
//  Address mapping:
//    lineAddr (8-bit) → byte address = lineAddr * 16
//    write word addr  = lineAddr * 16 + blockOffset * 4

#include "cpu/riscv_cached/yarp_core_wrapper.hh"

#include <cassert>
#include <cstring>
#include <iostream>

#include "base/logging.hh"
#include "base/trace.hh"
#include "debug/YarpCore.hh"
#include "mem/packet_access.hh"
#include "sim/system.hh"

namespace gem5 {

// ============================================================
// IMemPort
// ============================================================

bool
YarpCore::IMemPort::recvTimingResp(PacketPtr pkt)
{
    owner_->iMemRecvResp(pkt);
    return true;
}

void
YarpCore::IMemPort::recvReqRetry()
{
    owner_->iMemRecvRetry();
}

// ============================================================
// DMemPort
// ============================================================

bool
YarpCore::DMemPort::recvTimingResp(PacketPtr pkt)
{
    owner_->dMemRecvResp(pkt);
    return true;
}

void
YarpCore::DMemPort::recvReqRetry()
{
    owner_->dMemRecvRetry();
}

// ============================================================
// YarpStats
// ============================================================

YarpCore::YarpStats::YarpStats(YarpCore *parent)
    : statistics::Group(parent),
      ADD_STAT(cycles,             statistics::units::Cycle::get(),
               "Total RTL cycles simulated"),
      ADD_STAT(retiredInsns,       statistics::units::Count::get(),
               "Instructions retired"),
      ADD_STAT(iMemRequests,       statistics::units::Count::get(),
               "I-mem cache-line requests issued to memory bus"),
      ADD_STAT(dMemReadRequests,   statistics::units::Count::get(),
               "D-mem read requests issued to memory bus"),
      ADD_STAT(dMemWriteRequests,  statistics::units::Count::get(),
               "D-mem write requests issued to memory bus"),
      ADD_STAT(ipc, statistics::units::Rate<
                        statistics::units::Count,
                        statistics::units::Cycle>::get(),
               "Instructions per cycle")
{
    ipc = retiredInsns / cycles;
}

// ============================================================
// Construction / destruction
// ============================================================

YarpCore::YarpCore(const YarpCoreParams &p)
    : SimObject(p),
      clockEvent_([this]{ clockEdge(); }, name() + ".clockEvent"),
      rtl_(std::make_unique<Vyarp_top_cached>("yarp_top")),  // was: Vyarp_top
      iMemPort_(name() + ".icache_port", this),
      dMemPort_(name() + ".dcache_port", this),
      iMemReqPending_ (false),
      iMemRespReady_  (false),
      dMemReqPending_ (false),
      dMemRespReady_  (false),
      dMemRespIsWrite_(false),
      iMemRetryPkt_   (nullptr),
      dMemRetryPkt_   (nullptr),
      requestorId_    (p.system->getRequestorId(this)),
      clockPeriod_    (p.clock_period_ticks),
      resetCycles_    (p.reset_cycles),
      dumpRetireStats_(p.dump_retire_stats),
      simCycle_       (0),
      stats_          (this),
      iMemRespSkipCycles_(0),
      dMemRespSkipCycles_(0)
{
    // Initialise all RTL inputs to safe idle values
    rtl_->clk             = 0;
    rtl_->reset_n         = 0;
    rtl_->ext_imem_comp_i = 0;
    rtl_->ext_dmem_comp_i = 0;
    for (int i = 0; i < 4; ++i) {
        rtl_->ext_imem_data_i[i] = 0;
        rtl_->ext_dmem_data_i[i] = 0;
    }
    rtl_->eval();
}

YarpCore::~YarpCore()
{
    rtl_->final();

    if (dumpRetireStats_) {
        double ipc = simCycle_ ? (double)rtl_->retire_count / simCycle_ : 0.0;
        std::cout << "\n[YarpCore] FS Simulation complete\n"
                  << "  Cycles        : " << simCycle_          << "\n"
                  << "  retire_count  : " << rtl_->retire_count << "\n"
                  << "  IPC           : " << ipc                << "\n\n";
    }
}

// ============================================================
// gem5 SimObject lifecycle
// ============================================================

void
YarpCore::init()
{
    SimObject::init();

    // Sanity-check: ports must be connected before simulation starts
    if (!iMemPort_.isConnected())
        fatal("YarpCore %s: icache_port is not connected!", name());
    if (!dMemPort_.isConnected())
        fatal("YarpCore %s: dcache_port is not connected!", name());

    // Send range check so memory system knows our access range
    //iMemPort_.sendRangeChange();  //this ois produced by the peripherals (rom,ddr,uart etc and not the cpu)
    //dMemPort_.sendRangeChange();
}

void
YarpCore::startup()
{
    SimObject::startup();
    scheduleNextClock();
}

// ============================================================
// Port accessor — wires Python config to C++ ports
// ============================================================

Port &
YarpCore::getPort(const std::string &name, PortID idx)
{
    if (name == "icache_port")
        return iMemPort_;
    if (name == "dcache_port")
        return dMemPort_;
    return SimObject::getPort(name, idx);
}

// ============================================================
// Clock scheduling
// ============================================================

void
YarpCore::scheduleNextClock()
{
    schedule(clockEvent_, curTick() + clockPeriod_);
}

// ============================================================
// Main clock edge
// ============================================================

void
YarpCore::clockEdge()
{
    ++simCycle_;
    stats_.cycles++;

    // 1. De-assert one-cycle strobes from previous cycle
    rtl_->ext_imem_comp_i = 0;
    rtl_->ext_dmem_comp_i = 0;
    for (int i = 0; i < 4; ++i) {
        rtl_->ext_imem_data_i[i] = 0;
        rtl_->ext_dmem_data_i[i] = 0;
    }

    // 2. Reset sequencing
    driveReset();

    // 3. If responses arrived from memory bus this cycle, drive them
    //    into the RTL inputs BEFORE the rising edge
    driveIMemResponse();
    driveDMemResponse();

    // 4. Rising + falling edge
    tickRtl();

    // 5. Sample RTL outputs after clock settles
    sampleIMemRequest();
    sampleDMemRequest();
    sampleRetire();

    scheduleNextClock();
}

// ============================================================
// Reset
// ============================================================

void
YarpCore::driveReset()
{
    if (simCycle_ <= resetCycles_) {
        rtl_->reset_n = 0;
        DPRINTF(YarpCore, "[cycle %lu] reset_n=0\n", simCycle_);
    } else if (simCycle_ == resetCycles_ + 1) {
        rtl_->reset_n = 1;
        DPRINTF(YarpCore, "[cycle %lu] reset_n=1 (de-asserted)\n", simCycle_);
    }
}

// ============================================================
// Clock tick — full rising then falling edge
// ============================================================

void
YarpCore::tickRtl()
{
    rtl_->clk = 1;
    rtl_->eval();

    rtl_->clk = 0;
    rtl_->eval();
}

// ============================================================
// I-mem: sample RTL request → issue gem5 packet
// ============================================================

void
YarpCore::sampleIMemRequest()
{
    if (!rtl_->ext_imem_req_o)
        return;

    if (iMemReqPending_) {
        // RTL is holding the request; we're already waiting for a response
        return;
    }
        // Give cache one cycle to update hit/valid after refill
    if (iMemRespSkipCycles_ > 0) {
        iMemRespSkipCycles_--;
        return;
    }

    // ext_imem_addr_o is the 8-bit cache-LINE index from sa_top
    // Byte address = lineAddr * 16
    Addr lineAddr  = static_cast<Addr>(rtl_->ext_imem_addr_o);
    Addr byteAddr  = lineAddr * YARP_CACHELINE_BYTES;

    PacketPtr pkt  = buildIMemReadPkt(byteAddr);

    DPRINTF(YarpCore,
            "[cycle %lu] I-mem REQ: lineAddr=0x%02lx byteAddr=0x%08lx\n",
            simCycle_, lineAddr, byteAddr);

    if (iMemPort_.sendTimingReq(pkt)) {
        iMemReqPending_ = true;
        stats_.iMemRequests++;
    } else {
        // Port busy — will be retried via recvReqRetry / iMemRecvRetry
        iMemRetryPkt_ = pkt;
        DPRINTF(YarpCore, "[cycle %lu] I-mem sendTimingReq stalled\n",
                simCycle_);
    }
}

void
YarpCore::driveIMemResponse()
{
    if (!iMemRespReady_)
        return;

    // Load 4 × 32-bit words into Verilator WData array
    uint32_t words[4];
    std::memcpy(words, iMemRespData_, YARP_CACHELINE_BYTES);

    rtl_->ext_imem_data_i[0] = words[0];
    rtl_->ext_imem_data_i[1] = words[1];
    rtl_->ext_imem_data_i[2] = words[2];
    rtl_->ext_imem_data_i[3] = words[3];
    rtl_->ext_imem_comp_i    = 1;  // one-cycle strobe

    DPRINTF(YarpCore,
            "[cycle %lu] I-mem RESP driven: [%08x %08x %08x %08x]\n",
            simCycle_, words[0], words[1], words[2], words[3]);

    iMemRespReady_  = false;
    iMemReqPending_ = false;
    iMemRespSkipCycles_ = 4;   // skip 4 cycles after comp_i
}

// Called by IMemPort::recvTimingResp (gem5 memory system callback)
void
YarpCore::iMemRecvResp(PacketPtr pkt)
{
    assert(pkt->isRead());
    assert(pkt->getSize() == YARP_CACHELINE_BYTES);

    std::memcpy(iMemRespData_, pkt->getConstPtr<uint8_t>(),
                YARP_CACHELINE_BYTES);
    iMemRespReady_ = true;

    DPRINTF(YarpCore, "[cycle %lu] I-mem packet returned from memory bus\n",
            simCycle_);

    // gem5 requires the receiver to delete the packet
    delete pkt;
}

// Called when a previously stalled I-mem sendTimingReq can be retried
void
YarpCore::iMemRecvRetry()
{
    assert(iMemRetryPkt_ != nullptr);
    DPRINTF(YarpCore, "[cycle %lu] I-mem retry\n", simCycle_);

    if (iMemPort_.sendTimingReq(iMemRetryPkt_)) {
        iMemRetryPkt_   = nullptr;
        iMemReqPending_ = true;
        stats_.iMemRequests++;
    }
    // If it fails again, keep iMemRetryPkt_ and wait for next retry
}

// ============================================================
// D-mem: sample RTL request → issue gem5 packet
// ============================================================

void
YarpCore::sampleDMemRequest()
{
    if (dMemRespSkipCycles_ > 0) {
        dMemRespSkipCycles_--;
        return;
    }

    bool rReq = static_cast<bool>(rtl_->ext_dmem_r_req_o);
    bool wReq = static_cast<bool>(rtl_->ext_dmem_w_req_o);

    if (!rReq && !wReq)
        return;

    if (dMemReqPending_)
        return;  // already waiting for a response

    if (rReq && wReq)
        warn("[YarpCore][cycle %lu] r_req and w_req both asserted — "
             "treating as read", simCycle_);

    // ext_dmem_addr_o: 8-bit cache-LINE address from d_cache_top
    Addr lineAddr     = static_cast<Addr>(rtl_->ext_dmem_addr_o);
    Addr lineByteAddr = lineAddr * YARP_CACHELINE_BYTES;
    uint8_t boff      = static_cast<uint8_t>(rtl_->ext_dmem_blockoffset_o
                                              & 0x3u);
    bool    isWrite   = wReq && !rReq;

    PacketPtr pkt;

    if (isWrite) {
        // Write targets one 32-bit word within the cache line
        Addr wordAddr = lineByteAddr + static_cast<Addr>(boff) * 4;
        uint32_t wdata = rtl_->ext_dmem_wr_data_o;
        pkt = buildDMemWritePkt(wordAddr, boff, wdata);

        DPRINTF(YarpCore,
                "[cycle %lu] D-mem WRITE: lineAddr=0x%02lx boff=%u "
                "wordAddr=0x%08lx data=0x%08x\n",
                simCycle_, lineAddr, boff, wordAddr, wdata);

        stats_.dMemWriteRequests++;
    } else {
        pkt = buildDMemReadPkt(lineByteAddr);

        DPRINTF(YarpCore,
                "[cycle %lu] D-mem READ:  lineAddr=0x%02lx byteAddr=0x%08lx\n",
                simCycle_, lineAddr, lineByteAddr);

        stats_.dMemReadRequests++;
    }

    // Store metadata needed when response arrives
    dMemRespIsWrite_ = isWrite;

    if (dMemPort_.sendTimingReq(pkt)) {
        dMemReqPending_ = true;
    } else {
        dMemRetryPkt_ = pkt;
        DPRINTF(YarpCore, "[cycle %lu] D-mem sendTimingReq stalled\n",
                simCycle_);
    }
}

void
YarpCore::driveDMemResponse()
{
    if (!dMemRespReady_)
        return;

    if (!dMemRespIsWrite_) {
        // Load full 128-bit cache line into RTL input
        uint32_t words[4];
        std::memcpy(words, dMemRespData_, YARP_CACHELINE_BYTES);

        rtl_->ext_dmem_data_i[0] = words[0];
        rtl_->ext_dmem_data_i[1] = words[1];
        rtl_->ext_dmem_data_i[2] = words[2];
        rtl_->ext_dmem_data_i[3] = words[3];

        DPRINTF(YarpCore,
                "[cycle %lu] D-mem READ RESP driven: [%08x %08x %08x %08x]\n",
                simCycle_, words[0], words[1], words[2], words[3]);
    } else {
        DPRINTF(YarpCore, "[cycle %lu] D-mem WRITE ACK driven\n", simCycle_);
    }

    rtl_->ext_dmem_comp_i = 1;  // one-cycle strobe for both read and write

    dMemRespReady_  = false;
    dMemReqPending_ = false;
    dMemRespSkipCycles_ = 4;   // same as imem
}

// Called by DMemPort::recvTimingResp
void
YarpCore::dMemRecvResp(PacketPtr pkt)
{
    if (pkt->isRead()) {
        assert(pkt->getSize() == YARP_CACHELINE_BYTES);
        std::memcpy(dMemRespData_, pkt->getConstPtr<uint8_t>(),
                    YARP_CACHELINE_BYTES);
        dMemRespIsWrite_ = false;
    } else {
        // Write response — just need the comp_i ack, no data to load
        dMemRespIsWrite_ = true;
    }

    dMemRespReady_ = true;

    DPRINTF(YarpCore, "[cycle %lu] D-mem packet returned from memory bus "
            "(isWrite=%d)\n", simCycle_, dMemRespIsWrite_);

    delete pkt;
}

void
YarpCore::dMemRecvRetry()
{
    assert(dMemRetryPkt_ != nullptr);
    DPRINTF(YarpCore, "[cycle %lu] D-mem retry\n", simCycle_);

    if (dMemPort_.sendTimingReq(dMemRetryPkt_)) {
        dMemRetryPkt_   = nullptr;
        dMemReqPending_ = true;
    }
}

// ============================================================
// Packet builder helpers
// ============================================================

PacketPtr
YarpCore::buildIMemReadPkt(Addr addr)
{
    // Read request for a full 16-byte (128-bit) cache line
    RequestPtr req = std::make_shared<Request>(
        addr,
        YARP_CACHELINE_BYTES,
        Request::INST_FETCH,   // marks as instruction fetch
        requestorId_);

    req->setPC(addr);  // PC = fetch address for tracing

    PacketPtr pkt = new Packet(req, MemCmd::ReadReq);
    pkt->allocate();   // allocate data buffer in the packet
    return pkt;
}

PacketPtr
YarpCore::buildDMemReadPkt(Addr addr)
{
    RequestPtr req = std::make_shared<Request>(
        addr,
        YARP_CACHELINE_BYTES,
        0,               // no special flags for data read
        requestorId_);

    PacketPtr pkt = new Packet(req, MemCmd::ReadReq);
    pkt->allocate();
    return pkt;
}

PacketPtr
YarpCore::buildDMemWritePkt(Addr addr, uint8_t /*blockOffset*/,
                             uint32_t data)
{
    // Write targets a single 32-bit word
    RequestPtr req = std::make_shared<Request>(
        addr,
        sizeof(uint32_t),
        0,
        requestorId_);

    PacketPtr pkt = new Packet(req, MemCmd::WriteReq);
    pkt->allocate();
    // Copy the 4-byte write data into the packet
    pkt->setData(reinterpret_cast<const uint8_t*>(&data));
    return pkt;
}

// ============================================================
// Retire / statistics
// ============================================================

void
YarpCore::sampleRetire()
{
    if (!rtl_->retire_done)
        return;

    stats_.retiredInsns = static_cast<uint64_t>(rtl_->retire_count);

    DPRINTF(YarpCore, "[cycle %lu] RETIRE: retire_count=%u\n",
            simCycle_,
            static_cast<unsigned>(rtl_->retire_count));
}

} // namespace gem5
