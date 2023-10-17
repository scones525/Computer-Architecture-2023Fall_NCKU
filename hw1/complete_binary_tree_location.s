.data
# num1~num3 are test data
num1: .word 0x19
num2: .word 0x7
num3: .word 0x3
and1: .word 0x33333333,0x33333333
and2: .word 0x0f0f0f0f,0x0f0f0f0f
and3: .word 0x7f
and4: .word 0x55555555, 0x55555555
and5: .word 0x33333333, 0x33333333
str1: .asciz "Number of : "
str2: .asciz "'s depth is : "
str3: .asciz "  ,and its location(from left to right) is :"
newline: .string "\n"
.text
main:
    la a0, num1
    jal ra, counting_zero
    jal ra, print_result

    la a0, num2
    jal ra, counting_zero
    jal ra, print_result    
    
    la a0, num3
    jal ra, counting_zero
    jal ra, print_result    
    
    j exit_program
print_result:
    mv a3, t1
    li a7, 4
    la a0, str1
    ecall
    mv a0, t1
    li a7, 1
    ecall
    li a7, 4
    la a0, str2
    ecall
    
    li t2,32
    sub t0, t2, t0
    
    mv a0, t0
    li a7, 1
    ecall
    li a7, 4
    la a0, str3
    ecall
    
    addi sp, sp, -4
    sw ra, 0(sp)
    jal ra, cal_location
    sub a0, a3, t1
    li a7, 1
    ecall    
    lw ra, 0(sp)
    addi sp, sp, 4
 
    
    la a0, newline
    li a7, 4
    ecall
    ret
cal_location:
    mv a2, t0
    addi a2, a2, -1
    addi a1, x0, 1
loop:
    slli a1, a1, 1
    addi a2, a2, -1
    bne x0, a2, loop
    mv t1, a1
    ret
exit_program:
    li a7, 10
    ecall
counting_zero:
    mv t0, a0
    mv t6, x0     # this is res return value
    
    lw s0, 0(t0)
    mv t5, s0
start_count:

    # count leading zero in s0
    srli s1, s0, 1
    or s0, s1, s0
    srli s1, s0, 2
    or s0, s1, s0
    srli s1, s0, 4
    or s0, s1, s0
    srli s1, s0, 8
    or s0, s1, s0
    srli s1, s0, 16
    or s0, s1, s0
    
    #    x -= ((x >> 1) & 0x55555555);
    la s2, and4        # read 0x55555555 address
    lw s3, 0(s2)       # load 0x55555555
    srli s1, s0, 1
    and s1, s1, s3
    sub s0, s0, s1
    #    x = ((x >> 2) & 0x33333333) + (x & 0x33333333);
    la s2, and5
    lw s3, 0(s2)
    srli s1, s0, 2
    and s1, s1, s3
    and s2, s0, s3
    add s0, s1, s2
    #    x = ((x >> 4) + x) & 0x0f0f0f0f;
    la s2, and2
    lw s3, 0(s2)
    srli s1, s0, 4
    add s1, s1, s0
    and s0, s1, s3
    #    x += (x >> 8);
    srli s1, s0, 8
    add s0, s0, s1
    #    x += (x >> 16);
    srli s1, s0, 16
    add s0, s0, s1
    
    li s1, 32
    la s2, and3
    lw s3, 0(s2)
    and s0, s0, s3
    add t6, t6, s1
    sub a1, t6, s0
    mv t1, t5
    mv t0, a1
    ret
