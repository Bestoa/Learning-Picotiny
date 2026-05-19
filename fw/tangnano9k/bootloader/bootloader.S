.section .text

.global crtStart

crtStart:
    la a0, 0x100
    la a1, 0x40000000
    la a2, 0x08100 // 32KB
copy_loop:
    lw a3, 0(a0)
    sw a3, 0(a1)
    addi a0, a0, 4
    addi a1, a1, 4
    bne a0, a2, copy_loop

    la a0, 0x40000000
    jalr a1, a0, 0

loop:
    j loop
