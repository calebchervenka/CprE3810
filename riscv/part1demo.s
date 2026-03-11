#
# First part of the Lab 3 test program
#

# data section
.data

# Addi
.text
addi    x1,     x0,     1 		# Place 1  in x1
addi    x2,     x0,     2		# Place 2  in x2
addi    x3,     x0,     3		# Place 3  in x3
addi    x4,     x0,     4		# Place 4  in x4
addi    x5,     x0,     5		# Place 5  in x5
addi    x6,     x0,     6		# Place 6  in x6
addi    x7,     x0,     7		# Place 7  in x7
addi    x8,     x0,     8		# Place 8  in x8
addi    x9,     x0,     9		# Place 9  in x9
addi    x10,    x0,     10		# Place 10 in x10

# Add
add     x11,    x1,     x2		# Place 3  in x11
add     x12,    x3,     x4		# Place 7  in x12
add     x13,    x5,     x6		# Place 11 in x13
add     x14,    x7,     x8		# Place 15 in x14
add     x15,    x9,     x10     # Place 19 in x15

# Sub
sub     x16,    x1,     x2		# Place -1  in x16
sub     x17,    x3,     x4		# Place -1  in x17
sub     x18,    x5,     x6		# Place -1  in x18
sub     x19,    x7,     x8        # Place -1  in x19
sub     x20,    x9,     x10       # Place -1  in x20

# Load and Store 
# sw     x15,    0(x21)		# Store the value in x11 to memory address 0
lui      x21,    0x70F0F		# Place the address of the memory-mapped I/O in x21
# sw      x15,    0(x21)		# Store the value in x15 to the memory-mapped I/O
wfi