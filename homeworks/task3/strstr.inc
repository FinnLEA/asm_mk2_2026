
; char*	strstr(const char* str, const char* strsearch)
_strstr proc near
    push bp
    mov bp, sp
	
	mov bx, word ptr[bp + arg1] 			; str
	mov dx, word ptr[bp + arg2] 			; strsearch
	
	sub sp, 10
	mov word ptr[bp + var1], 0				; strlen1
	mov word ptr[bp + var2], 0				; strlen2
	mov word ptr[bp + var3], 0				; i - index
	mov word ptr[bp + var4], 0				; j - index
	mov word ptr[bp + var5], 0				; pointer for result (for ax when ret)
	
	push bx									; get strlen1
	call _strlen
	mov word ptr[bp + var1], ax
	add sp, 2
	
	push dx									; get strlen2
	call _strlen
	mov word ptr[bp + var2], ax
	add sp, 2
	
.loop1_strstr:								; for (int i = 0; i != strlen1; i++)
	mov ax, word ptr[bp + var3]
	cmp ax, word ptr[bp + var1]
	je .exit1_strstr
	
	mov word ptr[bp + var4], 0				; j = 0
	
.loop2_strstr:
	mov di, word ptr[bp + arg2]
	add di, word ptr[bp + var4]				; strsearch[j]
	mov bl, byte ptr[di]
	
	cmp bl, 0
	je .found_strstr

	mov ax, word ptr[bp + var3]
	add ax, word ptr[bp + var4]
	cmp ax, word ptr[bp + var1]
	je .next_i_strstr

	mov si, word ptr[bp + arg1]
	mov ax, word ptr[bp + var3]
	add ax, word ptr[bp + var4]
	add si, ax								; str[i + j]
	
	mov al, byte ptr[si]
	cmp al, 0
	je .exit1_strstr
	
	cmp al, bl
	jne .next_i_strstr
	
	inc word ptr[bp + var4]
	jmp .loop2_strstr

.next_i_strstr:
	inc word ptr[bp + var3]
	jmp .loop1_strstr
	
.found_strstr:
	mov ax, word ptr[bp + arg1]
	add ax, word ptr[bp + var3]
	mov word ptr[bp + var5], ax
	jmp .exit0_strstr
	
.exit1_strstr:
	mov ax, 0
	; carry flag = 1
	jmp .finish_strstr
	
.exit0_strstr:
	mov ax, word ptr[bp + var5]				; return pointer
	
.finish_strstr:
	mov sp, bp
    pop bp
    ret
_strstr endp
