# Control-hazard combination test: taken beq, not-taken bne, jal, and jalr return.
#
# Expected data memory word after running:
#   0x10010000 = 31
#
# Correct path accumulation:
#   +1 after taken beq target
#   +2 after not-taken bne fall-through
#   +4 after jal target
#   +16 inside jalr-return subroutine
#   +8 after returning with jalr
#
# Any unflushed wrong-path addi instructions add large values, making failures obvious.

.data

.text
    lui  a0, 0x10010
    addi s0, x0, 0
    sw   s0, 0(a0)

    addi t0, x0, 1
    addi t1, x0, 1

    beq  t0, t1, beq_taken
    addi s0, s0, 100
    addi s0, s0, 100

beq_taken:
    addi s0, s0, 1

    bne  t0, t1, bne_wrong
    addi s0, s0, 2

    jal  ra, jal_target
    addi s0, s0, 1000
    addi s0, s0, 1000

jal_target:
    addi s0, s0, 4

    jal  ra, jalr_func
after_call:
    addi s0, s0, 8
    sw   s0, 0(a0)
    jal  x0, done

bne_wrong:
    addi s0, s0, 500
    sw   s0, 0(a0)
    jal  x0, done

jalr_func:
    addi s0, s0, 16
    jalr x0, 0(ra)

done:
    wfi
    nop
    nop
