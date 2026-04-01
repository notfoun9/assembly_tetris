.data
raws = 22
columns = 12

/* ----------------------- Piece types ----------------------- */
//          1  2  3  4  5  6  7
// One of:  I, L, J, S, T, Z, O
// colors:  m, o, b, g, p, r, y
zero:
    .ascii "0\n"
one:
    .ascii "1\n"
two:
    .ascii "2\n"
three:
    .ascii "3\n"

.global piece_type
piece_type:
    .ascii "I"
piece_state:
    .byte 0 // from 0 to 3
prev_state:
    .byte 0

.global piece_position
piece_position:
    .quad 18
    .quad 19
    .quad 20
    .quad 21

.global previous_position
previous_position:
    .quad 18
    .quad 19
    .quad 31
    .quad 32

.text
.include "macros.s"
.global init_piece
init_piece:
    ret


// expects x0 - number of rotations
.global rotate_piece
rotate_piece:
    PROLOGUE

    bl cur_to_prev_pos

    mov x23, raws           // x23 - raws    
    mov x24, columns        // x24 - columns
    
    adr x22, piece_position
    ldp x10, x11, [x22]
    ldp x12, x13, [x22, #16]

    adr x25, piece_state

    adr x20, piece_type
    ldrb w20, [x20]         // w20 - piece_type
pick_rotation:
    ldrb w21, [x25]         // w21 - piece_state

    cmp w20, #'I'
    beq I_rotation

    cmp w20, #'L'
    beq L_rotation

    cmp w20, #'J'
    beq J_rotation

    cmp w20, #'S'
    beq S_rotation

    cmp w20, #'T'
    beq T_rotation

    cmp w20, #'Z'
    beq Z_rotation

    cmp w20, #'O'
    beq O_rotation

/* --------------------------   I   --------------------------  */
/* 0: ┌────────┐   1: ┌────────┐   2: ┌────────┐   3: ┌────────┐
      │ . . . .│      │ . .██ .│      │ . . . .│      │ .██ . .│
      │████████│ -- > │ . .██ .│ -- > │ . . . .│ -- > │ .██ . .│
      │ . . . .│ -- > │ . .██ .│ -- > │████████│ -- > │ .██ . .│
      │ . . . .│      │ . .██ .│      │ . . . .│      │ .██ . .│
      └────────┘      └────────┘      └────────┘      └────────┘
*/
I_rotation:
    cmp w21, #0
    bne I_not_zero
    // from 0 to 1
    sub x10, x10, x24  // 0:  - columns + 2
    add x10, x10, #2
    add x11, x11, #1   // 1:  + 1 
    add x12, x12, x24  // 2:  + columns
    add x13, x13, x24  // 3:  + 2 * columns -1
    add x13, x13, x24
    sub x13, x13, #1
b rotation_end


    I_not_zero:
    cmp w21, #1
    bne I_not_one
    // from 1 to 2
    add x10, x10, x24  // 0:  + 2 * columns - 2
    add x10, x10, x24
    sub x10, x10, #2
    add x11, x11, x24  // 1:  + columns - 1
    sub x11, x11, #1
    sub x13, x13, x24  // 3:  - columns + 1
    add x13, x13, #1
b rotation_end

    I_not_one:
    cmp w21, #2
    bne I_not_two
    // from 2 to 3
    sub x10, x10, x24  // 0:  - 2 * columns + 1
    sub x10, x10, x24
    add x10, x10, #1
    sub x11, x11, x24  // 1:  - columns
    sub x12, x12, #1   // 2:  - 1
    add x13, x13, x24  // 3:  + columns - 2
    sub x13, x13, #2
b rotation_end

    I_not_two:
    // assuming it's 3
    // from 3 to 0
    add x10, x10, x24  // 0:  + columns - 1
    sub x10, x10, #1
    sub x12, x12, x24  // 2: - columns + 1
    add x12, x12, #1
    sub x13, x13, x24  // 3:  - 2 * columns + 2
    sub x13, x13, x24
    add x13, x13, #2
b rotation_end

/* --------------------------   L   --------------------------  */
/* 0: ┌────────┐   1: ┌────────┐   2: ┌────────┐   3: ┌────────┐
      │ . .██ .│      │ .██ . .│      │ . . . .│      │████ . .│
      │██████ .│ -- > │ .██ . .│ -- > │██████ .│ -- > │ .██ . .│
      │ . . . .│ -- > │ .████ .│ -- > │██ . . .│ -- > │ .██ . .│
      └────────┘      └────────┘      └────────┘      └────────┘
*/
L_rotation:
    cmp w21, #0
    bne L_not_zero
    // from 0 to 1
    sub x10, x10, #1
    add x11, x11, #1
    add x12, x12, x24
    add x13, x13, x24
b rotation_end

    L_not_zero:
    cmp w21, #1
    bne L_not_one
    // from 1 to 2
    add x10, x10, x24
    sub x10, x10, #1

    sub x12, x12, x24
    add x12, x12, #1
    sub x13, x13, #2
b rotation_end

    L_not_one:
    cmp w21, #2
    bne L_not_two
    // from 2 to 3
    sub x10, x10, x24
    sub x11, x11, x24
    sub x12, x12, #1
    add x13, x13, #1
b rotation_end

    L_not_two:
    // assuming it's 3
    // from 3 to 0
    add x10, x10, #2
    add x11, x11, x24
    sub x11, x11, #1

    sub x13, x13, x24
    add x13, x13, #1
b rotation_end

b rotation_end

/* --------------------------   J   --------------------------  */
/* 0: ┌────────┐   1: ┌────────┐   2: ┌────────┐   3: ┌────────┐
      │██ . . .│      │ .████ .│      │ . . . .│      │ .██ . .│
      │██████ .│ -- > │ .██ . .│ -- > │██████ .│ -- > │ .██ . .│
      │ . . . .│ -- > │ .██ . .│ -- > │ . .██ .│ -- > │████ . .│
      └────────┘      └────────┘      └────────┘      └────────┘
*/
J_rotation:
    cmp w21, #0
    bne J_not_zero
    // from 0 to 1
    add x10, x10, #1   // 0:  + 1
    sub x11, x11, x24  // 1:  - columns + 2
    add x11, x11, #2
    add x13, x13, x24  // 3:  + columns - 1
    sub x13, x13, #1
b rotation_end

    J_not_zero:
    cmp w21, #1
    bne J_not_one
    // from 1 to 2
    add x10, x10, x24  // 0:  + columns - 1
    sub x10, x10, #1
    add x11, x11, x24  // 1:  + columns - 1
    sub x11, x11, #1
    add x12, x12, #1   // 2:  + 1
    add x13, x13, #1   // 3:  + 1
b rotation_end

    J_not_one:
    cmp w21, #2
    bne J_not_two
    // from 2 to 3
    sub x10, x10, x24  // 0:  - columns + 1
    add x10, x10, #1
    add x12, x12, x24  // 2:  + columns - 1
    sub x12, x12, #2
    sub x13, x13, #1   // 3:  - 1
b rotation_end

    J_not_two:
    // assuming it's 3
    // from 3 to 0
    sub x10, x10, #1   // 0:  - 1
    sub x11, x11, #1   // 1:  - 1
    sub x12, x12, x24  // 2:  - columns + 1
    add x12, x12, #1
    sub x13, x13, x24  // 3:  - columns + 1
    add x13, x13, #1
b rotation_end

/* --------------------------   S   --------------------------  */
/* 0: ┌────────┐   1: ┌────────┐   2: ┌────────┐   3: ┌────────┐
      │ .████ .│      │ .██ . .│      │ . . . .│      │██ . . .│
      │████ . .│ -- > │ .████ .│ -- > │ .████ .│ -- > │████ . .│
      │ . . . .│ -- > │ . .██ .│ -- > │████ . .│ -- > │ .██ . .│
      └────────┘      └────────┘      └────────┘      └────────┘
*/
S_rotation:
    cmp w21, #0
    bne S_not_zero
    // from 0 to 1
    add x11, x11, x24
    sub x11, x11, #1
    add x12, x12, #2
    add x13, x13, x24
    add x13, x13, #1
b rotation_end

    S_not_zero:
    cmp w21, #1
    bne S_not_one
    // from 1 to 2
    add x10, x10, x24
    add x11, x11, #1
    add x12, x12, x24
    sub x12, x12, #2
    sub x13, x13, #1
b rotation_end

    S_not_one:
    cmp w21, #2
    bne S_not_two
    // from 2 to 3
    sub x10, x10, #1
    sub x10, x10, x24
    sub x11, x11, #2
    sub x12, x12, x24
    add x12, x12, #1
b rotation_end

    S_not_two:
    // assuming it's 3
    // from 3 to 0
    add x10, x10, #1
    sub x11, x11, x24
    add x11, x11, #2
    sub x12, x12, #1
    sub x13, x13, x24
b rotation_end

/* --------------------------   T   --------------------------  */
/* 0: ┌────────┐   1: ┌────────┐   2: ┌────────┐   3: ┌────────┐
      │ .██ . .│      │ .██ . .│      │ . . . .│      │ .██ . .│
      │██████ .│ -- > │ .████ .│ -- > │██████ .│ -- > │████ . .│
      │ . . . .│ -- > │ .██ . .│ -- > │ .██ . .│ -- > │ .██ . .│
      └────────┘      └────────┘      └────────┘      └────────┘
*/
T_rotation:
    cmp w21, #0
    bne T_not_zero
    // from 0 to 1
    add x11, x11, #1
    add x12, x12, #1
    sub x13, x13, #1
    add x13, x13, x24
b rotation_end

    T_not_zero:
    cmp w21, #1
    bne T_not_one
    // from 1 to 2
    sub x10, x10, #1
    add x10, x10, x24
b rotation_end

    T_not_one:
    cmp w21, #2
    bne T_not_two
    // from 2 to 3
    add x10, x10, #1
    sub x10, x10, x24
    sub x11, x11, #1
    sub x12, x12, #1
b rotation_end

    T_not_two:
    // assuming it's 3
    // from 3 to 0
    sub x13, x13, x24
    add x13, x13, #1
b rotation_end

/* --------------------------   Z   --------------------------  */
/* 0: ┌────────┐   1: ┌────────┐   2: ┌────────┐   3: ┌────────┐
      │████ . .│      │ . .██ .│      │ . . . .│      │ .██ . .│
      │ .████ .│ -- > │ .████ .│ -- > │████ . .│ -- > │████ . .│
      │ . . . .│ -- > │ .██ . .│ -- > │ .████ .│ -- > │██ . . .│
      └────────┘      └────────┘      └────────┘      └────────┘
*/
Z_rotation:
    cmp w21, #0
    bne Z_not_zero
    // from 0 to 1
    add x10, x10, #2
    add x11, x11, x24
    add x12, x12, #1
    add x13, x13, x24
    sub x13, x13, #1
b rotation_end

    Z_not_zero:
    cmp w21, #1
    bne Z_not_one
    // from 1 to 2
    add x10, x10, x24
    sub x10, x10, #2
    add x12, x12, x24
    sub x12, x12, #1
    add x13, x13, #1
b rotation_end

    Z_not_one:
    cmp w21, #2
    bne Z_not_two
    // from 2 to 3
    sub x10, x10, x24
    add x10, x10, #1
    sub x11, x11, #1
    sub x12, x12, x24
    sub x13, x13, #2
b rotation_end

    Z_not_two:
    // assuming it's 3
    // from 3 to 0
    sub x10, x10, #1
    sub x11, x11, x24
    add x11, x11, #1
    sub x13, x13, x24
    add x13, x13, #2
b rotation_end

/* --------------------------   O   --------------------------  */
/* 0: ┌────────┐   1: ┌────────┐   2: ┌────────┐   3: ┌────────┐
      │ .████ .│      │ .████ .│      │ .████ .│      │ .████ .│
      │ .████ .│ -- > │ .████ .│ -- > │ .████ .│ -- > │ .████ .│
      │ . . . .│      │ . . . .│      │ . . . .│      │ . . . .│
      └────────┘      └────────┘      └────────┘      └────────┘
*/
O_rotation:
b rotation_end

rotation_end:
    // change the state
    ldrb w2, [x25]
    add w2, w2, #1
    and w2, w2, #3
    strb w2, [x25]

    sub x0, x0, #1
    cmp x0, #0
    bne pick_rotation

    // update position
    stp x10, x11, [x22]
    stp x12, x13, [x22, #16]
    
    EPILOGUE
    ret

cur_to_prev_pos:
    PROLOGUE
    str x0, [sp, #-16]!

    adr x0, piece_state
    adr x1, prev_state
    ldrb w2, [x0]
    strb w2, [x1]

    adr x0, previous_position
    adr x1, piece_position
    mov x2, #32
    bl memcpy

    ldr x0, [sp], #16
    EPILOGUE
    ret

.global restore_prev_state
restore_prev_state:
    PROLOGUE

    adr x0, piece_position
    adr x1, previous_position
    mov x2, #32
    bl memcpy

    adr x0, piece_state
    adr x1, prev_state
    ldrb w2, [x1]
    strb w2, [x0]

    EPILOGUE
    ret

.global move_down
move_down:
    PROLOGUE
    bl cur_to_prev_pos

    adr x0, piece_position
    ldp x1, x2, [x0]
    ldp x3, x4, [x0, #16]
    add x1, x1, #12
    add x2, x2, #12
    add x3, x3, #12
    add x4, x4, #12

    stp x1, x2, [x0]
    stp x3, x4, [x0, #16]

    EPILOGUE
    ret

.global move_right
move_right:
    PROLOGUE

    bl cur_to_prev_pos

    adr x0, piece_position
    ldp x1, x2, [x0]
    ldp x3, x4, [x0, #16]
    add x1, x1, #1
    add x2, x2, #1
    add x3, x3, #1
    add x4, x4, #1

    stp x1, x2, [x0]
    stp x3, x4, [x0, #16]

    EPILOGUE
    ret

.global move_left
move_left:
    PROLOGUE
    bl cur_to_prev_pos

    adr x0, piece_position
    ldp x1, x2, [x0]
    ldp x3, x4, [x0, #16]
    sub x1, x1, #1
    sub x2, x2, #1
    sub x3, x3, #1
    sub x4, x4, #1

    stp x1, x2, [x0]
    stp x3, x4, [x0, #16]

    EPILOGUE
    ret

.global spawn_new_piece
spawn_new_piece:
    PROLOGUE

    bl rand_64
    mov x2, #7
    udiv x1, x0, x2
    mul x1, x1, x2
    sub x0, x0, x1

    bl set_piece_type

    bl get_default_position
    mov x1, x0
    adr x0, piece_position
    mov x2, #32
    bl memcpy

    mov x2, #32
    adr x0, previous_position
    bl memcpy

    adr x0, piece_state
    mov w1, #0
    strb w1, [x0]

    EPILOGUE
    ret

.data
types:
    .ascii "ILJSTZO"

.text
// expects x0 - from 0 to 7 - types
// I, L, J, S, T, Z, O
set_piece_type:
    adr x1, types
    ldrb w0, [x1, x0]
    adr x1, piece_type
    strb w0, [x1]
    ret
