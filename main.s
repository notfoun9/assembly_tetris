.data
raws = 22
columns = 12

max_raw = raws - 2
min_raw = 1

max_column = columns - 2
min_column = 1

grid:
    .space raws * columns + 1
len = . - grid

cur_position:
    .quad 1
    .quad 1

prev_position:
    .quad 1
    .quad 1

.text
.include "macros.s"
.global _start

/* ------------------------------ */
/* --------- Main start --------- */
_start:
    bl clear_term
    bl hide_cursor

    bl get_terminal_state

    adr x0, new_term
    adr x1, orig_term
    mov x2, #60
    bl memcpy


// Set up flags: no echo, no std behaviour
    adr     x0, new_term
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
// term set

    bl fill_grid

    game_loop:
        bl adjust_grid
        bl save_cur_to_prev
        bl clear_term
        bl print_grid

        adr x1, symbl
        mov x0, #0
        mov x2, #1
        mov x8, #0x3F
        svc #0
        ldrb w3, [x1]

/* -- Switch case input char start -- */
switch_input_char_start:
        cmp w3, #'s'
        bne skip_down
            adr x10, cur_position 
            ldrb w4, [x10]
            cmp w4, max_raw
            beq switch_input_char_end
            add w4, w4, #1
            strb w4, [x10]
        skip_down:

        cmp w3, #'w'
        bne skip_up
            adr x10, cur_position 
            ldrb w4, [x10]
            cmp w4, min_raw
            beq switch_input_char_end
            sub w4, w4, #1
            strb w4, [x10]
        skip_up:

        cmp w3, #'d'
        bne skip_right
            adr x10, cur_position 
            ldrb w4, [x10, #8]
            cmp w4, max_column
            beq switch_input_char_end
            add w4, w4, #1
            strb w4, [x10, #8]
        skip_right:

        cmp w3, #'a'
        bne skip_left
            adr x10, cur_position 
            ldrb w4, [x10, #8]
            cmp w4, min_column
            beq switch_input_char_end
            sub w4, w4, #1
            strb w4, [x10, #8]
        skip_left:
/* --- Switch case input char end --- */
switch_input_char_end:

        cmp w3, #'q'
        beq game_loop_end
        b game_loop
    game_loop_end:

    bl recover_and_exit
/* ---------- Main end ---------- */
/* ------------------------------ */

recover_and_exit:
    bl show_cursor
    mov x0, #0
    mov x8, #0x5D
    svc #0

save_cur_to_prev:
    adr x2, cur_position
    ldp x0, x1, [x2]
    adr x2, prev_position
    stp x0, x1, [x2]
    ret

adjust_grid:
    adr x2, prev_position
    ldp x0, x1, [x2]

    mov x2, columns
    mul x0, x0, x2
    add x0, x0, x1
    mov w1, #' '

    adr x2, grid
    strb w1, [x2, x0]
    adr x2, cur_position
    ldp x0, x1, [x2]

    mov x2, columns
    mul x0, x0, x2
    add x0, x0, x1
    mov w1, #'g'

    adr x2, grid
    strb w1, [x2, x0]

    ret

fill_grid:
    mov x3, len
    sub x3, x3, #1
    adr x1, grid

    mov w0, #' '
    mov x2, #0
    full_fill:
        strb w0, [x1, x2]
        add x2, x2, #1
        cmp x2, x3
        blt full_fill


    mov w0, #'r'
    mov x2, #0
    horizontal_up:
        strb w0, [x1, x2]
        add x2, x2, #1
        cmp x2, columns
        blt horizontal_up

    mov x2, raws
    sub x2, x2, #1
    mov x4, columns
    mul x2, x2, x4
    horizontal_down:
        strb w0, [x1, x2]
        add x2, x2, #1
        cmp x2, x3
        bne horizontal_down

    mov x2, #0
    vertical:
        mov w0, #'r'
        strb w0, [x1, x2]

        add x2, x2, x4
        sub x2, x2, #1
        strb w0, [x1, x2]

        add x2, x2, #1
        cmp x2, x3
        blt vertical
    ret

print_grid:
    PROLOGUE
    adr x10, grid
    mov x11, #0 // raws
    mov x21, raws
    mov x12, #0 // columns
    mov x22, columns // columns
    adr x20, symbl
    // x23 - for tmp char
    // x24 - actual pos
    print_raws:
        cmp x11, x21
        beq print_raws_end
        mov x12, #0
        print_cols:
            cmp x12, x22
            beq print_cols_end

            mov x24, x11
            mul x24, x24, x22
            add x24, x24, x12
            ldrb w23, [x10, x24]
            cmp w23, #'r'
            beq red_cell
            cmp w23, #'b'
            beq blue_cell
            cmp w23, #'g'
            beq green_cell
            cmp w23, #' '
            beq blank_cell
            red_cell: 
                bl write_red_cell
                b no_cell
            green_cell: 
                bl write_green_cell
                b no_cell
            blue_cell: 
                bl write_blue_cell
                b no_cell
            blank_cell:
                bl write_blank_cell
                b no_cell
            no_cell:
            add x12, x12, #1
            b print_cols
        print_cols_end:
        add x11, x11, #1
        mov w23, '\n'
        strb w23, [x20]
        bl write_symbl
        b print_raws
    print_raws_end:
    EPILOGUE
    ret
