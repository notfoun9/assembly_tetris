	.text
	.global _start

_start:
	/* read 2 bytes: digit and newline */
	mov	x0, #1
	adr	x1, buf
	mov	x2, #2
	mov	x8, #63
	svc	#0
	cbz	x0, exit // if 0 bytes read exit

    adr x1, buf
	ldrb w0, [x1]        /* first byte */ 
	sub	w1, w0, #'0'    /* digit -> w1 */
	cmp	w1, #0
	blt	exit
	cmp	w1, #9
	bgt	exit

	adr	x0, tp
    strb w1, [x0] 

	mov	x1, #0
	mov	x8, #101
	svc	#0

exit:
	mov	x0, #0
	mov	x8, #93
	svc	#0

	.data
buf:
	.space 2
tp:
    .space 16

