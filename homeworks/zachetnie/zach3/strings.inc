; ============================================================================
; strings.inc - СИ-совместимые строковые функции + ввод/вывод
; Соглашение: cdecl (функции заканчиваются на ret, стек чистит вызывающий)
; ============================================================================

_putchar proc near
    push bp
    mov bp, sp
    mov dx, word ptr [bp + arg1]
    mov ah, 02h
    int 21h
    mov sp, bp
    pop bp
    ret
_putchar endp

_getchar proc near
    push bp
    mov bp, sp
    mov ah, 01h
    int 21h
    mov sp, bp
    pop bp
    ret
_getchar endp

_strlen proc near
    push bp
    mov bp, sp
    mov bx, word ptr [bp + arg1] 
    xor ax, ax
strlen_loop:
    cmp byte ptr [bx], 0
    je strlen_done
    inc ax
    inc bx
    jmp strlen_loop
strlen_done:
    mov sp, bp
    pop bp
    ret
_strlen endp

_putstr proc near
    push bp
    mov bp, sp
    push word ptr [bp + arg1] 
    call _strlen
    add sp, 2
    mov cx, ax
    mov dx, word ptr [bp + arg1]
    mov ah, 40h
    mov bx, 1
    int 21h
    mov sp, bp
    pop bp
    ret
_putstr endp

_getstr proc near
    push bp
    mov bp, sp
    dec word ptr [bp + arg2]
    mov bx, word ptr [bp + arg1]
    xor si, si
getstr_loop:
    cmp si, word ptr [bp + arg2]
    je getstr_done
    call _getchar
    cmp al, 10
    je getstr_done
    cmp al, 13
    je getstr_done
    mov byte ptr [bx], al
    inc bx
    inc si
    jmp getstr_loop
getstr_done:
    mov byte ptr [bx], 0
    call _putnewline
    mov sp, bp
    pop bp
    ret
_getstr endp

_putnewline proc near
    push bp
    mov bp, sp
    mov dx, 10
    push dx
    call _putchar
    add sp, 2
    mov dx, 13
    push dx
    call _putchar
    add sp, 2
    mov sp, bp
    pop bp
    ret
_putnewline endp

_exit proc near
    push bp
    mov bp, sp
    mov ax, word ptr [bp + arg1]
    mov ah, 4ch
    int 21h
    mov sp, bp
    pop bp
    ret
_exit endp

_exit0 proc near
    push bp
    mov bp, sp
    mov dx, 0
    push dx
    call _exit
    add sp, 2
    mov sp, bp
    pop bp
    ret
_exit0 endp

; ============================================================================
; СТРОКОВЫЕ ФУНКЦИИ
; ============================================================================

_strcpy proc near
    push bp
    mov bp, sp
    push si
    push di
    push es
    mov ax, word ptr [bp+arg1]     ; dst_seg
    mov es, ax
    xor di, di
    mov si, word ptr [bp+arg2]     ; src_off
strcpy_loop:
    mov al, [si]
    mov es:[di], al
    test al, al
    je strcpy_done
    inc si
    inc di
    jmp strcpy_loop
strcpy_done:
    mov ax, word ptr [bp+arg1]
    pop es
    pop di
    pop si
    mov sp, bp
    pop bp
    ret
_strcpy endp

_strcat proc near
    push bp
    mov bp, sp
    push si
    push di
    push es
    mov ax, word ptr [bp + arg1]
    mov es, ax
    xor di, di
    mov si, word ptr [bp + arg2]
strcat_find:
    cmp byte ptr es:[di], 0
    je strcat_copy
    inc di
    jmp strcat_find
strcat_copy:
    mov al, [si]
    mov es:[di], al
    test al, al
    je strcat_done
    inc si
    inc di
    jmp strcat_copy
strcat_done:
    mov ax, word ptr [bp + arg1]
    pop es
    pop di
    pop si
    mov sp, bp
    pop bp
    ret
_strcat endp

_strchr proc near
    push bp
    mov bp, sp
    push si
    push bx
    mov si, word ptr [bp+arg1]
    mov bl, byte ptr [bp+arg2]
strchr_loop:
    mov al, [si]
    test al, al
    je strchr_not_found
    cmp al, bl
    je strchr_found
    inc si
    jmp strchr_loop
strchr_found:
    mov ax, si
    jmp strchr_done
strchr_not_found:
    xor ax, ax
strchr_done:
    pop bx
    pop si
    mov sp, bp
    pop bp
    ret
_strchr endp

_strstr proc near
    push bp
    mov bp, sp
    push si
    push di
    push bx
    mov si, word ptr [bp+arg1]
    mov di, word ptr [bp+arg2]
    cmp byte ptr [di], 0
    je strstr_found_empty
    mov bx, si
strstr_outer:
    mov al, [si]
    test al, al
    jz strstr_not_found
    push si
    push di
strstr_inner:
    mov al, [di]
    test al, al
    je strstr_match
    mov ah, [si]
    test ah, ah
    je strstr_mismatch
    cmp al, ah
    jne strstr_mismatch
    inc si
    inc di
    jmp strstr_inner
strstr_mismatch:
    pop di
    pop si
    inc si
    jmp strstr_outer
strstr_match:
    pop di
    pop si
strstr_found:
    mov ax, si
    jmp strstr_done
strstr_found_empty:
    mov ax, si
    jmp strstr_done
strstr_not_found:
    xor ax, ax
strstr_done:
    pop bx
    pop di
    pop si
    mov sp, bp
    pop bp
    ret
_strstr endp

_strcmp proc near
    push bp
    mov bp, sp
    push si
    push di
    mov si, word ptr [bp+arg1]
    mov di, word ptr [bp+arg2]
strcmp_loop:
    mov al, [si]
    mov ah, [di]
    cmp al, ah
    jne strcmp_diff
    test al, al
    je strcmp_equal
    inc si
    inc di
    jmp strcmp_loop
strcmp_diff:
    movsx ax, al
    movsx bx, ah
    sub ax, bx
    jmp strcmp_done
strcmp_equal:
    xor ax, ax
strcmp_done:
    pop di
    pop si
    mov sp, bp
    pop bp
    ret
_strcmp endp

_stricmp proc near
    push bp
    mov bp, sp
    push si
    push di
    push bx
    mov si, word ptr [bp+arg1]
    mov di, word ptr [bp+arg2]
stricmp_loop:
    mov al, [si]
    mov bl, [di]
    cmp al, 'a'
    jb stricmp_skip_al
    cmp al, 'z'
    ja stricmp_skip_al
    sub al, 20h
stricmp_skip_al:
    cmp bl, 'a'
    jb stricmp_skip_bl
    cmp bl, 'z'
    ja stricmp_skip_bl
    sub bl, 20h
stricmp_skip_bl:
    cmp al, bl
    jne stricmp_diff
    test al, al
    je stricmp_equal
    inc si
    inc di
    jmp stricmp_loop
stricmp_diff:
    movsx ax, al
    movsx bx, bl
    sub ax, bx
    jmp stricmp_done
stricmp_equal:
    xor ax, ax
stricmp_done:
    pop bx
    pop di
    pop si
    mov sp, bp
    pop bp
    ret
_stricmp endp

_strtol proc near
    push bp
    mov bp, sp
    sub sp, 8
    push di
    push si
    push cx
    push bx
    push dx

    mov word ptr [bp-2], 1        ; знак (1 = положительное)
    mov word ptr [bp-4], 0        ; результат
    mov word ptr [bp-6], 0        ; флаг переполнения

    mov si, word ptr [bp+arg1]    ; исходная строка
    mov di, word ptr [bp+arg2]    ; end_ptr
    mov cx, word ptr [bp+arg3]    ; основание

strtol_skip_ws:
    mov al, byte ptr [si]
    test al, al
    jz strtol_empty
    cmp al, ' '
    je strtol_ws_next
    cmp al, 9
    je strtol_ws_next
    cmp al, 10
    je strtol_ws_next
    cmp al, 13
    je strtol_ws_next
    jmp strtol_check_sign
strtol_ws_next:
    inc si
    jmp strtol_skip_ws

strtol_check_sign:
    mov al, byte ptr [si]
    cmp al, '-'
    jne strtol_check_plus
    mov word ptr [bp-2], -1
    inc si
    jmp strtol_check_base
strtol_check_plus:
    cmp al, '+'
    jne strtol_check_base
    inc si

strtol_check_base:
    cmp cx, 0
    jne strtol_base_ready
    mov al, byte ptr [si]
    cmp al, '0'
    jne strtol_base_10
    mov al, byte ptr [si+1]
    cmp al, 'x'
    je strtol_base_16
    cmp al, 'X'
    je strtol_base_16
    mov cx, 8
    jmp strtol_base_ready
strtol_base_16:
    add si, 2
    mov cx, 16
    jmp strtol_base_ready
strtol_base_10:
    mov cx, 10

strtol_base_ready:
    cmp cx, 2
    jb strtol_invalid
    cmp cx, 16
    ja strtol_invalid
    mov word ptr [bp-8], si

strtol_convert:
    mov al, byte ptr [si]
    test al, al
    jz strtol_done
    cmp al, '0'
    jb strtol_not_digit
    cmp al, '9'
    jbe strtol_is_digit
    cmp al, 'A'
    jb strtol_not_digit
    cmp al, 'F'
    jbe strtol_is_upper
    cmp al, 'a'
    jb strtol_not_digit
    cmp al, 'f'
    jbe strtol_is_lower
    jmp strtol_not_digit

strtol_is_digit:
    sub al, '0'
    jmp strtol_check_digit
strtol_is_upper:
    sub al, 'A'
    add al, 10
    jmp strtol_check_digit
strtol_is_lower:
    sub al, 'a'
    add al, 10

strtol_check_digit:
    cmp al, cl
    jae strtol_not_digit
    movzx bx, al
    mov ax, word ptr [bp-4]
    mul cx
    cmp dx, 0
    jne strtol_overflow
    add ax, bx
    jc strtol_overflow
    cmp word ptr [bp-2], 1
    jne strtol_check_neg_limit
    cmp ax, 32767
    ja strtol_overflow
    jmp strtol_store
strtol_check_neg_limit:
    cmp ax, 32768
    ja strtol_overflow

strtol_store:
    mov word ptr [bp-4], ax
    inc si
    jmp strtol_convert

strtol_not_digit:
    cmp si, word ptr [bp-8]
    je strtol_no_digits
    jmp strtol_done

strtol_overflow:
    mov word ptr [bp-6], 1
    inc si
    jmp strtol_convert

strtol_no_digits:
    xor ax, ax
    mov word ptr [bp-4], ax
    mov si, word ptr [bp+arg1]

strtol_done:
    test di, di
    je strtol_skip_endptr
    mov word ptr [di], si
strtol_skip_endptr:
    mov ax, word ptr [bp-4]
    cmp word ptr [bp-6], 1
    jne strtol_apply_sign
    cmp word ptr [bp-2], 1
    je strtol_overflow_pos
    mov ax, 32768
    neg ax
    jmp strtol_return
strtol_overflow_pos:
    mov ax, 32767
    jmp strtol_return

strtol_apply_sign:
    cmp word ptr [bp-2], -1
    jne strtol_return
    neg ax

strtol_return:
    pop dx
    pop bx
    pop cx
    pop si
    pop di
    mov sp, bp
    pop bp
    ret

strtol_invalid:
strtol_empty:
    xor ax, ax
    test di, di
    je strtol_invalid_skip
    mov word ptr [di], si
strtol_invalid_skip:
    jmp strtol_return
_strtol endp

_strdup proc near
    push bp
    mov bp, sp
    push si
    push di
    push es
    mov si, word ptr [bp+arg1]
    push si
    call _strlen
    add sp, 2
    inc ax
    push ax
    call _malloc
    add sp, 2
    cmp ax, 0
    je strdup_fail
    mov es, ax
    xor di, di
strdup_copy:
    mov al, [si]
    mov es:[di], al
    test al, al
    je strdup_done
    inc si
    inc di
    jmp strdup_copy
strdup_done:
    mov ax, es
    jmp strdup_exit
strdup_fail:
    xor ax, ax
strdup_exit:
    pop es
    pop di
    pop si
    mov sp, bp
    pop bp
    ret
_strdup endp