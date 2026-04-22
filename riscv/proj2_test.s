#
# First part of the Lab 3 test program
#

# data section
.data

# code/instruction section
.text

# Tests
lui x1, 0x10010
addi x2, x0, 50
nop
nop
addi x1, x1, 0x100
nop
nop
nop
sw x2, 0(x1)
j pos1
nop
nop
lw x3, 0(x1)
pos1: 
lw x4, 0(x1)
nop
nop
nop
wfi