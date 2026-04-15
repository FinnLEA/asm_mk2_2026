print_num proc near
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx

	mov ax, [bp + arg1]
	mov cx, 0
	mov bx, 10

_pn_div_loop:
	xor dx, dx
	div bx
	push dx
	inc cx
	test ax, ax
	jnz _pn_div_loop

_pn_print_loop:
	pop dx
	add dl, '0'
	push dx
	call putchar
	add sp, 2
	loop _pn_print_loop

	pop dx
	pop cx
	pop bx
	pop ax
	mov sp, bp
	pop bp
	ret
print_num endp

split_text proc near
	; arg1 [bp + arg1] = text segment
	; arg2 [bp + arg2] = text size
	; arg3 [bp + arg3] = ptr to line count var (offset in SS)
	push bp
	mov bp, sp
	sub sp, 10
	; var_lines     = -2
	; var_array_seg = -4
	; var_start_idx = -6
	; var_line_idx  = -8
	; var_curr_idx  = -10

	; count lines
	mov cx, [bp + arg2]
	cmp cx, 0
	jne _st_count_init
	mov word ptr [bp-2], 0
	jmp _st_alloc_array

_st_count_init:
	mov word ptr [bp-2], 1
	push ds
	mov ds, [bp + arg1]
	xor bx, bx

_st_count_loop:
	cmp bx, cx
	jae _st_count_done
	mov al, byte ptr ds:[bx]
	cmp al, 10
	jne _st_count_next
	inc word ptr [bp-2]

_st_count_next:
	inc bx
	jmp _st_count_loop

_st_count_done:
	pop ds

_st_alloc_array:
	; allocate array of segments (lines * 2 bytes)
	mov ax, [bp-2]
	shl ax, 1
	push ax
	call mem_alloc
	add sp, 2
	mov [bp-4], ax

	; exit if allocation fails
	cmp ax, 0
	jz _st_exit

	; if text is empty, exit
	mov cx, [bp + arg2]
	cmp cx, 0
	je _st_exit

	; populate string array
	mov word ptr [bp-6], 0
	mov word ptr [bp-8], 0
	mov word ptr [bp-10], 0

_st_pop_loop:
	mov cx, [bp + arg2]
	mov bx, [bp-10]
	cmp bx, cx
	jg _st_exit
	je _st_process_line

	push ds
	mov ds, [bp + arg1]
	mov al, byte ptr ds:[bx]
	pop ds

	cmp al, 10
	jne _st_pop_next

_st_process_line:
	; length = current_idx - start_idx
	mov ax, [bp-10]
	sub ax, [bp-6]

	; optionally ignore '\r'
	cmp ax, 0
	jle _st_alloc_str
	push ds
	mov ds, [bp + arg1]
	mov di, [bp-10]
	dec di
	mov dl, byte ptr ds:[di]
	pop ds
	cmp dl, 13
	jne _st_alloc_str
	dec ax

_st_alloc_str:
	; ax = string length
	push ax
	inc ax
	push ax
	call mem_alloc
	add sp, 2
	pop cx

	; protect against mem_alloc failure
	cmp ax, 0
	jz _st_store_zero_seg

	; ax = new string segment
	push ds
	push es
	mov es, ax
	mov ds, [bp + arg1]
	mov si, [bp-6]
	xor di, di

	; cx is length to copy
	jcxz _st_copy_done

_st_copy_loop:
	mov dl, byte ptr ds:[si]
	mov byte ptr es:[di], dl
	inc si
	inc di
	loop _st_copy_loop

_st_copy_done:
	mov byte ptr es:[di], 0
	pop es
	pop ds
	jmp _st_store_seg

_st_store_zero_seg:
	xor ax, ax

_st_store_seg:
	; store segment address into our array
	push ds
	mov ds, [bp-4]
	mov di, [bp-8]
	shl di, 1
	mov word ptr ds:[di], ax
	pop ds

	; update pointers
	mov ax, [bp-10]
	inc ax
	mov [bp-6], ax ; next line starts at curr+1
	inc word ptr [bp-8]

_st_pop_next:
	inc word ptr [bp-10]
	jmp _st_pop_loop

_st_exit:
	; write line count to out-pointer
	mov di, [bp + arg3]
	mov ax, [bp-2]
	mov word ptr ss:[di], ax

	; return array segment in AX
	mov ax, [bp-4]
	add sp, 10
	mov sp, bp
	pop bp
	ret
split_text endp

compare_arrays proc near
	; arg1 [bp + arg1] = array1 seg
	; arg2 [bp + arg2] = lines1
	; arg3 [bp + arg3] = array2 seg
	; arg4 [bp + arg4] = lines2
	push bp
	mov bp, sp
	sub sp, 6
	; var_min_lines = -2
	; var_line_idx  = -4
	; var_char_idx  = -6

	mov ax, [bp + arg2]
	mov bx, [bp + arg4]
	cmp ax, bx
	jle _ca_set_min
	mov ax, bx

_ca_set_min:
	mov [bp-2], ax
	mov word ptr [bp-4], 0

_ca_line_loop:
	mov ax, [bp-4]
	cmp ax, [bp-2]
	jge _ca_check_extra

	; read seg1
	mov ax, [bp + arg1]
	cmp ax, 0
	je _ca_set_cx_zero
	push ds
	mov ds, ax
	mov bx, [bp-4]
	shl bx, 1
	mov cx, word ptr ds:[bx]
	pop ds
	jmp _ca_read_seg2

_ca_set_cx_zero:
	xor cx, cx

_ca_read_seg2:
	; read seg2
	mov ax, [bp + arg3]
	cmp ax, 0
	je _ca_set_dx_zero
	push ds
	mov ds, ax
	mov bx, [bp-4]
	shl bx, 1
	mov dx, word ptr ds:[bx]
	pop ds
	jmp _ca_char_loop_init

_ca_set_dx_zero:
	xor dx, dx

_ca_char_loop_init:
	mov word ptr [bp-6], 0

_ca_char_loop:
	mov bx, [bp-6]

	; read from string 1
	cmp cx, 0
	je _ca_char1_zero
	push ds
	mov ds, cx
	mov al, byte ptr ds:[bx]
	pop ds
	jmp _ca_char2_read

_ca_char1_zero:
	mov al, 0

_ca_char2_read:
	; read from string 2
	cmp dx, 0
	je _ca_char2_zero
	push ds
	mov ds, dx
	mov ah, byte ptr ds:[bx]
	pop ds
	jmp _ca_char_cmp

_ca_char2_zero:
	mov ah, 0

_ca_char_cmp:
	cmp al, ah
	jne _ca_mismatch_found

	cmp al, 0
	je _ca_line_match

	inc word ptr [bp-6]
	jmp _ca_char_loop

_ca_line_match:
	inc word ptr [bp-4]
	jmp _ca_line_loop

_ca_check_extra:
	; check if one array has more lines than the other
	mov ax, [bp + arg2]
	cmp ax, [bp + arg4]
	je _ca_identical

	; line count differs
	mov word ptr [bp-6], 0
	jmp _ca_mismatch_found

_ca_identical:
	push offset msg_identical
	call puts
	add sp, 2
	call crlf
	jmp _ca_exit

_ca_mismatch_found:
	push '('
	call putchar
	add sp, 2

	push [bp-4]
	call print_num
	add sp, 2

	push ';'
	call putchar
	add sp, 2
	push ' '
	call putchar
	add sp, 2

	push [bp-6]
	call print_num
	add sp, 2

	push ')'
	call putchar
	add sp, 2
	call crlf

_ca_exit:
	add sp, 6
	mov sp, bp
	pop bp
	ret
compare_arrays endp

do_task proc near
	var_seg_filename1  = -2
	var_seg_filename2  = -4
	var_file1_handle   = -6
	var_file2_handle   = -8
	var_file1_size     = -10
	var_file2_size     = -12
	var_seg_file1_data = -14
	var_seg_file2_data = -16
	var_lines1_count   = -18
	var_lines2_count   = -20
	var_seg_array1     = -22
	var_seg_array2     = -24

	push bp
	mov bp, sp
	sub sp, 24

	; header
	push offset msg_task_header
	call puts
	add sp, 2
	call crlf

	; alloc for file1 name
	push 256
	call mem_alloc
	add sp, 2
	cmp ax, 0
	jz alloc_error
	mov [bp + var_seg_filename1], ax

	; print prompt 1
	push offset msg_prompt1
	call puts
	add sp, 2

	; read file1 name
	push ds
	mov ds, [bp + var_seg_filename1]
	push 256
	push 0
	call gets
	add sp, 4
	pop ds
	call crlf

	; alloc for file2 name
	push 256
	call mem_alloc
	add sp, 2
	cmp ax, 0
	jz alloc_error
	mov [bp + var_seg_filename2], ax

	; print prompt 2
	push offset msg_prompt2
	call puts
	add sp, 2

	; read file2 name
	push ds
	mov ds, [bp + var_seg_filename2]
	push 256
	push 0
	call gets
	add sp, 4
	pop ds
	call crlf

	; open file1
	push ds
	mov ds, [bp + var_seg_filename1]
	push 0
	push 0
	call fopen
	add sp, 4
	pop ds
	cmp ax, -1
	jz fopen_error
	mov [bp + var_file1_handle], ax

	; open file2
	push ds
	mov ds, [bp + var_seg_filename2]
	push 0
	push 0
	call fopen
	add sp, 4
	pop ds
	cmp ax, -1
	jz fopen_error
	mov [bp + var_file2_handle], ax

	; get file sizes
	push [bp + var_file1_handle]
	call fsize
	add sp, 2
	mov [bp + var_file1_size], ax

	push [bp + var_file2_handle]
	call fsize
	add sp, 2
	mov [bp + var_file2_size], ax

	; alloc for file1 data
	mov ax, [bp + var_file1_size]
	inc ax
	push ax
	call mem_alloc
	add sp, 2
	cmp ax, 0
	jz alloc_error
	mov [bp + var_seg_file1_data], ax

	; alloc for file2 data
	mov ax, [bp + var_file2_size]
	inc ax
	push ax
	call mem_alloc
	add sp, 2
	cmp ax, 0
	jz alloc_error
	mov [bp + var_seg_file2_data], ax

	; read file1
	push ds
	mov ds, [bp + var_seg_file1_data]
	push [bp + var_file1_size]
	push 0
	push [bp + var_file1_handle]
	call fread
	add sp, 6
	mov bx, [bp + var_file1_size]
	mov byte ptr ds:[bx], 0
	pop ds

	; read file2
	push ds
	mov ds, [bp + var_seg_file2_data]
	push [bp + var_file2_size]
	push 0
	push [bp + var_file2_handle]
	call fread
	add sp, 6
	mov bx, [bp + var_file2_size]
	mov byte ptr ds:[bx], 0
	pop ds

	; TODO: maybe bugs here
	; split into lines arrays
	lea ax, [bp + var_lines1_count]
	push ax
	push [bp + var_file1_size]
	push [bp + var_seg_file1_data]
	call split_text
	add sp, 6
	mov [bp + var_seg_array1], ax

	lea ax, [bp + var_lines2_count]
	push ax
	push [bp + var_file2_size]
	push [bp + var_seg_file2_data]
	call split_text
	add sp, 6
	mov [bp + var_seg_array2], ax

	; perform array comparison
	push [bp + var_lines2_count]
	push [bp + var_seg_array2]
	push [bp + var_lines1_count]
	push [bp + var_seg_array1]
	call compare_arrays
	add sp, 8

close_file2_handle:
	push [bp + var_file2_handle]
	call fclose
	add sp, 2

close_file1_handle:
	push [bp + var_file1_handle]
	call fclose
	add sp, 2

do_task_exit:
	; free filename buffers
	push [bp + var_seg_filename2]
	call mem_free
	add sp, 2
	push [bp + var_seg_filename1]
	call mem_free
	add sp, 2

	call crlf
	add sp, 24
	mov sp, bp
	pop bp
	ret

alloc_error:
	push offset msg_alloc_err
	call puts
	add sp, 2
	jmp do_task_exit

fopen_error:
	push offset msg_open_err
	call puts
	add sp, 2
	jmp do_task_exit
do_task endp
