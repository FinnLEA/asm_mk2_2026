do_task proc near
	var_ptr_filename1  = -2
	var_ptr_filename2  = -4
	var_file1_handle   = -6
	var_file2_handle   = -8
	var_file1_size     = -10
	var_file2_size     = -12
	var_ptr_file1_data = -14
	var_ptr_file2_data = -16

	push bp
	mov bp, sp
	sub sp, 32

	; header
	push offset msg_task_header
	call puts
	add sp, 2
	call crlf

	; alloc for file1 name
	push 256
	call mem_alloc
	add sp, 2
	mov [bp + var_ptr_filename1], ax

	; print prompt 1
	push offset msg_prompt1
	call puts
	add sp, 2

	; read file1 name (enter full path 'C:\file1')
	push 256
	push [bp + var_ptr_filename1]
	call gets
	add sp, 4
	call crlf

	; alloc for file2 name
	push 256
	call mem_alloc
	add sp, 2
	mov [bp + var_ptr_filename2], ax

	; print prompt 2
	push offset msg_prompt2
	call puts
	add sp, 2

	; read file2 name (enter full path 'C:\file2')
	push 256
	push [bp + var_ptr_filename2]
	call gets
	add sp, 4
	call crlf

	; open file1
	mov si, word ptr [bp + var_ptr_filename1]
	push 0
	push si
	call fopen
	add sp, 4
	cmp ax, -1
	jz fopen_error
	mov [bp + var_file1_handle], ax

	; open file2
	mov si, word ptr [bp + var_ptr_filename2]
	push 0
	push si
	call fopen
	add sp, 4
	cmp ax, -1
	jz fopen_error
	mov [bp + var_file2_handle], ax

	; get file1 size
	push [bp + var_file1_handle]
	call fsize
	add sp, 2
	mov [bp + var_file1_size], ax

	; get file1 size
	push [bp + var_file2_handle]
	call fsize
	add sp, 2
	mov [bp + var_file2_size], ax

	; alloc for file1 data (with extra byte for null)
	push [bp + var_file1_size]
	inc  word ptr [bp + var_file1_size]
	push [bp + var_file1_size]
	call mem_alloc
	add  sp, 2
	dec  word ptr [bp + var_file1_size]
	mov  [bp + var_ptr_file1_data], ax

	; alloc for file2 data (with extra byte for null)
	push [bp + var_file2_size]
	inc  word ptr [bp + var_file2_size]
	push [bp + var_file2_size]
	call mem_alloc
	add  sp, 2
	dec  word ptr [bp + var_file2_size]
	mov  [bp + var_ptr_file2_data], ax

	; read file1
	push ds
	mov  ds, [bp + var_ptr_file1_data]
	push [bp + var_file1_size]
	push 0
	push [bp + var_file1_handle]
	call fread
	add  sp, 6
	pop  ds

	; read file2
	push ds
	mov  ds, [bp + var_ptr_file2_data]
	push [bp + var_file2_size]
	push 0
	push [bp + var_file2_handle]
	call fread
	add  sp, 6
	pop  ds

	; print file1
	push ds
	mov  ds, [bp + var_ptr_file1_data]
	push 0
	call puts
	add  sp, 2
	pop  ds

	; print file2
	push ds
	mov  ds, [bp + var_ptr_file2_data]
	push 0
	call puts
	add  sp, 2
	pop  ds

	int 3h
	; TODO: do task
	; code here

close_file2_handle:
	push [bp + var_file2_handle]
	call fclose
	add sp, 2

close_file1_handle:
	push [bp + var_file1_handle]
	call fclose
	add sp, 2

free_var_ptr_filename2:
	push [bp + var_ptr_filename2]
	call mem_free
	add sp, 2

free_var_ptr_filename1:
	push [bp + var_ptr_filename1]
	call mem_free
	add sp, 2

do_task_exit:
	call crlf

	add sp, 32
	mov sp, bp
	pop bp
	ret

fopen_error:
	push offset msg_open_err
	call puts
	add sp, 2
	jmp do_task_exit
do_task endp
