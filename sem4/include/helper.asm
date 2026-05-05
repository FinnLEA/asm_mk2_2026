read_char proc near
	push bp
	mov bp, sp
	sub sp, 2
	pushr bx, cx, dx

	mov bx, word ptr [bp + arg1]
	lea dx, word ptr [bp + var1]

	push ds
	mov ax, ss
	mov ds, ax

	push 1
	push dx
	push bx
	call fread
	add sp, 6

	pop ds

	cmp ax, 1
	jne _read_char_eof

	xor ax, ax
	mov al, byte ptr [bp + var1]
	jmp _read_char_exit

_read_char_eof:
	mov ax, -1

_read_char_exit:
	popr dx, cx, bx
	add sp, 2
	mov sp, bp
	pop bp
	ret
read_char endp

read_int_from_file proc near
	push bp
	mov bp, sp
	sub sp, 2
	pushr bx, cx, dx

	mov word ptr [bp + var1], 0

_skip_ws:
	push word ptr [bp + arg1]
	call read_char
	add sp, 2

	cmp ax, -1
	je _read_int_eof

	cmp al, ' '
	je _skip_ws
	cmp al, 9
	je _skip_ws
	cmp al, 13
	je _skip_ws
	cmp al, 10
	je _skip_ws

	cmp al, '-'
	jne _check_pos
	mov word ptr [bp + var1], 1
	jmp _read_digits

_check_pos:
	cmp al, '+'
	je _read_digits

	cmp al, '0'
	jl _read_int_eof
	cmp al, '9'
	jg _read_int_eof

	sub al, '0'
	xor ah, ah
	mov cx, ax
	jmp _read_loop

_read_digits:
	xor cx, cx

_read_loop:
	push word ptr [bp + arg1]
	call read_char
	add sp, 2

	cmp ax, -1
	je _read_int_done

	cmp al, ' '
	je _read_int_done
	cmp al, 9
	je _read_int_done
	cmp al, 13
	je _read_int_done
	cmp al, 10
	je _read_int_done

	sub al, '0'
	xor ah, ah
	mov bx, ax

	mov ax, cx
	mov dx, 10
	mul dx
	add ax, bx
	mov cx, ax

	jmp _read_loop

_read_int_done:
	mov ax, cx
	cmp word ptr [bp + var1], 1
	jne _read_int_ret
	neg ax
	jmp _read_int_ret

_read_int_eof:
	mov ax, 0
	mov bx, word ptr [bp + arg2]
	test bx, bx
	jz _read_int_ret
	mov word ptr [bx], 1

_read_int_ret:
	popr dx, cx, bx
	add sp, 2
	mov sp, bp
	pop bp
	ret
read_int_from_file endp

write_char_to_file proc near
	push bp
	mov bp, sp
	sub sp, 2
	pushr bx, cx, dx

	mov ax, word ptr [bp + arg2]
	mov byte ptr [bp + var1], al
	mov bx, word ptr [bp + arg1]
	lea dx, word ptr [bp + var1]

	push ds
	mov cx, ss
	mov ds, cx

	push 1
	push dx
	push bx
	call fwrite
	add sp, 6

	pop ds

	popr dx, cx, bx
	add sp, 2
	mov sp, bp
	pop bp
	ret
write_char_to_file endp

write_int_to_file proc near
	push bp
	mov bp, sp
	sub sp, 8
	pushr ax, bx, cx, dx, si

	mov ax, word ptr [bp + arg2]
	lea si, word ptr [bp + var1]
	mov cx, 0

	cmp ax, 0
	jge _itoa_loop
	neg ax
	push ax
	push '-'
	push [bp + arg1]
	call write_char_to_file
	add sp, 4
	pop ax

_itoa_loop:
	xor dx, dx
	mov bx, 10
	div bx
	add dl, '0'
	dec si
	mov byte ptr ss:[si], dl
	inc cx
	test ax, ax
	jnz _itoa_loop

_write_chars_loop:
	mov al, byte ptr ss:[si]
	xor ah, ah
	push ax
	push word ptr [bp + arg1]
	call write_char_to_file
	add sp, 4
	inc si
	loop _write_chars_loop

	popr si, dx, cx, bx, ax
	add sp, 8
	mov sp, bp
	pop bp
	ret
write_int_to_file endp
