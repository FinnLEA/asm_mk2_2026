.386

stack_seg segment para stack 'stack' use16
    db 65535 dup(?)
stack_seg ends

data_seg segment para 'data' use16 
    formated_string_buffer db 256 dup(0)
    formated_string_buffer2 db 256 dup(0)
    formated_string_buffer3 db 256 dup(0)

    input_expression db 1024 dup (?)
; msgs
    enter_num_sys_msg db 'enter input numerical system(h - hex, d - decimal):', 0
    enter_exp_msg db 'enter expression(for example: "-f + 1", "2 + 2"):', 0
    output_dec_msg db 'decimal: ', 0
    output_hex_msg db 'hex: ', 0

; errors
    overflow_msg db 'Overflow error',  0dh, 0ah, 0
    invalid_exp_msg db 'Invalid expression format',  0dh, 0ah, 0
    invalid_exp_operation_msg db 'Invalid operation',  0dh, 0ah, 0
    divide_by_zero db 'Divide by zero',  0dh, 0ah, 0
    invalid_number_msg db 'Invalid number',  0dh, 0ah, 0

    msg_vec dw offset overflow_msg, offset invalid_exp_msg, offset invalid_exp_operation_msg
            dw offset divide_by_zero, offset invalid_number_msg

    ERROR_OVERFLOW equ 0
    ERROR_INVALID_EXPRESSION equ 1
    ERROR_INVALID_EXPRESSION_OP equ 2
    ERROR_DIVIDE_BY_ZERO equ 3
    ERROR_INVALID_NUMBER equ 4

; global variables
    atoi_ptr     dw 0
    result_a     dw 0
    result_b     dw 0
    result_op    db 0
    
    base db ?
    operator db ?
    res_str db 6 dup(?)		
    res_str_dw db 20 dup(?)
    
data_seg ends

code_seg segment para 'code' use16
    assume cs:code_seg, ds:data_seg, ss:stack_seg

;----------------------------------------------------------------------
; puts - Print a zero‑terminated string
;----------------------------------------------------------------------
puts:
    push bp
    mov bp, sp
    mov di, word ptr [bp+4]
    mov ah, 02h
puts_loop:
    mov dl, byte ptr [di]
    int 21h
    inc di
    test dl, dl
    jnz puts_loop
    mov sp, bp
    pop bp
    ret

;----------------------------------------------------------------------
; putchar - display a character
;----------------------------------------------------------------------
putchar:
    push bp
    mov bp, sp
    mov dx, word ptr [bp+4]
    mov ah, 02h
    int 21h
    mov sp, bp
    pop bp
    ret
    
;----------------------------------------------------------------------
; getchar - read a character
;----------------------------------------------------------------------
getchar:
    push bp
    mov bp, sp
    mov ah, 01h
    int 21h
    mov sp, bp
    pop bp
    ret

;----------------------------------------------------------------------
; putnewline - output CRLF
;----------------------------------------------------------------------
putnewline:
    push bp
    mov bp, sp
    mov dx, 10
    push dx
    call putchar
    add sp, 2
    mov dx, 13
    push dx
    call putchar
    add sp, 2
    mov sp, bp
    pop bp
    ret

;----------------------------------------------------------------------
; itoa_hex - Convert 16‑bit signed to hex string
;----------------------------------------------------------------------
itoa_hex:
    push bp
    mov bp, sp
    mov di, [bp+4]
    mov bx, [bp+6]
    test bx, bx
    jnz itoa_hex_not_zero
    mov byte ptr [di], '0'
    inc di
    mov ax, 0
    jmp itoa_hex_done
itoa_hex_not_zero:
    test bx, bx
    jns itoa_hex_positive
    mov byte ptr [di], '-'
    inc di
    neg bx
itoa_hex_positive:
    mov cx, 4
itoa_hex_loop:
    rol bx, 4
    mov al, bl
    and al, 0Fh
    cmp al, 10  
    jl digit    
    add al, 'A' - 10
    jmp put_char
digit:
    add al, '0'
put_char:
    mov byte ptr [di], al
    inc di
    loop itoa_hex_loop
    mov byte ptr [di], 0
itoa_hex_done:
    mov ax, 8
    pop bp
    ret

;----------------------------------------------------------------------
; itoa_dec - Convert 16‑bit signed to decimal string
;----------------------------------------------------------------------
itoa_dec:
    push bp
    mov bp, sp
    mov di, word ptr [bp+4]
    mov ax, word ptr [bp+6]
    test ax, ax
    jnz itoa_not_zero
    mov byte ptr [di], '0'
    mov ax, 1
    jmp itoa_done
itoa_not_zero:
    xor bx, bx
    cmp ax, 0
    jge itoa_positive
    mov bx, 1 
    neg ax    
itoa_positive:
    xor cx, cx
    mov si, 10
itoa_divide_loop:
    xor dx, dx
    div si
    push dx
    inc cx
    test ax, ax
    jnz itoa_divide_loop
    mov di, word ptr [bp+4]
    test bx, bx
    jz itoa_no_sign
    mov byte ptr [di], '-'
    inc di
itoa_no_sign:
    mov bx, cx
    jcxz itoa_skip_write   
itoa_write_loop:
    pop dx
    add dl, '0'
    mov byte ptr [di], dl
    inc di
    loop itoa_write_loop
    mov byte ptr [di], 0
itoa_skip_write:
    mov ax, bx                
    test bx, bx                
    jz itoa_done_size
    inc ax
itoa_done_size:
itoa_done:
    mov sp, bp
    pop bp
    ret

;----------------------------------------------------------------------
; itoa_hex32 - Convert signed 32‑bit to hex string
;----------------------------------------------------------------------
itoa_hex32:
    push bp
    mov bp, sp
    push si
    push di
    push bx
    mov di, [bp+4]
    mov dx, [bp+6]
    mov ax, [bp+8]
    xor bh, bh
    test dx, dx
    jns itoa_hex32_positive
    mov bh, 1
    mov byte ptr [di], '-'
    inc di
    not dx
    not ax
    add ax, 1
    adc dx, 0
itoa_hex32_positive:
    xor bl, bl
    mov cx, 16
itoa_hex32_digit_loop:
    push ax
    mov ax, dx
    xor dx, dx
    div cx
    mov si, ax
    pop ax
    div cx
    push dx
    inc bl
    mov dx, si
    mov si, ax
    or si, dx
    jnz itoa_hex32_digit_loop
    xor ch, ch
    mov cl, bl
itoa_hex32_write_loop:
    pop dx
    add dl, '0'
    cmp dl, '9'
    jbe itoa_hex32_store
    add dl, 'A'-'0'-10
itoa_hex32_store:
    mov byte ptr [di], dl
    inc di
    dec cx
    jnz itoa_hex32_write_loop
    mov byte ptr [di], 0
    mov al, bl
    add al, bh
    xor ah, ah
    pop bx
    pop di
    pop si
    mov sp, bp
    pop bp
    ret

;----------------------------------------------------------------------
; itoa_dec32 - Convert signed 32‑bit to decimal string
;----------------------------------------------------------------------
itoa_dec32:
    push bp
    mov bp, sp
    push si
    push di
    push bx
    mov di, [bp+4]
    mov dx, [bp+6]
    mov ax, [bp+8]
    xor bh, bh
    test dx, dx
    jns itoa_dec32_positive
    mov bh, 1
    mov byte ptr [di], '-'
    inc di
    not dx
    not ax
    add ax, 1
    adc dx, 0
itoa_dec32_positive:
    xor bx, bx
    mov cx, 10
itoa_dec32_digit_loop:
    push ax
    mov ax, dx
    xor dx, dx
    div cx
    mov si, ax
    pop ax
    div cx
    push dx
    inc bl
    mov dx, si
    mov si, ax
    or si, dx
    jnz itoa_dec32_digit_loop
    mov cx, bx
itoa_dec32_write_loop:
    pop dx
    add dl, '0'
    mov [di], dl
    inc di
    dec cx
    jnz itoa_dec32_write_loop
    mov byte ptr [di], 0
    mov al, bl
    add al, bh
    xor ah, ah
    pop bx
    pop di
    pop si
    mov sp, bp
    pop bp
    ret

;----------------------------------------------------------------------
; atoi_dec - Convert decimal string to signed 16‑bit
;----------------------------------------------------------------------
atoi_dec:
    push bp
    mov bp, sp
    push si
    push di
    push bx
    push dx
    mov si, word ptr [bp+4]
    mov cx, word ptr [bp+6]
    xor ax, ax
    xor di, di
    test cx, cx
    jz atoi_dec_end_convert
    mov bl, byte ptr [si]
    cmp bl, '-'
    jne atoi_dec_no_sign
    inc di
    inc si
    dec cx
    test cx, cx
    jz atoi_dec_end_convert
atoi_dec_no_sign:
atoi_dec_convert_loop:
    mov bl, byte ptr [si]
    cmp bl, 0dh
    jb atoi_dec_end_convert
    cmp bl, '0'
    jb atoi_dec_invalid_number
    cmp bl, '9'
    ja atoi_dec_invalid_number
    sub bl, '0'
    mov bh, 0
    mov dx, ax
    cmp dx, 3276
    ja atoi_dec_overflow
    jne atoi_dec_safe_mul
    cmp di, 0
    jne atoi_dec_neg_limit
    cmp bl, 7
    ja atoi_dec_overflow
    jmp atoi_dec_safe_mul
atoi_dec_neg_limit:
    cmp bl, 8
    ja atoi_dec_overflow
atoi_dec_safe_mul:
    mov dx, 10
    mul dx
    test dx, dx
    jnz atoi_dec_overflow
    add ax, bx
    jc atoi_dec_overflow
    inc si
    dec cx
    jnz atoi_dec_convert_loop
atoi_dec_end_convert:
    test di, di
    clc
    jz atoi_dec_done
    cmp ax, 32768
    clc
    jne atoi_dec_neg_normal
    mov ax, -32768
    clc
    jmp atoi_dec_done
atoi_dec_neg_normal:
    neg ax
    clc
    jo atoi_dec_overflow
atoi_dec_done:
    pop dx
    pop bx
    pop di
    pop si
    mov sp, bp
    pop bp
    ret
atoi_dec_overflow:
    cmp di, 0
    jne atoi_dec_overflow_neg
    mov ax, ERROR_OVERFLOW
    stc
    jmp atoi_dec_done
atoi_dec_overflow_neg:
    mov ax, ERROR_OVERFLOW
    stc    
    jmp atoi_dec_done
atoi_dec_invalid_number:
    mov ax, ERROR_INVALID_NUMBER
    stc
    jmp atoi_dec_done

;----------------------------------------------------------------------
; atoi_hex - Convert hex string to signed 16‑bit
;----------------------------------------------------------------------
atoi_hex:
    push bp
    mov bp, sp
    push si
    push di
    push bx
    push dx
    mov si, word ptr [bp+4]
    mov cx, word ptr [bp+6]
    xor ax, ax
    xor di, di
    test cx, cx
    jz atoi_hex_invalid_number
    mov bl, byte ptr [si]
    cmp bl, '-'
    jne atoi_hex_no_sign
    inc di
    inc si
    dec cx
    test cx, cx
    jz atoi_hex_invalid_number
atoi_hex_no_sign:
    cmp cx, 2
    jb atoi_hex_no_prefix
    mov bl, byte ptr [si]
    cmp bl, '0'
    jne atoi_hex_no_prefix
    mov bl, byte ptr [si+1]
    cmp bl, 'x'
    je atoi_hex_prefix_skip
    cmp bl, 'X'
    jne atoi_hex_no_prefix
atoi_hex_prefix_skip:
    add si, 2
    sub cx, 2
    test cx, cx
    jz atoi_hex_invalid_number
atoi_hex_no_prefix:
atoi_hex_convert_loop:
    mov bl, byte ptr [si]
    cmp bl, '0'
    jb atoi_hex_invalid_number
    cmp bl, '9'
    jbe atoi_hex_digit_0_9
    cmp bl, 'A'
    jb atoi_hex_invalid_number
    cmp bl, 'F'
    jbe atoi_hex_digit_bA_F
    cmp bl, 'a'
    jb atoi_hex_invalid_number
    cmp bl, 'f'
    jbe atoi_hex_digit_a_f
    jmp atoi_hex_invalid_number
atoi_hex_digit_0_9:
    sub bl, '0'
    jmp atoi_hex_got_digit
atoi_hex_digit_bA_F:
    sub bl, 'A'
    add bl, 10
    jmp atoi_hex_got_digit
atoi_hex_digit_a_f:
    sub bl, 'a'
    add bl, 10
atoi_hex_got_digit:
    mov dx, ax
    shl dx, 4
    cmp di, 0
    je atoi_hex_check_pos_mul
    cmp dx, 8000h
    ja atoi_hex_overflow
    jmp atoi_hex_add_digit
atoi_hex_check_pos_mul:
    cmp dx, 7FFFh
    ja atoi_hex_overflow
atoi_hex_add_digit:
    xor bh, bh
    add dx, bx
    cmp di, 0
    je atoi_hex_check_pos_add
    cmp dx, 8000h
    ja atoi_hex_overflow
    cmp dx, 8000h
    jne atoi_hex_store_negative_result
    cmp cx, 1
    jne atoi_hex_overflow
atoi_hex_store_negative_result:
    mov ax, dx
    jmp atoi_hex_digit_done
atoi_hex_check_pos_add:
    cmp dx, 7FFFh
    ja atoi_hex_overflow
    mov ax, dx
atoi_hex_digit_done:
    inc si
    dec cx
    jnz atoi_hex_convert_loop
atoi_hex_end_convert:
    test di, di
    jz atoi_hex_done
    cmp ax, 8000h
    je atoi_hex_done
    neg ax
atoi_hex_done:
    pop dx
    pop bx
    pop di
    pop si
    mov sp, bp
    pop bp
    clc
    ret
atoi_hex_invalid_number:
    pop dx
    pop bx
    pop di
    pop si
    mov sp, bp
    pop bp
    mov ax, ERROR_INVALID_NUMBER
    stc
    ret
atoi_hex_overflow:
    pop dx
    pop bx
    pop di
    pop si
    mov sp, bp
    pop bp
    mov ax, ERROR_OVERFLOW
    stc
    ret

;----------------------------------------------------------------------
; error_handler - Display error message
;----------------------------------------------------------------------
error_handler:
    push bp
    mov bp, sp
    push dx
    mov ax, word ptr [bp+4]
    mov bx, ax
    shl bx, 1
    mov dx, word ptr [msg_vec + bx] 
    push dx
    call puts
    add sp, 2
    mov ax, 4cFFh
    int 21h
    pop dx
    mov sp, bp
    pop bp
    ret

;----------------------------------------------------------------------
; check_number - helper for format validation
;----------------------------------------------------------------------
check_number:
    push bp
    mov bp, sp
    push cx
    mov si, [bp+4]
    xor cx, cx
    cmp byte ptr [si], '-'
    jne check_number_cycle
    inc si
check_number_cycle:
    cmp byte ptr [si], ' '
    je check_number_end
    cmp byte ptr [si], 0
    je check_number_end
    cmp byte ptr [si], '0'
    jb check_error
    cmp byte ptr [si], '9'
    ja check_error
    inc cx
    inc si
    jmp check_number_cycle
check_number_end:
    cmp cx, 0
    je check_error
    clc
    pop cx
    mov sp, bp
    pop bp
    ret
check_error:
    stc
    pop cx
    mov sp, bp
    pop bp
    ret

;----------------------------------------------------------------------
; check_number_hex - helper for hex format validation
;----------------------------------------------------------------------
check_number_hex:
    push bp
    mov bp, sp
    push cx
    mov si, [bp+4]
    xor cx, cx
    cmp byte ptr [si], '-'
    jne check_hex_cycle
    inc si
check_hex_cycle:
    cmp byte ptr [si], ' '
    je check_hex_end
    cmp byte ptr [si], 0
    je check_hex_end
    cmp byte ptr [si], '0'
    jb check_hex_error
    cmp byte ptr [si], '9'
    jbe check_hex_next
    cmp byte ptr [si], 'A'
    jb check_hex_error
    cmp byte ptr [si], 'F'
    jbe check_hex_next
    jmp check_hex_error
check_hex_next:
    inc cx
    inc si
    jmp check_hex_cycle
check_hex_end:
    cmp cx, 0
    je check_hex_error
    clc
    pop cx
    mov sp, bp
    pop bp
    ret
check_hex_error:
    stc
    pop cx
    mov sp, bp
    pop bp
    ret

;----------------------------------------------------------------------
; parse_expression - Parse expression string
;----------------------------------------------------------------------
parse_expression:
    push bp
    mov bp, sp
    sub sp, 2+1+2+2
    mov di, [bp+4]
    mov cx, [bp+6]
    mov ax, 0
    mov word ptr [bp-7], ax
parse_expression_loop:
    inc di
    cmp byte ptr [di], ' '
    je parse_expression_loop_white_space
    cmp byte ptr [di], 0Dh
    je parse_expression_loop_end
    loop parse_expression_loop
parse_expression_loop_white_space:
    mov ax, word ptr [bp+4]
    mov si, di
    sub di, ax
    clc
    mov ax, di
    mov di, si
    push ax
    push [bp+4]
    call atoi_ptr
    jc parse_number_failed
    add sp, 4
    clc
    mov word ptr [result_a], ax
    inc di
    mov al, byte ptr [di]
    cmp al, '+'
    je parse_expression_op_valid
    cmp al, '-'
    je parse_expression_op_valid
    cmp al, '*'
    je parse_expression_op_valid
    cmp al, '/'
    je parse_expression_op_valid
    cmp al, '%'
    je parse_expression_op_valid
    jmp parse_expression_invalid_op
parse_expression_op_valid:
    mov byte ptr [result_op], al
    inc di
    inc di
    mov word ptr [bp-5], di
    dec di
    mov ax, word ptr [bp-7]
    cmp ax, 1
    je parse_expression_invalid_format
    mov ax, 1
    mov word ptr [bp-7], ax
    loop parse_expression_loop
parse_expression_loop_end:
    mov ax, word ptr [bp-7]
    cmp ax, 1
    jne parse_expression_invalid_format
    mov word ptr [bp-7], ax
    mov ax, 1
    mov ax, word ptr [bp-5]
    sub di, ax
    clc
    mov ax, word ptr [bp-5]
    cmp di, 0
    je parse_expression_invalid_second_operand
    push di
    push ax
    call atoi_ptr
    jc parse_number_failed
    add sp, 4
    clc
    mov word ptr [result_b], ax
    dec di
    mov sp, bp
    pop bp
    xor ax, ax
    clc
    ret
parse_number_failed:
    add sp, 4
    stc
    mov sp, bp
    pop bp
    ret
parse_expression_invalid_op:
    add sp, 4
    mov ax, ERROR_INVALID_EXPRESSION_OP
    stc
    mov sp, bp
    pop bp
    ret
parse_expression_invalid_second_operand:
    add sp, 4
    mov ax, ERROR_INVALID_EXPRESSION
    stc
    mov sp, bp
    pop bp
    ret
parse_expression_invalid_format:
    mov ax, ERROR_INVALID_EXPRESSION
    stc
    mov sp, bp
    pop bp
    ret

;----------------------------------------------------------------------
; calculate - Perform arithmetic operation
;----------------------------------------------------------------------
calculate:
    push bp
    mov bp, sp
    sub sp, 2
    mov ax, word ptr [bp+4]
    mov bx, word ptr [bp+6]
    mov cl, byte ptr [bp+8]
    cmp cl, '+'
    je op_add
    cmp cl, '-'
    je op_sub
    cmp cl, '*'
    je op_mul
    cmp cl, '/'
    je op_div
    cmp cl, '%'
    je op_mod
    jmp invalid_op
op_add:
    add ax, bx
    jo overflow_err
    xor dx, dx
    clc
    jmp done
op_sub:
    sub ax, bx
    jo overflow_err
    xor dx, dx
    clc
    jmp done
op_mul:
    imul bx
    clc
    jmp done
op_div:
    test bx, bx
    jz div_by_zero
    cmp bx, -1
    jne do_div
    cmp ax, -32768
    je overflow_err
do_div:
    cwd
    idiv bx
    xor dx, dx
    clc
    jmp done
op_mod:
    test bx, bx
    jz div_by_zero
    cmp bx, -1
    jne do_mod
    cmp ax, -32768
    je overflow_err
do_mod:
    cwd
    idiv bx
    mov ax, dx
    xor dx, dx
    clc
    jmp done
overflow_err:
    mov ax, ERROR_OVERFLOW
    stc
    jmp done
div_by_zero:
    mov ax, ERROR_DIVIDE_BY_ZERO
    stc
    jmp done
invalid_op:
    mov ax, ERROR_INVALID_EXPRESSION
    stc
done:
    mov sp, bp
    pop bp
    ret

;----------------------------------------------------------------------
; notation - validate base selection
;----------------------------------------------------------------------
notation:
    push bp
    mov bp, sp
    push cx
    xor cx, cx
    mov cl, byte ptr [bp+4]
    cmp cl, 'h'
    je notation_save_ok
    cmp cl, 'd'
    je notation_save_ok
    stc
    mov ah, 3
    jmp notation_end
notation_save_ok:
    mov byte ptr [base], cl
    clc
notation_end:
    pop cx
    mov sp, bp
    pop bp
    ret

;----------------------------------------------------------------------
; start - Entry point
;----------------------------------------------------------------------
start:
    mov ax, data_seg
    mov ds, ax
    mov ax, stack_seg 
    mov ss, ax
    mov bp, sp
    sub sp, 4

    push offset enter_num_sys_msg
    call puts
    add sp, 2

    mov ah, 01h
    int 21h       
    
    push ax
    call notation
    jc notation_error
    add sp, 2
    
    cmp al, 'h'
    je set_hex
    mov word ptr [atoi_ptr], offset atoi_dec
    jmp r_set_hex
    
set_hex:
    mov word ptr [atoi_ptr], offset atoi_hex
    
r_set_hex:
    call putnewline

    push offset enter_exp_msg
    call puts
    add sp, 2

    mov bx, 0
    mov cx, 1023
    lea dx, input_expression
    mov ah, 3Fh
    int 21h

    push ax
    push offset input_expression
    call parse_expression
    jc failed_parsing_expression
    add sp, 4

    mov ax, word ptr [result_a]
    mov bx, word ptr [result_b]
    mov cl, byte ptr [result_op]
    xor ch, ch

    push cx
    push word ptr [result_b]
    push word ptr [result_a]
    call calculate
    jc failed_to_calculate
    add sp, 6

    mov cl, byte ptr [result_op]
    cmp cl, '*'
    je print_32
    jne print_16

print_32:
    mov word ptr [bp-2], dx
    mov word ptr [bp-4], ax
    push dx
    push ax

    push offset output_dec_msg
    call puts
    add sp, 2

    pop ax
    pop dx

    push dx
    push ax

    push ax
    push dx
    push offset formated_string_buffer
    call itoa_dec32
    add sp, 6

    push offset formated_string_buffer
    call puts
    add sp, 2

    call putnewline

    push offset output_hex_msg
    call puts
    add sp, 2

    pop dx
    pop ax

    push dx
    push ax
    push offset formated_string_buffer2
    call itoa_hex32
    add sp, 6

    push offset formated_string_buffer2
    call puts
    add sp, 2

    call putnewline

    mov sp, bp
    mov ax, 4c00h
    int 21h

print_16:
    push ax

    push offset output_dec_msg
    call puts
    add sp, 2

    pop ax
    push ax

    push ax
    push offset formated_string_buffer
    call itoa_dec
    add sp, 4

    push offset formated_string_buffer
    call puts
    add sp, 2

    call putnewline

    pop ax
    push ax
    push offset formated_string_buffer2
    call itoa_hex
    add sp, 4

    push offset output_hex_msg
    call puts
    add sp, 2

    push offset formated_string_buffer2
    call puts
    add sp, 2

    call putnewline

    mov sp, bp
    mov ax, 4c00h
    int 21h

notation_error:
    add sp, 2
    mov ax, ERROR_INVALID_EXPRESSION
    push ax
    call error_handler
    add sp, 2

failed_to_calculate:
    add sp, 4
failed_parsing_expression:
    add sp, 4
    push ax
    call error_handler
    add sp, 2

    mov sp, bp
    mov ax, 4cFFh           
    int 21h

code_seg ends

end start