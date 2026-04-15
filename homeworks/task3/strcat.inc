
; char* strcat (char* dst, const char* src);
_strcat proc near
    push bp
    mov bp, sp
	
	mov bx, word ptr[bp + arg1]				; dst
	
	push bx
	call _strlen
	add sp, 2
	
	mov bx, word ptr[bp + arg1]				; dst
	mov di, word ptr[bp + arg2]				; src
	
	add bx, ax
	
	push di
	push bx
	call _strcpy
	add sp, 4
	
	mov ax, word ptr[bp + arg1]
	
.finish_strcat:
	mov sp, bp
    pop bp
    ret
_strcat endp
