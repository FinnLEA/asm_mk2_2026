
; char* strchr (const char* str, int c)
_strchr proc near
    push bp
    mov bp, sp
	
	mov bx, word ptr[bp + arg1]
	mov dl, byte ptr[bp + arg2]
	xor ax, ax
	
.loop_strchr:
	mov al, byte ptr[bx]
	
	cmp al, dl
	je .exit0_strchr
	
	cmp al, 0
	je .exit1_strchr
	
	inc bx
	jmp .loop_strchr
	
.exit1_strchr:
	mov ax, 0
	jmp .finish_strchr
	
.exit0_strchr:
	mov ax, bx
	
.finish_strchr:
	mov sp, bp
    pop bp
    ret
_strchr endp
