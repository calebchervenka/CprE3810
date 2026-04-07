#
# First part of the Lab 3 test program
#

# data section
.data

# code/instruction section
.text

# Store
addi t1, x0, 1024
add t1, t1, t1
add t1, t1, t1

addi t1, t1, 1

add t1, t1, t1
add t1, t1, t1
add t1, t1, t1
add t1, t1, t1
add t1, t1, t1
add t1, t1, t1
add t1, t1, t1
add t1, t1, t1
add t1, t1, t1
add t1, t1, t1
add t1, t1, t1
add t1, t1, t1
add t1, t1, t1
add t1, t1, t1
add t1, t1, t1
add t1, t1, t1


# TODO: Implement Load


# store into hex 10010100
# 10010000
# store value of 50

addi t1, t1, 0x100
addi t2, x0, 50
sw t2, 0(t1)

wfi
