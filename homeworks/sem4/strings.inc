; Функции для ввода-вывода строк/символов (используется соглашение cdecl)

; int atoi(const char *str)
; string to number conversion function. number in ax
_atoi: 
    push bp
    mov bp, sp
	
    push cx
    push si					; flag for a sign
    push bx
	
    mov bx, [bp + arg1]
    xor ax, ax      		; result
    xor cx, cx
    xor si, si        		; 0 = +, 1 = -

    ; minus check
    cmp byte ptr [bx], '-'
    jne _iteration
	
    mov si, 1				; negative number flag
    inc bx					; moved to numbers

_iteration:
    cmp byte ptr [bx], ' '
    je atoi_end
	
    cmp byte ptr [bx], 0
    je atoi_end

    ; get number
    xor cx, cx
    mov cl, byte ptr [bx]
    sub cl, '0'

    ; overflow check BEFORE multiplication 
    cmp si, 0
    jne check_neg

; = positive
check_pos:
    cmp ax, 3276				; maximum for consideration
    ja overflow_common			; if strictly greater - overflow

    jne safe_mul				; if strictly less, we safely multiply

    cmp cl, 7
    ja overflow_common			; if more - overflow
    jmp safe_mul				; otherwise, we multiply safely

; = negative
check_neg:
    cmp ax, 3276
    ja overflow_common			; similarly

    jne safe_mul

    ; ax == 3276 , check number
    cmp cl, 8
    ja overflow_common

safe_mul:
    imul ax, 10
    add ax, cx          	   ; + number

    inc bx				       ; iterate further by number
    jmp _iteration

; = 
overflow_common:
    stc
	jmp atoi_ret

atoi_end:
	cmp si, 0
	je success
	neg ax
success:
	clc				; if everything is good, the number is in ax
	jmp atoi_ret
	
atoi_ret:
	pop bx
	pop si
	pop cx
	mov sp, bp
	pop bp
	ret



; void itoa(int num, char *str)
; function to convert a number to a string
_itoa: 
    push bp
    mov bp, sp
	
	push si
	push di
	push cx
	push dx
	push bx
	
	mov ax, [bp + arg1]		; remembered the number
	mov bx, [bp + arg2]		; remembered the pointer to the buffer for writing
	
	xor di, di 				; 0=positive
	cmp ax, 0
	jge not_negative
	
	mov di, 1
	neg ax					; take the flag into account and make the number positive
	
not_negative: 
	cmp ax, 0
	jne not_zero
	mov byte ptr [bx], '0'
	mov byte ptr [bx + 1], 0
	jmp itoa_end
	
not_zero:
	mov si, bx				; buffer start address
	add si, 6				; saved to the end
	mov byte ptr [si], 0	; recorded the zero terminator

convert_cycle:
	xor dx, dx
	xor cx, cx
	mov cx, 10
	div cx	
	add dl, '0'
	
	dec si
	mov byte ptr [si], dl
	
	cmp ax, 0
	jne convert_cycle
	
	; recorded the zero terminator
	cmp di, 0
	je help_copy
	
	dec si
	mov byte ptr[si], '-'
	
help_copy:
	cmp si, bx
	je itoa_end
	
copy_string:
	mov cl, byte ptr [si]
	mov byte ptr [bx], cl
	inc bx
	inc si
	
	; we write the null terminator and exit
	cmp byte ptr [si], 0
	jne copy_string
	mov byte ptr [bx], 0
	
itoa_end:
	pop bx
	pop dx
	pop cx
	pop di
	pop si
    	mov sp, bp
    	pop bp
    	ret


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

    push bx
    
    mov bx, word ptr [bp + 4] 
    xor ax, ax ; счётчик (ax)

lencyc:    
    cmp byte ptr [bx], 0
    je lenret
    inc ax
    inc bx
    jmp lencyc
    
lenret:    
    pop bx
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
; читает строку с клавиатуры (либо max_len - 1 байт, либо до перевода строки) и сохраняет её в память, 
; при этом дописывает в конец строки завершающий 0
_getstr proc near
    push bp
    mov bp, sp
    
    dec word ptr [bp + 6] ; уменьшаем требуемую длину на 1 (max_len - 1)
    mov bx, word ptr [bp + 4] ; адрес начала строки
    mov si, 0 ; счётчик
 
getscyc: 
    cmp si, word ptr [bp + 6]
    je getsret
    
    call _getchar
    
    cmp al, 10
    je getsret
    cmp al, 13
    je getsret
    
    mov byte ptr [bx], al
    inc bx
    inc si
    jmp getscyc
    
getsret:
    mov byte ptr [bx], 0
    call _putnewline
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