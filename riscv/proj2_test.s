#
# First part of the Lab 3 test program
#

# data section
.data

# code/instruction section
.text

# Tests
lui a0, 0x10010
addi x1, x0, 4
add x1, x1, x1
add x2, x1, x0
sw x2, 0(a0)           # Zero-init array entries for sum accumulation
# sw x0, 4(a0)
# sw x0, 8(a0)
# sw x0, 12(a0)

# li a1, 0
# li t2, 4
# li t3, 0

# beq x0, x0, test1
# nop
# nop
# addi x1, x0, 14

# test1:
# addi x1, x0, 12
wfi