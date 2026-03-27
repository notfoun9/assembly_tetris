    .section .bss
buf:
    .skip 100

    .section .text
    .global _start

_start:
    // read(0, buf, 100)
    mov x0, #0          // stdin fd
    adr x1, buf
    mov x2, #100
    mov x8, #63         // syscall read
    svc #0
    // on return, x0 = number of bytes read (or negative error)
    // handle return value in x0

    // write(1, buf, x0)  -- echo input to stdout
    mov x1, x1          // buffer pointer still in x1 (or reload adr x1, buf)
    mov x2, x0          // length = bytes read
    mov x0, #1          // stdout fd
    mov x8, #64         // syscall write
    svc #0

    // exit(0)
    mov x0, #0
    mov x8, #93
    svc #0

