

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

    cmp byte ptr [bx], '+'
    je atoi_end

    cmp byte ptr [bx], '-'
    je atoi_end

    cmp byte ptr [bx], '*'
    je atoi_end

    cmp byte ptr [bx], '/'
    je atoi_end

    cmp byte ptr [bx], '%'
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



; void itoa32(int num, char *str)
; function to convert a number from dx:ax to a string
_itoa32:
	push bp
	mov bp, sp
	
	push ax
	push bx
	push cx
	push dx
	push si
	push di
	
	mov ax, [bp + arg1]		; remembered ax
	mov dx, [bp + arg2]		; remembered dx
	mov di, [bp + arg3]		; address of the beginning of the line to write
	
	cmp ax, 0
	jne not_zero32
	cmp dx, 0
	jne not_zero32
	
	mov byte ptr [di], '0'
	mov byte ptr [di + 1], 0
	jmp end_itoa32
	
not_zero32:
	xor cx, cx				; flag for a sign
	test dx, 8000h			; check the sign
	jz itoa_pos				; if 0 = positive
	
	; transform into a positive number
	not ax
	not dx
	add ax, 1
	adc dx, 0
	mov cx, 1				; flag for a negative number

itoa_pos:
	push cx
	push di
	
	add di, 12
	mov byte ptr [di], 0	; the pointer is at the end of the buffer
	dec di					; last digit pointer
	
itoa_divide:
	push di
	
	xor si, si              ; SI = remainder
	mov cx, 32				; loop counter
	
	; let's save the dividend in temporary registers
	mov di, ax				; DI = younger part
	mov bx, dx				; BX = senior part (temporary)
	
	; collect the private parts back here
	xor ax, ax
	xor dx, dx
	
itoa_div_loop:
	shl di, 1				; shift of the minor part
	rcl bx, 1				; shift of the major part with carry
	
	rcl si, 1				; added a bit to the remainder
	
	cmp si, 10
	jb below_10
	
	sub si, 10		
	
	; we write 1 in the quotient
    shl ax, 1
    rcl dx, 1
    or ax, 1
    jmp next_bit
	
below_10: 				
	; we write 0 in the quotient
    shl ax, 1
    rcl dx, 1
	
next_bit:
	loop itoa_div_loop
	; remainder in SI
	
	mov cx, si				; balance in CX
	pop di
	
	add cl, '0'
	dec di
	mov byte ptr [di], cl
	
	; check the quotient (it's in dx:ax)
    or dx, dx
    jnz itoa_divide
    or ax, ax
    jnz itoa_divide
	
	; sign
	pop si					; start of buffer
	pop cx					; flag
	
	cmp cx, 1
	jne copy_str_32
	
	dec di
	mov byte ptr [di], '-'
	
copy_str_32:	
	xor bx, bx
	mov bl, byte ptr [di]
	mov byte ptr [si], bl
	inc si
	inc di
	
	cmp byte ptr [di], 0
	jne copy_str_32

	mov byte ptr [si], 0

end_itoa32:
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	
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