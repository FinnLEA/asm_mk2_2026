read_char proc near
	; save callers base pointer
	push bp
	; set own base pointer
	mov bp, sp
	; allocate 2 bytes for local buffer
	sub sp, 2
	; save bx, cx, dx
	pushr bx, cx, dx

	; get file handle (arg1) into bx
	mov bx, word ptr [bp + arg1]
	; get address of local buffer into dx
	lea dx, word ptr [bp + var1]

	; save ds because we'll change it
	push ds
	; set ds = ss to access local buffer
	mov ax, ss
	mov ds, ax

	; push count = 1
	push 1
	; push pointer to buffer
	push dx
	; push file handle
	push bx
	; read one byte from file
	call fread
	; clean up 6 bytes of arguments
	add sp, 6

	; restore original ds
	pop ds

	; check if exactly 1 byte was read
	cmp ax, 1
	; if not, its eof or error
	jne _read_char_eof

	; zero high byte of ax
	xor ax, ax
	; load the read character into al
	mov al, byte ptr [bp + var1]
	; go to exit
	jmp _read_char_exit

_read_char_eof:
	; return -1 to indicate eof
	mov ax, -1

_read_char_exit:
	; restore dx, cx, bx
	popr dx, cx, bx
	; discard local buffer space
	add sp, 2
	; restore sp
	mov sp, bp
	; restore bp
	pop bp
	; return to caller
	ret
read_char endp

read_int_from_file proc near
	; save base pointer
	push bp
	; set own base pointer
	mov bp, sp
	; allocate 2 bytes for sign flag
	sub sp, 2
	; save bx, cx, dx
	pushr bx, cx, dx

	; sign flag = 0 (positive)
	mov word ptr [bp + var1], 0

_skip_ws:
	; push file handle
	push word ptr [bp + arg1]
	; read one character
	call read_char
	; clean stack
	add sp, 2

	; if eof, jump to eof handler
	cmp ax, -1
	je _read_int_eof

	; if space, skip it
	cmp al, ' '
	je _skip_ws
	; if tab, skip it
	cmp al, 9
	je _skip_ws
	; if carriage return, skip it
	cmp al, 13
	je _skip_ws
	; if line feed, skip it
	cmp al, 10
	je _skip_ws

	; check for minus sign
	cmp al, '-'
	jne _check_pos
	; mark sign negative
	mov word ptr [bp + var1], 1
	; go to digit reading
	jmp _read_digits

_check_pos:
	; if plus sign, just continue
	cmp al, '+'
	je _read_digits

	; reject characters below '0'
	cmp al, '0'
	jl _read_int_eof
	; reject characters above '9'
	cmp al, '9'
	jg _read_int_eof

	; convert ascii to digit value
	sub al, '0'
	; clear ah
	xor ah, ah
	; first digit goes into cx
	mov cx, ax
	; jump into the read loop
	jmp _read_loop

_read_digits:
	; clear accumulator
	xor cx, cx

_read_loop:
	; push file handle
	push word ptr [bp + arg1]
	; read next character
	call read_char
	; clean stack
	add sp, 2

	; eof means number is finished
	cmp ax, -1
	je _read_int_done

	; whitespace means number is finished
	cmp al, ' '
	je _read_int_done
	cmp al, 9
	je _read_int_done
	cmp al, 13
	je _read_int_done
	cmp al, 10
	je _read_int_done

	; convert digit to value
	sub al, '0'
	xor ah, ah
	; save new digit in bx
	mov bx, ax

	; multiply current total by 10
	mov ax, cx
	mov dx, 10
	mul dx
	; add new digit
	add ax, bx
	; store updated total in cx
	mov cx, ax

	; repeat
	jmp _read_loop

_read_int_done:
	; move total to ax
	mov ax, cx
	; if sign flag is negative, negate
	cmp word ptr [bp + var1], 1
	jne _read_int_ret
	neg ax
	jmp _read_int_ret

_read_int_eof:
	; return 0 for missing number
	mov ax, 0
	; if caller gave eof flag address, set it to 1
	mov bx, word ptr [bp + arg2]
	test bx, bx
	jz _read_int_ret
	mov word ptr [bx], 1

_read_int_ret:
	; restore registers
	popr dx, cx, bx
	; free local variable
	add sp, 2
	; restore sp
	mov sp, bp
	; restore bp
	pop bp
	ret
read_int_from_file endp

write_char_to_file proc near
	; save base pointer
	push bp
	; set own base pointer
	mov bp, sp
	; allocate 2 bytes for character buffer
	sub sp, 2
	; save bx, cx, dx
	pushr bx, cx, dx

	; get the character to write into ax
	mov ax, word ptr [bp + arg2]
	; place its low byte into local buffer
	mov byte ptr [bp + var1], al
	; load file handle into bx
	mov bx, word ptr [bp + arg1]
	; load buffer address into dx
	lea dx, word ptr [bp + var1]

	; save ds
	push ds
	; set ds = ss to access stack buffer
	mov cx, ss
	mov ds, cx

	; write 1 byte
	push 1
	; push buffer address
	push dx
	; push file handle
	push bx
	; call fwrite
	call fwrite
	; clean up 6 bytes
	add sp, 6

	; restore ds
	pop ds

	; restore dx, cx, bx
	popr dx, cx, bx
	; discard local buffer
	add sp, 2
	; restore sp
	mov sp, bp
	; restore bp
	pop bp
	ret
write_char_to_file endp

write_int_to_file proc near
	; save base pointer
	push bp
	; set own base pointer
	mov bp, sp
	; allocate 8 bytes for digit buffer
	sub sp, 8
	; save ax, bx, cx, dx, si
	pushr ax, bx, cx, dx, si

	; load the integer to write
	mov ax, word ptr [bp + arg2]
	; point si to the end of the local buffer
	lea si, word ptr [bp + var1]
	; digit count = 0
	mov cx, 0

	; if value >= 0, skip sign handling
	cmp ax, 0
	jge _itoa_loop
	; make value positive for conversion
	neg ax
	; save the absolute value
	push ax
	; push '-' character
	push '-'
	; push file handle
	push [bp + arg1]
	; write the minus sign
	call write_char_to_file
	; clean stack (4 bytes)
	add sp, 4
	; restore the absolute value
	pop ax

_itoa_loop:
	; clear dx before division
	xor dx, dx
	; divide by 10
	mov bx, 10
	div bx
	; convert remainder to ascii
	add dl, '0'
	; move pointer left (grow string backwards)
	dec si
	; store digit into buffer (use ss override)
	mov byte ptr ss:[si], dl
	; increment digit count
	inc cx
	; repeat until quotient is zero
	test ax, ax
	jnz _itoa_loop

_write_chars_loop:
	; load the next digit from buffer
	mov al, byte ptr ss:[si]
	; clear high byte
	xor ah, ah
	; push character as argument
	push ax
	; push file handle
	push word ptr [bp + arg1]
	; write the character
	call write_char_to_file
	; clean stack
	add sp, 4
	; move to next digit
	inc si
	; loop for cx digits
	loop _write_chars_loop

	; restore registers
	popr si, dx, cx, bx, ax
	; discard local buffer
	add sp, 8
	; restore sp
	mov sp, bp
	; restore bp
	pop bp
	ret
write_int_to_file endp
