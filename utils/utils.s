.text
.include "macros.s"
// expects x0 - return value, x1 - msg pointer
// msg must be NULL-terminated
.global strlen
strlen:
    mov x0, #0
    strlen_loop:
        ldrb w2, [x1, x0]
        add x0, x0, #1
        cmp w2, #0
        bne strlen_loop
    ret

// expects x0 - dest adr, x1 - source adr, x2 - N of bytes to copy
.global memcpy
memcpy:
    // save previous value of x2 on stack
    stp x2, x3, [sp, #-16]!
    sub x2, x2, #1
    memcpy_loop:
        ldrb w3, [x1, x2]
        strb w3, [x0, x2]
        cmp x2, #0
        beq memcpy_loop_end
        sub x2, x2, #1
        b memcpy_loop
    memcpy_loop_end:
    ldp x2, x3, [sp], #16
    ret

// expected x0 - write return val, x1 - msg pointer
// msg must be NULL-terminated
.global write_c_str
write_c_str:
    PROLOGUE
    bl strlen
    mov x2, x0
    mov x0, #0
    mov x8, #0x40
    svc #0
    EPILOGUE
    ret

// expected x0 - seconds, x1 - nanoseconds
.global nanosleep_call
nanosleep_call:
    adr x2, timespec
    stp x0, x1, [x2] 
    mov x0, x2
	mov	x1, #0
	mov	x8, #101
    svc #0
    ret

// will reserve x28 for the first timestamp
.global timer_start
timer_start:
    PROLOGUE
    mrs x28, cntvct_el0 // x28 - tickstamp 1
    EPILOGUE
    ret

// will place nanoseconds since the first timestamp on x0
.global timer_finish
timer_finish:
    PROLOGUE
    mrs x0, cntvct_el0 // x0 - tickstamp 2

    // load ticks
    sub x0, x0, x28 // delta_ticks

    mov x28, #1000
    mul x0, x0, x28
    mul x0, x0, x28
    mul x0, x0, x28

    mrs x28, cntfrq_el0
    udiv x0, x0, x28 // nanoseconds

    EPILOGUE
    ret

// expects uint in x0
.global print_num
print_num:
    PROLOGUE
    mov x1, x0   // x0 - number
    mov x2, #1   // x2 - counter
    mov x3, #10
    count_chars_loop:
        udiv x1, x1, x3
        cmp x1, #0
        beq count_chars_loop_end
        add x2, x2, #1
        b count_chars_loop
    count_chars_loop_end:
    mov x5, x2 // x5 - counter copy
    add x5, x5, #1
    
    mov w1, '\n'
    adr x4, printNumBuf  // x4 - buf ptr
    strb w1, [x4, x2]
    sub x2, x2, #1

    mov x3, #10   // x3 - 10
    place_chars_loop:
        udiv x1, x0, x3
        mul x1, x1, x3
        sub x1, x0, x1
        add w1, w1, #'0'
        strb w1, [x4, x2]
        sub x2, x2, #1
        udiv x0, x0, x3
        cmp x0, #0
        bne place_chars_loop
    place_chars_loop_end:

    mov x0, #0
    adr x1, printNumBuf
    mov x2, x5
    mov x8, #0x40
    svc #0

    EPILOGUE
    ret

.data
timespec:
    .quad 0
    .quad 0

printNumBuf:
    .byte 30
