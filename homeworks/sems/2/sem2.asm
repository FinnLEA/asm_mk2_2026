.386

arg1 equ 4
arg2 equ 6
arg3 equ 8
arg4 equ 10

var1 equ -2
var2 equ -4
var3 equ -6
var4 equ -8

include consts.inc

stack segment para stack
    db 65530 dup(?)
stack ends

data segment para public
    include data.inc
data ends

code segment para public use16

assume cs:code, ds:data, ss:stack

; ===================== ШАБЛОН ПРЕПОДАВАТЕЛЯ =====================

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
lencyc:
    cmp byte ptr [bx], 0
    je lenret
    inc ax
    inc bx
    jmp lencyc
lenret:
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
    mov cx, word ptr [bp + arg2]
    mov dx, word ptr [bp + arg1]
    mov ah, 3fh
    mov bx, 0
    int 21h
    mov bx, word ptr [bp + arg1]
    add bx, ax
    sub bx, 2
    mov byte ptr [bx], 0
    mov sp, bp
    pop bp
    ret
_getstr endp

_putnewline proc near
    push bp
    mov bp, sp
    push 10
    call _putchar
    add sp, 2
    push 13
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
    push 0
    call _exit
    add sp, 2
    mov sp, bp
    pop bp
    ret
_exit0 endp

; ===================== ПОДКЛЮЧЕНИЕ МОДУЛЕЙ =====================

include output.inc
include parser.inc
include math.inc
include errors.inc

; ===================== ГЛАВНАЯ ФУНКЦИЯ =====================

_calc proc near
    push bp
    mov bp, sp

    ; --- Запрос системы счисления ---
    push offset str_base
    call _putstr
    add sp, 2

    call _getchar

    cmp al, '1'
    je calc_dec
    cmp al, '2'
    je calc_hex
    jmp calc_dec

calc_hex:
    mov word ptr input_base, 16
    jmp calc_input

calc_dec:
    mov word ptr input_base, 10

calc_input:
    call _putnewline

    ; --- Запрос выражения ---
    push offset str_expression
    call _putstr
    add sp, 2

    push 255
    push offset expression_buffer
    call _getstr
    add sp, 4

    call _putnewline

    ; --- Проверка и парсинг ---
    push offset expression_buffer
    call _check
    jc calc_check_err           ; проверяем CF ДО add sp
    add sp, 2

    ; --- Вычисление ---
    xor ax, ax
    mov al, byte ptr operator
    push ax
    push word ptr num2
    push word ptr num1
    call _calculate
    jc calc_calc_err            ; проверяем CF ДО add sp
    add sp, 6

    ; --- Вывод DEC ---
    push offset str_res_DEC
    call _putstr
    add sp, 2

    cmp byte ptr is_result_32bit, 1
    je calc_print_32

    push word ptr result_low
    call _print_dec_16
    add sp, 2
    jmp calc_print_hex

calc_print_32:
    push word ptr result_low
    push word ptr result_high
    call _print_dec_32
    add sp, 4

calc_print_hex:
    call _putnewline

    ; --- Вывод HEX ---
    push offset str_res_HEX
    call _putstr
    add sp, 2

    cmp byte ptr is_result_32bit, 1
    je calc_print_hex32

    push word ptr result_low
    call _print_hex_16
    add sp, 2
    jmp calc_done

calc_print_hex32:
    push word ptr result_low
    push word ptr result_high
    call _print_hex_32
    add sp, 4

calc_done:
    call _putnewline
    jmp calc_exit

    ; --- Обработка ошибок ---
calc_check_err:
    add sp, 2               ; чистим аргумент _check
    jmp calc_error

calc_calc_err:
    add sp, 6               ; чистим аргументы _calculate
    jmp calc_error

calc_error:
    push ax
    call _error_handler
    add sp, 2

calc_exit:
    mov sp, bp
    pop bp
    ret
_calc endp

start:
    mov ax, data
    mov ds, ax
    mov ax, stack
    mov ss, ax

    call _calc
    call _exit0

code ends
end start