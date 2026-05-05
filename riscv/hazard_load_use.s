# Load/use hazard test: immediate consumers of loaded values.
#
# Expected data memory words after running:
#   0x10010000 = 123   original loaded value
#   0x10010004 = 7     original second loaded value
#   0x10010008 = 124   lw followed immediately by addi
#   0x1001000C = 131   lw followed immediately by add using a previous result
#   0x10010010 = 55    lw followed immediately by sw store-data path

.data

.text
    lui  a0, 0x10010

    # Seed data memory with known inputs.
    addi t0, x0, 123
    sw   t0, 0(a0)
    addi t1, x0, 7
    sw   t1, 4(a0)
    addi t2, x0, 55
    sw   t2, 16(a0)

    # Load-use into ALU operand A.
    lw   t3, 0(a0)
    addi t4, t3, 1
    sw   t4, 8(a0)

    # Load-use into a two-source ALU instruction.
    lw   t5, 4(a0)
    add  t6, t5, t4
    sw   t6, 12(a0)

    # Load immediately feeding store data.
    lw   s1, 16(a0)
    sw   s1, 16(a0)

    wfi
    nop
    nop
