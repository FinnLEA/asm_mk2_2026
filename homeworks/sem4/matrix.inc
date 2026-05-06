
; void readm1(const str *filename, void* segmentAddres)   
; читает матрицу в сегмент по адресу segmentAddres, преобразуя считанные строки в числа
; выводит сообщение об ошибке, если файл с данным именем не существует
ReadMatrix proc near 
    push bp
    mov bp, sp
	sub sp, 4				; [bp - 2] - fd
							; [bp - 4] - segmentAddres	
	push ds
	push es
	push bx
	push cx
	push dx
	push si
	push di
    
	mov dx, [bp + 4]		; filename
	mov ax, [bp + 6]		; segmentAddres
	mov [bp - 4], ax		; remember segmentAddres
	
	; check open file
	push 0
	push dx
	call _fopen 
	add sp, 4
	cmp ax, -1
	je error_openfile
	
	mov [bp - 2], ax		; fd
	
	mov ax, [bp - 4]
	mov es, ax
	
read_NM:
	; read 1-st string
	push offset line_buffer
	push [bp - 2]
	call line_to_buffer
	add sp, 4
	
	cmp ax, -1
	je error_readfile
	
write_NM:
	; parsing 1-st string (n, m)
	mov si, offset line_buffer
	
	push si					; ptr in line_buffer
	call _atoi
	add sp, 2
	mov es:[0], ax
	
skip_nm:
    mov al, [si]
    cmp al, ' '
    je next_nm
    cmp al, 0
    je done_nm
    inc si
    jmp skip_nm

next_nm:
    inc si

	push si
	call _atoi
	add sp, 2
	mov es:[2], ax
	
done_nm:
	
parsing_matrix:
	mov cx, es:[0]			; count of strings
	mov di, 4				; remember start	
	
read_MATRIX:
	push cx
	
	push offset line_buffer
	push [bp - 2]
	call line_to_buffer
	add sp, 4
	cmp ax, -1
	je error_readfile
	
	; reset the pointer to the beginning of the buffer
	mov si, offset line_buffer
	mov bx, es:[2]				; remember count elements in string
	
write_MATRIX:
	push si
	call _atoi
	add sp, 2
	
	stosw				; in ES:DI
	dec bx
    jz end_numbers      ; всё, строка закончилась

skip_to_next:
    mov al, [si]
    cmp al, ' '
    je next_number
	cmp al, 0
	je end_numbers
	
    inc si
    jmp skip_to_next

next_number:
    inc si               ; перепрыгнули пробел
	jmp write_MATRIX
	
end_numbers:
	pop cx
	loop read_MATRIX
	
	push [bp - 2]
	call _fclose
	add sp, 2
	
	mov ax, 0
	jmp ReadMatrix_ret
	
error_readfile:
	push ds
	mov ax, data
	mov ds, ax

	push offset emsg_readfile
	call _putstr
	add sp, 2

	push [bp + 4]
	call _putstr
	add sp, 2
	
	pop ds
	
	push [bp - 2]
	call _fclose
	add sp, 2
	
	mov ax, -1
	jmp ReadMatrix_ret
	
error_openfile:
	push ds
	mov ax, data
	mov ds, ax
	
	push offset emsg_openfile
	call _putstr
	add sp, 2
	
	push [bp + 4]
	call _putstr
	add sp, 2
	
	pop ds
	
	mov ax, -1		; return error flag
	jmp ReadMatrix_ret
	
ReadMatrix_ret:
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop es
	pop ds
	
    mov sp, bp
    pop bp
    ret
ReadMatrix endp



; void writem1(const str *filename, void* segmentAddres)   
; записывает матрицу в файл из сегмента по адресу segmentAddres, преобразуя считанные числа в строки
; выводит сообщение об ошибке, если файл с данным именем не существует
WriteMatrix proc near 
    push bp
    mov bp, sp
	sub sp, 4				; [bp - 2] - fd
							; [bp - 4] - segmentAddres
	push ds
	push es
	push bx
	push cx
	push dx
	push si
	push di
	
	mov dx, [bp + 4]		; filename
	mov ax, [bp + 6]		; segmentAddres
	mov [bp - 4], ax		; remember segmentAddres
	
	; check open file
	push 1
	push dx
	call _fopen 
	add sp, 4
	cmp ax, -1
	je error_openRESfile
	
	mov [bp - 2], ax		; fd
	
	mov ax, [bp + 6]
	mov es, ax
	
	xor si, si
	
write_NM2file:
	;n
	mov bx, es:[0]				
	push offset line2_buffer	; buffer
	push bx						; bx = number
	call _itoa
	add sp, 4
	
	push offset line2_buffer
	call _strlen				; ax - len just number
	add sp, 2

	; space
	mov si, offset line2_buffer
	add si, ax
	mov byte ptr [si], ' '
	mov byte ptr [si + 1], 0	
	
	inc ax						; + space
	
	push offset line2_buffer
	push ax
	push [bp - 2]
	call _fwrite
	add sp, 6
	cmp ax, -1
	je error_writefile
	
	; ptr fd on 'm'	
	;m
	mov ax, es:[2]
	push offset line2_buffer
	push ax
	call _itoa
	add sp, 4
	
	push offset line2_buffer
	call _strlen				; ax - len just number
	add sp, 2
	
	; \n
	mov si, offset line2_buffer
	add si, ax
	mov byte ptr [si], 13
	mov byte ptr [si + 1], 10
	mov byte ptr [si + 2], 0
	
	add ax, 2					; + \r and \n
	
	push offset line2_buffer
	push ax
	push [bp - 2]
	call _fwrite
	add sp, 6
	cmp ax, -1
	je error_writefile
	
	push offset msg
	call _putstr
	add sp, 2
	
	; successful write NM

	
write_MATRIX2file:
	xor si, si			; ptr in line2_buffer
	
	mov ax, es:[0]
	mul word ptr es:[2]	
	
	mov cx, ax			; cx - all count elements
	mov bx, es:[2]		; bx - count elements in string
	mov di, 4			; start matrix
	
matrix_loop:
    mov ax, es:[di]

    push offset line2_buffer
    push ax
    call _itoa
    add sp, 4
	
    push offset line2_buffer
    call _strlen
    add sp, 2


    ; space
    mov si, offset line2_buffer
    add si, ax
    mov byte ptr [si], ' '
    mov byte ptr [si + 1], 0

    inc ax

    push offset line2_buffer
    push ax
    push [bp - 2]
    call _fwrite
    add sp, 6
	
    cmp ax, -1
    je error_writefile

    add di, 2

    ; контроль строки
    dec bx
    cmp bx, 0
	jne continue_loop

    ; \r\n
    mov si, offset line2_buffer
    mov byte ptr [si], 13
    mov byte ptr [si + 1], 10

    push si
    push 2
    push [bp - 2]
    call _fwrite
    add sp, 6
	
    cmp ax, -1
    je error_writefile

    mov bx, es:[2]    ; reset m

continue_loop:
    dec cx
	cmp cx, 0
    je finish_matrix
	jmp matrix_loop

;--------------------------------------
	
error_openRESfile:
	push ds
	mov ax, data
	mov ds, ax
	
	push offset emsg_openfile
	call _putstr
	add sp, 2
	
	push [bp + 4]
	call _putstr
	add sp, 2
	
	pop ds
	
	mov ax, -1		; return error flag
	jmp WriteMatrix_ret
	
error_writefile:
	push ds
	mov ax, data
	mov ds, ax
	
	push offset emsg_writefile
	call _putstr
	add sp, 2
	
	push [bp + 4]
	call _putstr
	add sp, 2
	
	pop ds
	
	push [bp - 2]
	call _fclose
	add sp, 2

	mov ax, -1		; return error flag
	jmp WriteMatrix_ret

finish_matrix:
	jmp success_write
	
success_write:
	push ds
	
	mov ax, data
	mov ds, ax
	push offset msg_success_write
	call _putstr
	add sp, 2
	
	pop ds
	
	push [bp -2]
	call _fclose
	add sp, 2
		
	mov ax, 0
	jmp WriteMatrix_ret
	
WriteMatrix_ret:
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop es
	pop ds

    mov sp, bp
    pop bp
    ret
WriteMatrix endp


