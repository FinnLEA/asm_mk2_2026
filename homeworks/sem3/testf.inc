; testing string functions

_test_strlen proc near
    push bp
    mov bp, sp
	
    lea dx, msg_t_strlen
    push dx
    call _putstr
    add sp, 2
	
    mov ax, offset t_hello
    push ax
    call _strlen
    add sp, 2
    cmp ax, 13
    je strlen_ok
	
    lea dx, msg_fail
    push dx
    call _putstr
    add sp, 2
    mov ax, -1
    jmp strlen_done
strlen_ok:
    lea dx, msg_ok
    push dx
    call _putstr
    add sp, 2
    xor ax, ax
strlen_done:
    call _putnewline
    pop bp
    ret
_test_strlen endp

_test_strchr proc near
    push bp
    mov bp, sp
	
    lea dx, msg_t_strchr
    push dx
    call _putstr
    add sp, 2
	
    mov ax, 'e'
    push ax
    mov ax, offset t_hello
    push ax
    call _strchr
    add sp, 4
    cmp ax, 0
    je strchr_fail
	
    lea dx, msg_ok
    push dx
    call _putstr
    add sp, 2
    xor ax, ax
    jmp strchr_done
strchr_fail:
    lea dx, msg_fail
    push dx
    call _putstr
    add sp, 2
    mov ax, -1
strchr_done:
    call _putnewline
    pop bp
    ret
_test_strchr endp

_test_strcpy proc near
    push bp
    mov bp, sp
    lea dx, msg_t_strcpy
    push dx
    call _putstr
    add sp, 2
	
    mov ax, offset t_hello
    push ax
    mov ax, offset t_buf1
    push ax
    call _strcpy
    add sp, 4
	
    mov ax, offset t_buf1
    push ax
    mov ax, offset t_hello
    push ax
    call _strcmp
    add sp, 4
    cmp ax, 0
    je strcpy_ok
	
    lea dx, msg_fail
    push dx
    call _putstr
    add sp, 2
    mov ax, -1
    jmp strcpy_done
strcpy_ok:
    lea dx, msg_ok
    push dx
    call _putstr
    add sp, 2
    xor ax, ax
strcpy_done:
    call _putnewline
    pop bp
    ret
_test_strcpy endp

_test_strcat proc near
    push bp
    mov bp, sp
	
    lea dx, msg_t_strcat
    push dx
    call _putstr
    add sp, 2
	
    mov ax, offset t_hello
    push ax
    mov ax, offset t_buf2
    push ax
    call _strcpy
    add sp, 4
	
    mov ax, offset t_world
    push ax
    mov ax, offset t_buf2
    push ax
    call _strcat
    add sp, 4
	
    mov ax, offset t_buf2
    push ax
    mov ax, offset t_helloworld
    push ax
    call _strcmp
    add sp, 4
    cmp ax, 0
    je strcat_ok
	
    lea dx, msg_fail
    push dx
    call _putstr
    add sp, 2
    mov ax, -1
    jmp strcat_done
strcat_ok:
    lea dx, msg_ok
    push dx
    call _putstr
    add sp, 2
    xor ax, ax
strcat_done:
    call _putnewline
    pop bp
    ret
_test_strcat endp

_test_strcmp proc near
    push bp
    mov bp, sp
	
    lea dx, msg_t_strcmp
    push dx
    call _putstr
    add sp, 2
	
    mov ax, offset t_world
    push ax
    mov ax, offset t_hello
    push ax
    call _strcmp
    add sp, 4
    cmp ax, 0
    jne strcmp_ok      
	
    lea dx, msg_fail
    push dx
    call _putstr
    add sp, 2
    mov ax, -1
    jmp strcmp_done
strcmp_ok:
    lea dx, msg_ok
    push dx
    call _putstr
    add sp, 2
    xor ax, ax
strcmp_done:
    call _putnewline
    pop bp
    ret
_test_strcmp endp

_test_stricmp proc near
    push bp
    mov bp, sp
	
    lea dx, msg_t_stricmp
    push dx
    call _putstr
    add sp, 2
	
    mov ax, offset t_HELLO_UPPER
    push ax
    mov ax, offset t_hello
    push ax
    call _stricmp
    add sp, 4
    cmp ax, 0
    je stricmp_ok
	
    lea dx, msg_fail
    push dx
    call _putstr
    add sp, 2
    mov ax, -1
    jmp stricmp_done
stricmp_ok:
    lea dx, msg_ok
    push dx
    call _putstr
    add sp, 2
    xor ax, ax
stricmp_done:
    call _putnewline
    pop bp
    ret
_test_stricmp endp

_test_strstr proc near
    push bp
    mov bp, sp
	
    lea dx, msg_t_strstr
    push dx
    call _putstr
    add sp, 2
	
    mov ax, offset t_world
    push ax
    mov ax, offset t_hello_w
    push ax
    call _strstr
    add sp, 4
    cmp ax, 0
    je strstr_fail
	
    lea dx, msg_ok
    push dx
    call _putstr
    add sp, 2
    xor ax, ax
    jmp strstr_done
strstr_fail:
    lea dx, msg_fail
    push dx
    call _putstr
    add sp, 2
    mov ax, -1
strstr_done:
    call _putnewline
    pop bp
    ret
_test_strstr endp

_test_strtol proc near
    push bp
    mov bp, sp
	
    lea dx, msg_t_strtol
    push dx
    call _putstr
    add sp, 2
	
    mov ax, 0
    push ax
    mov ax, 10
    push ax
    mov ax, offset t_num_dec
    push ax
    call _strtol
    add sp, 6
    cmp ax, -123
    je strtol_ok
	
    lea dx, msg_fail
    push dx
    call _putstr
    add sp, 2
    mov ax, -1
    jmp strtol_done
strtol_ok:
    lea dx, msg_ok
    push dx
    call _putstr
    add sp, 2
    xor ax, ax
strtol_done:
    call _putnewline
    pop bp
    ret
_test_strtol endp

_test_strdup proc near
    push bp
    mov bp, sp
    lea dx, msg_t_strdup
    push dx
    call _putstr
    add sp, 2
	
    mov ax, offset t_hello
    push ax
    call _strdup
    add sp, 2
    cmp ax, -1
    je strdup_fail
	
    push ax
    call FreeMem
    add sp, 2
    lea dx, msg_ok
    push dx
    call _putstr
    add sp, 2
    xor ax, ax
    jmp strdup_done
strdup_fail:
    lea dx, msg_fail
    push dx
    call _putstr
    add sp, 2
    mov ax, -1
strdup_done:
    call _putnewline
    pop bp
    ret
_test_strdup endp

; ------------------------------------------------------------
; RUNNING ALL TESTS
run_string_tests proc near
    push bp
    mov bp, sp

    call _putnewline
    lea dx, msg_sep
    push dx
    call _putstr
    add sp, 2
	
    call _putnewline

    call _test_strlen
    call _test_strchr
    call _test_strcpy
    call _test_strcat
    call _test_strcmp
    call _test_stricmp
    call _test_strtol
	call _test_strstr
    call _test_strdup

    lea dx, msg_sep
    push dx
    call _putstr
    add sp, 2
	
    call _putnewline
    lea dx, msg_test_end
    push dx
    call _putstr
    add sp, 2
	
    call _putnewline

    pop bp
    ret
run_string_tests endp