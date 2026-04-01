.data
time_since_fall:
    .quad 0
fall_speed = 6

.text
.include "macros.s"
.global _start

/* ------------------------------ */
/* --------- Main start --------- */
_start:
    adr x0, time_since_fall
    mrs x1, cntvct_el0
    str x1, [x0]

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
    ldr     x1, [x0, #12]
    movz    x2, #0xA
    mvn     x2, x2      // x2 = ~0xA
    and     x1, x1, x2  // flag &= ~0xA
    str     x1, [x0, #12]
    mov     w1, #0
    strb    w1, [x0, #23]
    mov     w1, #1
    strb    w1, [x0, #22]
    
    bl set_terminal_state
// term set

    bl fill_grid
    bl spawn_new_piece

    game_loop:
        bl adjust_grid
        bl clear_term
        bl print_grid

        adr x0, time_since_fall
        ldr x1, [x0]
        mrs x2, cntvct_el0
        sub x1, x2, x1

        mov x2, #10
        mul x1, x1, x2

        mrs x2, cntfrq_el0
        udiv x1, x1, x2 // deciseconds
        mov x2, fall_speed
        cmp x1, x2
        bgt force_fall

        adr x1, symbl
        mov x0, #0
        mov x2, #1
        mov x8, #0x3F
        svc #0
        ldrb w0, [x1]

/* -- Switch case input char start -- */
        cmp w0, #' '
        bne skip_space
            bl teleport_down
            b switch_input_char_end
        skip_space:

        cmp w0, #'k'
        bne skip_clock
            mov w0, #1
            bl rotate_piece
            b switch_input_char_end
        skip_clock:

        cmp w0, #'j'
        bne skip_counterclock
            mov w0, #3
            bl rotate_piece
            b switch_input_char_end
        skip_counterclock:

        cmp w0, #'l'
        bne skip_double
            mov w0, #2
            bl rotate_piece
            b switch_input_char_end
        skip_double:

        cmp w0, #'a'
        bne skip_left
            bl move_left
            b switch_input_char_end
        skip_left:

        cmp w0, #'s'
        bne skip_down
            bl move_down
            b switch_input_char_end
        skip_down:

        cmp w0, #'d'
        bne skip_right
            bl move_right
            b switch_input_char_end
        skip_right:

        cmp w0, #'q'
        beq game_loop_end

/* --- Switch case input char end --- */
    force_fall:
        bl move_down
        adr x0, time_since_fall
        mrs x1, cntvct_el0
        str x1, [x0]

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

