.text

// places shadow char in w0
.global get_shadow_char
get_shadow_char:
    adr x0, piece_type
    ldrb w0, [x0]
    sub w0, w0, #0x20
    ret

.global write_cell
write_cell:
    /* color switch start */
    cmp w0, #' '
    beq write_blank_cell

    cmp w0, #'I'
    beq set_magenta_seq
    cmp w0, #'m'
    beq set_magenta_seq

    cmp w0, #'I' - 0x20
    beq set_magenta_shadow_seq

    cmp w0, #'L'
    beq set_orange_seq
    cmp w0, #'o'
    beq set_orange_seq

    cmp w0, #'L' - 0x20
    beq set_orange_shadow_seq

    cmp w0, #'J'
    beq set_blue_seq
    cmp w0, #'b'
    beq set_blue_seq

    cmp w0, #'J' - 0x20
    beq set_blue_shadow_seq

    cmp w0, #'S'
    beq set_green_seq
    cmp w0, #'g'
    beq set_green_seq

    cmp w0, #'S' - 0x20
    beq set_green_shadow_seq

    cmp w0, #'T'
    beq set_purple_seq
    cmp w0, #'p'
    beq set_purple_seq

    cmp w0, #'T' - 0x20
    beq set_purple_shadow_seq

    cmp w0, #'Z'
    beq set_red_seq
    cmp w0, #'r'
    beq set_red_seq

    cmp w0, #'Z' - 0x20
    beq set_red_shadow_seq

    cmp w0, #'O'
    beq set_yellow_seq
    cmp w0, #'y'
    beq set_yellow_seq

    cmp w0, #'O' - 0x20
    beq set_yellow_shadow_seq

    set_magenta_seq:
        adr x1, magenta_cell_seq
        b write_colored_cell
    set_magenta_shadow_seq:
        adr x1, magenta_shadow_cell_seq
        b write_colored_cell
    set_orange_seq:
        adr x1, orange_cell_seq
        b write_colored_cell
    set_orange_shadow_seq:
        adr x1, orange_shadow_cell_seq
        b write_colored_cell
    set_blue_seq:
        adr x1, blue_cell_seq
        b write_colored_cell
    set_blue_shadow_seq:
        adr x1, blue_shadow_cell_seq
        b write_colored_cell
    set_green_seq:
        adr x1, green_cell_seq
        b write_colored_cell
    set_green_shadow_seq:
        adr x1, green_shadow_cell_seq
        b write_colored_cell
    set_purple_seq:
        adr x1, purple_cell_seq
        b write_colored_cell
    set_purple_shadow_seq:
        adr x1, purple_shadow_cell_seq
        b write_colored_cell
    set_red_seq:
        adr x1, red_cell_seq
        b write_colored_cell
    set_red_shadow_seq:
        adr x1, red_shadow_cell_seq
        b write_colored_cell
    set_yellow_seq:
        adr x1, yellow_cell_seq
        b write_colored_cell
    set_yellow_shadow_seq:
        adr x1, yellow_shadow_cell_seq
        b write_colored_cell
    /* color switch end */

    write_colored_cell:
        mov x0, #0
        mov x2, colored_cell_len
        mov x8, #0x40
        svc #0
    ret
    write_blank_cell:
        mov x0, #0
        adr x1, blank_cell_seq
        mov x2, blank_cell_len
        mov x8, #0x40
        svc #0
    ret

// returns color char in w0
.global get_true_piece_color
get_true_piece_color:
    adr x0, piece_type
    ldrb w0, [x0]

    cmp w0, #'I'
    bne not_I
    mov w0, #'m'
    ret
    not_I:

    cmp w0, #'L'
    bne not_L
    mov w0, #'o'
    ret
    not_L:

    cmp w0, #'J'
    bne not_J
    mov w0, #'b'
    ret
    not_J:

    cmp w0, #'S'
    bne not_S
    mov w0, #'g'
    ret
    not_S:

    cmp w0, #'T'
    bne not_T
    mov w0, #'p'
    ret
    not_T:

    cmp w0, #'Z'
    bne not_Z
    mov w0, #'r'
    ret
    not_Z:

    cmp w0, #'O'
    bne not_O
    mov w0, #'y'
    ret
    not_O:
    ret

.data
magenta_cell_seq: // for I shape
    .ascii "\x1b[48;2;20;200;200m  \x1b[0m"

magenta_shadow_cell_seq: // for I shape shadow
    .ascii "\x1b[48;02;0;100;100m .\x1b[0m"

orange_cell_seq: // for L shape
    .ascii "\x1b[48;2;240;125;50m  \x1b[0m"

orange_shadow_cell_seq: // for L shape shadow
    .ascii "\x1b[48;02;110;50;10m .\x1b[0m"

blue_cell_seq: // for J shape
    .ascii "\x1b[48;2;60;100;250m  \x1b[0m"

blue_shadow_cell_seq: // for J shape shadow
    .ascii "\x1b[48;02;10;30;120m .\x1b[0m"

green_cell_seq: // for S shape
    .ascii "\x1b[48;02;40;200;50m  \x1b[0m"

green_shadow_cell_seq: // for S shape shadow
    .ascii "\x1b[48;02;10;100;10m .\x1b[0m"

purple_cell_seq: // for T shape
    .ascii "\x1b[48;2;170;50;220m  \x1b[0m"

purple_shadow_cell_seq: // for T shape shadow
    .ascii "\x1b[48;02;70;10;110m .\x1b[0m"

red_cell_seq: // for Z shape
    .ascii "\x1b[48;02;220;65;50m  \x1b[0m"

red_shadow_cell_seq: // for Z shape shadow
    .ascii "\x1b[48;02;100;15;00m .\x1b[0m"

yellow_cell_seq: // for O shape
    .ascii "\x1b[48;2;210;190;30m  \x1b[0m"

yellow_shadow_cell_seq: // for O shape shadow
    .ascii "\x1b[48;02;110;90;00m .\x1b[0m"
colored_cell_len = . - yellow_shadow_cell_seq

blank_cell_seq:
    .ascii " ."
blank_cell_len = 2
