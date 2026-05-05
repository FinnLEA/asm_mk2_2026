include <include/header.asm>

DSEG segment para public use16 "DATA"
	mat1_buf dw 8192 dup(0)
	mat2_buf dw 8192 dup(0)

	mat1_path db 256 dup(0)
	mat2_path db 256 dup(0)
	mat3_path db 256 dup(0)
	operation db 256 dup(0)

	mat3_fd  dw 0
	eof_flag dw 0

	mat1_cols dw 0
	mat1_rows dw 0

	mat2_cols dw 0
	mat2_rows dw 0

	prompt_mat1 db "enter matrix one path: ", 0
	prompt_mat2 db "enter matrix two path: ", 0
	prompt_mat3 db "enter out matrix path: ", 0
	prompt_op   db "operations: +, -, *, d (determinant of matrix one to out matrix)", 13, 10, "enter operation : ", 0
	msg_equal   db " = ", 0
	msg_space   db " ", 0

	str_add db "+", 0
	str_sub db "-", 0
	str_mul db "*", 0
	str_det db "d", 0

	error_file       db "error: file not found", 13, 10, 0
	error_dimensions db "error: invalid dimensions", 13, 10, 0
	error_operation  db "error: invalid operation", 13, 10, 0
DSEG ends

CSEG segment readonly para public use16 "CODE"
include <include/all.asm>

read_line proc near
	push bp
	mov bp, sp

_read_line_loop:
	push word ptr [bp + arg2]
	push word ptr [bp + arg1]
	call gets
	add sp, 4
	mov bx, word ptr [bp + arg1]
	cmp byte ptr [bx], 0
	je _read_line_loop

	mov sp, bp
	pop bp
	ret
read_line endp

mat_read proc near
	push bp
	mov bp, sp
	sub sp, 2
	pushr bx, cx, dx, di

	push 0
	push word ptr [bp + arg1]
	call fopen
	add sp, 4
	cmp ax, -1
	je _mat_read_file_error
	mov word ptr [bp + var1], ax

	push offset eof_flag
	push word ptr [bp + var1]
	call read_int_from_file
	add sp, 4
	mov bx, word ptr [bp + arg3]
	mov word ptr [bx], ax
	mov cx, ax

	push offset eof_flag
	push word ptr [bp + var1]
	call read_int_from_file
	add sp, 4
	mov bx, word ptr [bp + arg4]
	mov word ptr [bx], ax

	mul cx
	mov cx, ax

	mov di, word ptr [bp + arg2]

_mat_read_loop:
	cmp cx, 0
	je _mat_read_done

	push offset eof_flag
	push word ptr [bp + var1]
	call read_int_from_file
	add sp, 4

	mov word ptr [di], ax
	add di, 2
	dec cx
	jmp _mat_read_loop

_mat_read_done:
	push word ptr [bp + var1]
	call fclose
	add sp, 2
	mov ax, 1
	jmp _mat_read_exit

_mat_read_file_error:
	mov ax, 0

_mat_read_exit:
	popr di, dx, cx, bx
	add sp, 2
	mov sp, bp
	pop bp
	ret
mat_read endp

start:
	init

	; prompt matrix1 path
	push offset prompt_mat1
	call puts
	add sp, 2

	; read matrix1 path
	push 255
	push offset mat1_path
	call read_line
	add sp, 4

	call crlf

	; read matrix1 data
	push offset mat1_cols
	push offset mat1_rows
	push offset mat1_buf
	push offset mat1_path
	call mat_read
	add sp, 8
	cmp ax, 0
	je _exit_file_error

	; prompt matrix2 path
	push offset prompt_mat2
	call puts
	add sp, 2

	; read matrix2 path
	push 255
	push offset mat2_path
	call read_line
	add sp, 4

	call crlf

	; read matrix2 data
	push offset mat2_cols
	push offset mat2_rows
	push offset mat2_buf
	push offset mat2_path
	call mat_read
	add sp, 8
	cmp ax, 0
	je _exit_file_error

	; prompt matrix3 path
	push offset prompt_mat3
	call puts
	add sp, 2

	; read matrix3 path
	push 255
	push offset mat3_path
	call read_line
	add sp, 4

	call crlf

	; create matrix3 file
	mov dx, offset mat3_path
	mov cx, 0
	mov ah, 3Ch
	int 21h
	jc _exit_file_error
	mov mat3_fd, ax

	; prompt operation
	push offset prompt_op
	call puts
	add sp, 2

	; read operation
	push 255
	push offset operation
	call read_line
	add sp, 4

	call crlf

	; do chosen operation
	push offset operation
	push offset str_det
	call strcmp
	add sp, 4
	test ax, ax
	jz _do_det

	push offset operation
	push offset str_add
	call strcmp
	add sp, 4
	test ax, ax
	jz _do_add

	push offset operation
	push offset str_sub
	call strcmp
	add sp, 4
	test ax, ax
	jz _do_sub

	push offset operation
	push offset str_mul
	call strcmp
	add sp, 4
	test ax, ax
	jz _do_mul

	jmp _exit_operation_error

_do_add:
	mov ax, mat1_rows
	cmp ax, mat2_rows
	jne _exit_dimensions_error
	mov ax, mat1_cols
	cmp ax, mat2_cols
	jne _exit_dimensions_error

	push mat3_fd
	push mat1_cols
	push mat1_rows
	push offset mat2_buf
	push offset mat1_buf
	call mat_add
	add sp, 10
	jmp _cleanup

_do_sub:
	mov ax, mat1_rows
	cmp ax, mat2_rows
	jne _exit_dimensions_error
	mov ax, mat1_cols
	cmp ax, mat2_cols
	jne _exit_dimensions_error

	push mat3_fd
	push mat1_cols
	push mat1_rows
	push offset mat2_buf
	push offset mat1_buf
	call mat_sub
	add sp, 10
	jmp _cleanup

_do_mul:
	mov ax, mat1_cols
	cmp ax, mat2_rows
	jne _exit_dimensions_error

	push mat3_fd
	push mat2_cols
	push mat2_rows
	push mat1_cols
	push mat1_rows
	push offset mat2_buf
	push offset mat1_buf
	call mat_mul
	add sp, 14
	jmp _cleanup

_do_det:
	mov ax, mat1_rows
	cmp ax, mat1_cols
	jne _exit_dimensions_error
	cmp ax, 1
	jl _exit_dimensions_error
	cmp ax, 3
	jg _exit_dimensions_error

	push mat3_fd
	push mat1_rows
	push offset mat1_buf
	call mat_det
	add sp, 6
	jmp _cleanup

_cleanup:
	push mat3_fd
	call fclose
	add sp, 2

_exit:
	call exit_zero

_exit_file_error:
	push offset error_file
	call puts
	add sp, 2
	push -1
	call exit
	add sp, 2

_exit_dimensions_error:
	push offset error_dimensions
	call puts
	add sp, 2
	push -2
	call exit
	add sp, 2

_exit_operation_error:
	push offset error_operation
	call puts
	add sp, 2
	push -3
	call exit
	add sp, 2

code_end:
CSEG ends
end start
