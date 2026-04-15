; functions for working with an array of strings
; function for outputting the result of comparison of arrays of string segments
; void print_compare(int index_line, int index_symb)
_print_compare proc near
	push bp
	mov bp, sp
	
	push ax
	push dx

	mov dx, '('
	push dx
	call _putchar
	add sp, 2

	mov ax, [bp + arg1]
	push ax
	call _print_number
	add sp, 2
	
	mov dx, ';'
	push dx
	call _putchar
	add sp, 2
	
	mov ax, [bp + arg2]
	push ax
	call _print_number
	add sp, 2
	
	mov dx, ')'
	push dx
	call _putchar
	add sp, 2
	
	call _putnewline

print_compare_ret:
	pop dx
	pop ax
	mov sp, bp
	pop bp
	ret
_print_compare endp

; int compare_lines(const char* string1, const char* string2)
; compares strings, returns the index of the non-matching character
; ax = -1 if everything matches correctly
_compare_lines proc near
    push bp
    mov bp, sp
    
    push ds
    push es
    push si
    push di
    push cx
    
    mov ax, [bp + 4]
    mov ds, ax        ; string1
    
    mov ax, [bp + 6]
    mov es, ax        ; string2
    
    xor si, si
    xor di, di

compare_loop:
    mov al, ds:[si]
    mov cl, es:[di]

    cmp al, 0
    je check_end

    cmp al, cl
    jne find_discrepancy

    inc si
    inc di
    jmp compare_loop

check_end:
    cmp cl, 0
    je conformity
    jmp find_discrepancy

conformity:
    mov ax, -1
    jmp compare_lines_ret

find_discrepancy:
    mov ax, si

compare_lines_ret:
    pop cx
    pop di
    pop si
    pop es
    pop ds
    
    mov sp, bp
    pop bp
    ret
_compare_lines endp

; string segment array comparison function
; ВХОД: SI, DI - char** array_segments_strings
_compare_arrays proc near
    push bp
    mov bp, sp
    
    push ds
    push es
    push si
    push di
    push bx
    push cx

    ; DS = array1
    mov ax, [bp + arg1]
    mov ds, ax

    ; ES = array2
    mov ax, [bp + arg2]
    mov es, ax

    xor si, si
    xor di, di
    xor cx, cx

compare_arrays_loop:
    mov bx, [si]        ; str 1
    mov ax, es:[di]     ; str 2

    cmp bx, 0
    jne check_second
    cmp ax, 0
    je compare_equal     ; both are over
    jmp found_diff       ; only the first one ended

check_second:
    cmp ax, 0
    je found_diff        ; only the second one ended

    ; cmp
    push bx
    push ax
    call _compare_lines
    add sp, 4

    cmp ax, -1
    jne found_diff

    add si, 2
    add di, 2
    inc cx
    jmp compare_arrays_loop

found_diff:
    ; CX is the line number, AX is the character index
    push ax
    push cx
    call _print_compare
    add sp, 4
	
    jmp compare_arrays_ret

compare_equal:
    mov ax, -1

compare_arrays_ret:
    pop cx
    pop bx
    pop di
    pop si
    pop es
    pop ds

    mov sp, bp
    pop bp
    ret
_compare_arrays endp



_tests proc near
    push bp
    mov bp, sp
    push ds
    push es
    push bx
    push cx
    push dx
    push si
    push di

    ; filename1 -----
    push offset prompt1
    call _putstr
    add sp, 2

    push 19
    push offset filename1
    call _getstr
    add sp, 4

    push offset filename1
    call _read_file2buffer
    add sp, 2
    cmp ax, -1
    je error_open
    mov bx, ax                  ; bx = buffer 1

    push ax
    call _split_lines
    add sp, 2
    cmp ax, -1
    je error_split_lines
    mov si, ax                  ; si = array ptr-s 1

    ; filename2 -----
    push offset prompt2
    call _putstr
    add sp, 2

    push 19
    push offset filename2
    call _getstr
    add sp, 4

    push offset filename2
    call _read_file2buffer
    add sp, 2
    cmp ax, -1
    je error_open_file2
    mov dx, ax                  ; dx = buffer 2

    push ax
	call _split_lines
    add sp, 2
    cmp ax, -1
    je error_split_lines_file2
    mov di, ax                  ; di = array ptr-s 2

    ; cmp arrays -----
    push di                     ; array2
    push si                     ; array1
    call _compare_arrays
    add sp, 4
    cmp ax, -1
    jne compare_done
    push offset msg_equal
    call _putstr
    add sp, 2
    call _putnewline

compare_done:
    ; free -----
    push si
    call _free_lines
    add sp, 2

    push di
    call _free_lines
    add sp, 2

    push bx
    call FreeMem
    add sp, 2

    push dx
    call FreeMem
    add sp, 2

    xor ax, ax
    jmp tests_ret

error_open:
    push offset emsg_openfile
    call _putstr
    add sp, 2
    call _putnewline
    mov ax, -1
    jmp tests_ret

error_split_lines:
    push bx
    call FreeMem
    add sp, 2
    push offset emsg_splitlines
    call _putstr
    add sp, 2
    call _putnewline
    mov ax, ERROR_SPLITLINES
    jmp tests_ret

error_open_file2:
	cmp si, 0
	je skip_free_lines
    push si
    call _free_lines
    add sp, 2
	
skip_free_lines:
    push bx
    call FreeMem
    add sp, 2
    push offset emsg_openfile
    call _putstr
    add sp, 2
    call _putnewline
    mov ax, -1
    jmp tests_ret

error_split_lines_file2:
    push di
    call _free_lines
    add sp, 2
    push dx
    call FreeMem
    add sp, 2
    push offset emsg_splitlines
    call _putstr
    add sp, 2
    call _putnewline
    mov ax, ERROR_SPLITLINES
    jmp tests_ret

tests_ret:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop es
    pop ds
    mov sp, bp
    pop bp
    ret
_tests endp



