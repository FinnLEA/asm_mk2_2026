; include custom header
include <include/header.asm>

; start of data segment
DSEG segment para public use16 "DATA"
	; buffer for matrix 1 (max 8192 words)
	mat1_buf dw 8192 dup(0)
	; buffer for matrix 2
	mat2_buf dw 8192 dup(0)

	; path string for matrix 1
	mat1_path db 256 dup(0)
	; path string for matrix 2
	mat2_path db 256 dup(0)
	; path string for output matrix
	mat3_path db 256 dup(0)
	; operation string buffer
	operation db 256 dup(0)

	; file descriptor for output file
	mat3_fd  dw 0
	; eof flag used by read_int_from_file
	eof_flag dw 0
	; columns of matrix 1

	mat1_cols dw 0
	; rows of matrix 1
	mat1_rows dw 0
	; columns of matrix 2
	mat2_cols dw 0
	; rows of matrix 2
	mat2_rows dw 0

	; prompt strings
	prompt_mat1 db "enter matrix one path: ", 0
	prompt_mat2 db "enter matrix two path: ", 0
	prompt_mat3 db "enter out matrix path: ", 0
	prompt_op   db "operations: +, -, *, d (determinant of matrix one to out matrix)", 13, 10, "enter operation : ", 0
	msg_equal   db " = ", 0
	msg_space   db " ", 0

	; operation identifiers for comparison
	str_add db "+", 0
	str_sub db "-", 0
	str_mul db "*", 0
	str_det db "d", 0

	; error messages
	error_file       db "error: file not found", 13, 10, 0
	error_dimensions db "error: invalid dimensions", 13, 10, 0
	error_operation  db "error: invalid operation", 13, 10, 0
DSEG ends

; start of code segment
CSEG segment readonly para public use16 "CODE"
; include all other headers
include <include/all.asm>

; read_line – reads a non‑empty line from stdin
read_line proc near
	; save bp
	push bp
	; set frame pointer
	mov bp, sp

_read_line_loop:
	; push buffer size
	push word ptr [bp + arg2]
	; push buffer address
	push word ptr [bp + arg1]
	; call gets (standard C library)
	call gets
	; clean stack
	add sp, 4
	; load buffer address
	mov bx, word ptr [bp + arg1]
	; if first character is null, string is empty
	cmp byte ptr [bx], 0
	; keep asking until non‑empty
	je _read_line_loop

	; restore sp
	mov sp, bp
	; restore bp
	pop bp
	; return
	ret
read_line endp

; mat_read – read a matrix from a file
mat_read proc near
	; save bp
	push bp
	; set frame pointer
	mov bp, sp
	; allocate space for file handle (word)
	sub sp, 2
	; save bx, cx, dx, di
	pushr bx, cx, dx, di

	; fopen (path, "r") – push mode 0
	push 0
	; push path pointer (arg1)
	push word ptr [bp + arg1]
	; call fopen
	call fopen
	; clean stack
	add sp, 4
	; check for error (-1)
	cmp ax, -1
	; if error, jump to error label
	je _mat_read_file_error
	; store file handle in local variable
	mov word ptr [bp + var1], ax

	; read rows – push eof flag address
	push offset eof_flag
	; push file handle
	push word ptr [bp + var1]
	; read first integer
	call read_int_from_file
	; clean stack
	add sp, 4
	; get pointer to rows output (arg3)
	mov bx, word ptr [bp + arg3]
	; store rows
	mov word ptr [bx], ax
	; copy rows to cx for later multiplication
	mov cx, ax

	; read columns
	push offset eof_flag
	push word ptr [bp + var1]
	call read_int_from_file
	add sp, 4
	; get pointer to cols output (arg4)
	mov bx, word ptr [bp + arg4]
	; store columns
	mov word ptr [bx], ax

	; calculate total elements = rows * cols
	mul cx
	; cx now holds total number of elements
	mov cx, ax

	; di = buffer address (arg2)
	mov di, word ptr [bp + arg2]

_mat_read_loop:
	; if counter reached zero, done reading
	cmp cx, 0
	je _mat_read_done

	; push eof flag address
	push offset eof_flag
	; push file handle
	push word ptr [bp + var1]
	; read next matrix element
	call read_int_from_file
	add sp, 4

	; store element in buffer
	mov word ptr [di], ax
	; advance buffer pointer (2 bytes per word)
	add di, 2
	; decrement remaining count
	dec cx
	; repeat loop
	jmp _mat_read_loop

_mat_read_done:
	; push file handle
	push word ptr [bp + var1]
	; close the file
	call fclose
	add sp, 2
	; return success (1)
	mov ax, 1
	; go to exit
	jmp _mat_read_exit

_mat_read_file_error:
	; return failure (0)
	mov ax, 0

_mat_read_exit:
	; restore registers
	popr di, dx, cx, bx
	; free local variable
	add sp, 2
	; restore sp
	mov sp, bp
	; restore bp
	pop bp
	ret
mat_read endp

; program entry point
start:
	; initialise segments and stack (macro)
	init

	; prompt for matrix 1 path
	push offset prompt_mat1
	call puts
	add sp, 2

	; read matrix 1 path (max 255)
	push 255
	push offset mat1_path
	call read_line
	add sp, 4

	; print a newline
	call crlf

	; read matrix 1 data
	push offset mat1_cols
	push offset mat1_rows
	push offset mat1_buf
	push offset mat1_path
	call mat_read
	add sp, 8
	; check for failure (ax == 0)
	cmp ax, 0
	je _exit_file_error

	; prompt for matrix 2 path
	push offset prompt_mat2
	call puts
	add sp, 2

	; read matrix 2 path
	push 255
	push offset mat2_path
	call read_line
	add sp, 4

	call crlf

	; read matrix 2 data
	push offset mat2_cols
	push offset mat2_rows
	push offset mat2_buf
	push offset mat2_path
	call mat_read
	add sp, 8
	cmp ax, 0
	je _exit_file_error

	; prompt for output file path
	push offset prompt_mat3
	call puts
	add sp, 2

	; read output file path
	push 255
	push offset mat3_path
	call read_line
	add sp, 4

	call crlf

	; create output file (DOS function 3Ch)
	mov dx, offset mat3_path
	mov cx, 0
	mov ah, 3Ch
	int 21h
	; if carry set, creation failed
	jc _exit_file_error
	; store file handle
	mov mat3_fd, ax

	; prompt for operation
	push offset prompt_op
	call puts
	add sp, 2

	; read operation string
	push 255
	push offset operation
	call read_line
	add sp, 4

	call crlf

	; check if operation is "d"
	push offset operation
	push offset str_det
	call strcmp
	add sp, 4
	test ax, ax
	jz _do_det

	; check if operation is "+"
	push offset operation
	push offset str_add
	call strcmp
	add sp, 4
	test ax, ax
	jz _do_add

	; check if operation is "-"
	push offset operation
	push offset str_sub
	call strcmp
	add sp, 4
	test ax, ax
	jz _do_sub

	; check if operation is "*"
	push offset operation
	push offset str_mul
	call strcmp
	add sp, 4
	test ax, ax
	jz _do_mul

	; none matched -> operation error
	jmp _exit_operation_error

_do_add:
	; verify rows equal
	mov ax, mat1_rows
	cmp ax, mat2_rows
	jne _exit_dimensions_error
	; verify columns equal
	mov ax, mat1_cols
	cmp ax, mat2_cols
	jne _exit_dimensions_error

	; push arguments for mat_add
	push mat3_fd
	push mat1_cols
	push mat1_rows
	push offset mat2_buf
	push offset mat1_buf
	call mat_add
	add sp, 10
	jmp _cleanup

_do_sub:
	; verify dimensions match
	mov ax, mat1_rows
	cmp ax, mat2_rows
	jne _exit_dimensions_error
	mov ax, mat1_cols
	cmp ax, mat2_cols
	jne _exit_dimensions_error

	; push arguments for mat_sub
	push mat3_fd
	push mat1_cols
	push mat1_rows
	push offset mat2_buf
	push offset mat1_buf
	call mat_sub
	add sp, 10
	jmp _cleanup

_do_mul:
	; check mat1_cols == mat2_rows
	mov ax, mat1_cols
	cmp ax, mat2_rows
	jne _exit_dimensions_error

	; push arguments for mat_mul
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
	; ensure matrix1 is square
	mov ax, mat1_rows
	cmp ax, mat1_cols
	jne _exit_dimensions_error
	; size must be at least 1
	cmp ax, 1
	jl _exit_dimensions_error
	; size must be at most 3
	cmp ax, 3
	jg _exit_dimensions_error

	; push arguments for mat_det
	push mat3_fd
	push mat1_rows
	push offset mat1_buf
	call mat_det
	add sp, 6
	jmp _cleanup

_cleanup:
	; close the output file
	push mat3_fd
	call fclose
	add sp, 2

_exit:
	; exit program with code 0 (macro)
	call exit_zero

_exit_file_error:
	; print file error message
	push offset error_file
	call puts
	add sp, 2
	; exit with code -1
	push -1
	call exit
	add sp, 2

_exit_dimensions_error:
	; print dimensions error
	push offset error_dimensions
	call puts
	add sp, 2
	; exit with code -2
	push -2
	call exit
	add sp, 2

_exit_operation_error:
	; print operation error
	push offset error_operation
	call puts
	add sp, 2
	; exit with code -3
	push -3
	call exit
	add sp, 2

code_end:
CSEG ends
end start
