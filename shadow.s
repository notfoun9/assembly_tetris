.data
.global shadow_position
shadow_position:
    .quad 0
    .quad 0
    .quad 0
    .quad 0

.text
.include "macros.s"
.global adjust_shadow
adjust_shadow:
    PROLOGUE

// erase current shadow state
    adr x4, shadow_position
    ldp x0, x1, [x4]
    ldp x2, x3, [x4, #16]
    adr x4, grid
    mov w5, #' '
    strb w5, [x4, x0]
    strb w5, [x4, x1]
    strb w5, [x4, x2]
    strb w5, [x4, x3]
// erase current shadow state end

    adr x0, shadow_position
    adr x1, piece_position
    mov x2, #32
    bl memcpy
    bl teleport_down_shadow

// add current shadow state
    bl get_shadow_char
    mov w5, w0 // w5 - shadow char

    adr x4, shadow_position
    ldp x0, x1, [x4]
    ldp x2, x3, [x4, #16]

    adr x4, grid
    strb w5, [x4, x0]
    strb w5, [x4, x1]
    strb w5, [x4, x2]
    strb w5, [x4, x3]
// add current shadow state end

    EPILOGUE
    ret

teleport_down_shadow:
    PROLOGUE

    bl get_raws
    mov x12, x0
    sub x12, x12, #1

    bl get_columns
    mov x11, x0

    adr x0, shadow_position
    ldp x1, x2, [x0]
    ldp x3, x4, [x0, #16]
    adr x5, grid
    teleport_down_shadow_loop:
// FIXME:
        ldrb w6, [x5, x1]
        cmp w6, #'a'
        blt not_colored_char_1
        cmp w6, #'z'
        bgt not_colored_char_1
        b teleport_down_shadow_loop_end
        not_colored_char_1:
        udiv x6, x1, x11
        cmp x6, x12
        beq teleport_down_shadow_loop_end

        ldrb w6, [x5, x2]
        cmp w6, #'a'
        blt not_colored_char_2
        cmp w6, #'z'
        bgt not_colored_char_2
        b teleport_down_shadow_loop_end
        not_colored_char_2:
        udiv x6, x2, x11
        cmp x6, x12
        beq teleport_down_shadow_loop_end

        ldrb w6, [x5, x3]
        cmp w6, #'a'
        blt not_colored_char_3
        cmp w6, #'z'
        bgt not_colored_char_3
        b teleport_down_shadow_loop_end
        not_colored_char_3:
        udiv x6, x3, x11
        cmp x6, x12
        beq teleport_down_shadow_loop_end

        ldrb w6, [x5, x4]
        cmp w6, #'a'
        blt not_colored_char_4
        cmp w6, #'z'
        bgt not_colored_char_4
        b teleport_down_shadow_loop_end
        not_colored_char_4:
        udiv x6, x4, x11
        cmp x6, x12
        beq teleport_down_shadow_loop_end

        add x1, x1, #12
        add x2, x2, #12
        add x3, x3, #12
        add x4, x4, #12
        b teleport_down_shadow_loop
    teleport_down_shadow_loop_end:
    sub x1, x1, #12
    sub x2, x2, #12
    sub x3, x3, #12
    sub x4, x4, #12
    stp x1, x2, [x0]
    stp x3, x4, [x0, #16]

    EPILOGUE
    ret

.global erase_shadow
erase_shadow:
    mov x0, #0
    adr x1, shadow_position
    stp x0, x0, [x1]
    stp x0, x0, [x1, #16]
    ret
