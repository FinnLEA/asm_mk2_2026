print_result proc near
	push bp
	mov bp, sp

	push word ptr [bp + arg1]
	call puts
	add sp, 2

	cmp word ptr [bp + arg2], 0
	je _print_ok

	push offset msg_fail
	call puts
	add sp, 2
	jmp _print_newline

_print_ok:
	push offset msg_ok
	call puts
	add sp, 2

_print_newline:
	call crlf

	pop bp
	ret
print_result endp

strlen_test proc near
	push offset test_str1
	call strlen
	add sp, 2
	cmp ax, 5
	jne _strlen_fail

	push offset test_null
	call strlen
	add sp, 2
	cmp ax, 0
	jne _strlen_fail

	xor ax, ax
	jmp _strlen_done

_strlen_fail:
	mov ax, 1

_strlen_done:
	push ax
	push offset msg_strlen
	call print_result
	add sp, 4
	ret
strlen_test endp

strcpy_test proc near
	push offset test_str1
	push offset test_buf
	call strcpy
	add sp, 4

	push offset test_str1
	push offset test_buf
	call strcmp
	add sp, 4
	cmp ax, 0
	jne _strcpy_fail

	xor ax, ax
	jmp _strcpy_done

_strcpy_fail:
	mov ax, 1

_strcpy_done:
	push ax
	push offset msg_strcpy
	call print_result
	add sp, 4
	ret
strcpy_test endp

strcat_test proc near
	push offset test_str1
	push offset test_buf
	call strcpy
	add sp, 4

	push offset test_str2
	push offset test_buf
	call strcat
	add sp, 4

	push offset test_str3
	push offset test_buf
	call strcmp
	add sp, 4
	cmp ax, 0
	jne _strcat_fail

	xor ax, ax
	jmp _strcat_done

_strcat_fail:
	mov ax, 1

_strcat_done:
	push ax
	push offset msg_strcat
	call print_result
	add sp, 4
	ret
strcat_test endp

strcmp_test proc near
	push offset test_str1
	push offset test_str1
	call strcmp
	add sp, 4
	cmp ax, 0
	jne _strcmp_fail

	push offset test_str2
	push offset test_str1
	call strcmp
	add sp, 4
	cmp ax, 0
	je _strcmp_fail

	xor ax, ax
	jmp _strcmp_done

_strcmp_fail:
	mov ax, 1

_strcmp_done:
	push ax
	push offset msg_strcmp
	call print_result
	add sp, 4
	ret
strcmp_test endp

stricmp_test proc near
	push offset test_str5
	push offset test_str4
	call stricmp
	add sp, 4
	cmp ax, 0
	jne _stricmp_fail

	push offset test_str2
	push offset test_str1
	call stricmp
	add sp, 4
	cmp ax, 0
	je _stricmp_fail

	xor ax, ax
	jmp _stricmp_done

_stricmp_fail:
	mov ax, 1

_stricmp_done:
	push ax
	push offset msg_stricmp
	call print_result
	add sp, 4
	ret
stricmp_test endp

strchr_test proc near
	push 'e'
	push offset test_str1
	call strchr
	add sp, 4
	cmp ax, 0
	je _strchr_fail
	mov bx, ax
	cmp byte ptr [bx], 'e'
	jne _strchr_fail

	push 'z'
	push offset test_str1
	call strchr
	add sp, 4
	cmp ax, 0
	jne _strchr_fail

	xor ax, ax
	jmp _strchr_done

_strchr_fail:
	mov ax, 1

_strchr_done:
	push ax
	push offset msg_strchr
	call print_result
	add sp, 4
	ret
strchr_test endp

strstr_test proc near
	push offset test_str7
	push offset test_str6
	call strstr
	add sp, 4
	cmp ax, 0
	je _strstr_fail

	push offset test_str2
	push offset test_str6
	call strstr
	add sp, 4
	cmp ax, 0
	jne _strstr_fail

	xor ax, ax
	jmp _strstr_done

_strstr_fail:
	mov ax, 1

_strstr_done:
	push ax
	push offset msg_strstr
	call print_result
	add sp, 4
	ret
strstr_test endp

strtol_test proc near
	local endptr:word

	push bp
	mov bp, sp
	sub sp, 2

	push 10
	lea ax, [bp - 2]
	push ax
	push offset test_str8
	call strtol
	add sp, 6
	cmp ax, 12345
	jne _strtol_fail

	push 10
	lea ax, [bp - 2]
	push ax
	push offset test_str9
	call strtol
	add sp, 6
	cmp ax, -123
	jne _strtol_fail

	xor ax, ax
	jmp _strtol_done

_strtol_fail:
	mov ax, 1

_strtol_done:
	push ax
	push offset msg_strtol
	call print_result
	add sp, 4
	mov sp, bp
	pop bp
	ret
strtol_test endp

strdup_test proc near
	push offset test_str1
	call strdup
	add sp, 2
	cmp ax, 0
	je _strdup_fail

	push es
	mov es, ax
	mov bx, 0
	mov al, byte ptr es:[bx]
	cmp al, 'H'
	jne _strdup_fail_pop

	push es
	call mem_free
	add sp, 2
	pop es

	xor ax, ax
	jmp _strdup_done

_strdup_fail_pop:
	pop es

_strdup_fail:
	mov ax, 1

_strdup_done:
	push ax
	push offset msg_strdup
	call print_result
	add sp, 4
	ret
strdup_test endp

puts_test proc near
	push offset test_str1
	call puts
	add sp, 2
	xor ax, ax
	push ax
	push offset msg_puts
	call crlf
	call print_result
	add sp, 4
	ret
puts_test endp

crlf_test proc near
	call crlf
	xor ax, ax
	push ax
	push offset msg_crlf
	call print_result
	add sp, 4
	ret
crlf_test endp

strtol_advanced_test proc near
	push bp
	mov bp, sp

	push 16
	push offset endptr_storage
	push offset test_hex1
	call strtol
	add sp, 6
	cmp ax, 42
	jne _strtol_adv_fail

	push 0
	push offset endptr_storage
	push offset test_decimal
	call strtol
	add sp, 6
	cmp ax, 123
	jne _strtol_adv_fail

	push 8
	push offset endptr_storage
	push offset test_octal
	call strtol
	add sp, 6
	cmp ax, 63
	jne _strtol_adv_fail

	push 10
	push offset endptr_storage
	push offset test_invalid
	call strtol
	add sp, 6
	cmp ax, 42
	jne _strtol_adv_fail

	xor ax, ax
	jmp _strtol_adv_done

_strtol_adv_fail:
	mov ax, 1

_strtol_adv_done:
	push ax
	push offset msg_strtol_adv
	call print_result
	add sp, 4
	mov sp, bp
	pop bp
	ret
strtol_advanced_test endp

strchr_null_test proc near
	push 0
	push offset test_str1
	call strchr
	add sp, 4
	mov bx, ax
	cmp byte ptr [bx], 0
	jne _strchr_null_fail

	xor ax, ax
	jmp _strchr_null_done

_strchr_null_fail:
	mov ax, 1

_strchr_null_done:
	push ax
	push offset msg_strchr_null
	call print_result
	add sp, 4
	ret
strchr_null_test endp

strstr_empty_test proc near
	push offset test_empty
	push offset test_str6
	call strstr
	add sp, 4
	cmp ax, offset test_str6
	jne _strstr_empty_fail

	xor ax, ax
	jmp _strstr_empty_done

_strstr_empty_fail:
	mov ax, 1

_strstr_empty_done:
	push ax
	push offset msg_strstr_empty
	call print_result
	add sp, 4
	ret
strstr_empty_test endp

strcat_empty_test proc near
	push offset test_str1
	push offset test_buf
	call strcpy
	add sp, 4

	push offset test_empty
	push offset test_buf
	call strcat
	add sp, 4

	push offset test_str1
	push offset test_buf
	call strcmp
	add sp, 4
	cmp ax, 0
	jne _strcat_empty_fail

	xor ax, ax
	jmp _strcat_empty_done

_strcat_empty_fail:
	mov ax, 1

_strcat_empty_done:
	push ax
	push offset msg_strcat_empty
	call print_result
	add sp, 4
	ret
strcat_empty_test endp

stricmp_case_test proc near
	push offset test_mixed1
	push offset test_mixed2
	call stricmp
	add sp, 4
	cmp ax, 0
	jne _stricmp_case_fail

	xor ax, ax
	jmp _stricmp_case_done

_stricmp_case_fail:
	mov ax, 1

_stricmp_case_done:
	push ax
	push offset msg_stricmp_case
	call print_result
	add sp, 4
	ret
stricmp_case_test endp

mem_alloc_test proc near
	push 256
	call mem_alloc
	add sp, 2
	cmp ax, 0
	je _mem_alloc_fail
	mov bx, ax

	push 0
	call mem_alloc
	add sp, 2
	cmp ax, 0
	jne _mem_alloc_fail

	push bx
	call mem_free
	add sp, 2

	xor ax, ax
	jmp _mem_alloc_done

_mem_alloc_fail:
	mov ax, 1

_mem_alloc_done:
	push ax
	push offset msg_mem_alloc
	call print_result
	add sp, 4
	ret
mem_alloc_test endp

mem_free_test proc near
	push 128
	call mem_alloc
	add sp, 2
	cmp ax, 0
	je _mem_free_fail
	mov bx, ax

	push bx
	call mem_free
	add sp, 2
	cmp ax, 1
	jne _mem_free_fail

	push 0
	call mem_free
	add sp, 2
	cmp ax, 0
	jne _mem_free_fail

	xor ax, ax
	jmp _mem_free_done

_mem_free_fail:
	mov ax, 1

_mem_free_done:
	push ax
	push offset msg_mem_free
	call print_result
	add sp, 4
	ret
mem_free_test endp

mem_realloc_test proc near
	push 4096
	call mem_alloc
	add sp, 2
	cmp ax, 0
	je _mem_realloc_fail
	mov bx, ax

	push 4096
	push bx
	call mem_realloc
	add sp, 4
	cmp ax, 1
	jne _mem_realloc_fail

	push 100
	push 0
	call mem_realloc
	add sp, 4
	cmp ax, 0
	jne _mem_realloc_fail

	push bx
	call mem_free
	add sp, 2

	xor ax, ax
	jmp _mem_realloc_done

_mem_realloc_fail:
	mov ax, 1

_mem_realloc_done:
	push ax
	push offset msg_mem_realloc
	call print_result
	add sp, 4
	ret
mem_realloc_test endp

do_test proc near
	push bp
	mov bp, sp

	push offset msg_test_header
	call puts
	add sp, 2

	call crlf_test
	call puts_test
	call strlen_test
	call strcpy_test
	call strcat_test
	call strcmp_test
	call stricmp_test
	call strchr_test
	call strstr_test
	call strtol_test
	call strdup_test

	call strtol_advanced_test
	call strchr_null_test
	call strstr_empty_test
	call strcat_empty_test
	call stricmp_case_test
	call mem_alloc_test
	call mem_free_test
	call mem_realloc_test

	call crlf

	mov sp, bp
	pop bp
	ret
do_test endp
