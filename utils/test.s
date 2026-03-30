.data
msg:
    .ascii "Hello, World!\n\0"

msg2:
    .ascii "Aboba, Aboba!\n\0"

msg01:
    .ascii "Sleep fo 0.1s:\n\0"
msg15:
    .ascii "Sleep for 1.5s:\n\0"
msg5555:
    .ascii "Sleep for 5.555s:\n\0"

.text
.global _start
_start:
    adr x1, msg
    bl strlen
    mov x2, x0
    mov x0, #0
    mov x8, #0x40
    svc #0

    adr x1, msg2
    mov x0, #0
    mov x8, #0x40
    svc #0

    adr x0, msg2
    adr x1, msg
    bl memcpy

    adr x1, msg2
    mov x0, #0
    mov x8, #0x40
    svc #0

    mov x0, #0
    bl print_num
    mov x0, #1
    bl print_num
    mov x0, #10
    bl print_num
    mov x0, #1773
    bl print_num

    adr x1, msg01
    bl write_c_str
    bl timer_start
    mov x0, #0
    mov x1, #100
    mov x2, #100
    mul x1, x1, x2 // 10'000
    mul x1, x1, x2 // 1'000'000
    mul x1, x1, x2 // 100'000'000
    bl nanosleep_call
    bl timer_finish
    bl print_num

    adr x1, msg15
    bl write_c_str
    bl timer_start
    mov x0, #1
    mov x1, #100
    mov x2, #100
    mul x1, x1, x2 // 10'000
    mul x1, x1, x2 // 1'000'000
    mul x1, x1, x2 // 100'000'000
    mov x2, #5
    mul x1, x1, x2 // 500'000'000
    bl nanosleep_call
    bl timer_finish
    bl print_num

    adr x1, msg5555
    bl write_c_str
    bl timer_start
    mov x0, #5
    mov x1, #100
    mov x2, #100
    mul x1, x1, x2 // 10'000
    mul x1, x1, x2 // 1'000'000
    mov x2, #5
    mul x1, x1, x2 // 5'000'000
    mov x3, x1     // 5'000'000
    mov x2, #10
    mul x1, x1, x2 // 50'000'000
    mov x2, x3     // 50'000'000
    add x1, x1, x3 // 55'000'000
    mov x3, #10
    mul x1, x1, x3 // 550'000'000
    add x1, x1, x2 // 555'000'000

    bl nanosleep_call
    bl timer_finish
    bl print_num

    mov x0, #0
    mov x8, #0x5D
    svc #0

