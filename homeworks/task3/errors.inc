
_error_alloc proc near
	push bp
	mov bp, sp
	
	push offset str_error_alloc
	call _putstr
	add sp, 2
	
.finish_error_alloc:
	mov sp, bp
	pop bp
	ret
_error_alloc endp
