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


max_size equ 19

stack segment para stack
	db 65530 dup(?)
stack ends

data1 segment para public
	n1 dw ? ; число строк в матрице
	m1 dw ? ; число столбцов в матрице
	matr1 dw 30000 dup(?) ; матрица
data1 ends

data2 segment para public
	n2 dw ? ; число строк в матрице
	m2 dw ? ; число столбцов в матрице
	matr2 dw 30000 dup(?) ; матрица
data2 ends

data segment para public
	msg db "we are hear", 0

	line_buffer db 4096 dup(0)
	line2_buffer db 100 dup(0)
	
	msg_callfile1 db "Enter the filename  ( 1  matrix): ", 0
	msg_callfile2 db "Enter the filename  ( 2  matrix): ", 0
	msg_callfile3 db "Enter the filename  (res matrix): ", 0
	msg_operator db "Enter operator: ", 0
	
	emsg_openfile db "Error opening file: ", 0
	emsg_readfile db "Error reading file: ", 0
	emsg_readmatrix db "Error in ReadMatrix!", 0
	emsg_writematrix db "Error in WriteMatrix!", 0
	emsg_writefile db "Error write in file: ", 0
	emsg_operation db "Error operation!", 0
	emsg_sizeNM db "Invalid size for matrix operation", 0
	
	msg_unsuccess_calc db "Unsuccess calc!", 0
	msg_success_calc db "Success calc!", 0
	msg_success_read db "Success read in file!", 0
	msg_success_write db "Success write in file!", 0
	
	filename1 db 20 dup(0) 
	filename2 db 20 dup(0) 
	filename3 db 20 dup(0) 
	operator db 0
	
data ends

code segment para public use16

assume cs:code,ss:stack,ds:data1,es:data2

include strings.inc
include files.inc
include matrix.inc


; void receiving_files()
receiving_files proc near
	push bp
	mov bp, sp
	
	push bx
    
	push offset msg_callfile1
	call PrintStr
	add sp, 2
	
	push max_size
	push offset filename1
	call _getstr
	add sp, 4
	
	call _putnewline
	
	push offset msg_callfile2
	call PrintStr
	add sp, 2
	
	push max_size
	push offset filename2
	call _getstr
	add sp, 4
	
	call _putnewline
	
	push offset msg_callfile3
	call PrintStr
	add sp, 2
	
	push max_size
	push offset filename3
	call _getstr
	add sp, 4
	
	call _putnewline
	
	push offset msg_operator
	call PrintStr
	add sp, 2

read_operation:
	call _getchar
	
	cmp al, 13
	je read_operation
	cmp al, 10
	je read_operation
	
	
	cmp al, '-'
	je ok
	cmp al, '+'
	je ok
	cmp al, '*'
	je ok
	
	jmp error_operation

ok:
	xor bx, bx
	mov bl, al
	
	push ds
	mov ax, data
	mov ds, ax
	mov operator, bl
	pop ds
	
	xor ax, ax
	jmp receiving_files_ret

error_operation:
	push offset emsg_operation
	call PrintStr
	add sp, 2
	mov ax, -1
	jmp receiving_files_ret
	
receiving_files_ret:
	pop bx
	
    mov sp, bp
    pop bp
    ret
receiving_files endp
	
	
; void line_to_buffer(int fd, char* buffer)
line_to_buffer proc near
	push bp
    mov bp, sp
	sub sp, 2
	
	push bx
	push dx
	push cx
	push si
	push di
	
	mov dx, [bp + 4]	; fd
	mov [bp - 2], dx
	mov di, [bp + 6]	; fix line_buffer	
	xor si, si			; ptr in line_buffer
	xor cx, cx			; count symbols
	
read_cycle:
	mov ax, di			; start
	add ax, si			; offset
	mov dx, [bp - 2]
	
	push ax				; ax = line_buffer[si]
	push 1				; need read
	push dx 			; fd
	call _fread
	add sp, 6
	
	cmp ax, 1
	je ok_continue
	
	cmp ax, 0
	jne error_end
	
	cmp cx, 0
	je error_end
	jmp end_of_string


ok_continue:	
	mov bx, di
	cmp byte ptr [bx + si], 10
	je end_of_string
	cmp byte ptr [bx + si], 13
	je pass_cr

next_sym:	
	inc si
	inc cx	
	
pass_cr:
	jmp read_cycle
	
error_end:
	mov ax, -1
	jmp line_to_buffer_ret
	
end_of_string:
	mov bx, di
	mov byte ptr [bx + si], 0
	mov ax, cx
	
line_to_buffer_ret:
	pop di
	pop si
	pop cx
	pop dx
	pop bx
	
	mov sp, bp
    pop bp
    ret
line_to_buffer endp



AddSubToMatrix proc near
    push bp
    mov bp, sp
    sub sp, 4

    push bx
    push cx
    push dx
    push si
    push di

	mov bl ,[bp + 4]  					 ; operator
    mov byte ptr [bp - 4], bl

    ; openfile
    ; -----------------------
	push ds
	mov ax, data
	mov ds, ax
	
    push 1
    push offset filename3
    call _fopen
    add sp, 4

	pop ds
    cmp ax, -1
    je error_open_file

    mov [bp - 2], ax   					 ; fd
    
    ; write N-M  
    ; -----------------------
	; N
    mov ax, ds:[0]
    push offset line2_buffer
    push ax
    call _itoa
    add sp, 4

    push offset line2_buffer
    call _strlen
    add sp, 2

    mov bx, offset line2_buffer
    add bx, ax
    mov byte ptr [bx], ' '
    mov byte ptr [bx + 1], 0
    inc ax

    push offset line2_buffer
    push ax
    push [bp - 2]
    call _fwrite
    add sp, 6

    ; M + CRLF
    mov ax, ds:[2]
    push offset line2_buffer
    push ax
    call _itoa
    add sp, 4

    push offset line2_buffer
    call _strlen
    add sp, 2

    mov bx, offset line2_buffer
    add bx, ax
    mov byte ptr [bx], 13
    mov byte ptr [bx + 1], 10
    mov byte ptr [bx + 2], 0
    add ax, 2

    push offset line2_buffer
    push ax
    push [bp - 2]
    call _fwrite
    add sp, 6

    ; matrix
    ; -----------------------
    mov ax, ds:[0]
    mul word ptr ds:[2]
    mov cx, ax					; all count

    ; xor si, si					; ptr DS:SI
    ; xor di, di					; ptr ES:DI
	
	mov si, 4
	mov di, 4
	

    mov dx, ds:[2]     			; columns counter

loop_elements:
    mov ax, ds:[si]
    mov bx, es:[di]

    cmp byte ptr [bp - 4], '+'
    je do_add

    sub ax, bx
    jmp write_elem

do_add:
    add ax, bx

write_elem:
    push cx
    push dx

    push offset line2_buffer
    push ax
    call _itoa
    add sp, 4

    push offset line2_buffer
    call _strlen
    add sp, 2

    mov bx, offset line2_buffer
    add bx, ax
    mov byte ptr [bx], ' '
    mov byte ptr [bx + 1], 0
    inc ax

    push offset line2_buffer
    push ax
    push [bp - 2]
    call _fwrite
    add sp, 6

    pop dx
    pop cx

    add si, 2				 ; move our ptrs
    add di, 2

    dec dx
    jnz no_newline

    ; ELSE --> newline
    mov bx, offset line2_buffer
    mov byte ptr [bx], 13
    mov byte ptr [bx + 1], 10
    mov byte ptr [bx + 2], 0

    push offset line2_buffer
    push 2
    push [bp - 2]
    call _fwrite
    add sp, 6

    mov dx, ds:[2]					; updated

no_newline:
    dec cx
    jnz loop_elements

    ; closefile
    ; -----------------------
    push [bp - 2]
    call _fclose
    add sp, 2

    xor ax, ax						; success
    jmp done_add


error_open_file:
    push offset emsg_openfile
    call PrintStr
    add sp, 2
    mov ax, -1						; unsuccess
    jmp done_add
	
done_add:
    pop di
    pop si
    pop dx
    pop cx
    pop bx

    mov sp, bp
    pop bp
    ret
AddSubToMatrix endp


MulToMatrix proc near
    push bp
    mov bp, sp
    sub sp, 4           ; [bp - 2] = fd, [bp - 4] = sum
					     ; C[i][j] = sum ( A[i][k] * B[k][j])

    push bx
    push cx
    push dx
    push si
    push di

    ; -----------------------
    ; open file 
    push ds
    mov ax, data
    mov ds, ax

    push 1
    push offset filename3
    call _fopen
    add sp, 4

    pop ds

    cmp ax, -1
    je error_open_mul

    mov [bp - 2], ax				; fd

    ; -----------------------
    ; write N P
    ; N
    mov ax, ds:[0]
    push offset line2_buffer
    push ax
    call _itoa
    add sp, 4

    push offset line2_buffer
    call _strlen
    add sp, 2

    mov bx, offset line2_buffer
    add bx, ax
    mov byte ptr [bx], ' '
	mov byte ptr [bx+1], 0
    inc ax

    push offset line2_buffer
    push ax
    push [bp-2]
    call _fwrite
    add sp, 6

    ; P
    mov ax, es:[2]
    push offset line2_buffer
    push ax
    call _itoa
    add sp, 4

    push offset line2_buffer
    call _strlen
    add sp, 2
	
	; ax = strlen

    mov bx, offset line2_buffer
    add bx, ax
    mov byte ptr [bx], 13
    mov byte ptr [bx + 1], 10
	mov byte ptr [bx + 2], 0
    add ax, 2

    push offset line2_buffer
    push ax
    push [bp - 2]
    call _fwrite
    add sp, 6

    ; ----------------------- now matrix
    ; i loop
	xor bx, bx					; i = 0 str A
outer_i:
	
    xor dx, dx           		; j = 0 col B

outer_j:
    
    mov word ptr [bp - 4], 0	; sum = 0
    xor si, si            		; k = 0

inner_k:
    push cx

    ; -------- A[i][k] --------
    mov ax, bx
    mov di, ds:[2]      ; M
    mul di              ; i*M

    add ax, si          ; + k
    shl ax, 1

    mov di, ax
    mov ax, ds:[di]     ; AX = A[i][k]
    mov cx, ax          ; сохранить A

    ; -------- B[k][j] --------
    mov ax, si
    mov di, es:[2]      ; P
    mul di              ; k*P

    add ax, dx          ; + j
    shl ax, 1

    mov di, ax
    mov ax, es:[di]     ; AX = B[k][j]

    imul cx             ; AX = A * B

    ; -------- sum += --------
    add word ptr [bp-4], ax
	
	pop cx

    ; -------- k++ --------
    inc si
    mov ax, ds:[2]      ; M
    cmp si, ax
    jl inner_k
	

    ; ----- write sum -----
	mov ax, [bp - 4]
	
	push cx
	push dx
	
    push offset line2_buffer
    push ax
    call _itoa
    add sp, 4

    push offset line2_buffer
    call _strlen
    add sp, 2
	
	mov cx, ax							; cx = strlen

    mov di, offset line2_buffer
    add di, cx
    mov byte ptr [di], ' '
    mov byte ptr [di +  1], 0
    inc cx								; strlen + space

    push offset line2_buffer
    push cx
    push [bp-2]
    call _fwrite
    add sp, 6

    pop dx
	pop cx
	
	    ; ---- j++ ----
    inc dx
    mov ax, es:[2]
    cmp dx, ax
    jl outer_j

    ; ---- newline ----
    mov di, offset line2_buffer
    mov byte ptr [di], 13
    mov byte ptr [di+1], 10
    mov byte ptr [di+2], 0

    push offset line2_buffer
    push 2
    push [bp-2]
    call _fwrite
    add sp, 6

    ; ---- i++ ----
    inc bx
    mov ax, ds:[0]
    cmp bx, ax
    jl outer_i

    ; -----------------------
    ; close file
    push [bp-2]
    call _fclose
    add sp, 2

    xor ax, ax
    jmp done_mul

error_open_mul:
    push offset emsg_openfile
    call PrintStr
    add sp, 2
    mov ax, -1

done_mul:
    pop di
    pop si
    pop dx
    pop cx
    pop bx

    mov sp, bp
    pop bp
    ret
MulToMatrix endp
	
	
; void calc()    
; основная функция калькулятора (вызывает нужные функции) 
Calc proc near 
    push bp
    mov bp, sp
    
    push bx
    push ds
    push es

    ; input files + operator
    ; -----------------------
    call receiving_files
    cmp ax, -1
    je error_recieve
	

    call _putnewline

    ; read matrix1
    ; -----------------------
    push seg data1
    push offset filename1
    call ReadMatrix
    add sp, 4
    cmp ax, -1
    je error_readM1

    ; read matrix2
    ; -----------------------
    push seg data2
    push offset filename2
    call ReadMatrix
    add sp, 4
    cmp ax, -1
    je error_readM2
	
    ; operator
    ; -----------------------
	push ds
	mov ax, data
	mov ds, ax
	mov dl, operator
	pop ds

    ; fix segments
    ; -----------------------
    mov ax, seg data1
    mov ds, ax

    mov ax, seg data2
    mov es, ax

    ; -----------------------
    ; dispatch
    ; -----------------------
    cmp dl, '+'
    je add_sub_case
    cmp dl, '-'
    je add_sub_case
    cmp dl, '*'
    je mul_case

    mov ax, -1
    jmp error_op  

add_sub_case:
    ; size check
    ; -----------------------
    mov ax, ds:[0]
    mov bx, es:[0]
    cmp ax, bx
    jne error_size

    mov ax, ds:[2]
    mov bx, es:[2]
    cmp ax, bx
    jne error_size

    xor dh, dh
    push dx
    call AddSubToMatrix
    add sp, 2

    cmp ax, -1
    je no_success

    jmp ok_success

mul_case:
	
    mov ax, ds:[2]
    mov bx, es:[0]
    cmp ax, bx
    jne error_size
	
    call MulToMatrix
	cmp ax, -1
	je no_success
	
    jmp ok_success

ok_success:
    push offset msg_success_calc
    call PrintStr
    add sp, 2

    mov ax, 0
    jmp CalcRet
	
error_op:
	push offset emsg_operation
	call PrintStr
	add sp, 2
	
	mov ax, -1
	jmp CalcRet

error_size:
    push offset emsg_sizeNM
    call PrintStr
    add sp, 2

    mov ax, -1
    jmp CalcRet

error_recieve:
    mov ax, -1
    jmp CalcRet

error_readM1:
    push offset emsg_readmatrix
    call PrintStr
    add sp, 2

    push offset filename1
    call PrintStr
    add sp, 2

    mov ax, -1
    jmp CalcRet

error_readM2:
    push offset emsg_readmatrix
    call PrintStr
    add sp, 2

    push offset filename2
    call PrintStr
    add sp, 2

    mov ax, -1
    jmp CalcRet
	
no_success:
	push offset msg_unsuccess_calc
	call PrintStr
	add sp, 2
	mov ax, -1
	jmp CalcRet
	
CalcRet:
    pop es
    pop ds
    pop bx
    
    mov sp, bp
    pop bp
    ret
Calc endp


PrintStr proc near
    push bp
    mov bp, sp

    push ds
    mov ax, data
    mov ds, ax

    push [bp + 4]        ; offset str
    call _putstr
    add sp, 2

    pop ds

    mov sp, bp
    pop bp
    ret
PrintStr endp


start:
    mov ax, data
    mov ds, ax
    mov ax, stack
    mov ss, ax
    
    call Calc

	

	call _exit0
code ends

end start