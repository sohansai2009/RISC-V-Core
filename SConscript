Import('*')

# 1. Python Blueprint
SimObject('YarpCore.py', sim_objects=['YarpCore'])

# 2. C++ wrapper (FS mode — uses RequestPort, no FlatMemory)
Source('yarp_core_wrapper.cc')

Source('verilated.cpp')
Source('Vyarp_top_cached.cpp')          # was: Vyarp_top.cpp
Source('Vyarp_top_cached__Syms.cpp')    # was: Vyarp_top__Syms.cpp

# 4. Debug flag — enables DPRINTF(YarpCore, ...) at runtime with
#    --debug-flags=YarpCore
DebugFlag('YarpCore')

# 5. Verilator include paths
env.Append(CPPPATH=[
    '/usr/share/verilator/include',
    '/usr/share/verilator/include/vltstd',
])
