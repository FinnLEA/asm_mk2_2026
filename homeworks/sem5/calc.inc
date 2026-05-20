


; void convert(const char *input_line)
; function for taking numbers and an operand from a checked string
_convert proc near
	; ax = first number
	; dx = second number
	; operator in global data
	; CF = status
	
	push bp
	mov bp, sp
	sub sp, 2						; [bp - 2] = 1-st number
	
	push si
	push cx
	push bx
	
	mov si, [bp + 4]				; input_line
	
	; 1 number
	push [bp + 4]
	call _atoi	
	jc convert_error
	add sp, 2
	
	mov word ptr [bp - 2], ax		; saved 1 number
	
	; go to 2-nd number
	mov si, [bp + 4]				; start
	
	cmp byte ptr [si], '-'			; first un
	jne find_operator	
	inc si
	
	find_operator:
		cmp byte ptr [si], '0'
		jb operator_found

		cmp byte ptr [si], '9'
		ja operator_found

		inc si
		jmp find_operator
		
operator_found:
	mov al, byte ptr [si]
	mov byte ptr [operator], al
	
	inc si
	
	; SI in 2-st number
	push si
	call _atoi	
	jc convert_error
	add sp, 2
	
	mov dx, ax						; 2 number was written in dx
	mov ax, word ptr [bp - 2]		; 1 number was written in ax
	jmp convert_end

convert_end:
	pop bx
	pop cx
	pop si
	
	mov sp, bp
    pop bp 
	
	; AX-DX 1-2 NUMBERS
	clc
	ret

convert_error:
	add sp, 2

	pop bx
	pop cx
	pop si
	
	mov sp, bp
    pop bp
	
	mov ax, -1
	stc
	ret
_convert endp
	
	

; int check(const char *input_line)    
; function for checking the entered string for compliance with the format
_check proc near
    push bp
    mov bp, sp
	
	push bx
	push cx
	push si
	
	mov si, [bp + 4] 			; start of input_string
	
	; check 1 number
	push si
	call check_number	
	add sp, 2
    cmp ax, -1
	je _check_fail	
	
	; check_number intentionally advances SI
	; after check_number SI  = /0 or 'operator'
	
	; check sign
	cmp byte ptr [si], '+'
	je check_sign
	cmp byte ptr [si], '-'
	je check_sign
	cmp byte ptr [si], '*'
	je check_sign
	cmp byte ptr [si], '/'
	je check_sign
	cmp byte ptr [si], '%'
	je check_sign
	
	; otherwise, if the sign is incorrect
	jmp _check_fail

check_sign:
	inc si							; transition to the symbol AFTER the sign
	
	; check 2 number
	push si
	call check_number
	add sp, 2
	cmp ax, -1
	je _check_fail					; if error
	
	; checking for end of line after 2nd number
	cmp byte ptr [si], 0
	jne _check_fail
	
	jmp _check_ret

_check_fail:
	pop si
	pop cx
	pop bx
	
    mov sp, bp
    pop bp
	
	mov ax, -1
    ret	
	
_check_ret:
	; otherwise we were satisfied with everything
	pop si
	pop cx
	pop bx
	
    mov sp, bp
    pop bp
	
	mov ax, 0
    ret			
_check endp
	
	
	
; input:
; SI = current parsing position

; output:
; SI = first non-digit char
; CF = status

; int check_number(const char *str)
check_number proc near
	push bp
	mov bp, sp
	
	push cx
	
	xor cx, cx				; count numbers
	
	; checking for a negative number
	cmp byte ptr [si], '-'
	jne cycle_number
	inc si
	
cycle_number:
	cmp byte ptr [si], '+'
	je check_number_end
	cmp byte ptr [si], '-'
	je check_number_end
	cmp byte ptr [si], '*'
	je check_number_end
	cmp byte ptr [si], '/'
	je check_number_end
	cmp byte ptr [si], '%'
	je check_number_end
	cmp byte ptr [si], 0
	je check_number_end
	
	cmp byte ptr [si], '0'
	jb check_error	
	cmp byte ptr [si], '9'
	ja check_error
	
	; counted the number
	inc cx
	inc si
	jmp cycle_number
	
check_number_end:
	cmp cx, 0			; no numbers were counted
	je check_error	
	
	mov ax, 0					; successful formatting
	pop cx
	mov sp, bp
    pop bp

	ret
	
check_error:
	mov ax, -1				; formatting error - sets a flag
	pop cx
	mov sp, bp
    pop bp
	ret
check_number endp




	
; void operation (int num1, int num2, char op)
; operation execution function
_operation proc near
    push bp
    mov bp, sp
	
	mov bx, [bp + 4]		
	mov ax, [bp + 6]
	mov dx, [bp + 8]

    cmp bl, '+'
    je addition
    cmp bl, '-'
    je subtraction
    cmp bl, '*'
    je multiplication
    cmp bl, '/'
    je division
    cmp bl, '%'
    je remainder

	mov ax, -1
	stc
    jmp op_end

addition:
	add ax, dx
	jo overflow
	clc
    jmp op_end
subtraction:
    sub ax, dx
    jo overflow
	clc
    jmp op_end
multiplication:
	imul dx				; result in dx:ax (32-bit)
	
	jo overflow
	
	clc					; always success
    jmp op_end
	
division:
    cmp dx, 0
    je div_error

    cmp ax, 8000h      ; -32768
    jne safe_div
    cmp dx, -1
	jne safe_div
    jmp overflow
safe_div:
	mov bx, dx      ; divider
    cwd             
    idiv bx         ; ax = quotient, dx = divisible
    clc
    jmp op_end

remainder:
    cmp dx, 0
    je div_error
	
	cmp ax, 8000h      ; -32768
    jne safe_remain
    cmp dx, -1
    jne safe_remain
	
	; -32768 % -1 = 0
	xor ax, ax
	clc
	jmp op_end

safe_remain:
	mov bx, dx      ; divider
    cwd
    idiv bx
    mov ax, dx      ; take the remainder
    clc
    jmp op_end

div_error:
	mov ax, -1
	stc
    jmp op_end

overflow:
	mov ax, -1
	stc
	jmp op_end
	
op_end:
    mov sp, bp
    pop bp
    ret
_operation endp	
	
	
	
; void calc() - calculator function
; ax=-1 if error
_calc proc near
    push bp
    mov bp, sp
		
	sub sp, 4						; [bp - 2] = 1 number res
									; [bp - 4] = 2 number res

	push offset input_buffer
	call _check
	add sp, 2
	cmp ax, -1
	je error_check
	
	; taking numbers and an operand
	push offset input_buffer
	
	call _convert
	jnc convert_ok

	add sp, 2
	jmp error_convert

convert_ok:
	add sp, 2
	
	; after that in ax,dx are numbers, operator in global data
	
	push dx       			 ; +arg3
	push ax        			 ; +arg2
	mov al, [operator]		 
	cbw            			 
	push ax     			 ; +arg1
	
	call _operation
	jnc op_success
	
	add sp, 6
	jmp error_calc
	
op_success:
	add sp, 6
	
	
	; saved the result
	mov word ptr [bp - 2], ax
	mov word ptr [bp - 4], dx				

	cmp byte ptr [operator], '*'
	je _32res_print
	jmp _16res_print

_16res_print:	
	; WRITE RESULT IN WORD
	push offset res_str				; +arg2
	push word ptr [bp - 2]			; +arg1
	call _itoa
	add sp, 4
	
	mov ax, 0
	jmp end_calc

	
_32res_print:
	; WRITE RESULT IN DWORD
	push offset res_str			; arg3
	push word ptr [bp - 4]			; arg2
	push word ptr [bp - 2]			; arg1
	call _itoa32
	add sp, 6
	
	mov ax, 0
	jmp end_calc
	
error_check:
	mov ax,  -1
	jmp end_calc
	
error_convert:
	mov ax,  -1
	jmp end_calc
	
error_calc:
	mov ax,  -1
	jmp end_calc
	
end_calc:
	mov sp, bp
    pop bp
    ret
_calc endp
	