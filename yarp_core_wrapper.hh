// -*- mode: c++ -*-
// gem5 v25.1  Verilated wrapper header — YARP RISC-V core
// Full-System mode: IMemPort and DMemPort connect to gem5's memory bus.
//
// File: src/cpu/riscv_cached/yarp_core_wrapper.hh

#ifndef __CPU_RISCV_CACHED_YARP_CORE_WRAPPER_HH__
#define __CPU_RISCV_CACHED_YARP_CORE_WRAPPER_HH__

#include <cstdint>
#include <memory>
#include <queue>
#include <string>

// gem5 v25.1 headers
#include "mem/port.hh"
#include "mem/packet.hh"
#include "mem/request.hh"
#include "params/YarpCore.hh"
#include "sim/sim_object.hh"
#include "sim/eventq.hh"
#include "base/statistics.hh"
#include "base/trace.hh"

// Verilator generated header
#include "Vyarp_top_cached.h"        // was: #include "Vyarp_top.h"
namespace gem5 {

// ------------------------------------------------------------------ //
// Constants                                                           //
// ------------------------------------------------------------------ //

// RTL cache line = 128 bits = 16 bytes
static constexpr unsigned YARP_CACHELINE_BYTES = 16;

// ------------------------------------------------------------------ //
// Pending transaction descriptors                                     //
// ------------------------------------------------------------------ //

struct IMemPending {
    PacketPtr pkt;       // in-flight gem5 packet
    bool      waiting;   // true = sent, awaiting recvTimingResp
};

struct DMemPending {
    PacketPtr pkt;
    bool      isWrite;
    uint8_t   blockOffset;  // ext_dmem_blockoffset_o: word index [0-3]
    bool      waiting;
};

// ------------------------------------------------------------------ //
// YarpCore SimObject                                                  //
// ------------------------------------------------------------------ //

class YarpCore : public SimObject
{
  public:
    // ---------------------------------------------------------------- //
    // Instruction memory RequestPort                                    //
    // ---------------------------------------------------------------- //
    class IMemPort : public RequestPort
    {
      public:
        IMemPort(const std::string &name, YarpCore *owner)
            : RequestPort(name), owner_(owner) {}

      protected:
        // Called by gem5 when memory system returns a response packet
        bool recvTimingResp(PacketPtr pkt) override;
        // Called when a previously stalled sendTimingReq can be retried
        void recvReqRetry() override;

      private:
        YarpCore *owner_;
    };

    // ---------------------------------------------------------------- //
    // Data memory RequestPort                                           //
    // ---------------------------------------------------------------- //
    class DMemPort : public RequestPort
    {
      public:
        DMemPort(const std::string &name, YarpCore *owner)
            : RequestPort(name), owner_(owner) {}

      protected:
        bool recvTimingResp(PacketPtr pkt) override;
        void recvReqRetry() override;

      private:
        YarpCore *owner_;
    };

    // ---------------------------------------------------------------- //
    // Construction / destruction                                        //
    // ---------------------------------------------------------------- //
    explicit YarpCore(const YarpCoreParams &params);
    ~YarpCore() override;

    // gem5 SimObject interface
    void init()    override;
    void startup() override;

    // Port accessor — called by gem5 to wire ports in Python config
    Port &getPort(const std::string &name,
                  PortID idx = InvalidPortID) override;

  private:
    // ---------------------------------------------------------------- //
    // Clock event                                                       //
    // ---------------------------------------------------------------- //
    EventFunctionWrapper clockEvent_;
    void clockEdge();
    void scheduleNextClock();

    // ---------------------------------------------------------------- //
    // RTL helpers                                                       //
    // ---------------------------------------------------------------- //
    void driveReset();
    void tickRtl();

    // ---------------------------------------------------------------- //
    // I-mem port callbacks (called from IMemPort)                      //
    // ---------------------------------------------------------------- //
    void iMemRecvResp(PacketPtr pkt);
    void iMemRecvRetry();

    // ---------------------------------------------------------------- //
    // D-mem port callbacks (called from DMemPort)                      //
    // ---------------------------------------------------------------- //
    void dMemRecvResp(PacketPtr pkt);
    void dMemRecvRetry();

    // ---------------------------------------------------------------- //
    // Per-cycle interface sampling / driving                            //
    // ---------------------------------------------------------------- //
    void sampleIMemRequest();
    void sampleDMemRequest();

    void driveIMemResponse();   // assert comp_i when resp arrived
    void driveDMemResponse();

    void sampleRetire();

    // ---------------------------------------------------------------- //
    // Packet builder helpers                                            //
    // ---------------------------------------------------------------- //
    PacketPtr buildIMemReadPkt(Addr addr);
    PacketPtr buildDMemReadPkt(Addr addr);
    PacketPtr buildDMemWritePkt(Addr addr, uint8_t blockOffset,
                                uint32_t data);

    // ---------------------------------------------------------------- //
    // Private data                                                      //
    // ---------------------------------------------------------------- //

    // Verilated model
std::unique_ptr<Vyarp_top_cached> rtl_;   // was: std::unique_ptr<Vyarp_top>
    // gem5 memory ports
    IMemPort iMemPort_;
    DMemPort dMemPort_;

    // Pending transactions
    //   At most one outstanding I-mem request (RTL has a single cache)
    bool          iMemReqPending_;
    bool          iMemRespReady_;
    uint8_t       iMemRespData_[YARP_CACHELINE_BYTES];
    unsigned iMemRespSkipCycles_;
    bool          dMemReqPending_;
    bool          dMemRespReady_;
    bool          dMemRespIsWrite_;
    uint8_t       dMemRespData_[YARP_CACHELINE_BYTES];
    unsigned dMemRespSkipCycles_;

    // Retry queues — packets that couldn't be sent (port was busy)
    PacketPtr     iMemRetryPkt_;
    PacketPtr     dMemRetryPkt_;

    // RequestorID assigned by gem5 memory system
    RequestorID   requestorId_;

    // Config
    const Tick     clockPeriod_;
    const unsigned resetCycles_;
    const bool     dumpRetireStats_;

    uint64_t simCycle_;

    // ---------------------------------------------------------------- //
    // gem5 statistics                                                   //
    // ---------------------------------------------------------------- //
    struct YarpStats : public statistics::Group {
        YarpStats(YarpCore *parent);
        statistics::Scalar cycles;
        statistics::Scalar retiredInsns;
        statistics::Scalar iMemRequests;
        statistics::Scalar dMemReadRequests;
        statistics::Scalar dMemWriteRequests;
        statistics::Formula ipc;
    } stats_;
};

} // namespace gem5

#endif // __CPU_RISCV_CACHED_YARP_CORE_WRAPPER_HH__
