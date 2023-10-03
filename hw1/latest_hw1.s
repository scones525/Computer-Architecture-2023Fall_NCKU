.data
# num1~num3 are test data
num1: .word 0xf1ac,0x123
num2: .word 0x1ac,0x12123489
num3: .word 0x0,0x32498
and1: .word 0x33333333,0x33333333
and2: .word 0x0f0f0f0f,0x0f0f0f0f
and3: .word 0x7f
and4: .word 0x55555555, 0x55555555
and5: .word 0x33333333, 0x33333333
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
    mv a0, t0
    li a7, 1
    ecall
    la a0, newline
    li a7, 4
    ecall
    ret
exit_program:
    li a7, 10
    ecall
counting_zero:
    mv t0, a0
    mv t6, x0     # this is res return value
    
    lw s0, 0(t0)
    lw s1, 4(t0)

    andi s2, s0, -1

    bne x0, s2, start_count
    # from here to start_count is when s0 == 0
    addi t6, t6, 32
    addi s0, s1, 0
    
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
    mv t0, a1
    ret
