# Sorting Algorithm Template in RISC-V Assembly - Tyler Bibus
# This template provides a basic structure for implementing a sorting algorithm (i.e. mergesort) in RISC-V assembly language.

# Note: You MUST put the sorted array back in the SAME memory location as the original array.
#       During grading we will insert our own array and corresponding array_size for testing.
#       The max size will be 512 elements.
.data
    array_size: .word 8
    array: .word 12, 3, 6, 7, 5, 2, 9, 1
    
    # Adding global temporaries for Mergesort Left/Right memory blocks.
    # We allocate 2048 bytes (512 words) for left and right arrays natively.
    temp_left: .space 2048
    temp_right: .space 2048

.text
.globl main

main:
    # Save return address
    addi sp, sp, -4
    sw ra, 0(sp)
    
    # Call sorting function
    la a0, array
    lw a1, array_size
    jal ra, sort

    # restore stack
    lw ra, 0(sp)
    addi sp, sp, 4
    
    # Exit program
    wfi

# void sort(int* array, int size);
.globl sort
sort:
    # Check bounds. If size <= 0, gracefully skip evaluate
    blez a1, sort_end
    
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s0, 8(sp)
    sw s1, 4(sp)
    
    mv s0, a0 # a
    mv s1, a1 # length
    
    # left = 0
    li a1, 0
    # right = length - 1
    addi a2, s1, -1
    # a0 is already 'a'
    jal ra, merge_sort_rec
    
    lw ra, 12(sp)
    lw s0, 8(sp)
    lw s1, 4(sp)
    addi sp, sp, 16
sort_end:
    ret


# void merge_sort_rec(int a[], int left, int right)
merge_sort_rec:
    # a0 = a, a1 = left, a2 = right
    bge a1, a2, ms_rec_end  # if (left >= right) return
    
    addi sp, sp, -32
    sw ra, 28(sp)
    sw s0, 24(sp) # a
    sw s1, 20(sp) # left
    sw s2, 16(sp) # right
    sw s3, 12(sp) # middle
    
    mv s0, a0
    mv s1, a1
    mv s2, a2
    
    # int middle = left + (right - left) / 2;
    sub t0, s2, s1   # right - left
    srai t0, t0, 1   # arithmetic right shift representing division by 2
    add s3, s1, t0   # middle = left + (right - left) / 2
    
    # merge_sort_rec(a, left, middle);
    mv a0, s0
    mv a1, s1
    mv a2, s3
    jal ra, merge_sort_rec
    
    # merge_sort_rec(a, middle + 1, right);
    mv a0, s0
    addi a1, s3, 1
    mv a2, s2
    jal ra, merge_sort_rec
    
    # merge_sorted_arrays(a, left, middle, right);
    mv a0, s0
    mv a1, s1
    mv a2, s3
    mv a3, s2
    jal ra, merge_sorted_arrays
    
    lw ra, 28(sp)
    lw s0, 24(sp)
    lw s1, 20(sp)
    lw s2, 16(sp)
    lw s3, 12(sp)
    addi sp, sp, 32
ms_rec_end:
    ret


# void merge_sorted_arrays(int a[], int left, int middle, int right)
# a0 = a, a1 = left, a2 = middle, a3 = right
merge_sorted_arrays:
    addi sp, sp, -48
    sw ra, 44(sp)
    sw s0, 40(sp) # a
    sw s1, 36(sp) # left
    sw s2, 32(sp) # middle
    sw s3, 28(sp) # right
    sw s4, 24(sp) # left_length
    sw s5, 20(sp) # right_length
    sw s6, 16(sp) # i
    sw s7, 12(sp) # j
    sw s8, 8(sp)  # k
    sw s9, 4(sp)  # temp_left address
    sw s10, 0(sp) # temp_right address
    
    mv s0, a0
    mv s1, a1
    mv s2, a2
    mv s3, a3
    
    # int left_length = middle - left + 1;
    sub s4, s2, s1
    addi s4, s4, 1
    
    # int right_length = right - middle;
    sub s5, s3, s2
    
    la s9, temp_left
    la s10, temp_right
    
    # for (i = 0; i < left_length; i++) temp_left_array[i] = a[left + i];
    li s6, 0
loop_copy_left:
    bge s6, s4, loop_copy_left_end
    # a[left + i]
    add t0, s1, s6
    slli t0, t0, 2
    add t0, s0, t0
    lw t1, 0(t0)
    # temp_left[i]
    slli t2, s6, 2
    add t2, s9, t2
    sw t1, 0(t2)
    
    addi s6, s6, 1
    j loop_copy_left
loop_copy_left_end:

    # for (j = 0; j < right_length; j++) temp_right_array[j] = a[middle + 1 + j];
    li s7, 0
loop_copy_right:
    bge s7, s5, loop_copy_right_end
    # a[middle + 1 + j]
    addi t0, s2, 1 # middle + 1
    add t0, t0, s7
    slli t0, t0, 2
    add t0, s0, t0
    lw t1, 0(t0) # t1 = a[middle+1+j]
    
    # temp_right[j]
    slli t2, s7, 2
    add t2, s10, t2
    sw t1, 0(t2)
    
    addi s7, s7, 1
    j loop_copy_right
loop_copy_right_end:

    # loop index resets: for (i = 0, j = 0, k = left; k <= right; k++)
    li s6, 0 # i = 0
    li s7, 0 # j = 0
    mv s8, s1 # k = left

loop_merge:
    bgt s8, s3, loop_merge_end
    
    # if (i < left_length && (j >= right_length || temp_left_array[i] <= temp_right_array[j]))
    bge s6, s4, else_merge # Evaluates to false immediately (i >= left_length) pushing directly to else branch 
    bge s7, s5, if_merge # j >= right_length triggers True immediately (short-circuiting the OR conditional into the if branch natively)
    
    # Evaluate explicit memory boundary value checks: temp_left_array[i] <= temp_right_array[j]
    slli t0, s6, 2
    add t0, s9, t0
    lw t1, 0(t0) # t1 = temp_left[i]
    
    slli t2, s7, 2
    add t2, s10, t2
    lw t3, 0(t2) # t3 = temp_right[j]
    
    bgt t1, t3, else_merge # if (temp_left > temp_right) evaluate as false explicitly and go to else block

if_merge:
    # a[k] = temp_left_array[i]; i++;
    slli t0, s6, 2
    add t0, s9, t0
    lw t1, 0(t0)
    
    slli t2, s8, 2
    add t2, s0, t2
    sw t1, 0(t2)
    
    addi s6, s6, 1
    j endif_merge

else_merge:
    # a[k] = temp_right_array[j]; j++;
    slli t2, s7, 2
    add t2, s10, t2
    lw t3, 0(t2)
    
    slli t4, s8, 2
    add t4, s0, t4
    sw t3, 0(t4)
    
    addi s7, s7, 1

endif_merge:
    addi s8, s8, 1
    j loop_merge

loop_merge_end:
    lw ra, 44(sp)
    lw s0, 40(sp)
    lw s1, 36(sp)
    lw s2, 32(sp)
    lw s3, 28(sp)
    lw s4, 24(sp)
    lw s5, 20(sp)
    lw s6, 16(sp)
    lw s7, 12(sp)
    lw s8, 8(sp)
    lw s9, 4(sp)
    lw s10, 0(sp)
    addi sp, sp, 48
    ret
