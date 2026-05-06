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
    ERROR_SUCCESS        equ 0
    ERROR_FORMAT         equ 1
    ERROR_INVALID_OP     equ 2
    ERROR_DIV_ZERO       equ 3
    ERROR_DIV_OVERFLOW   equ 4
    ERROR_NUM_RANGE      equ 5
    ERROR_BASE           equ 6
    ERROR_READ_STRING    equ 7

    msg_prompt_base db "Select input base: 1 - Decimal, 2 - Hexadecimal: ",0
    msg_prompt_expr db "Enter expression: ", 0
    msg_result db "Result: ", 0
    msg_error_prefix db "Error: ", 0
    msg_error_format db "Invalid expression format", 0
    msg_error_invalid_op db "Invalid operator. Use + - * / %", 0
    msg_error_div_zero db "Division by zero", 0
    msg_error_div_overflow db "Division overflow (quotient out of range)", 0
    msg_error_num_range db "Number out of range (-32768..32767)", 0
    msg_error_base db "Invalid base selection", 0
    msg_newline db 13, 10, 0
    msg_hex_prefix db " (0x", 0
    msg_hex_suffix db ")", 0

    input_base db ?
    num1 dw ?
    num2 dw ?
    operator db ?
    result_low dw 0
    result_high dw 0

    str1 db 256 dup(0)
    num1_str db 10 dup(0)
    num2_str db 10 dup(0)
    dec_buf db 12 dup(0)
    hex_buf db 9 dup(0)
    temp_buf db 6 dup(0)
data ends

code segment para public use16
assume cs:code, ds:data, ss:stack

_putchar:
    push bp
    mov bp, sp
    mov dx, word ptr [bp + arg1]
    mov ah, 02h
    int 21h
    mov sp, bp
    pop bp
    ret

_getchar:
    push bp
    mov bp, sp
    mov ah, 01h
    int 21h
    mov sp, bp
    pop bp
    ret

_strlen:
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

_putstr:
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

_getstr:
    push bp
    mov bp, sp
    mov cx, word ptr [bp + arg2]
    mov dx, word ptr [bp + arg1]
    mov ah, 3fh
    mov bx, 0
    int 21h
    cmp ax, 0
    je getstr_error
    mov bx, word ptr [bp + arg1]
    add bx, ax
    sub bx, 2
    mov byte ptr [bx], 0
    clc
    jmp getstr_done
getstr_error:
    stc
    mov ax, ERROR_READ_STRING
getstr_done:
    mov sp, bp
    pop bp
    ret

_putnewline:
    push bp
    mov bp, sp
    push 13
    call _putchar
    add sp, 2
    push 10
    call _putchar
    add sp, 2
    mov sp, bp
    pop bp
    ret
	
_print_int:
    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    push dx

    mov ax, [bp+4]

    cmp ax, 0
    jge pi_pos

    mov dl, '-'
    push dx
    call _putchar
    add sp,2
    neg ax

pi_pos:
    mov cx, 10
    xor bx, bx

pi_loop:
    xor dx, dx
    div cx
    push dx
    inc bx
    cmp ax, 0
    jne pi_loop

pi_print:
    pop dx
    add dl, '0'
    push dx
    call _putchar
    add sp,2
    dec bx
    jnz pi_print

    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret

_exit:
    push bp
    mov bp, sp
    mov ax, word ptr [bp + arg1]
    mov ah, 4ch
    int 21h
    mov sp, bp
    pop bp
    ret

_exit0:
    push bp
    mov bp, sp
    push 0
    call _exit
    add sp, 2
    mov sp, bp
    pop bp
    ret

_print_string:
    push bp
    mov bp, sp
    push word ptr [bp + arg1]
    call _putstr
    add sp, 2
    mov sp, bp
    pop bp
    ret

_print_error:
    push bp
    mov bp, sp
    push ax
    push offset msg_error_prefix
    call _print_string
    add sp, 2
    pop ax
    cmp ax, ERROR_FORMAT
    je err_format
    cmp ax, ERROR_INVALID_OP
    je err_invop
    cmp ax, ERROR_DIV_ZERO
    je err_divz
    cmp ax, ERROR_DIV_OVERFLOW
    je err_divovf
    cmp ax, ERROR_NUM_RANGE
    je err_range
    cmp ax, ERROR_BASE
    je err_base
    jmp err_done
err_format:
    push offset msg_error_format
    call _print_string
    add sp, 2
    jmp err_done
err_invop:
    push offset msg_error_invalid_op
    call _print_string
    add sp, 2
    jmp err_done
err_divz:
    push offset msg_error_div_zero
    call _print_string
    add sp, 2
    jmp err_done
err_divovf:
    push offset msg_error_div_overflow
    call _print_string
    add sp, 2
    jmp err_done
err_range:
    push offset msg_error_num_range
    call _print_string
    add sp, 2
    jmp err_done
err_base:
    push offset msg_error_base
    call _print_string
    add sp, 2
err_done:
    push offset msg_newline
    call _print_string
    add sp, 2
    mov sp, bp
    pop bp
    ret

_to_upper:
    cmp al, 'a'
    jb tu_done
    cmp al, 'z'
    ja tu_done
    sub al, 'a' - 'A'
tu_done:
    ret

_is_valid_digit:
    push bx
    call _to_upper
    cmp input_base, 10
    je check_dec
    cmp al, '0'
    jb invalid_digit
    cmp al, '9'
    jbe hex_digit_ok
    cmp al, 'A'
    jb invalid_digit
    cmp al, 'F'
    jbe hex_letter_ok
    jmp invalid_digit
hex_digit_ok:
    sub al, '0'
    clc
    jmp done_valid
hex_letter_ok:
    sub al, 'A'
    add al, 10
    clc
    jmp done_valid
check_dec:
    cmp al, '0'
    jb invalid_digit
    cmp al, '9'
    ja invalid_digit
    sub al, '0'
    clc
    jmp done_valid
invalid_digit:
    stc
done_valid:
    pop bx
    ret

mul32x16:
    push bx
    push cx
    push si
    push di
    mov bx, ax
    mov ax, dx
    mul cx
    mov si, ax
    mov di, dx
    mov ax, bx
    mul cx
    add ax, si
    adc dx, di
    pop di
    pop si
    pop cx
    pop bx
    ret

_atoi:
    push bp
    mov bp, sp
    push bx
    push cx
    push dx
    push si

    mov si, [bp+arg1]

    xor ax, ax
    xor bx, bx

skip_spaces:
    mov dl, [si]
    cmp dl, ' '
    jne check_sign
    inc si
    jmp skip_spaces

check_sign:
    cmp byte ptr [si], '-'
    jne parse
    mov bl, 1
    inc si

parse:
    mov cl, input_base

next_char:
    mov dl, [si]
    cmp dl, 0
    je done
    cmp dl, ' '
    je done
    cmp dl, 13
    je done

    cmp cl, 10
    je dec_digit

    cmp dl, '0'
    jb errors
    cmp dl, '9'
    jbe hex_num
    cmp dl, 'A'
    jb errors
    cmp dl, 'F'
    jbe hex_big
    cmp dl, 'a'
    jb errors
    cmp dl, 'f'
    jbe hex_small
    jmp errors

hex_num:
    sub dl, '0'
    jmp digit_ready

hex_big:
    sub dl, 'A'-10
    jmp digit_ready

hex_small:
    sub dl, 'a'-10
    jmp digit_ready

dec_digit:
    cmp dl, '0'
    jb errors
    cmp dl, '9'
    ja errors
    sub dl, '0'

digit_ready:
    mov dh, 0
    push dx
    mov dx, 0
    mov cx, input_base
    mul cx
    pop dx

    add ax, dx

    inc si
    jmp next_char

done:
    cmp bl, 0
    je ok
    neg ax

ok:
    clc
    jmp exit

errors:
    stc
    mov ax, ERROR_FORMAT

exit:
    pop si
    pop dx
    pop cx
    pop bx
    mov sp, bp
    pop bp
    ret
_check:
    push bp
    mov bp, sp
    push bx
    push si
    push di

    mov si, word ptr [bp + arg1]
    mov di, offset num1_str
    xor bx, bx

read_num1:
    mov al, byte ptr [si]
    cmp al, 0
    je check_error_format
    cmp al, ' '
    je after_num1
    cmp al, '-'
    jne not_minus1
    cmp di, offset num1_str
    jne check_error_format
not_minus1:
    mov byte ptr [di], al
    inc di
    inc si
    jmp read_num1

after_num1:
    cmp di, offset num1_str
    je check_error_format
    mov byte ptr [di], 0
    inc si
    mov al, byte ptr [si]
    cmp al, '+'
    je op_ok
    cmp al, '-'
    je op_ok
    cmp al, '*'
    je op_ok
    cmp al, '/'
    je op_ok
    cmp al, '%'
    je op_ok
    jmp check_error_invalid_op

op_ok:
    mov operator, al
    inc si
    cmp byte ptr [si], ' '
    jne check_error_format
    inc si
    mov di, offset num2_str
read_num2:
    mov al, byte ptr [si]
    cmp al, 0
    je after_num2
    cmp al, ' '
    je check_error_format
    cmp al, 13
    je after_num2
    mov byte ptr [di], al
    inc di
    inc si
    jmp read_num2

after_num2:
    mov byte ptr [di], 0
    cmp byte ptr [si], 0
    jne check_error_format
    push offset num1_str
    call _atoi
    add sp, 2
    jc check_return
    mov num1, ax
    push offset num2_str
    call _atoi
    add sp, 2
    jc check_return
    mov num2, ax
    clc
    xor ax, ax
    jmp check_done

check_error_format:
    stc
    mov ax, ERROR_FORMAT
    jmp check_done

check_error_invalid_op:
    stc
    mov ax, ERROR_INVALID_OP

check_return:
check_done:
    pop di
    pop si
    pop bx
    mov sp, bp
    pop bp
    ret

_print_result_32:
    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    mov result_low, ax
    mov result_high, dx

    push offset msg_result
    call _print_string
    add sp, 2

    mov dx, result_high
    mov ax, result_low
    cmp dx, 0
    jge dec_abs
    neg ax
    neg dx
    sbb dx, 0
    push ax
    push dx
    mov al, '-'
    call _putchar
    pop dx
    pop ax
dec_abs:
    mov si, offset dec_buf + 11
    mov byte ptr [si], 0
    dec si
    mov bx, 10
dec_loop:
    push ax
    mov ax, dx
    xor dx, dx
    div bx
    mov cx, ax
    pop ax
    div bx
    add dl, '0'
    mov byte ptr [si], dl
    dec si
    mov dx, cx
    cmp dx, 0
    jne dec_loop
    cmp ax, 0
    jne dec_loop
    inc si
    push si
    call _print_string
    add sp, 2

    push offset msg_hex_prefix
    call _print_string
    add sp, 2

    mov dx, result_high
    mov ax, result_low
    mov di, offset hex_buf
    add di, 8
    mov byte ptr [di], 0
    dec di
    mov cx, 8
hex_loop:
    push cx
    mov bx, ax
    and bx, 0Fh
    cmp bl, 9
    jbe hex_digit
    add bl, 'A'-10
    jmp hex_store
hex_digit:
    add bl, '0'
hex_store:
    mov byte ptr [di], bl
    dec di
    shr dx, 1
    rcr ax, 1
    shr dx, 1
    rcr ax, 1
    shr dx, 1
    rcr ax, 1
    shr dx, 1
    rcr ax, 1
    pop cx
    dec cx
    jnz hex_loop
    inc di
    cmp byte ptr [di], '0'
    jne hex_skip
    mov al, byte ptr [di+1]
    cmp al, 0
    jne hex_skip
    inc di
hex_skip:
    push di
    call _print_string
    add sp, 2
    push offset msg_hex_suffix
    call _print_string
    add sp, 2
    push offset msg_newline
    call _print_string
    add sp, 2

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    mov sp, bp
    pop bp
    ret

_calc:
    push bp
    mov bp, sp

ask_base:
    push offset msg_prompt_base
    call _print_string
    add sp, 2
    call _getchar
    cmp al, '1'
    je set_dec
    cmp al, '2'
    je set_hex
    push ERROR_BASE
    call _print_error
    add sp, 2
    jmp ask_base
set_dec:
    mov input_base, 10
    jmp base_ok
set_hex:
    mov input_base, 16
base_ok:
    push offset msg_newline
    call _print_string
    add sp, 2

    push offset msg_prompt_expr
    call _print_string
    add sp, 2
    push 256
    push offset str1
    call _getstr
    add sp, 4
    jc calc_error

    push offset str1
    call _check
    add sp, 2
    jc calc_error

    mov al, operator
    cmp al, '+'
    je op_add
    cmp al, '-'
    je op_sub
    cmp al, '*'
    je op_mul
    cmp al, '/'
    je op_div
    cmp al, '%'
    je op_mod
    mov ax, ERROR_INVALID_OP
    stc
    jmp calc_error

op_add:
    mov ax, num1
    add ax, num2
    cwd
    jmp op_done
op_sub:
    mov ax, num1
    sub ax, num2
    cwd
    jmp op_done
op_mul:
    mov ax, num1
    imul num2
    jmp op_done
op_div:
    cmp num2, 0
    je div_zero
    cmp num1, -32768
    jne div_ok
    cmp num2, -1
    jne div_ok
    mov ax, ERROR_DIV_OVERFLOW
    stc
    jmp calc_error
div_ok:
    mov ax, num1
    cwd
    idiv num2
    cwd
    jmp op_done
op_mod:
    cmp num2, 0
    je div_zero
    cmp num1, -32768
    jne mod_ok
    cmp num2, -1
    jne mod_ok
    mov ax, ERROR_DIV_OVERFLOW
    stc
    jmp calc_error
mod_ok:
    mov ax, num1
    cwd
    idiv num2
    mov ax, dx
    cwd
    jmp op_done
div_zero:
    mov ax, ERROR_DIV_ZERO
    stc
    jmp calc_error
op_done:
    call _print_result_32
    clc
    jmp calc_return
calc_error:
    call _print_error
calc_return:
    mov sp, bp
    pop bp
    ret

start:
    mov ax, data
    mov ds, ax
    mov ax, stack
    mov ss, ax
    call _calc
    call _exit0

code ends
end start