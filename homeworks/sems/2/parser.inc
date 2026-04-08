; ============================================================
; int atoi(const char *str)
; ѕринимает: указатель на нуль-терминированную строку с числом
; ¬озвращает: AX = число (CF=0) или AX = код ошибки (CF=1)
; ============================================================
_atoi proc near
    push bp
    mov bp, sp
    
    push si
    push bx
    push cx
    push dx

    mov si, [bp + arg1]
    xor ax, ax
    xor cx, cx

    cmp byte ptr [si], 0
    je atoi_err_empty

    cmp byte ptr [si], '-'
    jne atoi_digits

    mov cx, 1
    inc si

    cmp byte ptr [si], '-'
    je atoi_err_multisign
    cmp byte ptr [si], 0
    je atoi_err_format
    cmp byte ptr [si], ' '
    je atoi_err_format

atoi_digits:
    cmp byte ptr [si], 0
    je atoi_after_loop

    mov dl, byte ptr [si]

    cmp dl, '0'
    jb atoi_err_invalid
    cmp dl, '9'
    jbe atoi_is_digit_09

    cmp word ptr input_base, 10
    je atoi_err_invalid

    cmp dl, 'A'
    jb atoi_err_invalid
    cmp dl, 'F'
    jbe atoi_is_hex_upper

    cmp dl, 'a'
    jb atoi_err_invalid
    cmp dl, 'f'
    jbe atoi_is_hex_lower

    jmp atoi_err_invalid

atoi_is_digit_09:
    sub dl, '0'
    jmp atoi_accumulate

atoi_is_hex_upper:
    sub dl, 'A'
    add dl, 10
    jmp atoi_accumulate

atoi_is_hex_lower:
    sub dl, 'a'
    add dl, 10

atoi_accumulate:
    push dx
    mov bx, word ptr input_base
    mul bx
    cmp dx, 0
    pop dx
    jne atoi_err_overflow

    xor dh, dh
    add ax, dx
    jc atoi_err_overflow

    inc si
    jmp atoi_digits

atoi_after_loop:
    cmp cx, 1
    je atoi_negative

    ; положительное число
    cmp word ptr input_base, 16
    je atoi_hex_positive

    ; DEC: 0..32767
    cmp ax, 32767
    ja atoi_err_overflow
    jmp atoi_success

atoi_hex_positive:
    ; HEX без минуса: 0..FFFFh
    ; числа 8000h-FFFFh будут интерпретированы как отрицательные через WORD
    jmp atoi_success

atoi_negative:
    ; отрицательное: абсолютное значение <= 32768
    cmp ax, 32768
    ja atoi_err_overflow
    neg ax

atoi_success:
    clc
    jmp atoi_end

atoi_err_empty:
    mov ax, ERROR_EMPTY_INPUT
    jmp atoi_error
atoi_err_multisign:
    mov ax, ERROR_MULTIPLE_SIGNS
    jmp atoi_error
atoi_err_format:
    mov ax, ERROR_FORMAT
    jmp atoi_error
atoi_err_invalid:
    mov ax, ERROR_INVALID_CHAR
    jmp atoi_error
atoi_err_overflow:
    mov ax, ERROR_OVERFLOW_NUM
    jmp atoi_error

atoi_error:
    stc

atoi_end:
    pop dx
    pop cx
    pop bx
    pop si
    mov sp, bp
    pop bp
    ret
_atoi endp

; ============================================================
; int check(const char *input_line)
; ѕровер€ет формат строки "num1 op num2", парсит и сохран€ет
; num1, num2, operator в глобальные переменные
; ¬озвращает: AX = 0 (CF=0) или AX = код ошибки (CF=1)
; ============================================================
_check proc near
    push bp
    mov bp, sp
    
    push si
    push bx
    push di

    mov si, [bp + arg1]

    ; --- проверка пустой строки ---
    cmp byte ptr [si], 0
    je check_err_empty

    ; --- запомнить начало числа1 ---
    mov di, si

    ; --- пропустить знак минуса если есть ---
    cmp byte ptr [si], '-'
    jne check_skip_sign1
    inc si
check_skip_sign1:

    ; --- пропустить цифры числа1 ---
check_num1_loop:
    cmp byte ptr [si], 0
    je check_err_format
    cmp byte ptr [si], ' '
    je check_num1_done

    mov dl, byte ptr [si]
    cmp dl, '0'
    jb check_err_invalid
    cmp dl, '9'
    jbe check_num1_next

    cmp word ptr input_base, 10
    je check_err_invalid

    cmp dl, 'A'
    jb check_err_invalid
    cmp dl, 'F'
    jbe check_num1_next
    cmp dl, 'a'
    jb check_err_invalid
    cmp dl, 'f'
    jbe check_num1_next

    jmp check_err_invalid

check_num1_next:
    inc si
    jmp check_num1_loop

check_num1_done:
    ; SI указывает на пробел после числа1
    ; провер€ем что число1 не пустое
    cmp si, di
    je check_err_format

    ; --- временно ставим 0 вместо пробела ---
    mov bl, byte ptr [si]
    mov byte ptr [si], 0

    ; --- вызываем atoi дл€ числа1 ---
    push di
    call _atoi
    jc check_atoi1_err          ; провер€ем CF ƒќ add sp!
    add sp, 2

    mov word ptr num1, ax
    jmp check_restore1

check_atoi1_err:
    add sp, 2                   ; чистим стек при ошибке
    mov byte ptr [si], bl       ; восстанавливаем пробел
    stc
    jmp check_end               ; AX уже содержит код ошибки

check_restore1:
    ; восстанавливаем пробел
    mov byte ptr [si], bl

    ; --- парсинг оператора ---
    inc si                      ; пропускаем пробел

    mov al, byte ptr [si]

    cmp al, 0
    je check_err_no_op

    cmp al, '+'
    je check_op_ok
    cmp al, '-'
    je check_op_ok
    cmp al, '*'
    je check_op_ok
    cmp al, '/'
    je check_op_ok
    cmp al, '%'
    je check_op_ok
    jmp check_err_invalid_op

check_op_ok:
    mov byte ptr operator, al
    inc si

    ; --- провер€ем пробел после оператора ---
    cmp byte ptr [si], ' '
    jne check_err_format
    inc si

    ; --- провер€ем что есть второе число ---
    cmp byte ptr [si], 0
    je check_err_no_second

    ; --- запоминаем начало числа2 ---
    mov di, si

    ; --- пропускаем знак минуса если есть ---
    cmp byte ptr [si], '-'
    jne check_skip_sign2
    inc si
check_skip_sign2:

    ; --- пропускаем цифры числа2 ---
check_num2_loop:
    cmp byte ptr [si], 0
    je check_num2_done

    mov dl, byte ptr [si]
    cmp dl, '0'
    jb check_err_invalid
    cmp dl, '9'
    jbe check_num2_next

    cmp word ptr input_base, 10
    je check_err_invalid

    cmp dl, 'A'
    jb check_err_invalid
    cmp dl, 'F'
    jbe check_num2_next
    cmp dl, 'a'
    jb check_err_invalid
    cmp dl, 'f'
    jbe check_num2_next

    jmp check_err_invalid

check_num2_next:
    inc si
    jmp check_num2_loop

check_num2_done:
    ; --- вызываем atoi дл€ числа2 ---
    push di
    call _atoi
    jc check_atoi2_err          ; провер€ем CF ƒќ add sp!
    add sp, 2

    mov word ptr num2, ax
    jmp check_success

check_atoi2_err:
    add sp, 2                   ; чистим стек при ошибке
    stc
    jmp check_end               ; AX уже содержит код ошибки

check_success:
    xor ax, ax                  ; ERROR_SUCCESS = 0
    clc
    jmp check_end

check_err_empty:
    mov ax, ERROR_EMPTY_INPUT
    jmp check_error
check_err_format:
    mov ax, ERROR_FORMAT
    jmp check_error
check_err_invalid:
    mov ax, ERROR_INVALID_CHAR
    jmp check_error
check_err_no_op:
    mov ax, ERROR_NO_OPERATOR
    jmp check_error
check_err_invalid_op:
    mov ax, ERROR_INVALID_OPERATOR
    jmp check_error
check_err_no_second:
    mov ax, ERROR_NO_SECOND_OPERAND
    jmp check_error

check_error:
    stc

check_end:
    pop di
    pop bx
    pop si
    mov sp, bp
    pop bp
    ret
_check endp