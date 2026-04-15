.386
arg1 equ 4
arg2 equ 6
arg3 equ 8
arg4 equ 10
var1 equ -2
var2 equ -4
var3 equ -6
var4 equ -8

stack segment para stack
    db 65530 dup(?)
stack ends

data segment para public
    msg_prompt1 db 'Enter path to file 1: $'
    msg_prompt2 db 'Enter path to file 2: $'
    msg_ok      db '[OK]', 13, 10, '$'
    msg_fail    db '[FAIL]', 13, 10, '$'
    msg_unit    db '--- UNIT TESTS ---', 13, 10, '$'
    msg_main    db '--- MAIN FILE TEST ---', 13, 10, '$'
    msg_diff    db '(', 0
    msg_semi    db '; ', 0
    msg_paren   db ')', 13, 10, '$'
    
    ; Имена тестов для вывода
    msg_strlen  db 'strlen test: $'
    msg_strstr  db 'strstr test: $'
    msg_strchr  db 'strchr test: $'
    msg_strcpy  db 'strcpy test: $'
    msg_strcat  db 'strcat test: $'
    msg_strcmp  db 'strcmp test: $'
    msg_stricmp db 'stricmp test: $'
    msg_strtol  db 'strtol test: $'
    msg_strdup  db 'strdup test: $'
    
    t_hello     db 'Hello, World!', 0
    t_search    db 'World', 0
    t_num       db '123', 0
    t_hex       db '0x1A', 0
    g_arr1_seg  dw 0
    g_cnt1      dw 0
    g_arr2_seg  dw 0
    g_cnt2      dw 0
data ends

code segment para public use16
assume cs:code, ds:data, ss:stack

include strings.inc
include memory.inc
include fileio.inc

_print_msg proc near
    push bp
    mov bp, sp
    push dx
    mov dx, word ptr [bp + 4]
    mov ah, 09h
    int 21h
    pop dx
    mov sp, bp
    pop bp
    ret
_print_msg endp

_print_num proc near
    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    push dx
    mov ax, word ptr [bp + 4]
    xor cx, cx
    mov bx, 10
pn_loop:
    xor dx, dx
    div bx
    push dx
    inc cx
    test ax, ax
    jnz pn_loop
pn_print:
    pop dx
    add dl, '0'
    mov ah, 02h
    int 21h
    loop pn_print
    pop dx
    pop cx
    pop bx
    pop ax
    mov sp, bp
    pop bp
    ret
_print_num endp

_split_and_store proc near
    push bp
    mov bp, sp
    sub sp, 2
    push si
    push di
    push es
    push ds
    push bx
    push cx
    push dx
    mov si, word ptr [bp + arg1]
    push ds
    mov ds, si
    xor bx, bx
    xor cx, cx
sl_cnt:
    cmp byte ptr [bx], 0
    je sl_cnt_done
    cmp byte ptr [bx], 10
    jne sl_next
    inc cx
sl_next:
    inc bx
    jmp sl_cnt
sl_cnt_done:
    inc cx
    mov word ptr [bp - 2], cx
    pop ds
    mov ax, cx
    shl ax, 1
    push ax
    call _malloc
    add sp, 2
    test ax, ax
    jz sl_fail
    mov di, ax
    push ds
    mov ds, si
    xor si, si
    xor bx, bx
sl_parse:
    mov dx, si
    xor ax, ax
sl_len:
    cmp byte ptr [si], 0
    je sl_alloc
    cmp byte ptr [si], 10
    je sl_alloc
    inc si
    inc ax
    jmp sl_len
sl_alloc:
    push ax
    inc ax
    call _malloc
    add sp, 2
    test ax, ax
    jz sl_fail
    push dx
    push ax
    call _strcpy
    add sp, 4
    push es
    mov es, di
    mov si, bx
    shl si, 1
    mov word ptr es:[si], ax
    pop es
    inc bx
    cmp byte ptr [si], 10
    jne sl_next_line
    inc si
sl_next_line:
    cmp bx, word ptr [bp - 2]
    jl sl_parse
    mov ax, di
    mov bx, word ptr [bp - 2]
    jmp sl_done
sl_fail:
    xor ax, ax
    xor bx, bx
sl_done:
    pop ds
    pop dx
    pop cx
    pop bx
    pop es
    pop di
    pop si
    mov sp, bp
    pop bp
    ret
_split_and_store endp

_compare_arrays proc near
    push bp
    mov bp, sp
    push si
    push di
    push es
    push ds
    push bx
    push cx
    push dx
    mov si, word ptr [bp + arg1]
    mov bx, word ptr [bp + arg2]
    mov di, word ptr [bp + arg3]
    mov cx, word ptr [bp + arg4]
    cmp bx, cx
    jbe cmp_min_ok
    mov bx, cx
cmp_min_ok:
    xor bp, bp
cmp_loop:
    cmp bp, bx
    jge cmp_done
    push ds
    mov ds, si
    mov si, bp
    shl si, 1
    mov dx, word ptr [si]
    mov ds, di
    mov ax, word ptr [si]
    pop ds
    push ds
    mov ds, dx
    xor si, si
    mov es, ax
    xor di, di
    xor cx, cx
cmp_char:
    mov al, [si]
    mov ah, es:[di]
    cmp al, ah
    jne cmp_diff
    test al, al
    je cmp_equal
    inc si
    inc di
    inc cx
    jmp cmp_char
cmp_equal:
    pop es
    pop ds
    jmp cmp_next
cmp_diff:
    push bp
    call _print_num
    add sp, 2
    push offset msg_semi
    call _print_msg
    add sp, 2
    push cx
    call _print_num
    add sp, 2
    push offset msg_paren
    call _print_msg
    add sp, 2
    pop es
    pop ds
cmp_next:
    inc bp
    jmp cmp_loop
cmp_done:
    pop dx
    pop cx
    pop bx
    pop ds
    pop es
    pop di
    pop si
    mov sp, bp
    pop bp
    ret
_compare_arrays endp

; ============================================================================
; ОБНОВЛЁННЫЕ ЮНИТ-ТЕСТЫ С ВЫВОДОМ ИМЁН И [OK]/[FAIL]
; ============================================================================
_test_units proc near
    push bp
    mov bp, sp
    push ax
    push bx
    push si
    push di

    ; 1. strlen
    push offset msg_strlen
    call _print_msg
    add sp, 2
    push offset t_hello
    call _strlen
    add sp, 2
    cmp ax, 13
    je t1_ok
    push offset msg_fail
    call _print_msg
    add sp, 2
    jmp t1_end
t1_ok:
    push offset msg_ok
    call _print_msg
    add sp, 2
t1_end:

    ; 2. strstr
    push offset msg_strstr
    call _print_msg
    add sp, 2
    push offset t_search
    push offset t_hello
    call _strstr
    add sp, 4
    cmp ax, 0
    je t2_fail
    push offset msg_ok
    call _print_msg
    add sp, 2
    jmp t2_end
t2_fail:
    push offset msg_fail
    call _print_msg
    add sp, 2
t2_end:

    ; 3. strchr
    push offset msg_strchr
    call _print_msg
    add sp, 2
    push 'W'
    push offset t_hello
    call _strchr
    add sp, 4
    cmp ax, 0
    je t3_fail
    push offset msg_ok
    call _print_msg
    add sp, 2
    jmp t3_end
t3_fail:
    push offset msg_fail
    call _print_msg
    add sp, 2
t3_end:

    ; 4. strcpy
    push offset msg_strcpy
    call _print_msg
    add sp, 2
    push 64
    call _malloc
    add sp, 2
    mov di, ax
    cmp ax, 0
    je t4_fail
    push offset t_hello
    push di
    call _strcpy
    add sp, 4
    push ds
    mov ds, di
    xor bx, bx
    push bx
    call _strlen
    add sp, 2
    pop ds
    cmp ax, 13
    je t4_ok
    push offset msg_fail
    call _print_msg
    add sp, 2
    jmp t4_cleanup
t4_ok:
    push offset msg_ok
    call _print_msg
    add sp, 2
t4_cleanup:
    push di
    call _free
    add sp, 2
t4_fail:

    ; 5. strcat
    push offset msg_strcat
    call _print_msg
    add sp, 2
    push 64
    call _malloc
    add sp, 2
    mov di, ax
    cmp ax, 0
    je t5_fail
    push ds
    mov ds, di
    xor bx, bx
    mov byte ptr [bx], 'A'
    inc bx
    mov byte ptr [bx], 'B'
    inc bx
    mov byte ptr [bx], 0
    pop ds
    push offset t_hello
    push di
    call _strcat
    add sp, 4
    push ds
    mov ds, di
    xor bx, bx
    push bx
    call _strlen
    add sp, 2
    pop ds
    cmp ax, 15
    je t5_ok
    push offset msg_fail
    call _print_msg
    add sp, 2
    jmp t5_cleanup
t5_ok:
    push offset msg_ok
    call _print_msg
    add sp, 2
t5_cleanup:
    push di
    call _free
    add sp, 2
t5_fail:

    ; 6. strcmp
    push offset msg_strcmp
    call _print_msg
    add sp, 2
    push offset t_hello
    push offset t_hello
    call _strcmp
    add sp, 4
    cmp ax, 0
    je t6_ok
    push offset msg_fail
    call _print_msg
    add sp, 2
    jmp t6_end
t6_ok:
    push offset msg_ok
    call _print_msg
    add sp, 2
t6_end:

    ; 7. stricmp
    push offset msg_stricmp
    call _print_msg
    add sp, 2
    push offset t_hello
    push offset t_hello
    call _stricmp
    add sp, 4
    cmp ax, 0
    je t7_ok
    push offset msg_fail
    call _print_msg
    add sp, 2
    jmp t7_end
t7_ok:
    push offset msg_ok
    call _print_msg
    add sp, 2
t7_end:

    ; 8. strtol
    push offset msg_strtol
    call _print_msg
    add sp, 2
    push 10
    push 0
    push offset t_num
    call _strtol
    add sp, 6
    cmp ax, 123
    je t8_ok
    push offset msg_fail
    call _print_msg
    add sp, 2
    jmp t8_end
t8_ok:
    push offset msg_ok
    call _print_msg
    add sp, 2
t8_end:

    ; 9. strdup
    push offset msg_strdup
    call _print_msg
    add sp, 2
    push offset t_hello
    call _strdup
    add sp, 2
    mov di, ax
    cmp ax, 0
    je t9_fail
    push ds
    mov ds, di
    xor bx, bx
    push bx
    call _strlen
    add sp, 2
    pop ds
    cmp ax, 13
    je t9_ok
    push offset msg_fail
    call _print_msg
    add sp, 2
    jmp t9_cleanup
t9_ok:
    push offset msg_ok
    call _print_msg
    add sp, 2
t9_cleanup:
    push di
    call _free
    add sp, 2
t9_fail:

    pop di
    pop si
    pop bx
    pop ax
    mov sp, bp
    pop bp
    ret
_test_units endp

_test_main proc near
    push bp
    mov bp, sp
    sub sp, 8
    push ax
    push bx
    push si
    push di
    push es
    push offset msg_main
    call _print_msg
    add sp, 2
    push 256
    call _malloc
    add sp, 2
    cmp ax, 0
    je tm_err
    mov si, ax
    push offset msg_prompt1
    call _print_msg
    add sp, 2
    push ds
    mov ds, si
    push 256
    push 0
    call _getstr
    add sp, 4
    pop ds
    push 256
    call _malloc
    add sp, 2
    cmp ax, 0
    je tm_err
    mov di, ax
    push offset msg_prompt2
    call _print_msg
    add sp, 2
    push ds
    mov ds, di
    push 256
    push 0
    call _getstr
    add sp, 4
    pop ds
    push ds
    mov ds, si
    push 0
    call _file_getsize
    add sp, 2
    pop ds
    cmp ax, -1
    je tm_err
    mov word ptr [bp - 4], ax
    push ds
    mov ds, di
    push 0
    call _file_getsize
    add sp, 2
    pop ds
    cmp ax, -1
    je tm_err
    mov word ptr [bp - 8], ax
    push word ptr [bp - 4]
    call _malloc
    add sp, 2
    cmp ax, 0
    je tm_err
    mov word ptr [bp - 2], ax
    push word ptr [bp - 8]
    call _malloc
    add sp, 2
    cmp ax, 0
    je tm_err
    mov word ptr [bp - 6], ax
    push word ptr [bp - 4]
    push 0
    push word ptr [bp - 2]
    push ds
    mov ds, si
    push 0
    call _file_readall
    add sp, 8
    pop ds
    cmp ax, -1
    je tm_err_all
    push word ptr [bp - 8]
    push 0
    push word ptr [bp - 6]
    push ds
    mov ds, di
    push 0
    call _file_readall
    add sp, 8
    pop ds
    cmp ax, -1
    je tm_err_all
    push word ptr [bp - 2]
    call _split_and_store
    add sp, 2
    mov g_arr1_seg, ax
    mov g_cnt1, bx
    push word ptr [bp - 6]
    call _split_and_store
    add sp, 2
    mov g_arr2_seg, ax
    mov g_cnt2, bx
    push g_cnt2
    push g_arr2_seg
    push g_cnt1
    push g_arr1_seg
    call _compare_arrays
    add sp, 8
tm_err_all:
    pop ax
    push ax
    call _free
    add sp, 2
    pop ax
    push ax
    call _free
    add sp, 2
tm_err:
    push di
    call _free
    add sp, 2
    push si
    call _free
    add sp, 2
    push g_arr1_seg
    call _free
    add sp, 2
    push g_arr2_seg
    call _free
    add sp, 2
    call _putnewline
    pop es
    pop di
    pop si
    pop bx
    pop ax
    mov sp, bp
    pop bp
    ret
_test_main endp

_tests proc near
    push bp
    mov bp, sp
    call _test_units
    call _test_main
    mov sp, bp
    pop bp
    ret
_tests endp

start:
    mov ax, data
    mov ds, ax
    mov ax, stack
    mov ss, ax
    call _tests
    call _exit0

code ends
end start