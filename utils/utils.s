.text
.include "macros.s"
// expects x0 - return value, x1 - msg pointer
// msg must be NULL-terminated
.global strlen
strlen:
    // save previous value of x2 on stack
    str x2, [sp, #-16]!
    mov x0, #0
    strlen_loop:
        ldrb w2, [x1, x0]
        add x0, x0, #1
        cmp w2, #0
        bne strlen_loop
    ldr x2, [sp, #16]!
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
// resets x2
.global nanosleep_call
nanosleep_call:
    adr x2, timespec
    stp x0, x1, [x2] 
    mov x0, x2
	mov	x1, #0
	mov	x8, #101
    svc #0
    ret

.data
timespec:
    .quad 0
    .quad 0

