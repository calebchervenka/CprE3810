# Mergesort - Software Scheduled for 5-Stage Pipeline (No Forwarding)
# CPRE 3810 - Pipeline Hazard Scheduling
#
# Pipeline: IF -> ID -> EX -> MEM -> WB
# No data forwarding. Branch resolved end of EX stage.
#
# HAZARD RULES APPLIED:
#   DATA: Producer at pos P, consumer at pos C: require C - P >= 3
#         (2 independent instructions between producer and consumer)
#   CTRL: Branch/jump at pos B: instructions at B+1 and B+2 are always fetched.
#         If they are squashed on taken path, they must be safe to squash.
#         Fill with instructions that are useful on not-taken path and safe on taken path.
#
# ANNOTATION KEY in comments:
#   [Dx/2] = data hazard delay slot x of 2
#   [Cx/2] = control hazard delay slot x of 2
#   * = filled with useful instruction (not a NOP)

.data
    array_size: .word 12
    array:      .word 65, 12, 10, 89, 11, 70, 67, 5, 9, 45, 90, 7
    .align 2
    temp_array: .space 2048

.text
    li    sp, 0x10012000
    li    fp, 0
    lasw  ra, pump
    j     main
    nop                          # [C1/2] no useful instr available
    nop                          # [C2/2] no useful instr available
pump:
    j     end
    nop                          # [C1/2]
    nop                          # [C2/2]
    ebreak

# ------------------------------------------------------------------
# main
# ------------------------------------------------------------------
main:
    addi  sp, sp, -4
    lasw  a0, array              # [D1/2 for addi sp] * fills sp hazard slot
    lasw  t0, array_size         # [D2/2 for addi sp] * fills sp hazard slot
    sw    ra, 0(sp)              # sp ready (lasw expands to 5+ instrs above)
    lw    a1, 0(t0)              # a1 = size
    nop                          # [D1/2 for lw a1]
    nop                          # [D2/2 for lw a1]
    jal   ra, sort
    nop                          # [C1/2]
    nop                          # [C2/2]
    lw    ra, 0(sp)
    addi  sp, sp, 4              # [D1/2 for lw ra] * useful
    nop                          # [D2/2 for lw ra]
    jr    ra
    nop                          # [C1/2]
    nop                          # [C2/2]

# ------------------------------------------------------------------
# sort(int* array, int size)  a0=array, a1=size
# ------------------------------------------------------------------
.globl sort
sort:
    li    t0, 1
    addi  sp, sp, -4             # [D1/2 for li t0] * useful
    nop                          # [D2/2 for li t0]
    slt   t1, t0, a1             # t1 = (1 < size)
    sw    ra, 0(sp)              # [D1/2 for slt t1] * useful (sp ready: addi was 3 instrs ago)
    nop                          # [D2/2 for slt t1]
    beq   t1, x0, sort_end
    mv    a2, a1                 # [C1/2] * a2 = size; squashed if taken (safe)
    addi  a2, a2, -1             # [C2/2] * a2 = high; squashed if taken (safe)
    # ^^^ HAZARD EXAMPLE 1 (Control): 2 branch slots filled with useful arg setup.
    # If branch taken: squashed, sp stays clean since we branch before jal.
    # If branch not taken: a2 = size-1 = high, exactly what mergesort needs.
    # Zero NOPs used for this branch.
    li    a1, 0                  # a1 = low = 0
    # a2 written 2 instrs ago (addi a2), a1 just written. jal reads both in ID.
    # a2: gap from addi a2 to jal = need >= 3 positions apart.
    # addi a2 @ -2, li a1 @ -1, nop @ 0, jal @ 1: gap(addi a2, jal) = 3. OK.
    nop                          # [D1/2 for a1, a2 combined]
    # a1 written 2 instrs ago (li a1 @ -2), jal is next @ +1: gap=3. OK.
    # Both a1 and a2 safe now with this single nop.
    # ^^^ HAZARD EXAMPLE 2 (Data): Only 1 NOP needed instead of 2 because
    # the "li a1" instruction between "addi a2" and the jal also serves as
    # a delay slot for a2. Single NOP covers both a1 and a2.
    jal   ra, mergesort
    nop                          # [C1/2]
    nop                          # [C2/2]
    lw    ra, 0(sp)
    addi  sp, sp, 4              # [D1/2 for lw ra] *
    nop                          # [D2/2 for lw ra]
sort_end:
    jr    ra
    nop                          # [C1/2]
    nop                          # [C2/2]

# ------------------------------------------------------------------
# mergesort(int* array, int low, int high)
# a0=array, a1=low, a2=high
# Frame: 16 bytes  [ra@12, s0@8, s1@4, s2@0]
# s0=low, s1=high, s2=mid
# ------------------------------------------------------------------
mergesort:
    slt   t0, a1, a2             # t0 = (low < high)
    nop                          # [D1/2 for t0]
    nop                          # [D2/2 for t0]
    beq   t0, x0, ms_ret        # base case: low >= high, return
    addi  sp, sp, -16            # [C1/2] * frame alloc; squashed if taken (safe)
    mv    s0, a1                 # [C2/2] * s0=low; squashed if taken (safe)
    # ^^^ HAZARD EXAMPLE 3 (Control): Branch to ms_ret fills 2 ctrl slots with
    # frame allocation and argument save. If taken: pipeline flushes both,
    # sp unmodified, s0 unmodified - correct. If not taken: both execute
    # and are necessary. Zero NOPs for control hazard.

    # sp written by addi sp @ pos 0 (relative to here). sw ra @ pos 2 uses sp.
    # gap = 2. Exactly safe (need >= 2 between producer and consumer).
    sw    ra, 12(sp)             # sp gap = 2 (addi sp, mv s0, sw ra). OK.
    sw    s0,  8(sp)             # s0 gap = 2 (mv s0, sw ra, sw s0). OK.
    # ^^^ HAZARD EXAMPLE 4 (Data): sp used with gap=2 (minimum), no NOP needed.
    # s0 also used with gap=2 (minimum), no NOP needed.
    # Two consecutive stores, both at minimum gap, no NOPs inserted.
    mv    s1, a2                 # s1 = high
    sw    s2,  0(sp)             # [D1/2 for mv s1] * save old s2 - independent!
    sw    s1,  4(sp)             # s1 gap = 2 (mv s1, sw s2, sw s1). OK.
    # ^^^ HAZARD EXAMPLE 5 (Data): "sw s2" inserted between "mv s1" and "sw s1"
    # to fill the data hazard slot with a necessary save instruction. Zero NOPs.

    add   s2, s0, s1             # s2 = low + high
    nop                          # [D1/2 for add s2]
    nop                          # [D2/2 for add s2]
    srli  s2, s2, 1              # s2 = mid

    # LEFT CALL: mergesort(array, low, mid)
    mv    a1, s0                 # a1 = low
    mv    a2, s2                 # a2 = mid
    nop                          # [D1/2 for a1, a2]
    nop                          # [D2/2 for a1, a2]
    jal   ra, mergesort
    nop                          # [C1/2]
    nop                          # [C2/2]

    # RIGHT CALL: mergesort(array, mid+1, high)
    addi  a1, s2, 1              # a1 = mid + 1
    mv    a2, s1                 # a2 = high
    nop                          # [D1/2 for a1, a2]
    nop                          # [D2/2 for a1, a2]
    jal   ra, mergesort
    nop                          # [C1/2]
    nop                          # [C2/2]

    # MERGE CALL: merge(array, low, mid, high)
    mv    a1, s0                 # a1 = low
    mv    a2, s2                 # a2 = mid
    mv    a3, s1                 # a3 = high
    nop                          # [D1/2 for a1,a2,a3]
    nop                          # [D2/2 for a1,a2,a3]
    jal   ra, merge
    nop                          # [C1/2]
    nop                          # [C2/2]

    # EPILOGUE
    lw    ra, 12(sp)
    lw    s0,  8(sp)             # [D1/2 for lw ra] * independent load
    lw    s1,  4(sp)             # [D2/2 for lw ra] * independent load
    # ^^^ HAZARD EXAMPLE 6 (Data): "lw ra" hazard slots filled with two other
    # necessary restore loads. Zero NOPs for ra's data hazard.
    lw    s2,  0(sp)
    addi  sp, sp, 16             # [D1/2 for lw s2 (last)] * useful
    nop                          # [D2/2 for lw s2]
    # ra also needed: lw ra @ pos 0, jr ra @ pos 6 (gap=6 >> 2). Safe.
ms_ret:
    jr    ra
    nop                          # [C1/2]
    nop                          # [C2/2]


# ------------------------------------------------------------------
# merge(int* array, int low, int mid, int high)
# a0=array, a1=low, a2=mid, a3=high
# t0=i, t1=j, t2=k, t3=&temp, t4,t5=data, t6=addr scratch
# ------------------------------------------------------------------
merge:
    mv    t0, a1                 # i = low
    addi  t1, a2, 1             # j = mid + 1
    mv    t2, a1                 # k = low
    lasw  t3, temp_array         # t3 = &temp_array (lasw provides safe gap internally)

merge_loop:
    # --- check left exhausted: i > mid ---
    slt   t4, a2, t0             # t4 = (mid < i)?
    nop                          # [D1/2 for t4]
    nop                          # [D2/2 for t4]
    bne   t4, x0, merge_right_rem

    # --- check right exhausted: j > high ---
    slt   t4, a3, t1             # t4 = (high < j)?
    nop                          # [D1/2 for t4]
    nop                          # [D2/2 for t4]
    bne   t4, x0, merge_left_rem

    # --- load arr[i] and arr[j] ---
    slli  t6, t0, 2              # t6 = i*4
    slli  t5, t1, 2              # [D1/2 for t6] * t5 = j*4 (independent, fills slot!)
    # ^^^ HAZARD EXAMPLE 7 (Data): j*4 calculation fills i*4's hazard slot.
    # One NOP saved.
    nop                          # [D2/2 for t6]
    add   t6, a0, t6             # t6 = &arr[i]
    add   t5, a0, t5             # [D1/2 for add t6] * t5 = &arr[j] (independent!)
    nop                          # [D2/2 for add t6]
    lw    t4, 0(t6)              # t4 = arr[i]
    lw    t5, 0(t5)              # [D1/2 for lw t4] * t5 = arr[j] (independent addr!)
    nop                          # [D2/2 for lw t4]
    # t5 (arr[j]) written 2 instrs ago; slt reads t5 here... gap = 2. OK.
    # t4 (arr[i]) written 3 instrs ago; gap = 3. OK.
    # ^^^ HAZARD EXAMPLE 8 (Data): "lw t5" fills lw t4's hazard slot.
    # Both loads happen back-to-back with the second filling the first's delay slot.
    nop                          # [D1/2 for lw t5] (t5 just written, need 2 more instrs)
    nop                          # [D2/2 for lw t5]
    slt   t6, t5, t4             # t6 = (arr[j] < arr[i])?
    nop                          # [D1/2 for slt t6]
    nop                          # [D2/2 for slt t6]
    beq   t6, x0, merge_copy_left  # arr[i] <= arr[j]: copy from left

# --- copy from right: temp[k] = arr[j] ---
merge_copy_right:
    slli  t6, t2, 2              # [C1/2] * t6 = k*4
    add   t6, t3, t6             # [C2/2] * t6 = &temp[k]
    nop                          # [D1/2 for add t6]
    nop                          # [D2/2 for add t6]
    sw    t5, 0(t6)              # temp[k] = arr[j]
    addi  t1, t1, 1              # j++
    addi  t2, t2, 1              # k++
    j     merge_loop
    nop                          # [C1/2]
    nop                          # [C2/2]

# --- copy from left: temp[k] = arr[i] ---
merge_copy_left:
    slli  t6, t2, 2              # [C1/2] * t6 = k*4
    add   t6, t3, t6             # [C2/2] * t6 = &temp[k]
    nop                          # [D1/2 for add t6]
    nop                          # [D2/2 for add t6]
    sw    t4, 0(t6)              # temp[k] = arr[i]
    addi  t0, t0, 1              # i++
    addi  t2, t2, 1              # k++
    j     merge_loop
    nop                          # [C1/2]
    nop                          # [C2/2]

# --- left remainder ---
merge_left_rem:
    slt   t4, a2, t0             # t4 = (mid < i)?
    nop                          # [D1/2 for t4]
    nop                          # [D2/2 for t4]
    bne   t4, x0, merge_copy_back
    slli  t6, t0, 2              # [C1/2] * t6 = i*4
    add   t6, a0, t6             # [C2/2] * t6 = &arr[i]
    nop                          # [D1/2 for add t6]
    nop                          # [D2/2 for add t6]
    lw    t4, 0(t6)              # t4 = arr[i]
    slli  t6, t2, 2              # [D1/2 for lw t4] * t6 = k*4
    add   t6, t3, t6             # [D2/2 for lw t4] * t6 = &temp[k]
    # ^^^ Both lw delay slots filled with &temp[k] calculation. Zero NOPs.
    nop                          # [D1/2 for add t6 (second)]
    nop                          # [D2/2 for add t6 (second)]
    sw    t4, 0(t6)              # temp[k] = arr[i]
    addi  t0, t0, 1              # i++
    addi  t2, t2, 1              # k++
    j     merge_left_rem
    nop                          # [C1/2]
    nop                          # [C2/2]

# --- right remainder ---
merge_right_rem:
    slt   t4, a3, t1             # t4 = (high < j)?
    nop                          # [D1/2 for t4]
    nop                          # [D2/2 for t4]
    bne   t4, x0, merge_copy_back
    slli  t6, t1, 2              # [C1/2] * t6 = j*4
    add   t6, a0, t6             # [C2/2] * t6 = &arr[j]
    nop                          # [D1/2 for add t6]
    nop                          # [D2/2 for add t6]
    lw    t5, 0(t6)              # t5 = arr[j]
    slli  t6, t2, 2              # [D1/2 for lw t5] * t6 = k*4
    add   t6, t3, t6             # [D2/2 for lw t5] * t6 = &temp[k]
    nop                          # [D1/2 for add t6 (second)]
    nop                          # [D2/2 for add t6 (second)]
    sw    t5, 0(t6)              # temp[k] = arr[j]
    addi  t1, t1, 1              # j++
    addi  t2, t2, 1              # k++
    j     merge_right_rem
    nop                          # [C1/2]
    nop                          # [C2/2]

# --- copy temp back to array ---
merge_copy_back:
    mv    t0, a1                 # k = low (reset)
merge_copy_back_loop:
    slt   t4, a3, t0             # t4 = (high < k)?
    nop                          # [D1/2 for t4]
    nop                          # [D2/2 for t4]
    bne   t4, x0, merge_ret
    slli  t4, t0, 2              # [C1/2] * t4 = k*4
    add   t4, t3, t4             # [C2/2] * t4 = &temp[k]
    nop                          # [D1/2 for add t4]
    nop                          # [D2/2 for add t4]
    lw    t4, 0(t4)              # t4 = temp[k]
    slli  t5, t0, 2              # [D1/2 for lw t4] * t5 = k*4
    add   t5, a0, t5             # [D2/2 for lw t4] * t5 = &arr[k]
    nop                          # [D1/2 for add t5]
    nop                          # [D2/2 for add t5]
    sw    t4, 0(t5)              # arr[k] = temp[k]
    addi  t0, t0, 1              # k++
    j     merge_copy_back_loop
    nop                          # [C1/2]
    nop                          # [C2/2]

merge_ret:
    jr    ra
    nop                          # [C1/2]
    nop                          # [C2/2]

end:
    wfi
    ebreak