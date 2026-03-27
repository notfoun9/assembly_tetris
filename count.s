	.text
	.global _start

/* -------------------------------- */
// main execution start
_start:
    bl clear_term
    bl hide_cursor

    mov w7, #5

    countdown:
    bl fill_countdown_buffer
    bl print_countdown
    bl sleep

    bl clear_term

    sub w7, w7, #1

    cbnz w7, countdown

    mov x0, #1
    adr x1, boom
    mov x2, boom_len
    mov x8, #64
    svc #0

    bl show_cursor
    bl exit
// main execution end
/* -------------------------------- */

hide_cursor:
    mov x0, #1
    adr x1, hide_cursor_seq
    mov x2, hide_cursor_seq_len
    mov x8, #64
    svc #0
    ret

show_cursor:
    mov x0, #1
    adr x1, show_cursor_seq
    mov x2, show_cursor_seq_len
    mov x8, #64
    svc #0
    ret

clear_term:
    mov x0, #1
    adr x1, escape_seq
    mov x2, escape_seq_len
    mov x8, #64
    svc #0
    ret
    
sleep:
    adr x0, timespec
    mov x1, #0
    mov x8, #101
    svc #0
    ret

fill_countdown_buffer:
    mov w0, w7
    add w0, w0, #'0'
    adr x1, countdown_buffer
	strb w0, [x1]
    mov w0, #'\n'
    strb w0, [x1, #1]
    ret

print_countdown:
    mov x0, #1
    adr x1, countdown_buffer
    mov x2, 2 
    mov x8, #64
    svc #0
    ret

exit:
	mov	x0, #0
	mov	x8, #93
	svc	#0

    .section .data
boom:
    .ascii "BOOM!!!\n"
    boom_len = . - boom

hide_cursor_seq:
    .ascii "\033[?25l"
    hide_cursor_seq_len = . - hide_cursor_seq

show_cursor_seq:
    .ascii "\033[?25h"
    show_cursor_seq_len = . - show_cursor_seq

escape_seq:
    .ascii "\033[2J\033[H"
    escape_seq_len = . - escape_seq

countdown_buffer:
    .space 2

timespec:
    .quad 1
    .quad 0
