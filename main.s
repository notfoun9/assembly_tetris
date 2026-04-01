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
    bl spawn_new_piece

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
        cmp w9, #' '
        bne skip_space
            bl teleport_down
            b switch_input_char_end
        skip_space:

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

        cmp w9, #'l'
        bne skip_double
            mov x0, #2
            bl rotate_piece
            b switch_input_char_end
        skip_double:

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

