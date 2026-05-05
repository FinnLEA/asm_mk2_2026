mat_add proc near
	push bp
	mov bp, sp
	sub sp, 4
	pushr ax, bx, cx, si, di

	push word ptr [bp + arg3]
	push word ptr [bp + arg5]
	call write_int_to_file
	add sp, 4

	push ' '
	push word ptr [bp + arg5]
	call write_char_to_file
	add sp, 4

	push word ptr [bp + arg4]
	push word ptr [bp + arg5]
	call write_int_to_file
	add sp, 4

	push 10
	push word ptr [bp + arg5]
	call write_char_to_file
	add sp, 4

	mov si, word ptr [bp + arg1]
	mov di, word ptr [bp + arg2]
	mov bx, word ptr [bp + arg5]

	mov word ptr [bp + var1], 0

_mat_add_row_loop:
	mov ax, word ptr [bp + var1]
	cmp ax, word ptr [bp + arg3]
	jge _mat_add_done

	mov word ptr [bp + var2], 0

_mat_add_col_loop:
	mov ax, word ptr [bp + var2]
	cmp ax, word ptr [bp + arg4]
	jge _mat_add_col_done

	mov ax, word ptr ds:[si]
	add ax, word ptr es:[di]

	push ax
	push bx
	call write_int_to_file
	add sp, 4

	mov ax, word ptr [bp + var2]
	inc ax
	cmp ax, word ptr [bp + arg4]
	je _mat_add_skip_space

	push ' '
	push bx
	call write_char_to_file
	add sp, 4

_mat_add_skip_space:
	add si, 2
	add di, 2
	inc word ptr [bp + var2]
	jmp _mat_add_col_loop

_mat_add_col_done:
	push 10
	push bx
	call write_char_to_file
	add sp, 4

	inc word ptr [bp + var1]
	jmp _mat_add_row_loop

_mat_add_done:
	popr di, si, cx, bx, ax
	add sp, 4
	mov sp, bp
	pop bp
	ret
mat_add endp

mat_sub proc near
	push bp
	mov bp, sp
	sub sp, 4
	pushr ax, bx, cx, si, di

	push word ptr [bp + arg3]
	push word ptr [bp + arg5]
	call write_int_to_file
	add sp, 4

	push ' '
	push word ptr [bp + arg5]
	call write_char_to_file
	add sp, 4

	push word ptr [bp + arg4]
	push word ptr [bp + arg5]
	call write_int_to_file
	add sp, 4

	push 10
	push word ptr [bp + arg5]
	call write_char_to_file
	add sp, 4

	mov si, word ptr [bp + arg1]
	mov di, word ptr [bp + arg2]
	mov bx, word ptr [bp + arg5]

	mov word ptr [bp + var1], 0
_mat_sub_row_loop:
	mov ax, word ptr [bp + var1]
	cmp ax, word ptr [bp + arg3]
	jge _mat_sub_done

	mov word ptr [bp + var2], 0
_mat_sub_col_loop:
	mov ax, word ptr [bp + var2]
	cmp ax, word ptr [bp + arg4]
	jge _mat_sub_col_done

	mov ax, word ptr ds:[si]
	sub ax, word ptr es:[di]

	push ax
	push bx
	call write_int_to_file
	add sp, 4

	mov ax, word ptr [bp + var2]
	inc ax
	cmp ax, word ptr [bp + arg4]
	je _mat_sub_skip_space

	push ' '
	push bx
	call write_char_to_file
	add sp, 4

_mat_sub_skip_space:
	add si, 2
	add di, 2
	inc word ptr [bp + var2]
	jmp _mat_sub_col_loop

_mat_sub_col_done:
	push 10
	push bx
	call write_char_to_file
	add sp, 4

	inc word ptr [bp + var1]
	jmp _mat_sub_row_loop

_mat_sub_done:
	popr di, si, cx, bx, ax
	add sp, 4
	mov sp, bp
	pop bp
	ret
mat_sub endp

mat_mul proc near
	push bp
	mov bp, sp
	sub sp, 6
	pushr ax, bx, cx, dx, si, di

	push word ptr [bp + arg3]
	push word ptr [bp + arg7]
	call write_int_to_file
	add sp, 4

	push ' '
	push word ptr [bp + arg7]
	call write_char_to_file
	add sp, 4

	push word ptr [bp + arg6]
	push word ptr [bp + arg7]
	call write_int_to_file
	add sp, 4

	push 10
	push word ptr [bp + arg7]
	call write_char_to_file
	add sp, 4

	mov word ptr [bp + var1], 0

_mul_outer:
	mov ax, word ptr [bp + var1]
	cmp ax, word ptr [bp + arg3]
	jge _mul_done

	mov word ptr [bp + var2], 0

_mul_inner:
	mov ax, word ptr [bp + var2]
	cmp ax, word ptr [bp + arg6]
	jge _mul_next_i

	mov word ptr [bp + var3], 0
	xor cx, cx

_mul_k_loop:
	mov ax, word ptr [bp + var3]
	cmp ax, word ptr [bp + arg4]
	jge _mul_k_done

	mov ax, word ptr [bp + var1]
	imul word ptr [bp + arg4]
	add ax, word ptr [bp + var3]
	shl ax, 1
	mov si, word ptr [bp + arg1]
	add si, ax
	mov bx, word ptr ds:[si]

	mov ax, word ptr [bp + var3]
	imul word ptr [bp + arg6]
	add ax, word ptr [bp + var2]
	shl ax, 1
	mov di, word ptr [bp + arg2]
	add di, ax
	mov ax, word ptr es:[di]

	imul bx
	add cx, ax

	inc word ptr [bp + var3]
	jmp _mul_k_loop

_mul_k_done:
	push cx
	push word ptr [bp + arg7]
	call write_int_to_file
	add sp, 4

	mov ax, word ptr [bp + var2]
	inc ax
	cmp ax, word ptr [bp + arg6]
	je _mul_skip_space

	push ' '
	push word ptr [bp + arg7]
	call write_char_to_file
	add sp, 4

_mul_skip_space:
	inc word ptr [bp + var2]
	jmp _mul_inner

_mul_next_i:
	push 10
	push word ptr [bp + arg7]
	call write_char_to_file
	add sp, 4

	inc word ptr [bp + var1]
	jmp _mul_outer

_mul_done:
	popr di, si, dx, cx, bx, ax
	add sp, 6
	mov sp, bp
	pop bp
	ret
mat_mul endp

mat_det proc near
	push bp
	mov bp, sp
	pushr ax, bx, cx, dx, si

	push 1
	push word ptr [bp + arg3]
	call write_int_to_file
	add sp, 4

	push ' '
	push word ptr [bp + arg3]
	call write_char_to_file
	add sp, 4

	push 1
	push word ptr [bp + arg3]
	call write_int_to_file
	add sp, 4

	push 10
	push word ptr [bp + arg3]
	call write_char_to_file
	add sp, 4

	mov si, word ptr [bp + arg1]
	mov cx, word ptr [bp + arg2]

	cmp cx, 1
	je _det_1
	cmp cx, 2
	je _det_2
	cmp cx, 3
	je _det_3
	jmp _det_done

_det_1:
	mov ax, word ptr ds:[si]
	jmp _det_write

_det_2:
	mov ax, word ptr ds:[si]
	imul word ptr ds:[si + 6]
	mov bx, ax
	mov ax, word ptr ds:[si + 2]
	imul word ptr ds:[si + 4]
	sub bx, ax
	mov ax, bx
	jmp _det_write

_det_3:
	mov ax, word ptr ds:[si + 8]
	imul word ptr ds:[si + 16]
	mov bx, ax
	mov ax, word ptr ds:[si + 10]
	imul word ptr ds:[si + 14]
	sub bx, ax
	mov ax, word ptr ds:[si]
	imul bx
	mov cx, ax

	mov ax, word ptr ds:[si + 6]
	imul word ptr ds:[si + 16]
	mov bx, ax
	mov ax, word ptr ds:[si + 10]
	imul word ptr ds:[si + 12]
	sub bx, ax
	mov ax, word ptr ds:[si + 2]
	imul bx
	sub cx, ax

	mov ax, word ptr ds:[si + 6]
	imul word ptr ds:[si + 14]
	mov bx, ax
	mov ax, word ptr ds:[si + 8]
	imul word ptr ds:[si + 12]
	sub bx, ax
	mov ax, word ptr ds:[si + 4]
	imul bx
	add cx, ax

	mov ax, cx

_det_write:
	push ax
	push word ptr [bp + arg3]
	call write_int_to_file
	add sp, 4

	push 10
	push word ptr [bp + arg3]
	call write_char_to_file
	add sp, 4

_det_done:
	popr si, dx, cx, bx, ax
	mov sp, bp
	pop bp
	ret
mat_det endp
