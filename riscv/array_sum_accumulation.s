# Array Sum Accumulation - Problem File
# Memory addressing starts at 0x10010000


.text
.globl _start

_start:
    lui a0, 0x10010
    nop
    nop
    nop
    sw x0, 0(a0)           # Zero-init array entries for sum accumulation
    sw x0, 4(a0)
    sw x0, 8(a0)
    sw x0, 12(a0)
    li a1, 0
    li t2, 4
    li t3, 0
    addi t5, zero, 100
    addi t6, zero, 200

loop:
    lw t0, 0(a0)
    nop
    nop
    add a1, a1, t0
    addi a0, a0, 4
    addi t3, t3, 1
    nop
    nop
    nop
    add t4, t3, zero
    nop
    nop
    nop
    blt t4, t2, loop
    nop
    nop
    nop
    sw a1, 32(a0)
    wfi
