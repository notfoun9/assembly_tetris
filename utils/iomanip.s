.text

.global write_symbl
write_symbl:
    mov x0, #0
    adr x1, symbl
    mov x2, #1
    mov x8, WRITE
    svc #0
    ret

.global write_red_cell
write_red_cell:
    mov x0, #0
    adr x1, red_cell_seq
    mov x2, red_cell_seq_len
    mov x8, WRITE
    svc #0
    ret

.global write_green_cell
write_green_cell:
    mov x0, #0
    adr x1, green_cell_seq
    mov x2, green_cell_seq_len
    mov x8, WRITE
    svc #0
    ret

.global write_blue_cell
write_blue_cell:
    mov x0, #0
    adr x1, blue_cell_seq
    mov x2, blue_cell_seq_len
    mov x8, WRITE
    svc #0
    ret

.global write_blank_cell
write_blank_cell:
    mov x0, #0
    adr x1, blank_cell_seq
    mov x2, blank_cell_seq_len
    mov x8, WRITE
    svc #0
    ret


.global read_symbl
read_symbl:
    mov x0, #0
    adr x1, symbl
    mov x2, #1
    mov x8, READ
    svc #0
    ret

// sets termios from new_term
.global set_terminal_state
set_terminal_state:
    mov x0, #0x0
    mov x1, TCSETS
    adr x2, new_term
    mov x8, IOCTL
    svc #0
    ret

// gets termios into orig_term
.global get_terminal_state
get_terminal_state:
    mov x0, #0x0
    mov x1, TCGETS
    adr x2, orig_term
    mov x8, IOCTL
    svc #0
    ret

// x0 - dest, x1 - src, x2 - len
.global handle_error
handle_error:
    mov x8, EXIT
    mov x0, #-1
    svc #0

.global hide_cursor
hide_cursor:
    mov x0, #1
    adr x1, hide_cursor_seq
    mov x2, hide_cursor_seq_len
    mov x8, #64
    svc #0
    ret

.global show_cursor
show_cursor:
    mov x0, #1
    adr x1, show_cursor_seq
    mov x2, show_cursor_seq_len
    mov x8, #64
    svc #0
    ret

.global clear_term
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

red_cell_seq:
    .ascii "\x1b[41m  \x1b[0m"
    red_cell_seq_len = . - red_cell_seq

blue_cell_seq:
    .ascii "\x1b[44m  \x1b[0m"
    blue_cell_seq_len = . - blue_cell_seq

green_cell_seq:
    .ascii "\x1b[42m  \x1b[0m"
    green_cell_seq_len = . - green_cell_seq

blank_cell_seq:
    .ascii "  "
    blank_cell_seq_len = . - blank_cell_seq

.global orig_term
orig_term:
    .space  60

.global new_term
new_term:
    .space  60

newline:
    .ascii "\n"

null_term:
    .ascii "\0"

.global symbl
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
