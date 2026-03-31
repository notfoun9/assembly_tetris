.data
/* -- Default positions -- */
/* ---------- I ---------- */
/* ┌────────┐
   │ . . . .│
   │████████│
   │ . . . .│
   │ . . . .│
   └────────┘
*/
default_position_I:
    .quad 16
    .quad 17
    .quad 18
    .quad 19

/* ---------- L ---------- */
/* ┌────────┐
   │ . .██ .│
   │██████ .│
   │ . . . .│
   └────────┘
*/
default_position_L:
    .quad 19
    .quad 29
    .quad 30
    .quad 31

/* ---------- J ---------- */
/* ┌────────┐
   │██ . . .│
   │██████ .│
   │ . . . .│
   └────────┘
*/
default_position_J:
    .quad 17
    .quad 29
    .quad 30
    .quad 31

/* ---------- S ---------- */
/* ┌────────┐
   │ .████ .│
   │████ . .│
   │ . . . .│
   └────────┘
*/
default_position_S:
    .quad 18
    .quad 19
    .quad 29
    .quad 30

/* ---------- T ---------- */
/* ┌────────┐
   │ .██ . .│
   │██████ .│
   │ . . . .│
   └────────┘
*/
default_position_T:
    .quad 18
    .quad 29
    .quad 30
    .quad 31

/* ---------- Z ---------- */
/* ┌────────┐
   │████ . .│
   │ .████ .│
   │ . . . .│
   └────────┘
*/
default_position_Z:
    .quad 17
    .quad 18
    .quad 30
    .quad 31

/* ---------- O ---------- */
/* ┌────────┐
   │ .████ .│
   │ .████ .│
   │ . . . .│
   └────────┘
*/
default_position_O:
    .quad 17
    .quad 18
    .quad 29
    .quad 30

.text
.global get_default_position
get_default_position:
    adr x1, piece_type
    ldrb w0, [x1]

    cmp w0, #'I'
    bne not_I
    adr x0, default_position_I
    ret
    not_I:

    cmp w0, #'L'
    bne not_L
    adr x0, default_position_L
    ret
    not_L:

    cmp w0, #'J'
    bne not_J
    adr x0, default_position_J
    ret
    not_J:

    cmp w0, #'S'
    bne not_S
    adr x0, default_position_S
    ret
    not_S:

    cmp w0, #'T'
    bne not_T
    adr x0, default_position_T
    ret
    not_T:

    cmp w0, #'Z'
    bne not_Z
    adr x0, default_position_Z
    ret
    not_Z:

    cmp w0, #'O'
    bne not_O
    adr x0, default_position_O
    ret
    not_O:
    ret
