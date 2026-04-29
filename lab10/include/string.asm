putchar proc near
	push bp
	mov bp, sp

	mov dx, word ptr [bp + arg1]
	mov ah, 02h
	int 21h

	mov sp, bp
	pop bp
	ret
putchar endp

getchar proc near
	push bp
	mov bp, sp

	mov ah, 01h
	int 21h

	mov sp, bp
	pop bp
	ret
getchar endp

strlen proc near
	push bp
	mov bp, sp
	pushr cx, di

	mov di, word ptr [bp + arg1]
	xor ax, ax

_strlen_loop:
	mov cl, byte ptr [di]
	test cl, cl
	jz _strlen_exit
	inc ax
	inc di
	jmp _strlen_loop

_strlen_exit:
	popr di, cx
	mov sp, bp
	pop bp
	ret
strlen endp

puts proc near
	push bp
	mov bp, sp

	push word ptr [bp + arg1]
	call strlen
	add sp, 2

	mov cx, ax
	mov dx, word ptr [bp + arg1]
	mov ah, 40h
	mov bx, 1
	int 21h

	mov sp, bp
	pop bp
	ret
puts endp

gets proc near
	push bp
	mov bp, sp
	pushr si

	dec word ptr [bp + arg2]
	mov bx, word ptr [bp + arg1]
	mov si, 0

_gets_loop:
	cmp si, word ptr [bp + arg2]
	je _gets_exit

	call getchar

	cmp al, 13
	je _gets_exit
	cmp al, 10
	je _gets_exit

	mov byte ptr [bx], al
	inc bx
	inc si
	jmp _gets_loop

_gets_exit:
	mov byte ptr [bx], 0
	popr si
	mov sp, bp
	pop bp
	ret
gets endp

crlf proc near
	push bp
	mov bp, sp

	mov dx, 13
	push dx
	call putchar
	add sp, 2

	mov dx, 10
	push dx
	call putchar
	add sp, 2

	mov sp, bp
	pop bp
	ret
crlf endp

strcpy proc near
	push bp
	mov bp, sp
	pushr si, di

	mov di, word ptr [bp + arg1]
	mov si, word ptr [bp + arg2]
	mov ax, di

_strcpy_loop:
	mov dl, byte ptr [si]
	mov byte ptr es:[di], dl
	test dl, dl
	jz _strcpy_exit

	inc si
	inc di
	jne _strcpy_loop

_strcpy_exit:
	popr di, si
	mov sp, bp
	pop bp
	ret
strcpy endp

strcat proc near
	push bp
	mov bp, sp
	pushr si, di

	mov di, word ptr [bp + arg1]
	mov si, word ptr [bp + arg2]
	mov ax, di

_strcat_find_end:
	cmp byte ptr es:[di], 0
	je _strcat_copy_loop
	inc di
	jmp _strcat_find_end

_strcat_copy_loop:
	mov dl, byte ptr [si]
	mov byte ptr es:[di], dl
	inc si
	inc di
	cmp dl, 0
	jne _strcat_copy_loop

	popr di, si
	mov sp, bp
	pop bp
	ret
strcat endp

strcmp proc near
	push bp
	mov bp, sp
	pushr si, di

	mov si, word ptr [bp + arg1]
	mov di, word ptr [bp + arg2]
	xor ax, ax

_strcmp_loop:
	mov al, byte ptr [si]
	mov ah, byte ptr es:[di]

	cmp al, ah
	jne _strcmp_diff

	cmp al, 0
	je _strcmp_equal

	inc si
	inc di
	jmp _strcmp_loop

_strcmp_diff:
	xor ah, ah
	mov dh, 0
	sub ax, dx
	jmp _strcmp_exit

_strcmp_equal:
	xor ax, ax

_strcmp_exit:
	popr di, si
	mov sp, bp
	pop bp
	ret
strcmp endp

stricmp proc near
	push bp
	mov bp, sp
	pushr si, di

	mov si, word ptr [bp + arg1]
	mov di, word ptr [bp + arg2]
	xor ax, ax

_stricmp_loop:
	mov al, byte ptr [si]
	mov ah, byte ptr es:[di]

	; convert AL to lowercase if 'A'-'Z'
	cmp al, 'A'
	jb _stricmp_skip1
	cmp al, 'Z'
	ja _stricmp_skip1
	add al, 32

_stricmp_skip1:
	; convert AH to lowercase if 'A'-'Z'
	cmp ah, 'A'
	jb _stricmp_skip2
	cmp ah, 'Z'
	ja _stricmp_skip2
	add ah, 32

_stricmp_skip2:
	cmp al, ah
	jne _stricmp_diff

	test al, al
	je _stricmp_equal

	inc si
	inc di
	jmp _stricmp_loop

_stricmp_diff:
	mov cx, ax
	movzx ax, ch
	movzx bx, cl
	sub ax, bx
	jmp _stricmp_exit

_stricmp_equal:
	xor ax, ax

_stricmp_exit:
	popr di, si
	mov sp, bp
	pop bp
	ret
stricmp endp

strchr proc near
	push bp
	mov bp, sp
	pushr bx, si, di

	mov di, word ptr [bp + arg1]
	mov al, byte ptr [bp + arg2]

_strchr_loop:
	mov bl, byte ptr [di]
	cmp bl, al
	je _strchr_found

	test bl, bl
	je _strchr_not_found

	inc di
	jmp _strchr_loop

_strchr_not_found:
	xor ax, ax
	jmp _strchr_exit

_strchr_found:
	mov ax, di

_strchr_exit:
	popr di, si, bx
	mov sp, bp
	pop bp
	ret
strchr endp

strstr proc near
	push bp
	mov bp, sp
	pushr bx, si, di

	mov bx, word ptr [bp + arg1]

_strstr_outer:
	mov si, bx
	mov di, word ptr [bp + arg2]

_strstr_inner:
	mov dl, byte ptr es:[di]
	cmp dl, 0
	je _strstr_found

	mov al, byte ptr [si]
	cmp al, dl
	jne _strstr_next_outer

	inc si
	inc di
	jmp _strstr_inner

_strstr_next_outer:
	mov al, byte ptr [bx]
	cmp al, 0
	je _strstr_not_found
	inc bx
	jmp _strstr_outer

_strstr_found:
	mov ax, bx
	jmp _strstr_exit

_strstr_not_found:
	xor ax, ax

_strstr_exit:
	popr di, si, bx
	mov sp, bp
	pop bp
	ret
strstr endp

strtol proc near
	push bp
	mov bp, sp
	sub sp, 6

	pushr bx, cx, si, di

	mov si, word ptr [bp + arg1]
	mov cx, word ptr [bp + arg3]

	; default to base 10 if 0 is passed
	cmp cx, 0
	jne _strtol_skip_base_detect
	mov cx, 10

_strtol_skip_base_detect:
	mov word ptr [bp + var1], cx
	mov word ptr [bp + var2], 0
	mov word ptr [bp + var3], 0

_strtol_skip_ws:
	mov al, byte ptr [si]
	cmp al, ' '
	je _strtol_inc_ws
	cmp al, 9
	je _strtol_inc_ws
	jmp _strtol_sign

_strtol_inc_ws:
	inc si
	jmp _strtol_skip_ws

_strtol_sign:
	mov al, byte ptr [si]
	cmp al, '-'
	jne _strtol_check_pos
	mov word ptr [bp + var2], 1
	inc si
	jmp _strtol_loop

_strtol_check_pos:
	cmp al, '+'
	jne _strtol_loop
	inc si

_strtol_loop:
	xor bx, bx
	mov bl, byte ptr [si]
	cmp bl, 0
	je _strtol_done

	; check digit
	cmp bl, '0'
	jb _strtol_done
	cmp bl, '9'
	ja _strtol_alpha
	sub bl, '0'
	jmp _strtol_check_base

_strtol_alpha:
	cmp bl, 'A'
	jb _strtol_done
	cmp bl, 'Z'
	ja _strtol_lower
	sub bl, 'A' - 10
	jmp _strtol_check_base

_strtol_lower:
	cmp bl, 'a'
	jb _strtol_done
	cmp bl, 'z'
	ja _strtol_done
	sub bl, 'a' - 10

_strtol_check_base:
	mov cx, word ptr [bp + var1]
	cmp bx, cx
	; stop if digit is out base bounds
	jae _strtol_done

	mov ax, word ptr [bp + var3]
	mul cx

	; add new digit
	add ax, bx

	; store in local variables
	mov word ptr [bp + var3], ax

	inc si
	jmp _strtol_loop

_strtol_done:
	mov ax, word ptr [bp + var3]

	; apply sign
	cmp word ptr [bp + var2], 1
	jne _strtol_set_end

	neg ax

_strtol_set_end:
	; end_ptr if not null
	mov di, word ptr [bp + arg2]
	cmp di, 0
	je _strtol_exit
	mov word ptr es:[di], si

_strtol_exit:
	popr di, si, cx, bx
	add sp, 6
	mov sp, bp
	pop bp
	ret
strtol endp

strdup proc near
	push bp
	mov bp, sp
	pushr bx, cx, si, di, es

	push word ptr [bp + arg1]
	call strlen
	add sp, 2

	test ax, ax
	jz _strdup_exit

	inc ax
	push ax
	call mem_alloc
	add sp, 2

	test ax, ax
	jz _strdup_exit

	; setup segment for copy
	mov es, ax

	xor di, di
	mov si, word ptr [bp + arg1]

strdup_loop:
	mov bl, byte ptr [si]
	mov byte ptr es:[di], bl
	inc si
	inc di
	test bl, bl
	jnz strdup_loop

	mov ax, es

_strdup_exit:
	popr es, di, si, cx, bx
	mov sp, bp
	pop bp
	ret
strdup endp
