#include "custom_ops.S"
.section .text

.global crtStart
.global main
.global irqCallback
.global set_timer
.global disable_irq
.global enable_irq

crtStart:
    j crtInit
    nop
    nop
    nop

.balign 0x400
.global  trap_entry
// x0 is constant
// x2 is sp (always changing)
// x3-4 are gp, tp (fixed through program)
// x8-9, x18-27 are callee-saved registers
trap_entry:
    sw x1,  - 1*4(sp)
    sw x5,  - 2*4(sp)
    sw x6,  - 3*4(sp)
    sw x7,  - 4*4(sp)
    sw x10, - 5*4(sp)
    sw x11, - 6*4(sp)
    sw x12, - 7*4(sp)
    sw x13, - 8*4(sp)
    sw x14, - 9*4(sp)
    sw x15, -10*4(sp)
    sw x16, -11*4(sp)
    sw x17, -12*4(sp)
    sw x28, -13*4(sp)
    sw x29, -14*4(sp)
    sw x30, -15*4(sp)
    sw x31, -16*4(sp)
    addi sp,sp,-16*4
    picorv32_getq_insn(a0, q1)
    call irqCallback
    lw x1 , 15*4(sp)
    lw x5,  14*4(sp)
    lw x6,  13*4(sp)
    lw x7,  12*4(sp)
    lw x10, 11*4(sp)
    lw x11, 10*4(sp)
    lw x12,  9*4(sp)
    lw x13,  8*4(sp)
    lw x14,  7*4(sp)
    lw x15,  6*4(sp)
    lw x16,  5*4(sp)
    lw x17,  4*4(sp)
    lw x28,  3*4(sp)
    lw x29,  2*4(sp)
    lw x30,  1*4(sp)
    lw x31,  0*4(sp)
    addi sp,sp,16*4
    picorv32_retirq_insn()

crtInit:
.option push
.option norelax
    la gp, __global_pointer$
.option pop
    la sp, _stack_start

# copy data section
    la a0, _sidata
    la a1, _sdata
    la a2, _edata
    bge a1, a2, end_init_data
loop_init_data:
    lw a3, 0(a0)
    sw a3, 0(a1)
    addi a0, a0, 4
    addi a1, a1, 4
    blt a1, a2, loop_init_data
end_init_data:

bss_init:
    la a0, _bss_start
    la a1, _bss_end
bss_loop:
    beq a0,a1,bss_done
    sw zero,0(a0)
    add a0,a0,4
    j bss_loop
bss_done:

ctors_init:
    la a0, _ctors_start
    addi sp,sp,-4
ctors_loop:
    la a1, _ctors_end
    beq a0,a1,ctors_done
    lw a3,0(a0)
    add a0,a0,4
    sw a0,0(sp)
    jalr  a3
    lw a0,0(sp)
    j ctors_loop
ctors_done:
    addi sp,sp,4

    /* Enable IRQ */
    picorv32_maskirq_insn(zero, zero)
    call main
infinitLoop:
    j infinitLoop

set_timer:
    picorv32_timer_insn(zero, a0)
    ret

disable_irq:
    li t0, 0xffffffff
    picorv32_maskirq_insn(zero, t0)
    ret

enable_irq:
    picorv32_maskirq_insn(zero, zero)
    ret
