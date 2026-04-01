; ============================================================
; int do_add(int a, int b)
; Возвращает: AX = a + b, CF=0
; ============================================================
_do_add proc near
    push bp
    mov bp, sp

    mov ax, [bp + arg1]
    add ax, [bp + arg2]

    clc

    mov sp, bp
    pop bp
    ret
_do_add endp

; ============================================================
; int do_sub(int a, int b)
; Возвращает: AX = a - b, CF=0
; ============================================================
_do_sub proc near
    push bp
    mov bp, sp

    mov ax, [bp + arg1]
    sub ax, [bp + arg2]

    clc

    mov sp, bp
    pop bp
    ret
_do_sub endp

; ============================================================
; long do_mul(int a, int b)
; Возвращает: DX:AX = a * b, CF=0
; Результат 32-битный!
; ============================================================
_do_mul proc near
    push bp
    mov bp, sp

    mov ax, [bp + arg1]
    imul word ptr [bp + arg2]   ; DX:AX = AX * arg2 (знаковое)

    clc

    mov sp, bp
    pop bp
    ret
_do_mul endp

; ============================================================
; int do_div(int a, int b)
; Возвращает: AX = a / b (CF=0) или AX = код ошибки (CF=1)
; ============================================================
_do_div proc near
    push bp
    mov bp, sp
    push bx

    ; проверка делителя на ноль
    mov bx, [bp + arg2]
    cmp bx, 0
    je div_err_zero

    ; проверка переполнения: -32768 / -1 = 32768 (не влезает)
    cmp word ptr [bp + arg1], -32768
    jne div_no_overflow
    cmp bx, -1
    je div_err_overflow

div_no_overflow:
    mov ax, [bp + arg1]
    cwd                         ; расширяем знак AX -> DX:AX
    idiv bx                     ; AX = частное, DX = остаток

    clc
    jmp div_end

div_err_zero:
    mov ax, ERROR_DIV_ZERO
    stc
    jmp div_end

div_err_overflow:
    mov ax, ERROR_DIV_OVERFLOW
    stc

div_end:
    pop bx
    mov sp, bp
    pop bp
    ret
_do_div endp

; ============================================================
; int do_mod(int a, int b)
; Возвращает: AX = a % b (CF=0) или AX = код ошибки (CF=1)
; ============================================================
_do_mod proc near
    push bp
    mov bp, sp
    push bx

    mov bx, [bp + arg2]
    cmp bx, 0
    je mod_err_zero

    cmp word ptr [bp + arg1], -32768
    jne mod_no_overflow
    cmp bx, -1
    je mod_err_overflow

mod_no_overflow:
    mov ax, [bp + arg1]
    cwd
    idiv bx
    mov ax, dx                  ; остаток в DX, переносим в AX

    clc
    jmp mod_end

mod_err_zero:
    mov ax, ERROR_DIV_ZERO
    stc
    jmp mod_end

mod_err_overflow:
    mov ax, ERROR_DIV_OVERFLOW
    stc

mod_end:
    pop bx
    mov sp, bp
    pop bp
    ret
_do_mod endp

; ============================================================
; int calculate(int a, int b, int op)
; Вызывает нужную арифметическую функцию по коду оператора
; Результат: AX (или DX:AX для умножения), CF при ошибке
; Также сохраняет результат в result_low, result_high, is_result_32bit
; ============================================================
_calculate proc near
    push bp
    mov bp, sp

    mov al, byte ptr [bp + arg3]

    cmp al, '+'
    je calc_add
    cmp al, '-'
    je calc_sub
    cmp al, '*'
    je calc_mul
    cmp al, '/'
    je calc_div
    cmp al, '%'
    je calc_mod

    mov ax, ERROR_INVALID_OPERATOR
    stc
    jmp calc_end

calc_add:
    push word ptr [bp + arg2]
    push word ptr [bp + arg1]
    call _do_add
    add sp, 4
    
    mov word ptr result_low, ax
    cwd
    mov word ptr result_high, dx
    mov byte ptr is_result_32bit, 0
    
    clc
    jmp calc_end

calc_sub:
    push word ptr [bp + arg2]
    push word ptr [bp + arg1]
    call _do_sub
    add sp, 4
    
    mov word ptr result_low, ax
    cwd
    mov word ptr result_high, dx
    mov byte ptr is_result_32bit, 0
    
    clc
    jmp calc_end

calc_mul:
    push word ptr [bp + arg2]
    push word ptr [bp + arg1]
    call _do_mul
    add sp, 4
    
    mov word ptr result_low, ax
    mov word ptr result_high, dx
    mov byte ptr is_result_32bit, 1
    
    clc
    jmp calc_end

calc_div:
    push word ptr [bp + arg2]
    push word ptr [bp + arg1]
    call _do_div
    jc calc_div_err             ; проверяем CF ДО add sp
    add sp, 4
    
    mov word ptr result_low, ax
    cwd
    mov word ptr result_high, dx
    mov byte ptr is_result_32bit, 0
    
    clc
    jmp calc_end

calc_div_err:
    add sp, 4                   ; чистим стек при ошибке
    stc                         ; восстанавливаем CF=1
    jmp calc_end

calc_mod:
    push word ptr [bp + arg2]
    push word ptr [bp + arg1]
    call _do_mod
    jc calc_mod_err             ; проверяем CF ДО add sp
    add sp, 4
    
    mov word ptr result_low, ax
    cwd
    mov word ptr result_high, dx
    mov byte ptr is_result_32bit, 0
    
    clc
    jmp calc_end

calc_mod_err:
    add sp, 4                   ; чистим стек при ошибке
    stc                         ; восстанавливаем CF=1

calc_end:
    mov sp, bp
    pop bp
    ret
_calculate endp