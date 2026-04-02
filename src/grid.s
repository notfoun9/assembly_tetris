.data
raws = 25
columns = 12

.global score
score:
    .quad 0x0

max_raw = raws - 2
min_raw = 1

max_column = columns - 2
min_column = 1

.global grid
grid:
    .space raws * columns
len = . - grid

field:
    .space 10000

.text
.include "macros.s"
.global adjust_grid
adjust_grid:
    PROLOGUE

// check for collisions with walls:
    bl does_collide_with_walls
    cmp x0, #0
    bne restore_position
// check for collisions with walls end

// check for collisions with placed pieces:
    // places #0 x0 if non-placing collision
    // places #1 x0 if placing collision
    bl does_collide_with_pieces
    cmp x0, #0
    beq restore_position
    cmp x0, #1
    bne no_pieces_collisions
        bl restore_prev_state
        bl place_piece_on_grid
        bl clear_lines
        bl remove_shadow
        bl spawn_new_piece
    no_pieces_collisions:
// check for collisions with placed pieces end

// check for collisions with floor:
    bl does_collide_with_floor
    cmp x0, #0
    beq no_floor_collision
        bl restore_prev_state
        bl place_piece_on_grid
        bl clear_lines
        bl remove_shadow
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

    bl adjust_shadow
    bl is_game_over
    cmp x0, #1
    beq game_over

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

.global fill_grid
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

    mov w0, #'='
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
    mov x4, columns
    horizontal_up:
        strb w0, [x1, x2]
        add x2, x2, #1
        cmp x2, x4
        bne horizontal_up

    mov w0, #'|'
    mov x2, #0
    vertical:
        strb w0, [x1, x2]

        add x2, x2, x4
        sub x2, x2, #1
        strb w0, [x1, x2]

        add x2, x2, #1
        cmp x2, x3
        blt vertical

    corners:
        mov w0, #'{'
        strb w0, [x1]
        mov w0, #'}'
        mov x2, columns
        sub x2, x2, #1
        strb w0, [x1, x2]

        mov w0, #'['
        mov x3, len
        sub x2, x3, x2
        sub x2, x2, #1
        strb w0, [x1, x2]

        mov w0, #']'
        sub x3, x3, #1
        strb w0, [x1, x3]
    ret

.global print_grid
print_grid:
    PROLOGUE
    adr x0, field
    adr x10, grid
    mov x11, #0 // raws
    mov x21, raws
    mov x12, #0 // columns
    mov x22, columns // columns
    // x23 - for tmp char
    // x24 - actual pos
    print_raws:
        cmp x11, x21
        beq print_raws_end

        mov x1, x11
        bl place_left_side_line
        
        print_raw:
        mov x12, #0
        print_cols:
            cmp x12, x22
            beq print_cols_end

            mov x24, x11
            mul x24, x24, x22
            add x24, x24, x12
            ldrb w1, [x10, x24]
            bl write_cell

            add x12, x12, #1
            b print_cols
        print_cols_end:
        add x11, x11, #1
        mov w23, #'\n'
        strb w23, [x0], #1
        b print_raws
    print_raws_end:
    mov w23, #0
    strb w23, [x0], #1
    adr x1, field
    bl write_c_str
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

// places #0 x0 if non-placing collision
// places #1 x0 if placing collision
does_collide_with_pieces:
    adr x1, piece_position
    adr x2, grid
    mov x3, #0
    pieces_collision_check_loop:
        cmp x3, #32
        beq no_collision

        ldr x0, [x1, x3]
        ldrb w4, [x2, x0]
        cmp w4, #'a'
        blt no_collision_for_cell
        cmp w4, #'z'
        bgt no_collision_for_cell

        adr x4, previous_position
        ldr x4, [x4, x3]
        sub x4, x0, x4
        cmp x4, #12
        beq placeing_collision
        b no_placing_collision

        no_collision_for_cell:
        add x3, x3, #8
        b pieces_collision_check_loop
    no_placing_collision:
    mov x0, #0
    ret

    placeing_collision:
    mov x0, #1
    ret

    no_collision:
    mov x0, #-1
    ret

.global place_piece_on_grid
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

.global teleport_down
teleport_down:
    PROLOGUE

// erase current piece state
    adr x4, piece_position
    ldp x0, x1, [x4]
    ldp x2, x3, [x4, #16]
    adr x4, grid
    mov w5, #' '
    strb w5, [x4, x0]
    strb w5, [x4, x1]
    strb w5, [x4, x2]
    strb w5, [x4, x3]
// erase current piece state end

teleport_down_loop:
    bl move_down

    bl does_collide_with_pieces
    cmp x0, #1
    bne teleport_no_pieces_collisions
        bl restore_prev_state
        bl place_piece_on_grid
        bl clear_lines
        bl remove_shadow
        bl spawn_new_piece
        b teleport_down_loop_end
    teleport_no_pieces_collisions:

    bl does_collide_with_floor
    cmp x0, #0
    beq teleport_no_floor_collision
        bl restore_prev_state
        bl place_piece_on_grid
        bl clear_lines
        bl remove_shadow
        bl spawn_new_piece
        b teleport_down_loop_end
    teleport_no_floor_collision:
b teleport_down_loop

teleport_down_loop_end:

    bl is_game_over
    cmp x0, #1
    beq game_over

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

.global get_raws
get_raws:
    mov x0, raws
    ret

.global get_columns
get_columns:
    mov x0, columns
    ret

clear_lines:
    PROLOGUE
    adr x0, grid
    mov x10, #0
    adr x1, piece_position
    mov x2, #0
    clear_lines_loop:
        cmp x2, #32
        beq clear_lines_loop_end

        ldr x3, [x1, x2]
        // x3 = raw * columns + column
        // x3 / columns = raw
        mov x4, columns
        udiv x3, x3, x4
        mul x3, x3, x4
        add x3, x3, #1   // x3 - first char on raw
        mov x4, max_column
        add x4, x4, x3
        
        check_line_loop:
            cmp x3, x4
            beq clear_line

            ldrb w5, [x0, x3]
            cmp w5, #'a'
            blt check_line_loop_end
            cmp w5, #'z'
            bgt check_line_loop_end

            add x3, x3, #1
            b check_line_loop
        check_line_loop_end:

        add x2, x2, #8
        b clear_lines_loop

    clear_lines_loop_end:
    cmp x10, #0
    bne increase_score
    EPILOGUE
    ret

// x10 - lines cleared
increase_score:
    adr x1, score
    ldr x2, [x1]

    cmp x10, #1
    bne not_1_line
    add x2, x2, #40
    b increase_score_end
    not_1_line:

    cmp x10, #2
    bne not_2_line
    add x2, x2, #100
    b increase_score_end
    not_2_line:

    cmp x10, #3
    bne not_3_line
    add x2, x2, #400
    b increase_score_end
    not_3_line:

    cmp x10, #4
    bne not_4_line
    add x2, x2, #1200
    b increase_score_end
    not_4_line:

    increase_score_end:
    str x2, [x1]
    bl update_score_window
    mov x10, #0
    b clear_lines_loop_end

clear_line:
    add x10, x10, #1
    mov x4, columns
    udiv x3, x3, x4 // x3 - cur raw
    mov x5, #1
    clear_line_loop:
        cmp x3, x5
        beq check_line_loop_end

        mov x6, #1
        mov x7, max_column
        copy_upper_line_loop:
            cmp x6, x7
            mov x8, columns
            bgt copy_upper_line_loop_end
            mul x8, x3, x8
            add x8, x8, x6  // x8 - cur cell
            sub x9, x8, #12 // x9 - cell upper
            ldrb w9, [x0, x9]
            strb w9, [x0, x8]
        
            add x6, x6, #1
            b copy_upper_line_loop
        copy_upper_line_loop_end:
        sub x3, x3, #1
        b clear_line_loop

// returns 1 in x0 if true
.global is_game_over
is_game_over:
    adr x0, grid
    mov x1, min_column
    mov x2, columns
    add x1, x1, x2
    add x2, x2, x2
    sub x2, x2, #1
    is_game_over_loop:
        ldrb w3, [x0, x1]
        cmp w3, #'a'
        blt game_is_not_over
        cmp w3, #'z'
        bgt game_is_not_over
        b game_is_over

        game_is_not_over:
        add x1, x1, #1
        cmp x1, x2
        bne is_game_over_loop
    mov x0, #0
    ret
    game_is_over:
    mov x0, #1
    ret

// expects x0 - field ptr, x1 - raw
place_left_side_line:
    PROLOGUE
    cmp x1, left_window_start
    blt place_idle_line
    cmp x1, left_window_end
    bgt place_idle_line
    bl place_window_line
    EPILOGUE
    ret

    place_idle_line:
    adr x1, idle_line
    mov x2, idle_line_length
    bl memcpy
    add x0, x0, idle_line_length
    EPILOGUE
    ret

place_window_line:    
    PROLOGUE
    adr x2, left_window
    mov x3, x1
    sub x3, x3, left_window_start
    find_line_cycle:
        cmp x3, #0
        beq find_line_cycle_end

        find_null_cycle:
            add x2, x2, #1
            ldrb w4, [x2]
            cmp x4, #0
            bne find_null_cycle
        find_null_cycle_end:

        add x2, x2, #1
        sub x3, x3, #1
        b find_line_cycle
    find_line_cycle_end:

    // now x2 points on the start of the line to print
    place_line_cycle:
        ldrb w3, [x2], #1
        cmp w3, #0
        beq place_line_cycle_end
        strb w3, [x0], #1
        b place_line_cycle
    place_line_cycle_end:

    EPILOGUE
    ret

// x2 - new score
update_score_window:
    mov x1, x2
    mov x3, #1 // chars counter
    mov x4, #10
    chars_count_loop:
        udiv x1, x1, x4
        cmp x1, #0
        beq chars_count_loop_end
        add x3, x3, #1
        b chars_count_loop
    chars_count_loop_end:

    adr x1, left_window       
    add x1, x1, place_to_insert_score
    add x1, x1, x3
    score_str_loop:
        udiv x3, x2, x4
        mul x3, x3, x4
        sub x3, x2, x3
        add x3, x3, #'0'
        strb w3, [x1], #-1
        udiv x2, x2, x4
        cmp x2, #0
        bne score_str_loop
    score_str_loop_end:
    ret

left_window_start = 0
left_window_hight = 16
left_window_end = left_window_start + left_window_hight - 1

idle_line_length = 23
place_to_insert_score = 62 + 28 + 13


.data
idle_line:
    .ascii  "                       "
left_window:
    .ascii  "  ┏━━━━━━━━━━━━━━━━━┓  \0"
    .ascii  "  ┃                 ┃  \0"
    .ascii  "  ┃ Score:  0       ┃  \0" // 3rd line to insert score
    .ascii  "  ┃                 ┃  \0"
    .ascii  "  ┗━━━━━━━━━━━━━━━━━┛  \0"
    .ascii  "                       \0"
    .ascii  "  ┏━━━━━━━━━━━━━━━━━┓  \0"
    .ascii  "  ┃ Left          A ┃  \0"
    .ascii  "  ┃ Right         D ┃  \0"
    .ascii  "  ┃ Down          S ┃  \0"
    .ascii  "  ┃ Drop      Space ┃  \0"
    .ascii  "  ┃ Rotate ↻      K ┃  \0"
    .ascii  "  ┃ Rotate ↺      J ┃  \0"
    .ascii  "  ┃ Rotate 180°   L ┃  \0"
    .ascii  "  ┃ Quit          Q ┃  \0"
    .ascii  "  ┗━━━━━━━━━━━━━━━━━┛  \0"
