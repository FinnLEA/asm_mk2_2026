
; char* strcpy (char* es:[dst], const char* src)
_strcpy proc near
    push bp
    mov bp, sp
	
	mov di, word ptr[bp + arg1]				; dst
	mov si, word ptr[bp + arg2]				; src
	xor ax, ax
	
.loop_strcpy:
	mov al, byte ptr ds:[si]
	mov byte ptr es:[di], al
	inc si
	inc di
	
	cmp al, 0
	jne .loop_strcpy
	
	mov ax, word ptr[bp + arg1]
	
.finish_strcpy:
	mov sp, bp
    pop bp
    ret
_strcpy endp
