# Mergesort Algorithm in RISC-V Assembly
# Optimized for RARS/CPRE 3810 Compatibility
# Patterns adapted from grendel.s

.data
    # Data segment starts at 0x10010000
    array_size: .word 12
    array:      .word 65, 12, 10, 89, 11, 70, 67, 5, 9, 45, 90, 7
    
    .align 2
    temp_array: .space 2048 # Workspace for 512 elements (max allowed size)

.text
    # Entry Pattern from grendel.s
    # Initializing stack at 0x10012000 to provide 4KB safety buffer
    li   sp, 0x10012000
    li   fp, 0
    la   ra, pump
    j    main

pump:
    j end
    ebreak # Hard halt trigger

main:
    # Save return address
    addi sp, sp, -4
    sw   ra, 0(sp)
    
    # Setup parameters: a0 = array, a1 = size
    la   a0, array
    lw   a1, array_size
    
    # Call sorting wrapper
    jal  ra, sort

    # Restore return address
    lw   ra, 0(sp)
    addi sp, sp, 4
    
    # Final exit path
    j    end

# void sort(int* array, int size);
.globl sort
sort:
    # Check if size <= 1 (t0 = 1; if a1 <= t0 return)
    # Using slt for compatibility: t1 = (1 < size) ? 1 : 0
    li   t0, 1
    slt  t1, t0, a1 # t1 = 1 if 1 < size
    beq  t1, x0, sort_end # if 1 >= size (t1 == 0), end
    
    # Save return address
    addi sp, sp, -4
    sw   ra, 0(sp)
    
    # Initial call to mergesort: mergesort(array, low=0, high=size-1)
    # a0: array (remains same)
    # a1: low = 0
    # a2: high = size - 1
    mv   a2, a1
    addi a2, a2, -1
    li   a1, 0
    jal  ra, mergesort
    
    # Restore return address and return
    lw   ra, 0(sp)
    addi sp, sp, 4
sort_end:
    jr   ra

# void mergesort(int* array, int low, int high)
mergesort:
    # If low >= high, return
    # Compatibility version: slt t0, low, high; if t0 == 0 return
    slt  t0, a1, a2
    beq  t0, x0, ms_ret
    
    # Save frame: ra, low, high, mid
    addi sp, sp, -16
    sw   ra, 12(sp)
    sw   s0, 8(sp)
    sw   s1, 4(sp)
    sw   s2, 0(sp)
    
    # Preserve current arguments
    mv   s0, a1 # s0 = low
    mv   s1, a2 # s1 = high
    
    # Calculate middle index: mid = (low + high) / 2
    add  s2, s0, s1
    srli s2, s2, 1 # s2 = mid
    
    # Left recursive call: mergesort(array, low, mid)
    mv   a1, s0
    mv   a2, s2
    jal  ra, mergesort
    
    # Right recursive call: mergesort(array, mid + 1, high)
    addi a1, s2, 1
    mv   a2, s1
    jal  ra, mergesort
    
    # Merge sorted halves: merge(array, low, mid, high)
    mv   a1, s0
    mv   a2, s2
    mv   a3, s1
    jal  ra, merge
    
    # Epilogue: Restore frame
    lw   ra, 12(sp)
    lw   s0, 8(sp)
    lw   s1, 4(sp)
    lw   s2, 0(sp)
    addi sp, sp, 16
ms_ret:
    jr   ra

# void merge(int* array, int low, int mid, int high)
# a0: array base, a1: low, a2: mid, a3: high
merge:
    # t0: i = low
    # t1: j = mid + 1
    # t2: k = low
    mv   t0, a1
    addi t1, a2, 1
    mv   t2, a1
    
    la   t3, temp_array
    
merge_loop:
    # while (i <= mid && j <= high)
    # Check i > mid (t4 = 1 if mid < i)
    slt  t4, a2, t0
    bne  t4, x0, merge_right_remainder
    
    # Check j > high (t4 = 1 if high < j)
    slt  t4, a3, t1
    bne  t4, x0, merge_left_remainder
    
    # Load values: t4 = arr[i], t5 = arr[j]
    slli t6, t0, 2
    add  t6, a0, t6
    lw   t4, 0(t6)
    
    slli t6, t1, 2
    add  t6, a0, t6
    lw   t5, 0(t6)
    
    # Compare arr[i] <= arr[j]
    # Compatibility: t6 = (arr[j] < arr[i]) ? 1 : 0
    slt  t6, t5, t4
    beq  t6, x0, merge_copy_left # if not t5 < t4, then t4 <= t5
    
merge_copy_right:
    slli t6, t2, 2
    add  t6, t3, t6
    sw   t5, 0(t6) # temp[k] = arr[j]
    addi t1, t1, 1
    j    merge_inc_k

merge_copy_left:
    slli t6, t2, 2
    add  t6, t3, t6
    sw   t4, 0(t6) # temp[k] = arr[i]
    addi t0, t0, 1

merge_inc_k:
    addi t2, t2, 1
    j    merge_loop

merge_left_remainder:
    # while (i <= mid)
    slt  t4, a2, t0
    bne  t4, x0, merge_batch_copy_back
    
    slli t6, t0, 2
    add  t6, a0, t6
    lw   t4, 0(t6)
    
    slli t6, t2, 2
    add  t6, t3, t6
    sw   t4, 0(t6)
    
    addi t0, t0, 1
    addi t2, t2, 1
    j    merge_left_remainder

merge_right_remainder:
    # while (j <= high)
    slt  t4, a3, t1
    bne  t4, x0, merge_batch_copy_back
    
    slli t6, t1, 2
    add  t6, a0, t6
    lw   t5, 0(t6)
    
    slli t6, t2, 2
    add  t6, t3, t6
    sw   t5, 0(t6)
    
    addi t1, t1, 1
    addi t2, t2, 1
    j    merge_right_remainder

merge_batch_copy_back:
    # Copy from temp back to array: for (k = low; k <= high; k++)
    mv   t0, a1 # index k
merge_copy_back_loop:
    slt  t4, a3, t0 # t4 = 1 if high < t0
    bne  t4, x0, merge_return
    
    slli t4, t0, 2
    add  t4, t3, t4 # addr in temp
    lw   t4, 0(t4)
    
    slli t5, t0, 2
    add  t5, a0, t5 # addr in array
    sw   t4, 0(t5)
    
    addi t0, t0, 1
    j    merge_copy_back_loop

merge_return:
    jr   ra

end:
    wfi
    ebreak
