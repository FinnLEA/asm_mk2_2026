; Функции для ввода-вывода строк/символов (используется соглашение cdecl)

; void putchar(int c)
; выводит символ на экран (младший байт переданного аргумента)
_putchar proc near
    push bp
    mov bp, sp
    
    mov dx, word ptr [bp + 4]
    mov ah, 02h
    int 21h
    
    mov sp, bp
    pop bp
    ret
_putchar endp    
    
; int getchar()
; читает символ с клавиатуры и возвращает его (считанный символ - младший байт (al) регистра ax)
_getchar proc near
    push bp
    mov bp, sp
    
    mov ah, 01h
    int 21h
    
    mov sp, bp
    pop bp
    ret
_getchar endp

; int strlen(const char *str)
; находит длинну строки (до завершающего нуля), адрес которой является аргументом
_strlen proc near
    push bp
    mov bp, sp
    
    mov bx, word ptr [bp + 4] 
    xor ax, ax ; счётчик (ax)

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
    
; void putstr(const char *str)
; выводит строку на экран (до завершающего нуля), адрес которой передан в качестве аргумента
_putstr proc near
    push bp
    mov bp, sp
    
    ; находим длину строки
    push word ptr [bp + 4] 
    call _strlen
    add sp, 2
    
    ; выводим строку
    mov cx, ax
    mov dx, word ptr [bp + 4]
    mov ah, 40h
    mov bx, 1
    int 21h
    
    mov sp, bp
    pop bp
    ret
_putstr endp
    
; void getstr(const char *str, int max_len)
; читает строку с клавиатуры с поддержкой Backspace,
; выводит подсказки (если вызывается отдельно) и сохраняет строку в память.
_getstr proc near
    push bp
    mov bp, sp
    push bx
    push cx
    push si

    mov cx, word ptr [bp + 6] ; max_len
    dec cx                    ; оставляем 1 байт под нуль-терминатор
    mov bx, word ptr [bp + 4] ; адрес буфера
    xor si, si                ; счётчик введённых символов

getscyc:
    cmp si, cx
    je getsret

    mov ah, 08h               ; читаем символ БЕЗ авто-эха
    int 21h

    cmp al, 13                ; Enter (CR)
    je getsret
    cmp al, 10                ; LF
    je getsret

    cmp al, 8                 ; Backspace
    jne getscyc_store

    ; --- Обработка Backspace ---
    test si, si
    jz getscyc                ; если буфер пуст, игнорируем
    dec si
    dec bx                    ; откатываем указатель в буфере

; Визуальное удаление символа: курсор назад, пробел, курсор назад
    mov dl, 8
    mov ah, 02h
    int 21h
    mov dl, ' '
    int 21h
    mov dl, 8
    int 21h
    jmp getscyc

; --- Сохранение символа ---
getscyc_store:
    cmp al, 32                ; игнорируем управляющие символы (< пробела)
    jb getscyc
    cmp al, 126               ; и символы > ~
    ja getscyc

    mov byte ptr [bx], al
    inc bx
    inc si

; Ручной вывод символа на экран
    mov dl, al
    mov ah, 02h
    int 21h
    jmp getscyc

getsret:
    mov byte ptr [bx], 0      ; нуль-терминатор
    call _putnewline
    pop si
    pop cx
    pop bx
    mov sp, bp
    pop bp
    ret
_getstr endp

; void putnewline()
; выводит на экран возврат каретки (\r) и перевод строки (\n), т.е. переводит вывод на новую строку
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

; void exit(int code)
; завершает работу программы с кодом, переданным в качетве аргумента (кодом является младший байт аргумента)  
_exit proc near
    push bp
    mov bp, sp
    
    mov ax, word ptr [bp + 4]
    mov ah, 4ch
    int 21h
    
    mov sp, bp
    pop bp
    ret
_exit endp
    
; void exit0()
; завершает работу программы с кодом 0 
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