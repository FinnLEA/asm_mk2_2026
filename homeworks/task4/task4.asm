; шаблон для зачётного задания №2 (калькулятор матриц)
.386

arg1 equ 4
arg2 equ 6
arg3 equ 8
arg4 equ 10

var1 equ -2
var2 equ -4
var3 equ -6
var4 equ -8
var5 equ -10

stack segment para stack
db 65530 dup(?)
stack ends

data1 segment para public
	n1 dw ? ; число строк в матрице
	m1 dw ? ; число столбцов в матрице
	matrix1 dw 15000 dup(?) ; матрица

	filename1 db "file1.txt",0
	handle1 dw ?
	temp_buf db 10 dup(?)
data1 ends

data2 segment para public
	n2 dw ? ; число строк в матрице
	m2 dw ? ; число столбцов в матрице
	matrix2 dw 15000 dup(?) ; матрица

	filename2 db "file2.txt",0
	handle2 dw ?
data2 ends

data segment para public
	buffer db 16384 dup(?),0
	buffer_num db 10 dup(?),0

	error_open 		db "Error: opening file",0
	error_read 		db "Error: reading file",0
	error_writing 	db "Error: writing file",0
	error_close 	db "Error: closing file",0
	error_size		db "Error: wrong size",0
data ends

code segment para public use16

assume cs:code,ss:stack,ds:data1,es:data2

include strings.inc
include files.inc
	
	
; int atoi(const char *str)
; функция перевода строки в число
atoi proc near
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
	sub bl, '0'

	mov cx, ax
	mov ax, 10
	mul cx
	add ax, bx
	
	inc si
	jmp .loop_atoi

.done_atoi:
	cmp word ptr[bp + var1], 1
	je .neg_atoi
	jmp .finish_atoi

.neg_atoi:
	neg ax								; if num < 0
	
.finish_atoi:
    mov sp, bp
    pop bp
    ret
atoi endp


; void itoa(int num, char *str)
; функция перевода числа в строку    
itoa proc near
    push bp
    mov bp, sp
	
	mov ax, word ptr[bp + arg1]			; number
	mov di, word ptr[bp + arg2]			; return string
	
	sub sp, 2
	
	push bx
	
	mov word ptr[bp + var1], 0			; symbol counter
	mov bx, 10							; divider = 10
	
	test ax, ax							; check for negative number
	jns .loop_itoa
	
	mov byte ptr[di], '-'
	inc di	
	
.loop_itoa:
	cwd
	idiv bx								; dx = remainder = our digit
	
	cmp dx, 0							; remainder can be negative
	jge .positive_rem_itoa
	
	neg dx
	
.positive_rem_itoa:
	add dl, '0'
	push dx								; write to stack for .convert_to_string
	inc word ptr[bp + var1]
	
	cmp ax, 0
	jne .loop_itoa
	
.convert_to_string_itoa:
	cmp word ptr[bp + var1], 0
	je .finish_itoa
	
	pop dx								; take byte from stack and put in string
	mov byte ptr[di], dl
	
	inc di
	dec word ptr[bp + var1]
	jmp .convert_to_string_itoa
	
.finish_itoa:
	mov byte ptr[di], 0
	
	pop bx
	
    mov sp, bp
	pop bp
    ret
itoa endp


   
; void readm1(const str *filename, void* segmentAddres)   
; читает матрицу в сегмент по адресу segmentAddres, преобразуя считанные строки в числа
; выводит сообщение об ошибке, если файл с данным именем не существует
ReadMatrix1 proc near 
    push bp
    mov bp, sp
	
	; word ptr[bp + arg1]					; filename
	; word ptr[bp + arg2]					; segmentAddres
	
	mov ax, word ptr[bp + arg2]
	mov ds, ax
	
	sub sp, 4
	; word ptr[bp + var1]					; for buffer
	; word ptr[bp + var2]					; for ds:[matrix1]
	
	push 0
	push word ptr[bp + arg1]
	call _fopen								; opening file1
	add sp, 4
	
	cmp ax, -1
	je .err_open_ReadMatrix1
	
	mov ds:[handle1], ax
	
	mov bx, data
	mov es, bx
	
	push offset es:[buffer]					; reading file1 to buffer
	push 16384
	push ds:[handle1]
	call _fread
	add sp, 6
	
	cmp ax, -1
	je .err_read_ReadMatrix1
	
	mov bx, offset es:[buffer] 				; get n1
	mov word ptr[bp + var1], bx
	mov si, offset es:[buffer_num]
	xor dx, dx
	
.loop_n1_ReadMatrix1:
	mov bx, word ptr[bp + var1]
	mov dl, byte ptr[bx]
	
	cmp dl, ' '
	je .done_n1_ReadMatrix1
	
	mov byte ptr[si], dl
	inc word ptr[bp + var1]
	inc si
	
	jmp .loop_n1_ReadMatrix1

.done_n1_ReadMatrix1:
	mov byte ptr[si], 0
	inc word ptr[bp + var1]
	
	push offset es:[buffer_num]
	call atoi
	add sp, 2
	mov ds:[n1], ax
	
	
	mov si, offset es:[buffer_num]			; get m1
	xor dx, dx

.loop_m1_ReadMatrix1:
	mov bx, word ptr[bp + var1]
	mov dl, byte ptr[bx]
	
	cmp dl, 0dh
	je .done_m1_ReadMatrix1
	cmp dl, 0ah
	je .done_m1_ReadMatrix1
	
	mov byte ptr[si], dl
	inc word ptr[bp + var1]
	inc si
	
	jmp .loop_m1_ReadMatrix1

.done_m1_ReadMatrix1:
	mov byte ptr[si], 0
	add word ptr[bp + var1], 2
	
	push offset es:[buffer_num]
	call atoi
	add sp, 2
	mov ds:[m1], ax

	
	mov bx, offset ds:[matrix1]				; get numbers for matrix1
	mov word ptr[bp + var2], bx

.loop_numbers_ReadMatrix1:
	mov si, offset es:[buffer_num]
	xor dx, dx
	
.loop_num_ReadMatrix1:
	mov bx, word ptr[bp + var1]
	mov dl, byte ptr[bx]
	
	cmp dl, 0
	je .done_numbers_ReadMatrix1
	
	cmp dl, ' '
	je .space_ReadMatrix1
	cmp dl, 0dh
	je .rn_ReadMatrix1
	
	mov byte ptr[si], dl
	inc word ptr[bp + var1]
	inc si

	jmp .loop_num_ReadMatrix1
	
.space_ReadMatrix1:
	mov byte ptr[si], 0
	inc word ptr[bp + var1]
	
	push offset es:[buffer_num]
	call atoi
	add sp, 2
	
	mov si, word ptr[bp + var2]
	mov word ptr[si], ax
	add word ptr[bp + var2], 2
	
	jmp .loop_numbers_ReadMatrix1
	
.rn_ReadMatrix1:
	mov byte ptr[si], 0
	add word ptr[bp + var1], 2
	
	push offset es:[buffer_num]
	call atoi
	add sp, 2
	
	mov si, word ptr[bp + var2]
	mov word ptr[si], ax
	add word ptr[bp + var2], 2
	
	jmp .loop_numbers_ReadMatrix1
	
.done_numbers_ReadMatrix1:
	mov byte ptr[si], 0
	
	push offset es:[buffer_num]
	call atoi
	add sp, 2
	
	mov si, word ptr[bp + var2]
	mov word ptr[si], ax
	
	jmp .finish_ReadMatrix1
	
.err_open_ReadMatrix1:						; error with opening file
	mov ax, data
	mov ds, ax
	
	push offset error_open
	call _putstr
	add sp, 2
	
	jmp .finish_ReadMatrix1
	
.err_read_ReadMatrix1:						; error with reading file
	mov ax, data
	mov ds, ax
	
	push offset error_read
	call _putstr
	add sp, 2

.finish_ReadMatrix1:
    mov sp, bp
    pop bp
    ret
ReadMatrix1 endp


; void readm2(const str *filename, void* segmentAddres)   
; читает матрицу в сегмент по адресу segmentAddres, преобразуя считанные строки в числа
; выводит сообщение об ошибке, если файл с данным именем не существует
ReadMatrix2 proc near 
    push bp
    mov bp, sp
	
	; word ptr[bp + arg1]					; filename
	; word ptr[bp + arg2]					; segmentAddres
	
	sub sp, 4
	; word ptr[bp + var1]					; for buffer
	; word ptr[bp + var2]					; for ds:[matrix2]
	
	mov ax, word ptr[bp + arg2]
	mov ds, ax
	
	push 0
	push word ptr[bp + arg1]
	call _fopen								; opening file2
	add sp, 4
	
	cmp ax, -1
	je .err_open_ReadMatrix2
	
	mov bx, ax								; save handle
	
	mov ax, data
	mov ds, ax								; ds
	
	mov dx, word ptr[bp + arg2]
	mov es, dx								; es
	
	mov es:[handle2], bx					; save handle
	
	push offset buffer					; reading file2 to buffer
	push 16384
	push bx
	call _fread
	add sp, 6
	
	cmp ax, -1
	je .err_read_ReadMatrix2
	
	mov bx, offset buffer 				; get n2
	mov word ptr[bp + var1], bx
	mov si, offset buffer_num
	xor dx, dx
	
.loop_n2_ReadMatrix2:
	mov bx, word ptr[bp + var1]
	mov dl, byte ptr[bx]
	
	cmp dl, ' '
	je .done_n2_ReadMatrix2
	
	mov byte ptr[si], dl
	inc word ptr[bp + var1]
	inc si
	
	jmp .loop_n2_ReadMatrix2

.done_n2_ReadMatrix2:
	mov byte ptr[si], 0
	inc word ptr[bp + var1]
	
	push offset buffer_num
	call atoi
	add sp, 2
	
	mov es:[n2], ax

	
	mov si, offset buffer_num			; get m2
	xor dx, dx

.loop_m2_ReadMatrix2:
	mov bx, word ptr[bp + var1]
	mov dl, byte ptr[bx]
	
	cmp dl, 0dh
	je .done_m2_ReadMatrix2
	cmp dl, 0ah
	je .done_m2_ReadMatrix2
	
	mov byte ptr[si], dl
	inc word ptr[bp + var1]
	inc si
	
	jmp .loop_m2_ReadMatrix2

.done_m2_ReadMatrix2:
	mov byte ptr[si], 0
	add word ptr[bp + var1], 1
	
	push offset buffer_num
	call atoi
	add sp, 2
	mov es:[m2], ax

	
	mov bx, offset matrix2				; get numbers for matrix2
	mov word ptr[bp + var2], bx

.loop_numbers_ReadMatrix2:
	mov si, offset buffer_num
	xor dx, dx
	
.loop_num_ReadMatrix2:
	mov bx, word ptr[bp + var1]
	mov dl, byte ptr[bx]
	
	cmp dl, 0
	je .done_numbers_ReadMatrix2
	
	cmp dl, ' '
	je .space_ReadMatrix2
	cmp dl, 0ah
	je .rn_ReadMatrix2
	
	mov byte ptr[si], dl
	inc word ptr[bp + var1]
	inc si

	jmp .loop_num_ReadMatrix2
	
.space_ReadMatrix2:
	mov byte ptr[si], 0
	inc word ptr[bp + var1]
	
	push offset buffer_num
	call atoi
	add sp, 2
	
	mov si, word ptr[bp + var2]
	mov es:[si], ax
	add word ptr[bp + var2], 2
	
	jmp .loop_numbers_ReadMatrix2
	
.rn_ReadMatrix2:
	mov byte ptr[si], 0
	add word ptr[bp + var1], 1
	
	push offset buffer_num
	call atoi
	add sp, 2
	
	mov si, word ptr[bp + var2]
	mov es:[si], ax
	add word ptr[bp + var2], 2
	
	jmp .loop_numbers_ReadMatrix2
	
.done_numbers_ReadMatrix2:
	mov byte ptr[si], 0
	
	push offset buffer_num
	call atoi
	add sp, 2
	
	mov si, word ptr[bp + var2]
	mov es:[si], ax
	
	jmp .finish_ReadMatrix2
	
.err_open_ReadMatrix2:						; error with opening file
	mov ax, data
	mov ds, ax
	
	push offset error_open
	call _putstr
	add sp, 2
	
	jmp .finish_ReadMatrix2
	
.err_read_ReadMatrix2:						; error with reading file
	mov ax, data
	mov ds, ax
	
	push offset error_read
	call _putstr
	add sp, 2

.finish_ReadMatrix2:
    mov sp, bp
    pop bp
    ret
ReadMatrix2 endp


; void Addition(void* segmentAddres1, void* segmentAddres2)
Addition proc near
	push bp
	mov bp, sp
	
	mov ax, word ptr[bp + arg1]
	mov ds, ax								; data1
	
	mov ax, word ptr[bp + arg2]
	mov es, ax								; data2

	
	sub sp, 10
	mov word ptr[bp + var1], 0				; counter
	
	mov ax, word ptr[n1]
	mov word ptr[bp + var2], ax				; n1
	mov ax, word ptr[m1]
	mov word ptr[bp + var3], ax				; m1
	
	mov bx, offset n2
	mov ax, es:[bx]
	mov word ptr[bp + var4], ax				; n2
	
	mov bx, offset m2
	mov ax, es:[bx]
	mov word ptr[bp + var5], ax				; m2
	
	mov ax, word ptr[bp + var2]	
	mov dx, word ptr[bp + var4]
	cmp ax, dx								; n1 ? n2
	jne .err_size_Addition
	
	mov ax, word ptr[bp + var3]
	mov dx, word ptr[bp + var5]
	cmp ax, dx								; m1 ? m2
	jne .err_size_Addition
	
.loop_Addition:
	mov bx, offset matrix1
	add bx, word ptr[bp + var1]
	mov ax, word ptr[bx]					; num1

	mov bx, offset matrix2
	add bx, word ptr[bp + var1]
	mov dx, es:[bx]							; num2

	add ax, dx								; num1 = num1 + num2
	
	push offset temp_buf
	push ax
	call itoa
	add sp, 4
	
	push offset temp_buf					; printing
	call _putstr
	add sp, 2
	
	xor ax, ax
	mov al, ' '
	push ax
	call _putchar
	add sp, 2
	
	dec word ptr[bp + var3]					; m1 -= 1
	
	cmp word ptr[bp + var3], 0				; m1 == 0 ?
	je .newline_Addition

	add word ptr[bp + var1], 2				; counter++ (+2 because of word)
	jmp .loop_Addition
	
.newline_Addition:
	dec word ptr[bp + var2]					; n1 -= 1
	
	cmp word ptr[bp + var2], 0				; n1 == 0 ?
	je .finish_Addition
	
	mov ax, word ptr[bp + var5]
	mov word ptr[bp + var3], ax				; m1 = m2
	add word ptr[bp + var1], 2				; counter++
	
	call _putnewline
	jmp .loop_Addition
	
.err_size_Addition:
	mov ax, data
	mov ds, ax
	
	push offset error_size
	call _putstr
	add sp, 2

.finish_Addition:
    mov sp, bp
    pop bp
    ret
Addition endp



; void Subtraction(void* segmentAddres1, void* segmentAddres2)
Subtraction proc near
	push bp
	mov bp, sp
	
	mov ax, word ptr[bp + arg1]
	mov ds, ax								; data1
	
	mov ax, word ptr[bp + arg2]
	mov es, ax								; data2

	
	sub sp, 10
	mov word ptr[bp + var1], 0				; counter
	
	mov ax, word ptr[n1]
	mov word ptr[bp + var2], ax				; n1
	mov ax, word ptr[m1]
	mov word ptr[bp + var3], ax				; m1
	
	mov bx, offset n2
	mov ax, es:[bx]
	mov word ptr[bp + var4], ax				; n2
	
	mov bx, offset m2
	mov ax, es:[bx]
	mov word ptr[bp + var5], ax				; m2
	
	mov ax, word ptr[bp + var2]	
	mov dx, word ptr[bp + var4]
	cmp ax, dx								; n1 ? n2
	jne .err_size_Subtraction
	
	mov ax, word ptr[bp + var3]
	mov dx, word ptr[bp + var5]
	cmp ax, dx								; m1 ? m2
	jne .err_size_Subtraction
	
.loop_Subtraction:
	mov bx, offset matrix1
	add bx, word ptr[bp + var1]
	mov ax, word ptr[bx]					; num1

	mov bx, offset matrix2
	add bx, word ptr[bp + var1]
	mov dx, es:[bx]							; num2

	sub ax, dx								; num1 = num1 + num2
	
	push offset temp_buf
	push ax
	call itoa
	add sp, 4
	
	push offset temp_buf					; printing
	call _putstr
	add sp, 2
	
	xor ax, ax
	mov al, ' '
	push ax
	call _putchar
	add sp, 2
	
	dec word ptr[bp + var3]					; m1 -= 1
	
	cmp word ptr[bp + var3], 0				; m1 == 0 ?
	je .newline_Subtraction

	add word ptr[bp + var1], 2				; counter++ (+2 because of word)
	jmp .loop_Subtraction
	
.newline_Subtraction:
	dec word ptr[bp + var2]					; n1 -= 1
	
	cmp word ptr[bp + var2], 0				; n1 == 0 ?
	je .finish_Subtraction
	
	mov ax, word ptr[bp + var5]
	mov word ptr[bp + var3], ax				; m1 = m2
	add word ptr[bp + var1], 2				; counter++
	
	call _putnewline
	jmp .loop_Subtraction
	
.err_size_Subtraction:
	mov ax, data
	mov ds, ax
	
	push offset error_size
	call _putstr
	add sp, 2

.finish_Subtraction:
    mov sp, bp
    pop bp
    ret
Subtraction endp






	

; void calc()
; основная функция калькулятора (вызывает нужные функции) 
Calc proc near 
    push bp
    mov bp, sp
	
	push ds									; ReadMatrix1
	push offset ds:[filename1]
	call ReadMatrix1
	add sp, 4
	
	mov ax, data2
	mov es, ax
	
	push es									; ReadMatrix2
	push offset es:[filename2]
	call ReadMatrix2
	add sp, 4

	mov ax, data1
	mov ds, ax
	
	mov ax, word ptr[handle1]				; closing file1
	push ax									
	call _fclose
	add sp, 2

	cmp ax, -1
	je .err_close_calc	
	
	mov ax, data2
	mov es, ax
	
	mov ax, es:[handle2]					; closing file2
	push ax
	call _fclose
	add sp, 2
	
	cmp ax, -1
	je .err_close_calc
	
	
	
	; --- test ---
	
	;mov ax, data
	;mov ds, ax	
	
	;mov ax, data2
	;mov es, ax
	
	;mov bx, offset matrix2
	;mov ax, es:[bx]
	
	; ------------
	
	push es
	push ds
	call Addition
	add sp, 4
	
	call _putnewline
	call _putnewline

	push es
	push ds
	call Subtraction
	add sp, 4	
	
	
	
	
	
	
	jmp .finish_calc

.err_close_calc:
	mov ax, data
	mov ds, ax

	push offset error_close
	call _putstr
	add sp, 2
	
.finish_calc:
    mov sp, bp
    pop bp
    ret
Calc endp


start: ; вызов функции calc (модифицировать главную функцию программы не требуется)
    mov ax, data1
    mov ds, ax
    mov ax, data2
    mov es, ax
    mov ax, stack
    mov ss, ax
    
    call Calc

	call _exit0
code ends

end start