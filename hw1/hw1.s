.data
num1: .word 0xf1ac,0x123
num2: .word 0x1ac,0x12123489
num3: .word 0x1,0x32498
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
    jal ra, count_ones
    jal ra, print_result

    la a0, num2
    jal ra, counting_zero
    jal ra, count_ones
    jal ra, print_result    
    
    la a0, num3
    jal ra, counting_zero
    jal ra, count_ones
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

    j shift_right_or_equal      
    jr ra   
shift_right_or_equal:     
    #now data address in a0 
    #and do shift right and or equal 5 times.
    li s0, 1
    li s1, 1
    li s2, 6
    #high 32bit in s3, low 32bit in s4
    lw s3, 0(t0)
    lw s4, 4(t0)
Loop:    #s0 in this loop are : 1,2,4,8,16,32
         #t0 : data address
    addi s1, s1, 1
    li s6, 32
    sub s6, s6, s0 # s6 32-n bits, how many bits that mask need to shift
                   #  31,30,28,24,16,0
    
    sll s7, s3, s6 #upper 32-n bit need to and w/ lower 32 bit
    #shift s3, s4
    srl s8, s3, s0
    srl s9, s4, s0
    #add upper32bits shift's bit into lower 32bits
    or s9, s9, s7
    
    or s3, s3, s8
    or s4, s4, s9 
    slli s0, s0, 1
    ble s1, s2, Loop
    
    mv t0, s3
    mv t1, s4
    ret

count_ones:
    mv s0, t0
    mv s1, t1

    #x -= ((x >> 1) & 0x5555555555555555 );
    slli s7, s0, 31      # s7 store bit that shift to lower 32bits
    srli s8, s0, 1       # x >> 1
    srli s9, s1, 1
    or s9, s9, s7   
    la t2, and4
    lw t3, 0(t2)         #0x55555555
    lw t4, 4(t2)         #0x55555555
    
    and s8, s8, t3       #  x and x05555555555555555
    and s9, s9, t4
    # do sub here s0,s1 - s8,s9
    sub s1, s1, s9
    sltu a3, s1, s9
    sub s0, s0, s8
    sub s0, s0, a3

    #x = ((x >> 2) & 0x3333333333333333) + (x &0x3333333333333333);
    #              s2                                 s3
    
    # x >> 2
    slli s7, s0, 30
    srli s8, s0, 2
    srli s9, s1, 2
    or s9, s9, s7
    # load 0x3333333333333333
    la t2, and5
    lw t3, 0(t2)
    lw t4, 4(t2)
    # and with 0x3333333333333333
    and s8, s8, t3
    and s9, s9, t4
    # x &0x3333333333333333 store in s2, s3
    and s2, s0, t3
    and s3, s1, t4
    # add together they are s8,s9 and s2,s3 respectively
    add s1, s9, s3
    sltu a3, s1, s3
    add s0, s8, s2
    add s0, s0, a3

    #x = ((x >> 4) + x) & 0x0f0f0f0f0f0f0f0f;
    
        # x >> 4
    slli s7, s0, 28
    srli s8, s0, 4
    srli s9, s1, 4
    or s9, s9, s7
    
        # (x>>4) + x store in s8,s9
    add s9, s9, s1
    sltu a3, s9, s1
    add a4, s8, s0
    add s8, a4, a3

        # & 0x0f0f0f0f0f0f0f0f
    la t2, and2 
    lw t3, 0(t2)
    lw t4, 4(t2)
    and s0, s8, t3
    and s1, s9, t4

    # x += (x >> 8);
    slli s7, s0, 24
    srli s8, s0, 8
    srli s9, s1, 8
    or s9, s9, s7

    add s1, s9, s1
    sltu a3, s1, s9
    add s0, s0, s8
    add s0, s0, a3

    # x += (x >> 16);
    slli s7, s0, 16
    srli s8, s0, 16
    srli s9, s1, 16
    or s9, s9, s7

    add s1, s9, s1
    sltu a3, s1, s9
    add s0, s0, s8
    add s0, s0, a3    
    

    # x += (x >> 32);
    mv s8, x0
    mv s9, s0

    add s1, s9, s1
    sltu a3, s1, s9
    add s0, s0, s8
    add s0, s0, a3
    
    li t0,64
    andi t1, s1, 0x7f
    sub t0, t0, t1
    ret
