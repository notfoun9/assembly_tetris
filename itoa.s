    .section .data

    value = 12345
buf:
    .space 20

    .section .text
    .global _start


_start:
    mov x0, #value        // number to print
    adr x1, buf           // buffer base
    add x1, x1, #19       // point to last byte in buffer (end)
    mov x2, #0            // digit count (use x2, 64-bit)

    bl convert_loop

    // exit(0)
    mov x0, #0
    mov x8, #93
    svc #0

convert_loop:
    mov x3, #10
    udiv x4, x0, x3       // x4 = x0 / 10 We place in x4(tmp) number without the last digit 
    mul x5, x4, x3        // x5 = (x0/10)*10   // Place in x5 number with 0 on the last digit place 
    sub x6, x0, x5        // x6 = x0 % 10   // x6 is the last digit of the number
    add x6, x6, #'0'      // ascii digit  // x6 is the last digit in ascii format
    strb w6, [x1], #-1    // store byte, then decrement pointer
    add x2, x2, #1        // digit count++
    mov x0, x4   // Cut the last digit of the number
    cbnz x0, convert_loop

    // x1 currently points one byte before first digit; fix pointer to first digit
    add x1, x1, #1        // move to first digit

    // place newline after digits
    add x2, x2, #1        // length = digits + newline
    add x3, x1, x2        // x3 = x1 + length
    sub x3, x3, #1        // x3 points to the newline position
    mov w4, #'\n'
    strb w4, [x3]

    // write(fd=1, buf=x1, len=x2)
    mov x0, #1
    mov x8, #64
    svc #0

    ret
