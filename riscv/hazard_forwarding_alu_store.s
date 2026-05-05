# Data-forwarding test: ALU EX/MEM, ALU MEM/WB, priority, and store-data forwarding.
#
# Expected data memory words after running:
#   0x10010000 = 99    store-data forwarding into sw
#   0x10010004 = 14    EX/MEM forwarding to both ALU operands
#   0x10010008 = 21    MEM/WB forwarding to ALU operand
#   0x1001000C = 11    MEM forwarding priority over older WB value

.data

.text
    lui  a0, 0x10010

    # EX/MEM -> EX forwarding on both source operands.
    addi t0, x0, 7
    add  t1, t0, t0

    # MEM/WB -> EX forwarding. The independent instruction creates a one-cycle gap.
    addi t2, x0, 20
    addi t3, x0, 1
    add  t4, t2, t3

    # Forwarding priority: newest s1=11 must beat older s1=5.
    addi s1, x0, 5
    addi s1, s1, 6
    add  s2, s1, x0

    # Store-data forwarding: sw must store 99 even though s3 was just written.
    addi s3, x0, 99
    sw   s3, 0(a0)

    sw   t1, 4(a0)
    sw   t4, 8(a0)
    sw   s2, 12(a0)

    wfi
    nop
    nop
