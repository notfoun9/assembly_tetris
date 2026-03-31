.text

.global write_symbl
write_symbl:
    mov x0, #0
    adr x1, symbl
    mov x2, #1
    mov x8, WRITE
    svc #0
    ret

// expects w0 - char on color: r, g, b, y, o, m, p, ' '
.global write_cell
write_cell:
    /* color switch start */
    cmp w0, #' '
    bne not_blank_cell
        adr x1, blank_cell_seq
        b write_blank_cell
    not_blank_cell:

    cmp w0, #'r'
    bne not_red_cell
        adr x1, red_cell_seq
        b write_colored_cell
    not_red_cell:

    cmp w0, #'g'
    bne not_green_cell
        adr x1, green_cell_seq
        b write_colored_cell
    not_green_cell:

    cmp w0, #'b'
    bne not_blue_cell
        adr x1, blue_cell_seq
        b write_colored_cell
    not_blue_cell:

    cmp w0, #'y'
    bne not_yellow_cell
        adr x1, yellow_cell_seq
        b write_colored_cell
    not_yellow_cell:

    cmp w0, #'o'
    bne not_orange_cell
        adr x1, orange_cell_seq
        b write_colored_cell

    not_orange_cell:

    cmp w0, #'m'
    bne not_magenta_cell
        adr x1, magenta_cell_seq
        b write_colored_cell
    not_magenta_cell:

    cmp w0, #'p'
    bne not_purple_cell
        adr x1, purple_cell_seq
        b write_colored_cell
    not_purple_cell:
    /* color switch end */

    write_colored_cell:
        mov x0, #0
        mov x2, colored_cell_len
        mov x8, #0x40
        svc #0
    ret
    write_blank_cell:
        mov x0, #0
        mov x2, blank_cell_len
        mov x8, #0x40
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

red_cell_seq: // for Z shape
    .ascii "\x1b[48;02;220;65;50m  \x1b[0m"

green_cell_seq: // for S shape
    .ascii "\x1b[48;02;40;200;50m  \x1b[0m"

blue_cell_seq: // for J shape
    .ascii "\x1b[48;2;60;100;250m  \x1b[0m"

yellow_cell_seq: // for O shape
    .ascii "\x1b[48;2;210;190;30m  \x1b[0m"

orange_cell_seq: // for L shape
    .ascii "\x1b[48;2;240;165;50m  \x1b[0m"

magenta_cell_seq: // for I shape
    .ascii "\x1b[48;2;20;200;200m  \x1b[0m"

purple_cell_seq: // for T shape
    .ascii "\x1b[48;2;200;50;200m  \x1b[0m"

colored_cell_len = . - purple_cell_seq 

blank_cell_seq:
    .ascii "  "
blank_cell_len = 2

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
