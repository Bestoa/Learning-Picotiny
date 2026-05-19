#include "custom_ops.S"
.section .text

.global crtStart
.global main

crtStart:
    j crtInit
    nop
    nop
    nop

.balign 0x400
.global  trap_entry
trap_entry:
    picorv32_retirq_insn()

crtInit:
.option push
.option norelax
    la gp, __global_pointer$
.option pop
    la sp, _stack_start

bss_init:
    la a0, _bss_start
    la a1, _bss_end
bss_loop:
    beq a0,a1,bss_done
    sw zero,0(a0)
    add a0,a0,4
    j bss_loop
bss_done:

    call main
infinitLoop:
    j infinitLoop
