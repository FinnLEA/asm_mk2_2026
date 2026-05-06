; add matrices
mat_add proc near
	; save bp
	push bp
	; set frame pointer
	mov bp, sp
	; allocate locals
	sub sp, 4
	; save registers
	pushr ax, bx, cx, si, di

	; push rows
	push word ptr [bp + arg3]
	; push file descriptor
	push word ptr [bp + arg5]
	; write rows to file
	call write_int_to_file
	; clean stack
	add sp, 4

	; push space char
	push ' '
	; push file descriptor
	push word ptr [bp + arg5]
	; write space to file
	call write_char_to_file
	; clean stack
	add sp, 4

	; push cols
	push word ptr [bp + arg4]
	; push file descriptor
	push word ptr [bp + arg5]
	; write cols to file
	call write_int_to_file
	; clean stack
	add sp, 4

	; push newline char
	push 10
	; push file descriptor
	push word ptr [bp + arg5]
	; write newline to file
	call write_char_to_file
	; clean stack
	add sp, 4

	; load mat1 ptr
	mov si, word ptr [bp + arg1]
	; load mat2 ptr
	mov di, word ptr [bp + arg2]
	; load file descriptor
	mov bx, word ptr [bp + arg5]

	; init row counter
	mov word ptr [bp + var1], 0

; row loop start
_mat_add_row_loop:
	; load row counter
	mov ax, word ptr [bp + var1]
	; compare with total rows
	cmp ax, word ptr [bp + arg3]
	; exit if done
	jge _mat_add_done

	; init col counter
	mov word ptr [bp + var2], 0

; col loop start
_mat_add_col_loop:
	; load col counter
	mov ax, word ptr [bp + var2]
	; compare with total cols
	cmp ax, word ptr [bp + arg4]
	; exit col loop if done
	jge _mat_add_col_done

	; load mat1 value
	mov ax, word ptr ds:[si]
	; add mat2 value
	add ax, word ptr es:[di]

	; push sum
	push ax
	; push file descriptor
	push bx
	; write sum to file
	call write_int_to_file
	; clean stack
	add sp, 4

	; load col counter
	mov ax, word ptr [bp + var2]
	; increment counter
	inc ax
	; check if last col
	cmp ax, word ptr [bp + arg4]
	; skip space if last col
	je _mat_add_skip_space

	; push space char
	push ' '
	; push file descriptor
	push bx
	; write space to file
	call write_char_to_file
	; clean stack
	add sp, 4

; skip space label
_mat_add_skip_space:
	; advance mat1 ptr
	add si, 2
	; advance mat2 ptr
	add di, 2
	; increment col counter
	inc word ptr [bp + var2]
	; repeat col loop
	jmp _mat_add_col_loop

; col loop done
_mat_add_col_done:
	; push newline char
	push 10
	; push file descriptor
	push bx
	; write newline to file
	call write_char_to_file
	; clean stack
	add sp, 4

	; increment row counter
	inc word ptr [bp + var1]
	; repeat row loop
	jmp _mat_add_row_loop

; add done
_mat_add_done:
	; restore registers
	popr di, si, cx, bx, ax
	; free locals
	add sp, 4
	; restore sp
	mov sp, bp
	; restore bp
	pop bp
	; return
	ret
; end add proc
mat_add endp

; sub matrices
mat_sub proc near
	; save bp
	push bp
	; set frame pointer
	mov bp, sp
	; allocate locals
	sub sp, 4
	; save registers
	pushr ax, bx, cx, si, di

	; push rows
	push word ptr [bp + arg3]
	; push file descriptor
	push word ptr [bp + arg5]
	; write rows to file
	call write_int_to_file
	; clean stack
	add sp, 4

	; push space char
	push ' '
	; push file descriptor
	push word ptr [bp + arg5]
	; write space to file
	call write_char_to_file
	; clean stack
	add sp, 4

	; push cols
	push word ptr [bp + arg4]
	; push file descriptor
	push word ptr [bp + arg5]
	; write cols to file
	call write_int_to_file
	; clean stack
	add sp, 4

	; push newline char
	push 10
	; push file descriptor
	push word ptr [bp + arg5]
	; write newline to file
	call write_char_to_file
	; clean stack
	add sp, 4

	; load mat1 ptr
	mov si, word ptr [bp + arg1]
	; load mat2 ptr
	mov di, word ptr [bp + arg2]
	; load file descriptor
	mov bx, word ptr [bp + arg5]

	; init row counter
	mov word ptr [bp + var1], 0

; row loop start
_mat_sub_row_loop:
	; load row counter
	mov ax, word ptr [bp + var1]
	; compare with total rows
	cmp ax, word ptr [bp + arg3]
	; exit if done
	jge _mat_sub_done

	; init col counter
	mov word ptr [bp + var2], 0

; col loop start
_mat_sub_col_loop:
	; load col counter
	mov ax, word ptr [bp + var2]
	; compare with total cols
	cmp ax, word ptr [bp + arg4]
	; exit col loop if done
	jge _mat_sub_col_done

	; load mat1 value
	mov ax, word ptr ds:[si]
	; sub mat2 value
	sub ax, word ptr es:[di]

	; push diff
	push ax
	; push file descriptor
	push bx
	; write diff to file
	call write_int_to_file
	; clean stack
	add sp, 4

	; load col counter
	mov ax, word ptr [bp + var2]
	; increment counter
	inc ax
	; check if last col
	cmp ax, word ptr [bp + arg4]
	; skip space if last col
	je _mat_sub_skip_space

	; push space char
	push ' '
	; push file descriptor
	push bx
	; write space to file
	call write_char_to_file
	; clean stack
	add sp, 4

; skip space label
_mat_sub_skip_space:
	; advance mat1 ptr
	add si, 2
	; advance mat2 ptr
	add di, 2
	; increment col counter
	inc word ptr [bp + var2]
	; repeat col loop
	jmp _mat_sub_col_loop

; col loop done
_mat_sub_col_done:
	; push newline char
	push 10
	; push file descriptor
	push bx
	; write newline to file
	call write_char_to_file
	; clean stack
	add sp, 4

	; increment row counter
	inc word ptr [bp + var1]
	; repeat row loop
	jmp _mat_sub_row_loop

; sub done
_mat_sub_done:
	; restore registers
	popr di, si, cx, bx, ax
	; free locals
	add sp, 4
	; restore sp
	mov sp, bp
	; restore bp
	pop bp
	; return
	ret
; end sub proc
mat_sub endp

; mul matrices
mat_mul proc near
	; save bp
	push bp
	; set frame pointer
	mov bp, sp
	; allocate locals
	sub sp, 6
	; save registers
	pushr ax, bx, cx, dx, si, di

	; push mat1 rows
	push word ptr [bp + arg3]
	; push file descriptor
	push word ptr [bp + arg7]
	; write rows to file
	call write_int_to_file
	; clean stack
	add sp, 4

	; push space char
	push ' '
	; push file descriptor
	push word ptr [bp + arg7]
	; write space to file
	call write_char_to_file
	; clean stack
	add sp, 4

	; push mat2 cols
	push word ptr [bp + arg6]
	; push file descriptor
	push word ptr [bp + arg7]
	; write cols to file
	call write_int_to_file
	; clean stack
	add sp, 4

	; push newline char
	push 10
	; push file descriptor
	push word ptr [bp + arg7]
	; write newline to file
	call write_char_to_file
	; clean stack
	add sp, 4

	; init outer loop counter
	mov word ptr [bp + var1], 0

; outer loop start
_mul_outer:
	; load outer counter
	mov ax, word ptr [bp + var1]
	; compare with mat1 rows
	cmp ax, word ptr [bp + arg3]
	; exit if done
	jge _mul_done

	; init inner loop counter
	mov word ptr [bp + var2], 0

; inner loop start
_mul_inner:
	; load inner counter
	mov ax, word ptr [bp + var2]
	; compare with mat2 cols
	cmp ax, word ptr [bp + arg6]
	; next row if done
	jge _mul_next_i

	; init dot product counter
	mov word ptr [bp + var3], 0
	; clear sum
	xor cx, cx

; dot product loop start
_mul_k_loop:
	; load dot product counter
	mov ax, word ptr [bp + var3]
	; compare with mat1 cols
	cmp ax, word ptr [bp + arg4]
	; exit dot product if done
	jge _mul_k_done

	; load outer counter
	mov ax, word ptr [bp + var1]
	; multiply by mat1 cols
	imul word ptr [bp + arg4]
	; add dot product counter
	add ax, word ptr [bp + var3]
	; multiply by 2 for word offset
	shl ax, 1
	; load mat1 ptr
	mov si, word ptr [bp + arg1]
	; add offset
	add si, ax
	; read mat1 value
	mov bx, word ptr ds:[si]

	; load dot product counter
	mov ax, word ptr [bp + var3]
	; multiply by mat2 cols
	imul word ptr [bp + arg6]
	; add inner counter
	add ax, word ptr [bp + var2]
	; multiply by 2 for word offset
	shl ax, 1
	; load mat2 ptr
	mov di, word ptr [bp + arg2]
	; add offset
	add di, ax
	; read mat2 value
	mov ax, word ptr es:[di]

	; multiply values
	imul bx
	; add to sum
	add cx, ax

	; increment dot product counter
	inc word ptr [bp + var3]
	; repeat dot product loop
	jmp _mul_k_loop

; dot product done
_mul_k_done:
	; push sum
	push cx
	; push file descriptor
	push word ptr [bp + arg7]
	; write sum to file
	call write_int_to_file
	; clean stack
	add sp, 4

	; load inner counter
	mov ax, word ptr [bp + var2]
	; increment counter
	inc ax
	; check if last col
	cmp ax, word ptr [bp + arg6]
	; skip space if last col
	je _mul_skip_space

	; push space char
	push ' '
	; push file descriptor
	push word ptr [bp + arg7]
	; write space to file
	call write_char_to_file
	; clean stack
	add sp, 4

; skip space label
_mul_skip_space:
	; increment inner counter
	inc word ptr [bp + var2]
	; repeat inner loop
	jmp _mul_inner

; next row label
_mul_next_i:
	; push newline char
	push 10
	; push file descriptor
	push word ptr [bp + arg7]
	; write newline to file
	call write_char_to_file
	; clean stack
	add sp, 4

	; increment outer counter
	inc word ptr [bp + var1]
	; repeat outer loop
	jmp _mul_outer

; mul done
_mul_done:
	; restore registers
	popr di, si, dx, cx, bx, ax
	; free locals
	add sp, 6
	; restore sp
	mov sp, bp
	; restore bp
	pop bp
	; return
	ret
; end mul proc
mat_mul endp

; calc matrix det
mat_det proc near
	; save bp
	push bp
	; set frame pointer
	mov bp, sp
	; save registers
	pushr ax, bx, cx, dx, si

	; push 1 for rows
	push 1
	; push file descriptor
	push word ptr [bp + arg3]
	; write rows to file
	call write_int_to_file
	; clean stack
	add sp, 4

	; push space char
	push ' '
	; push file descriptor
	push word ptr [bp + arg3]
	; write space to file
	call write_char_to_file
	; clean stack
	add sp, 4

	; push 1 for cols
	push 1
	; push file descriptor
	push word ptr [bp + arg3]
	; write cols to file
	call write_int_to_file
	; clean stack
	add sp, 4

	; push newline char
	push 10
	; push file descriptor
	push word ptr [bp + arg3]
	; write newline to file
	call write_char_to_file
	; clean stack
	add sp, 4

	; load mat ptr
	mov si, word ptr [bp + arg1]
	; load dimensions
	mov cx, word ptr [bp + arg2]

	; check if 1x1
	cmp cx, 1
	; jump if 1x1
	je _det_1
	; check if 2x2
	cmp cx, 2
	; jump if 2x2
	je _det_2
	; check if 3x3
	cmp cx, 3
	; jump if 3x3
	je _det_3
	; jump to done if other
	jmp _det_done

; 1x1 det
_det_1:
	; read single element
	mov ax, word ptr ds:[si]
	; jump to write
	jmp _det_write

; 2x2 det
_det_2:
	; read m00
	mov ax, word ptr ds:[si]
	; mul m11
	imul word ptr ds:[si + 6]
	; store term1
	mov bx, ax
	; read m01
	mov ax, word ptr ds:[si + 2]
	; mul m10
	imul word ptr ds:[si + 4]
	; sub term2 from term1
	sub bx, ax
	; move result to ax
	mov ax, bx
	; jump to write
	jmp _det_write

; 3x3 det
_det_3:
	; read m11
	mov ax, word ptr ds:[si + 8]
	; mul m22
	imul word ptr ds:[si + 16]
	; store term
	mov bx, ax
	; read m12
	mov ax, word ptr ds:[si + 10]
	; mul m21
	imul word ptr ds:[si + 14]
	; sub terms
	sub bx, ax
	; read m00
	mov ax, word ptr ds:[si]
	; mul subdet
	imul bx
	; store running total
	mov cx, ax

	; read m10
	mov ax, word ptr ds:[si + 6]
	; mul m22
	imul word ptr ds:[si + 16]
	; store term
	mov bx, ax
	; read m12
	mov ax, word ptr ds:[si + 10]
	; mul m20
	imul word ptr ds:[si + 12]
	; sub terms
	sub bx, ax
	; read m01
	mov ax, word ptr ds:[si + 2]
	; mul subdet
	imul bx
	; sub from running total
	sub cx, ax

	; read m10
	mov ax, word ptr ds:[si + 6]
	; mul m21
	imul word ptr ds:[si + 14]
	; store term
	mov bx, ax
	; read m11
	mov ax, word ptr ds:[si + 8]
	; mul m20
	imul word ptr ds:[si + 12]
	; sub terms
	sub bx, ax
	; read m02
	mov ax, word ptr ds:[si + 4]
	; mul subdet
	imul bx
	; add to running total
	add cx, ax

	; move final result to ax
	mov ax, cx

; write det result
_det_write:
	; push result
	push ax
	; push file descriptor
	push word ptr [bp + arg3]
	; write result to file
	call write_int_to_file
	; clean stack
	add sp, 4

	; push newline char
	push 10
	; push file descriptor
	push word ptr [bp + arg3]
	; write newline to file
	call write_char_to_file
	; clean stack
	add sp, 4

; det done
_det_done:
	; restore registers
	popr si, dx, cx, bx, ax
	; restore sp
	mov sp, bp
	; restore bp
	pop bp
	; return
	ret
; end det proc
mat_det endp
