

k_exit proc
    push bp
    mov bp, sp

	movzx dx, byte ptr ds:[orig_mode]
	push dx
	call _set_mode
	add sp, 2

    call exit0

    mov sp, bp
    pop bp
    ret
k_exit endp