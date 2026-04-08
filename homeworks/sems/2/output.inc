; ============================================================
; void itoa(int num, char *str)
; Переводит 16-битное знаковое число в десятичную строку
; ============================================================
_itoa proc near
    push bp
    mov bp, sp
    
    push si
    push bx
    push cx
    push dx

    mov ax, [bp + arg1]         ; число
    mov si, [bp + arg2]         ; адрес буфера
    xor cx, cx                  ; счётчик цифр

    ; проверка на отрицательное
    cmp ax, 0
    jge itoa_positive

    ; отрицательное: ставим минус и берём модуль
    mov byte ptr [si], '-'
    inc si
    neg ax

itoa_positive:
    ; если число = 0, отдельно обрабатываем
    cmp ax, 0
    jne itoa_push_loop

    mov byte ptr [si], '0'
    inc si
    jmp itoa_finish

    ; разбиваем число на цифры (от младшей к старшей, в стек)
itoa_push_loop:
    cmp ax, 0
    je itoa_pop_loop

    xor dx, dx
    mov bx, 10
    div bx                      ; AX = частное, DX = остаток

    add dl, '0'                 ; остаток -> символ
    push dx                     ; в стек
    inc cx                      ; считаем цифры
    jmp itoa_push_loop

    ; достаём из стека (от старшей к младшей)
itoa_pop_loop:
    cmp cx, 0
    je itoa_finish

    pop dx
    mov byte ptr [si], dl
    inc si
    dec cx
    jmp itoa_pop_loop

itoa_finish:
    mov byte ptr [si], 0        ; завершающий ноль

    pop dx
    pop cx
    pop bx
    pop si
    mov sp, bp
    pop bp
    ret
_itoa endp

; ============================================================
; void print_dec_16(int num)
; Выводит 16-битное знаковое число в десятичной системе
; ============================================================
_print_dec_16 proc near
    push bp
    mov bp, sp

    ; переводим число в строку itoa_buffer
    push offset itoa_buffer
    push word ptr [bp + arg1]
    call _itoa
    add sp, 4

    ; выводим строку
    push offset itoa_buffer
    call _putstr
    add sp, 2

    mov sp, bp
    pop bp
    ret
_print_dec_16 endp

; ============================================================
; void print_dec_32(int high, int low)
; Выводит 32-битное знаковое число (DX:AX формат) в десятичной
; high = [bp+arg1], low = [bp+arg2]
; ============================================================
_print_dec_32 proc near
    push bp
    mov bp, sp

    push si
    push bx
    push cx
    push di

    mov dx, [bp + arg1]         ; старшие 16 бит
    mov ax, [bp + arg2]         ; младшие 16 бит

    mov si, offset itoa_buffer
    xor cx, cx

    ; проверка на отрицательное
    test dx, 8000h
    jz p32_positive

    mov byte ptr [si], '-'
    inc si

    ; NEG 32-bit
    not dx
    not ax
    add ax, 1
    adc dx, 0

p32_positive:
    ; проверка на ноль
    cmp dx, 0
    jne p32_push_loop
    cmp ax, 0
    jne p32_push_loop

    mov byte ptr [si], '0'
    inc si
    jmp p32_finish

p32_push_loop:
    cmp dx, 0
    jne p32_do_divide
    cmp ax, 0
    je p32_pop_loop

p32_do_divide:
    mov di, 10

    ; делим DX:AX на 10
    mov bx, ax                  ; сохраняем младшую часть
    mov ax, dx                  ; AX = старшая часть
    xor dx, dx
    div di                      ; AX = старшая/10, DX = остаток

    xchg bx, ax                 ; AX = младшая часть, BX = новая старшая
    div di                      ; AX = новая младшая, DX = цифра

    push dx                     ; сохраняем цифру в стек
    inc cx

    mov dx, bx                  ; DX = новая старшая часть
    jmp p32_push_loop

p32_pop_loop:
    cmp cx, 0
    je p32_finish

    pop dx
    add dl, '0'
    mov byte ptr [si], dl
    inc si
    dec cx
    jmp p32_pop_loop

p32_finish:
    mov byte ptr [si], 0

    push offset itoa_buffer
    call _putstr
    add sp, 2

    pop di
    pop cx
    pop bx
    pop si
    mov sp, bp
    pop bp
    ret
_print_dec_32 endp

; ============================================================
; void print_hex_16(int num)
; Выводит 16-битное число в шестнадцатеричной системе (4 цифры)
; ============================================================
_print_hex_16 proc near
    push bp
    mov bp, sp
    
    push cx
    push bx

    ; сначала выводим префикс ПОКА НЕ загрузили число в AX
    push '0'
    call _putchar
    add sp, 2
    push 'x'
    call _putchar
    add sp, 2

    ; ТЕПЕРЬ загружаем число в AX (после того как префикс уже выведен)
    mov ax, [bp + arg1]
    mov cx, 4

hex16_loop:
    rol ax, 4
    mov bx, ax
    and bx, 0Fh

    cmp bl, 9
    jbe hex16_digit
    add bl, 'A' - 10
    jmp hex16_print
hex16_digit:
    add bl, '0'
hex16_print:
    push ax              ; СОХРАНЯЕМ AX перед вызовом putchar
    push bx
    call _putchar
    add sp, 2
    pop ax               ; ВОССТАНАВЛИВАЕМ AX после вызова

    dec cx
    jnz hex16_loop

    pop bx
    pop cx
    mov sp, bp
    pop bp
    ret
_print_hex_16 endp

; ============================================================
; void print_hex_32(int high, int low)
; Выводит 32-битное число в hex (8 цифр)
; high = [bp+arg1], low = [bp+arg2]
; ============================================================
_print_hex_32 proc near
    push bp
    mov bp, sp

    ; выводим "0x" префикс
    push '0'
    call _putchar
    add sp, 2
    push 'x'
    call _putchar
    add sp, 2

    ; сначала старшие 16 бит (без префикса)
    mov ax, [bp + arg1]
    push ax
    call _print_hex_16_nopfx
    add sp, 2

    ; потом младшие 16 бит
    mov ax, [bp + arg2]
    push ax
    call _print_hex_16_nopfx
    add sp, 2

    mov sp, bp
    pop bp
    ret
_print_hex_32 endp

; ============================================================
; void print_hex_16_nopfx(int num)
; То же что print_hex_16 но без префикса "0x"
; ============================================================
_print_hex_16_nopfx proc near
    push bp
    mov bp, sp
    
    push cx
    push bx

    mov ax, [bp + arg1]
    mov cx, 4

hex16np_loop:
    rol ax, 4
    mov bx, ax
    and bx, 0Fh

    cmp bl, 9
    jbe hex16np_digit
    add bl, 'A' - 10
    jmp hex16np_print
hex16np_digit:
    add bl, '0'
hex16np_print:
    push bx
    call _putchar
    add sp, 2

    dec cx
    jnz hex16np_loop

    pop bx
    pop cx
    mov sp, bp
    pop bp
    ret
_print_hex_16_nopfx endp