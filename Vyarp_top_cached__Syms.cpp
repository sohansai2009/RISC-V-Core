// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table implementation internals

#include "Vyarp_top_cached__Syms.h"
#include "Vyarp_top_cached.h"



// FUNCTIONS
Vyarp_top_cached__Syms::Vyarp_top_cached__Syms(Vyarp_top_cached* topp, const char* namep)
    // Setup locals
    : __Vm_namep(namep)
    , __Vm_didInit(false)
    // Setup submodule names
{
    // Pointer to top level
    TOPp = topp;
    // Setup each module's pointers to their submodules
    // Setup each module's pointer back to symbol table (for public functions)
    TOPp->__Vconfigure(this, true);
}
