_error_handler proc near
	push bp
    mov bp, sp
	
	mov ax, [bp + arg1]
	shl ax, 1
	mov bx, ax
	mov ax, word ptr [error_table + bx]
	
	push ax
	call _putstr
	add sp, 2
	
	call _putnewline
	
    mov sp, bp
    pop bp
    ret
_error_handler endp