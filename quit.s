.text
.global _start
_start:
    adr x0, orig
    bl get_terminal_state
    // --- Check Return Value ---
    cmp x0, #0
    blt handle_error


    adr     x0, new
    ldr     x6, [x0, #12]
    movz    x7, #0xA
    mvn     x7, x7      // x7 = ~0xA
    and     x6, x6, x7  // flag &= ~0xA
    str     x6, [x0, #12]

    mov     w6, #1
    strb    w6, [x0, #23]

    mov     w6, #0
    strb    w6, [x0, #22]
    
    bl set_terminal_state
    // --- Check Return Value ---
    cmp x0, #0
    blt handle_error

    bl clear_term
    bl hide_cursor

    read_loop_start:
        bl read_symbl
        adr x0, symbl
        ldrb w1, [x0], #0
        sub w1, w1, #'q'
        cbnz w1, read_loop_start

    bl restore_and_exit

write_symbl:
    mov x0, #0
    adr x1, symbl
    mov x2, #1
    mov x8, WRITE
    svc #0
    ret

read_symbl:
    mov x0, #0
    adr x1, symbl
    mov x2, #1
    mov x8, READ
    svc #0
    ret

// x0 - src
set_terminal_state:
    mov x2, x0
    mov x0, #0x0
    mov x1, TCSETS
    mov x8, IOCTL
    svc #0
    ret

// x0 - dest
get_terminal_state:
    mov x2, x0
    mov x0, #0x0
    mov x1, TCGETS
    mov x8, IOCTL
    svc #0
    ret

restore_and_exit:
    bl show_cursor

    adr x0, orig
    bl set_terminal_state
    // --- Check Return Value ---
    cmp x0, #0
    blt handle_error

    mov x0, #0
    mov x8, EXIT
    svc #0

// x0 - dest, x1 - src, x2 - len
memcpy:
    memcpy_start:
        cbz x2, memcpy_end
        ldrb w3, [x1], #1
        strb w3, [x0], #1
        sub x2, x2, #1
        b memcpy_start
    memcpy_end:
    ret

handle_error:
    mov x8, EXIT
    mov x0, #-1
    svc #0

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
    adr x1, clear_screen_seq
    mov x2, clear_screen_seq_len
    mov x8, #64
    svc #0
    ret

.data
hide_cursor_seq:
    .ascii "\033[?25l"
    hide_cursor_seq_len = . - hide_cursor_seq

show_cursor_seq:
    .ascii "\033[?25h"
    show_cursor_seq_len = . - show_cursor_seq

clear_screen_seq:
    .ascii "\033[2J\033[H"
    clear_screen_seq_len = . - clear_screen_seq

orig:
    .space  60
new:
    .space  60
timespec:
    .quad 1
    .quad 0
symbl:
    .ascii "0"

termios_size = 60

IOCTL = 0x1D
EXIT = 0x5D
WRITE = 0x40
READ = 0x3F
NANOSLEEP = 0x65

TCGETS = 0x5401
TCSETS = 0x5402
