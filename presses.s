	.text
	.global _start

_start:
    bl exit

exit:
	mov	x0, #0
	mov	x8, #93
	svc	#0

    .section .data
