    .section .data
msg_main:
    .asciz "In main\n"

.global _start
.text
_start:
    bl main

    mov x0, #0
    mov x8, #0x5D
    svc #0

main:
    /* -------- Stack frame Prologue -------- */
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #32 // better be aligned to 16
    /* -------------------------------------- */


    adr x1, msg_main
    bl write_str


    /* -------- Stack frame Epilogue -------- */
    mov sp, x29
    ldp x29, x30, [sp], #16
    ret
    /* -------------------------------------- */
 
// print string placed in x1
write_str:
    mov x2, #0

    .len_loop:
        ldrb w3, [x1, x2]
        cbz w3, .len_done
        add x2, x2, #1
        b .len_loop
    .len_done:

    mov x0, #1
    mov x8, #0x40
    svc #0

    ret
