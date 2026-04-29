assume CS:CSEG, DS:DSEG, ES:DSEG, SS:SSEG

exit proc near
	push bp
	mov bp, sp

	mov ax, word ptr [bp + arg1]
	mov ah, 4Ch
	int 21h

	mov sp, bp
	pop bp
	ret
exit endp

exit_zero proc near
	push bp
	mov bp, sp

	mov ax, 4C00h
	int 21h

	mov sp, bp
	pop bp
	ret
exit_zero endp
