; шаблон для зачётного задания №2 (калькулятор) с использованием стековых фреймов
.386

arg1 equ 4
arg2 equ 6
arg3 equ 8
arg4 equ 10

var1 equ -2
var2 equ -4
var3 equ -6
var4 equ -8


ERROR_SUCCESS 	equ 0
ERROR_NOTATION 	equ 1
ERROR_NUMBER 	equ 2
ERROR_OVERFLOW 	equ 3
ERROR_OPERATION equ 4
ERROR_DIV_ZERO	equ 5

MAX_AX_DEC 		equ 3276
MAX_BL_POS_DEC 	equ 7
MAX_BL_NEG_DEC 	equ 8

MAX_AX_POS_HEX 	equ 07FFh
MAX_BL_POS_HEX 	equ 0Fh

MAX_AX_NEG_HEX	equ 0800h
MAX_BL_NEG_HEX 	equ 00h


stack segment para stack
db 65530 dup(?)
stack ends

data segment para public
	notation dw 10
	
	buffer db 255 dup(?)
	strnum1 db 255 dup(?)
	strnum2 db 255 dup(?)
	
	number1 dw ?
	number2 dw ?
	operation db ?
	
	result_low dw ?
	result_high dw ?
	
	result_dec db 255 dup(?)
	result_hex db 255 dup(?)
	
	test_str db 255 dup(?)
	

; enters:
	string_enter_note db "Enter string (notation num1 op num2): ",0
	
; errors:
	notation_error_note db "Error: wrong notation! (may be 10 or 16)",0
	number_error_note db "Error: wrong number! (may be (-)12345 or (-)ABC)!",0
	overflow_error_note db "Error: overflow number! (may be in [-32768 | 32767])!",0
	operation_error_note db "Error: wrong operation! (may be +,-,*,/,%)",0
	div_zero_error_note db "Error: dividing by 0!",0
	
; printing:
	result_dec_note db "Dec: ",0
	result_hex_note db "Hex: ",0
	
data ends

code segment para public use16

assume cs:code,ds:data,ss:stack



; void putchar(int c)
; выводит символ на экран (младший байт переданного аргумента)
_putchar:
    push bp
    mov bp, sp
    
    mov dx, word ptr [bp + arg1]
    mov ah, 02h
    int 21h
    
    mov sp, bp
    pop bp
    ret
    
	
	
; int getchar()
; читает символ с клавиатуры и возвращает его (считанный символ - младший байт регистра ax)
_getchar:
    push bp
    mov bp, sp
    
    mov ah, 01h
    int 21h
    
    mov sp, bp
    pop bp
    ret

	
	
; int strlen(const char *str)
; находит длинну строки (до завершающего нуля), адрес которой является аргументом
_strlen: 
    push bp
    mov bp, sp
    
    mov bx, word ptr [bp + arg1] 
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
    
	
	
; void putstr(const char *str)
; выводит строку на экран (до завершающего нуля), адрес которой передан в качестве аргумента
_putstr: 
    push bp
    mov bp, sp
    
    ; находим длину строки
    push word ptr [bp + arg1] 
    call _strlen
    add sp, 2
    
    ; выводим строку
    mov cx, ax
    mov dx, word ptr [bp + arg1]
    mov ah, 40h
    mov bx, 1
    int 21h
    
    mov sp, bp
    pop bp
    ret
    
	
	
; void getstr(const char *str, int max_len)
; читает строку с клавиатуры (либо max_len байт, либо до перевода строки) и сохраняет её в память, 
; при этом дописывает в конец строки завершающий 0
_getstr:
    push bp
    mov bp, sp
	
    ; чтение строки
    mov cx, word ptr [bp + arg2]
    mov dx, word ptr [bp + arg1]
    mov ah, 3fh
    mov bx, 0								
    int 21h
    
    ; добавление в конец завершающего нуля
    mov bx, word ptr [bp + arg1]
    add bx, ax ; добавляем к адресу начала строки длину считанной строки
    sub bx, 2 ; убираем из строки возврат каретки (\r) и перевод строки (\n) 
    mov byte ptr [bx], 0

    mov sp, bp
    pop bp
    ret
	
	
	
; void putnewline()
; выводит на экран возврат каретки (\r) и перевод строки (\n), т.е. переводит вывод на новую строку
_putnewline:
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


	
; void exit(int code)
; завершает работу программы с кодом, переданным в качетве аргумента (кодом является младший байт аргумента)  
_exit:
    push bp
    mov bp, sp
    
    mov ax, word ptr [bp + arg1]
    mov ah, 4ch
	int 21h
    
    mov sp, bp
    pop bp
    ret
    
	
	
; void exit0()
; завершает работу программы с кодом 0 
_exit0:
    push bp
    mov bp, sp
    
    mov dx, ERROR_SUCCESS
    push dx
    call _exit
    add sp, 2
    
    mov sp, bp
    pop bp
    ret

	

; void exit1()
; finish program with code 1 (wrong notation)
_exit1:
    push bp
    mov bp, sp
    
	push offset notation_error_note
	call _putstr
	add sp, 2
	
    mov dx, ERROR_NOTATION
    push dx
    call _exit
    add sp, 2
    
    mov sp, bp
    pop bp
    ret



; void exit2()
; finish program with code 2 (wrong number)
_exit2:
    push bp
    mov bp, sp
    
	push offset number_error_note
	call _putstr
	add sp, 2
	
    mov dx, ERROR_NUMBER
    push dx
    call _exit
    add sp, 2
    
    mov sp, bp
    pop bp
    ret

	

; void exit3()
; finish program with code 3 (overflow number)
_exit3:
    push bp
    mov bp, sp
    
	push offset overflow_error_note
	call _putstr
	add sp, 2
	
    mov dx, ERROR_OVERFLOW
    push dx
    call _exit
    add sp, 2
    
    mov sp, bp
    pop bp
    ret
	
	

; void exit4()
; finish program with code 4 (wrong operation)
_exit4:
    push bp
    mov bp, sp
    
	push offset operation_error_note
	call _putstr
	add sp, 2
	
    mov dx, ERROR_OPERATION
    push dx
    call _exit
    add sp, 2
    
    mov sp, bp
    pop bp
    ret

	
	
; void exit5()
; finish program with code 5 (divide by 0)
_exit5:
    push bp
    mov bp, sp
    
	push offset div_zero_error_note
	call _putstr
	add sp, 2
	
    mov dx, ERROR_DIV_ZERO
    push dx
    call _exit
    add sp, 2
    
    mov sp, bp
    pop bp
    ret	
	
	
; int atoi(const char *str)
; функция перевода строки в число
_atoi:
    push bp
    mov bp, sp
	
	sub sp, 2
	mov word ptr[bp + var1], 0
	
	xor ax, ax
	xor bx, bx
	xor cx, cx
	
	mov si, word ptr[bp + arg1]
	mov bl, byte ptr[si]
	
	cmp bl, '-'
	jne .loop_atoi
	mov word ptr[bp + var1], 1
	inc si
	
.loop_atoi:
	mov bl, byte ptr[si]
	cmp bl, 0
	je .done_atoi
	
	cmp word ptr[notation], 10
	je .dec_atoi
	
	cmp word ptr[notation], 16
	je .hex_atoi

.dec_atoi:
	sub bl, '0'
	
	cmp word ptr[bp + var1], 1
	je .negative_check_overflow_dec
	
.positive_check_overflow_dec:				; checking overflow if num = positive
	cmp ax, MAX_AX_DEC
	ja .overflow_atoi
	jne .checked_overflow_atoi_dec
	
	cmp bl, MAX_BL_POS_DEC
	ja .overflow_atoi
	jmp .checked_overflow_atoi_dec	
	
.negative_check_overflow_dec:				; checking overflow if num = negative
	cmp ax, MAX_AX_DEC
	ja .overflow_atoi
	jne .checked_overflow_atoi_dec
	
	cmp bl, MAX_BL_NEG_DEC
	ja .overflow_atoi

.checked_overflow_atoi_dec:
	mov cx, ax
	mov ax, word ptr[notation]
	mul cx
	add ax, bx
	
	inc si
	jmp .loop_atoi

	
.hex_atoi:
	cmp bl, 'A'
	jae .for_digit_allow_A_atoi
	
	sub bl, '0'
	jmp .hex_atoi2

.for_digit_allow_A_atoi:
	sub bl, 'A'
	add bl, 10
	
.hex_atoi2:
	cmp word ptr[bp + var1], 1
	je .negative_check_overflow_hex
	
.positive_check_overflow_hex:				; checking overflow if num = positive
	cmp ax, MAX_AX_POS_HEX
	ja .overflow_atoi
	jne .checked_overflow_atoi_hex
	
	cmp bl, MAX_BL_POS_HEX
	ja .overflow_atoi
	jmp .checked_overflow_atoi_hex	
	
.negative_check_overflow_hex:				; checking overflow if num = negative
	cmp ax, MAX_AX_NEG_HEX
	ja .overflow_atoi
	jne .checked_overflow_atoi_hex
	
	cmp bl, MAX_BL_NEG_HEX
	ja .overflow_atoi

.checked_overflow_atoi_hex:
	mov cx, ax
	mov ax, word ptr[notation]
	mul cx
	add ax, bx
	
	inc si
	jmp .loop_atoi

.overflow_atoi:
	mov ax, ERROR_OVERFLOW
	stc
	jmp .finish_atoi
	
.done_atoi:
	cmp word ptr[bp + var1], 1
	je .neg_atoi
	clc
	jmp .finish_atoi

.neg_atoi:
	neg ax								; if num < 0
	clc
	
.finish_atoi:
    mov sp, bp
    pop bp
    ret



; void itoadec(int num, char *str)
; функция перевода числа в строку    
_itoadec: 
    push bp
    mov bp, sp
	
	mov ax, word ptr[bp + arg1]			; number
	mov di, word ptr[bp + arg2]			; return string
	
	sub sp, 2
	mov word ptr[bp + var1], 0			; symbol counter
	mov bx, 10							; divider = 10
	
	test ax, ax							; check for negative number
	jns .loop_itoadec
	
	mov byte ptr[di], '-'
	inc di	
	
.loop_itoadec:
	cwd
	idiv bx								; dx = remainder = our digit
	
	cmp dx, 0							; remainder can be negative
	jge .positive_rem_itoadec
	
	neg dx
	
.positive_rem_itoadec:
	add dl, '0'
	push dx								; write to stack for .convert_to_string
	inc word ptr[bp + var1]
	
	cmp ax, 0
	jne .loop_itoadec
	
.convert_to_string_itoadec:
	cmp word ptr[bp + var1], 0
	je .finish_itoadec
	
	pop dx								; take byte from stack and put in string
	mov byte ptr[di], dl
	
	inc di
	dec word ptr[bp + var1]
	jmp .convert_to_string_itoadec
	
.finish_itoadec:
	mov byte ptr[di], 0
	
    mov sp, bp
    pop bp
    ret
	
	
	
; void itoahex(int num, char *str)
; функция перевода числа в строку    
_itoahex: 
    push bp
    mov bp, sp
	
	mov ax, word ptr[bp + arg1]			; number
	mov di, word ptr[bp + arg2]			; return string
	
	sub sp, 2
	mov word ptr[bp + var1], 0			; symbol counter
	mov bx, 16							; divider = 16	
	
.loop_itoahex:
	xor dx, dx
	div bx
	
	cmp dl, 9
	jbe .isdigit_itoahex
	
	add dl, 'A'
	sub dl, 10
	jmp .store_itoahex

.isdigit_itoahex:
	add dl, '0'
	
.store_itoahex:
	push dx
	inc word ptr[bp + var1]
	
	cmp ax, 0
	jne .loop_itoahex

.convert_to_string_itoahex:
	cmp word ptr[bp + var1], 0
	je .finish_itoahex
	
	pop dx
	mov byte ptr[di], dl
	
	inc di
	dec word ptr[bp + var1]
	jmp .convert_to_string_itoahex
	
.finish_itoahex:
	mov byte ptr[di], 0
	
    mov sp, bp
    pop bp
    ret	
	

; void itoadec32(int dx(high), int ax(low), const char* str)
_itoadec32:
	push bp
	mov bp, sp
	
	mov dx, word ptr[bp + arg1]
	mov ax, word ptr[bp + arg2]
	mov di, word ptr[bp + arg3]
	
	sub sp, 8
	mov word ptr[bp + var1], 0			; symbol counter
	mov word ptr[bp + var2], dx			; saving dx
	mov word ptr[bp + var3], ax			; saving ax
	mov word ptr[bp + var4], 0			; temp
	
	mov bx, 10							; divider
	
	cmp dx, 0
	jge .loop_itoadec32
	
	not ax
	not dx
	inc ax
	adc dx, 0
	
	mov word ptr[bp + var2], dx			; saving good numbers > 0
	mov word ptr[bp + var3], ax
	
	mov byte ptr[di], '-'
	inc di
	
.loop_itoadec32:
	mov dx, word ptr[bp + var2]
	mov ax, word ptr[bp + var3]

	mov ax, dx
	xor dx, dx
	; (0 : dx) / 10
	div bx
	; ax = dx / 10
	; dx = dx % 10
	
	mov word ptr[bp + var4], ax			; saving (0 : dx) / 10 for new dx
	
	mov ax, word ptr[bp + var3]
	; ((dx%10) : ax) / 10
	div bx
	; dx = our digit 
	; ax = new ax
	
	add dl, '0'
	push dx								; add digit to stack
	inc word ptr[bp + var1]
	
	mov dx, word ptr[bp + var4]			; take new dx
	
	mov word ptr[bp + var2], dx
	mov word ptr[bp + var3], ax
	
	cmp dx, 0
	jne .loop_itoadec32
	cmp ax, 0
	jne .loop_itoadec32
	
.convert_to_string_itoadec32:
	cmp word ptr[bp + var1], 0
	je .done_itoadec32
	
	pop dx
	mov byte ptr[di], dl
	inc di
	dec word ptr[bp + var1]
	
	jmp .convert_to_string_itoadec32
	
.done_itoadec32:
	mov byte ptr[di], 0
	
.finish_itoadec32:
	mov sp ,bp
	pop bp
	ret


	
; void itoahex32(int dx(high), int ax(low), const char* str)
_itoahex32:
	push bp
	mov bp, sp
	
	mov dx, word ptr[bp + arg1]
	mov ax, word ptr[bp + arg2]
	mov di, word ptr[bp + arg3]
	
	sub sp, 6
	mov word ptr[bp + var1], 0			; symbol counter
	mov word ptr[bp + var2], dx			; saving dx
	mov word ptr[bp + var3], 4			; for low part if ax == 0000

	cmp dx, 0
	jne .low_part_itoahex32

	push di
	push ax
	call _itoahex
	add sp, 4
	jmp .finish_itoahex32
	
.low_part_itoahex32:
	mov bx, 16
	
.loop_itoahex32_low:
	xor dx, dx
	div bx
	cmp dx, 9
	jbe .isdigit_itoahex32_low
	
	add dl, 'A'
	sub dl, 10
	
	push dx
	inc word ptr[bp + var1]
	dec word ptr[bp + var3]
	cmp word ptr[bp + var3], 0
	
	jne .loop_itoahex32_low
	jmp .high_part_itoahex32
	
.isdigit_itoahex32_low:
	add dl, '0'
	
	push dx
	inc word ptr[bp + var1]
	dec word ptr[bp + var3]
	cmp word ptr[bp + var3], 0
	
	jne .loop_itoahex32_low
	
	
.high_part_itoahex32:
	mov ax, word ptr[bp + var2]
	mov word ptr[bp + var3], 4
	
.loop_itoahex32_high:
	xor dx, dx
	div bx
	cmp dx, 9
	jbe .isdigit_itoahex32_high
	
	add dl, 'A'
	sub dl, 10
	
	push dx
	inc word ptr[bp + var1]
	dec word ptr[bp + var3]
	cmp word ptr[bp + var3], 0
	
	jne .loop_itoahex32_high
	jmp .convert_to_string_itoahex32
	
.isdigit_itoahex32_high:
	add dl, '0'
	
	push dx
	inc word ptr[bp + var1]
	dec word ptr[bp + var3]
	cmp word ptr[bp + var3], 0
	
	jne .loop_itoahex32_high
	
.convert_to_string_itoahex32:
	cmp word ptr[bp + var1], 0
	je .done_itoahex32
	
	pop dx								; take byte from stack and put this in string
	mov byte ptr[di], dl
	
	inc di
	dec word ptr[bp + var1]
	jmp .convert_to_string_itoahex32
	
.done_itoahex32:
	mov byte ptr[di], 0
	
.finish_itoahex32:
	mov sp ,bp
	pop bp
	ret
	
	
; int check(const char *input_line)    
; функция проверки введённой строки на соответствие формату
_check: 
    push bp
    mov bp, sp
	
	sub sp, 2
	mov word ptr[bp + var1], 0			; counter buffer (for each operand)
	mov bx, word ptr[bp + arg1]
	
	xor ax, ax
	xor dx, dx
	xor si, si
	
	
.notation_check:
	mov dl, byte ptr[bx]
	cmp dl, '1'
	jne .error1_check
	
	inc bx
	mov dl, byte ptr[bx]
	cmp dl, '0'
	jne .dec_notation_checked
	; mov word ptr[notation], 10		; notation is already = 10
	
	inc bx
	mov dl, byte ptr[bx]
	cmp dl, ' '	
	jne .error1_check
	
	inc bx
	jmp .number1_check
	
.dec_notation_checked:
	cmp dl, '6'
	jne .error1_check
	mov word ptr[notation], 16			; notation = 16	
	
	inc bx
	mov dl, byte ptr[bx]
	cmp dl, ' '
	jne .error1_check
	
	inc bx
	
	
.number1_check:							; check num1
	mov dl, byte ptr[bx]				; first digit
	
	cmp dl, 0
	je .error2_check
	
	cmp dl, ' '
	je .error2_check
	
	cmp dl, '-'
	jne .number1_loop_check
	mov byte ptr[strnum1], dl
	inc word ptr[bp + var1]
	inc bx
	
	mov dl, byte ptr[bx]
	cmp dl, 0
	je .error2_check
	cmp dl, ' '
	je .error2_check
	
.number1_loop_check:
	cmp word ptr[notation], 10
	jne .number1_hex_loop_check

.number1_dec_loop_check:				; if dec 
	mov si, word ptr[bp + var1]
	mov dl, byte ptr[bx]
	
	cmp dl, 0
	je .error4_check
	
	cmp dl, ' '
	je .finish_number1					
	
	cmp dl, '0'							
	jb .error2_check					; digit < 0
	cmp dl, '9'
	ja .error2_check					; digit > 9
	
	mov si, word ptr[bp + var1]
	mov byte ptr[strnum1 + si], dl

	inc word ptr[bp + var1]
	inc bx
	jmp .number1_dec_loop_check

.number1_hex_loop_check:				; if hex 
	mov si, word ptr[bp + var1]
	mov dl, byte ptr[bx]
	
	cmp dl, 0
	je .error4_check
	
	cmp dl, ' '
	je .finish_number1					
	
	cmp dl, '0'							
	jb .error2_check					; digit < 0
	cmp dl, 'F'
	ja .error2_check					; digit > F
	cmp dl, '9'
	jbe .done_digit1_hex_check			; digit <= 9
	cmp dl, 'A'
	jae .done_digit1_hex_check			; digit >= A 
	
	jmp .error2_check					; else = error2
	
.done_digit1_hex_check:
	mov si, word ptr[bp + var1]
	mov byte ptr[strnum1 + si], dl

	inc word ptr[bp + var1]
	inc bx
	jmp .number1_hex_loop_check

.finish_number1:
	mov si, word ptr[bp + var1]
	mov byte ptr[strnum1 + si], 0
	inc bx
	
	
.operation_check:						; check op
	mov dl, byte ptr[bx]
	
	cmp dl, '+'
	jne .plus_checked
	jmp .finish_operation

.plus_checked:
	cmp dl, '-'
	jne .minus_checked
	jmp .finish_operation

.minus_checked:
	cmp dl, '*'
	jne .multi_checked
	jmp .finish_operation	

.multi_checked:
	cmp dl, '/'
	jne .divide_checked
	jmp .finish_operation

.divide_checked:
	cmp dl, '%'
	jne .error4_check
	
.finish_operation:
	mov byte ptr[operation], dl
	inc bx
	
	mov dl, byte ptr[bx]
	cmp dl, ' '
	jne .error2_check
	inc bx

	
.number2_check:							; check num2
	mov word ptr[bp + var1], 0			; counter for num2 = 0
	mov dl, byte ptr[bx]				; first digit
	cmp dl, 0
	je .error2_check
	
	cmp dl, ' '
	je .error2_check
	
	cmp dl, '-'
	jne .number2_loop_check
	mov byte ptr[strnum2], dl
	inc word ptr[bp + var1]
	inc bx
	
	mov dl, byte ptr[bx]
	cmp dl, 0
	je .error2_check	
	cmp dl, ' '
	je .error2_check
	
.number2_loop_check:
	cmp word ptr[notation], 10
	jne .number2_hex_loop_check
	
.number2_dec_loop_check:				; if dec 
	mov si, word ptr[bp + var1]
	mov dl, byte ptr[bx]
	
	cmp dl, 0
	je .finish_number2
	
	cmp dl, '0'							
	jb .error2_check					; digit < 0
	cmp dl, '9'
	ja .error2_check					; digit > 9
	
	mov si, word ptr[bp + var1]
	mov byte ptr[strnum2 + si], dl

	inc word ptr[bp + var1]
	inc bx
	jmp .number2_dec_loop_check

.number2_hex_loop_check:				; if hex 
	mov si, word ptr[bp + var1]
	mov dl, byte ptr[bx]
	
	cmp dl, 0
	je .finish_number2	
	
	cmp dl, '0'							
	jb .error2_check					; digit < 0
	cmp dl, 'F'
	ja .error2_check					; digit > F
	cmp dl, '9'
	jbe .done_digit2_hex_check			; digit <= 9
	cmp dl, 'A'
	jae .done_digit2_hex_check			; digit >= A 
	
	jmp .error2_check					; else = error2
	
.done_digit2_hex_check:
	mov si, word ptr[bp + var1]
	mov byte ptr[strnum2 + si], dl
	
	inc word ptr[bp + var1]
	inc bx
	jmp .number2_loop_check

.finish_number2:
	mov si, word ptr[bp + var1]
	mov byte ptr[strnum2 + si], 0
	
	clc									; CF = 0
	jmp .finish_check

	
.error1_check:							; wrong notation
	mov ax, ERROR_NOTATION
	stc									; CF = 1
	jmp .finish_check
	
.error2_check:							; wrong number
	mov ax, ERROR_NUMBER
	stc									; CF = 1
	jmp .finish_check
	
.error4_check:							; wrong operation
	mov ax, ERROR_OPERATION
	stc									; CF = 1
	jmp .finish_check
	
.finish_check:
    mov sp, bp
    pop bp
    ret


	
; int/long calculating(const int number1, const int number2, const char* operation)
; main calculating ////////////////////////////////////////////////////////////////
_calculating:							
	push bp
	mov bp, sp
	
	mov ax, word ptr[bp + arg1]				; number1
	mov bx, word ptr[bp + arg2]				; number2
	mov si, word ptr[bp + arg3]				
	mov	cl, byte ptr[si]					; operation	
	
	cmp cl, '+'
	jne .plus_checked_calculating
	
	add ax, bx								; addition
	jo .overflow_calculating
	clc
	jmp .finish_calculating

.plus_checked_calculating:					
	cmp cl, '-'
	jne .minus_checked_calculating
	
	sub ax, bx								; subtraction
	jo .overflow_calculating
	clc
	jmp .finish_calculating

.minus_checked_calculating:					
	cmp cl, '*'
	jne .multi_checked_calculating
	
	imul bx									; multiplication
	; jo .overflow_calculating				; 32 bits never overflow
	clc
	jmp .finish_calculating


.multi_checked_calculating:					
	cmp cl, '/'
	jne .divide_checked_calculating
	
	cmp bx, 0								; divide by 0
	je .divided_by_zero_calculating
	
	cmp ax, 8000h							; checking single overflow case
	jne .continue_divide_calculating1
	cmp bx, -1
	je .overflow_calculating				; /////////////////////////////
	
.continue_divide_calculating1:
	cwd
	idiv bx									; divition (integer)
	xor dx, dx
	
	cmp ax, 07FFFh
	jna .cmp_for_divide_calculating1
	mov dx, 0FFFFh							; for negative result
	
.cmp_for_divide_calculating1:
	clc
	jmp .finish_calculating

.divide_checked_calculating:				; the last one is '%'
	cmp bx, 0								; divide by 0
	je .divided_by_zero_calculating

	cmp ax, 8000h							; checking single overflow case
	jne .continue_divide_calculating2
	cmp bx, -1
	je .overflow_calculating				; /////////////////////////////
	
	
.continue_divide_calculating2:
	cwd
	idiv bx									; divition (remainder)
	mov ax, dx
	xor dx, dx								; /// FIXED ///
	
	cmp ax, 07FFFh
	jna .cmp_for_divide_calculating2
	mov dx, 0FFFFh							; for negative remainder
	
.cmp_for_divide_calculating2:
	clc
	jmp .finish_calculating
	
.overflow_calculating:
	mov ax, ERROR_OVERFLOW
	stc
	jmp .finish_calculating

.divided_by_zero_calculating:
	mov ax, ERROR_DIV_ZERO
	stc

.finish_calculating:
	mov sp, bp
	pop bp
	ret
	
	
; void calc()    
; функция калькулятора (вызывает нужные функции: чтения строки, проверки строки, 
; перевода строк в числа, выполнения математической операции и вывода результата)
; выводит соответствующее коду ошибки сообщение, если вызываемая функция завершилась неуспешно. 
_calc:
    push bp
    mov bp, sp
	
	push offset string_enter_note 			; enter string //////////////////////////////
	call _putstr
	add sp, 2
	
	push 255
	push offset buffer
	call _getstr
	add sp, 4
	
	call _putnewline
	
	push offset buffer						; check string //////////////////////////////
	call _check
	push 2									; saving 2
	jc .CF_calc
	add sp, 2								; clear saving value: 2
	
	push offset strnum1						; atoi for num1 /////////////////////////////
	call _atoi
	push 2									; saving 2
	jc .CF_calc	
	add sp, 2								; clear saving value: 2
	mov word ptr[number1], ax
	
	push offset strnum2						; atoi for num2 /////////////////////////////
	call _atoi
	push 2									; saving 2
	jc .CF_calc
	add sp, 2								; clear saving value: 2
	mov word ptr[number2], ax
	
	push offset operation					; main calculating //////////////////////////
	push word ptr[number2]
	push word ptr[number1]
	call _calculating
	push 6									; saving 6
	jc .CF_calc	
	add sp, 2								; clear saving value: 6
	
	mov word ptr[result_low], ax
	mov word ptr[result_high], dx			
	
	push offset result_dec					; convert dec to string /////////////////////
	push word ptr[result_low]
	push word ptr[result_high]
	call _itoadec32
	add sp, 6
	
	push offset result_dec_note				; printing dec number ///////////////////////
	call _putstr
	add sp, 2
	
	push offset result_dec
	call _putstr
	add sp, 2

	call _putnewline
	
	push offset result_hex					; convert hex to string /////////////////////
	push word ptr[result_low]
	push word ptr[result_high]
	call _itoahex32
	add sp, 6
	
	push offset result_hex_note				; printing hex number ///////////////////////
	call _putstr
	add sp, 2
	
	push offset result_hex
	call _putstr
	add sp, 2
	
	
	jmp .finish_calc

	
.CF_calc:
	pop dx
	add sp, dx								; clear stack
	
	cmp ax, ERROR_NOTATION
	je .error1_calc

	cmp ax, ERROR_NUMBER
	je .error2_calc

	cmp ax, ERROR_OVERFLOW
	je .error3_calc 
	
	cmp ax, ERROR_OPERATION
	je .error4_calc

	cmp ax, ERROR_DIV_ZERO
	je .error5_calc
	
.error1_calc:								; wrong notation
	call _exit1
	jmp .finish_calc
	
.error2_calc:								; wrong number
	call _exit2
	jmp .finish_calc
	
.error3_calc:								; overflow number
	call _exit3
	jmp .finish_calc
	
.error4_calc:								; wrong operation
	call _exit4
	jmp .finish_calc
	
.error5_calc:								; divide by 0
	call _exit5

.finish_calc:
    mov sp, bp
    pop bp
    ret

start: ; вызов функции calc (модифицировать главную функцию программы не требуется)
    mov ax, data
    mov ds, ax
    mov ax, stack
    mov ss, ax
    
    call _calc
	
	call _exit0
code ends

end start
