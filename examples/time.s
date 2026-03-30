.data
tp:
    .quad 1
    .quad 0
buf:
    .space 20

.global _start
.text
_start:
        mrs x10, cntvct_el0 // x10 - tickstamp 1

        adr	x0, tp
        mov	x1, #0
        mov	x8, #101  // sleep
        svc	#0

        mrs x11, cntvct_el0 // x11 - tickstamp 2

        // load ticks
        sub x4, x11, x10 // delta_ticks

        mov x6, #1000
        mul x4, x4, x6
        mul x4, x4, x6
        mul x4, x4, x6

        mrs x5, cntfrq_el0
        udiv x4, x4, x5 // nanoseconds

        mov x0, x4
        bl print_num

        // exit
        mov x0, #0
        mov x8, #93
        svc #0

// expects uint in x0
print_num:
    adr x1, buf
    add x1, x1, #19
    mov x2, #0

    b convert_loop

    convert_loop:
        mov x3, #10
        udiv x4, x0, x3
        mul x5, x4, x3
        sub x6, x0, x5
        add x6, x6, #'0'
        strb w6, [x1], #-1
        add x2, x2, #1
        mov x0, x4
        cbnz x0, convert_loop
    convert_loop_end:

    add x2, x2, #2
    add x3, x1, x2
    sub x3, x3, #1
    mov w4, #'\n'
    strb w4, [x3]

    mov x0, #1
    mov x8, #64
    svc #0

    ret
