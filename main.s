.data
raws = 24
columns = 12

max_raw = raws - 2
min_raw = 1

max_column = columns - 2
min_column = 1

grid:
    .space raws * columns + 1
len = . - grid

.text
.include "macros.s"
.global _start

/* ------------------------------ */
/* --------- Main start --------- */
_start:
    bl timer_start
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
        bl clear_term
        bl print_grid

        adr x1, symbl
        mov x0, #0
        mov x2, #1
        mov x8, #0x3F
        svc #0
        ldrb w9, [x1]

/* -- Switch case input char start -- */
switch_input_char_start:
        cmp w9, #'k'
        bne skip_clock
            mov x0, #1
            bl rotate_piece
            b switch_input_char_end
        skip_clock:

        cmp w9, #'j'
        bne skip_counterclock
            mov x0, #3
            bl rotate_piece
            b switch_input_char_end
        skip_counterclock:

        cmp w9, #'a'
        bne skip_left
            bl move_left
            b switch_input_char_end
        skip_left:

        cmp w9, #'s'
        bne skip_down
            bl move_down
            b switch_input_char_end
        skip_down:

        cmp w9, #'d'
        bne skip_right
            bl move_right
            b switch_input_char_end
        skip_right:

        cmp w9, #'q'
        beq game_loop_end

/* --- Switch case input char end --- */
switch_input_char_end:

        b game_loop
    game_loop_end:

    bl recover_and_exit
/* ---------- Main end ---------- */
/* ------------------------------ */

recover_and_exit:
    bl show_cursor
    bl clear_term

    bl timer_finish
    bl print_num

    mov x0, #0
    mov x8, #0x5D
    svc #0

adjust_grid:
    PROLOGUE

// check for collisions with walls:
    bl does_collide_with_walls
    cmp x0, #0
    bne restore_position
// check for collisions with walls

// check for collisions with floor:
    bl does_collide_with_floor
    cmp x0, #0
    beq no_floor_collision
        bl restore_prev_state
        bl place_piece_on_grid
        bl spawn_new_piece
    no_floor_collision:
// check for collisions with floor

// erase previous piece state start
    adr x4, previous_position
    ldp x0, x1, [x4]
    ldp x2, x3, [x4, #16]
    adr x4, grid
    mov w5, #' '
    strb w5, [x4, x0]
    strb w5, [x4, x1]
    strb w5, [x4, x2]
    strb w5, [x4, x3]
// erase previous piece state end

// add current piece state start
    adr x4, piece_position
    ldp x0, x1, [x4]
    ldp x2, x3, [x4, #16]

    adr x5, piece_type
    ldrb w5, [x5]
    adr x4, grid
    strb w5, [x4, x0]
    strb w5, [x4, x1]
    strb w5, [x4, x2]
    strb w5, [x4, x3]
// add current piece state end

    EPILOGUE
    ret
restore_position:
    bl restore_prev_state
    EPILOGUE
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
    mov x11, #1 // raws
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
            ldrb w0, [x10, x24]
            bl write_cell

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

// stores #0 in x0 if no collision
does_collide_with_walls:
    adr x4, piece_position
    mov x0, #4
    mov x2, columns
    walls_collision_check_loop:
        ldr x1, [x4], #8

        udiv x3, x1, x2
        mul x3, x3, x2
        sub x1, x1, x3

        cmp x1, #0
        beq walls_collision_check_end
        cmp x1, #11
        beq walls_collision_check_end

        sub x0, x0, #1
        cmp x0, #0
        bne walls_collision_check_loop
    walls_collision_check_end:
    ret

// pos = raw * columns + column
// pos / columns = raw
// *check if raw == raws - 1 || raw == 0
does_collide_with_floor:
    adr x4, piece_position
    mov x0, #4
    mov x2, columns
    mov x3, raws
    sub x3, x3, #1
    floor_collision_check_loop:
        ldr x1, [x4], #8

        udiv x1, x1, x2
        cmp x1, x3
        beq floor_collision_check_end

        sub x0, x0, #1
        cmp x0, #0
        bne floor_collision_check_loop
    floor_collision_check_end:
    ret

place_piece_on_grid:
    PROLOGUE
    
    adr x1, piece_position
    ldp x2, x3, [x1]
    ldp x4, x5, [x1, #16]

    bl get_true_piece_color

    adr x1, grid
    strb w0, [x1, x2]
    strb w0, [x1, x3]
    strb w0, [x1, x4]
    strb w0, [x1, x5]

    EPILOGUE
    ret
