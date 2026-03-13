#
# First part of the Lab 3 test program
#

# data section
.data

# code/instruction section
.text

# addi
addi  x1,  x0,  1 		# Place 1  in x1
addi  x2,  x0,  2		# Place 2  in x2
addi  x3,  x0,  3		# Place 3  in x3
addi  x4,  x0,  4		# Place 4  in x4
addi  x5,  x0,  5		# Place 5  in x5

# addi (negative)
addi  x6,  x0,  -1		# Place -1 in x6
addi  x7,  x0,  -2		# Place -2 in x7
addi  x8,  x0,  -3		# Place -3 in x8
addi  x9,  x0,  -4		# Place -4 in x9
addi  x10, x0,  -5        # Place -5 in x10

# sub
sub   x11, x1,  x2		# Place 1 - 2  in x11
sub   x12, x1,  x3		# Place 1 - 3  in x12
sub   x13, x1,  x4        # Place 1 - 4  in x13
sub   x14, x1,  x5        # Place 1 - 5  in x14
sub   x15, x2,  x1        # Place 2 - 1  in x15

# lw and sw
sw    x1, 0(x0)		# Store 1 at address 0
sw    x2, 4(x0)		# Store 2 at address 4
sw    x3, 8(x0)		# Store 3 at address 8
sw    x4, 12(x0)		# Store 4 at address 12
sw    x5, 16(x0)		# Store 5 at address 16

wfi
