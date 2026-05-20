


;					ширина		высота	     начало у		начало x	у      x
; int is_in_button(int width, int height, int button_y, int bytton_x, int y, int x)
; return ax = 0 if in, ax = -1 if NOT in
is_in_button proc near
	push bp
	mov bp, sp
	sub sp, 12
	
	push bx
	push cx
	push dx
	push di
	push si
	
	mov ax, [bp + 14]				; x
	mov bx, [bp + 12]				; y
	mov cx, [bp + 10]				; bytton_x
	mov dx, [bp + 8]				; button_y
	mov di, [bp + 6]				; height
	mov si, [bp + 4]				; width
	
	mov [bp - 12], ax				; x
	mov [bp - 10], bx				; y
	mov [bp - 8],  cx				; bytton_x
	mov [bp - 6],  dx				; button_y
	mov [bp - 4],  di				; height
	mov [bp - 2],  si				; weidth
	
	;--------------------------------------------------
	mov bx, [bp - 8]				; start_button_X
	cmp [bp - 12], bx
	jb not_in_button
	
	add bx, [bp - 2]				
	cmp [bp - 12], bx				; right border
	ja not_in_button
	
	mov bx, [bp - 6]
	cmp [bp - 10], bx
	jb not_in_button
	
	add bx, [bp - 4]
	cmp [bp - 10], bx
	ja not_in_button
	
	; else --> in button
	
	mov ax, 0
	jmp is_in_button_ret
	
	not_in_button:
		mov ax, -1
	
is_in_button_ret:
	pop si
	pop di
	pop dx
	pop cx
	pop bx

	mov sp, bp
	pop bp
	ret
is_in_button endp


; int check_button(int y, int x)
; return ax = symbol_id, -1 if fail
check_button proc near
	push bp
	mov bp, sp
	sub sp, 6
	
	push bx
	push dx
	push si
	
	mov bx, [bp + 6]			; x
	mov dx, [bp + 4]			; y
	mov [bp - 2], bx			; [bp - 2] = x
	mov [bp - 4], dx			; [bp - 4] = y
	
	mov word ptr [bp - 6], COUNT_SYMBS	; all count if symbols
	mov si, offset btn_1		; start of table
	cycle_table:

		push word ptr [bp - 2]	; x
		push word ptr [bp - 4]  ; y
		push word ptr [si]		; start_x_button
		push word ptr [si + 2]	; start_y_button
		push word ptr [si + 4]	; height
		push word ptr [si + 6]	; width
		call is_in_button		; 0 = in, -1 = not in
		add sp, 12
		
		cmp ax, 0
		je find_simbol
		
		dec word ptr [bp - 6]
		cmp word ptr [bp - 6], 0
		je not_find_symbol
		
		add si, 10
		jmp cycle_table

		not_find_symbol:
			mov ax, -1
			jmp end_cycle_table
		
		find_simbol:
			mov ax, [si + 8]
			jmp end_cycle_table
		
	end_cycle_table:
	
check_button_ret:	

	pop si
	pop dx
	pop bx
	
	mov sp, bp
	pop bp
	ret
check_button endp


; int check_key(int symbol) scan_code and ascii
; return ax = symbol_id, -1 if fail
check_key proc near
	push bp
	mov bp, sp
	
	mov ax, [bp + 4]		; scan_code in ah
	
	cmp ah, 1h
	je return_esc
	
	cmp al, '+'
	je return_pls
	cmp al, '-'
	je return_mns
	cmp al, '*'
	je return_mul
	cmp al, '/'
	je return_div
	cmp al, '%'
	je return_mod
	
	cmp ah, 1Ch
	je return_equ
	cmp ah, 0Eh
	je return_ers
	
	
	cmp ah, 2h
	je return1
	cmp ah, 3h
	je return2
	cmp ah, 4h
	je return3
	cmp ah, 5h
	je return4
	cmp ah, 6h
	je return5
	cmp ah, 7h
	je return6
	cmp ah, 8h
	je return7
	cmp ah, 9h
	je return8
	cmp ah, 0Ah
	je return9
	cmp ah, 0Bh
	je return0
	
	
	jmp not_key_find
	
return_esc:
	mov ax, -2
	jmp check_key_ret

return_ers:
	mov ax, 20
	jmp check_key_ret
return_equ:
	mov ax, 19
	jmp check_key_ret
	
return_pls:
	mov ax, 10
	jmp check_key_ret
return_mns:
	mov ax, 11
	jmp check_key_ret
return_mul:
	mov ax, 12
	jmp check_key_ret
return_div:
	mov ax, 13
	jmp check_key_ret
return_mod:
	mov ax, 14
	jmp check_key_ret

	
return0:
	mov ax, 0
	jmp check_key_ret
return1:
	mov ax, 1
	jmp check_key_ret
return2:
	mov ax, 2
	jmp check_key_ret
return3:
	mov ax, 3
	jmp check_key_ret
return4:
	mov ax, 4
	jmp check_key_ret
return5:
	mov ax, 5
	jmp check_key_ret
return6:
	mov ax, 6
	jmp check_key_ret
return7:
	mov ax, 7
	jmp check_key_ret
return8:
	mov ax, 8
	jmp check_key_ret
return9:
	mov ax, 9
	jmp check_key_ret

not_key_find:
	mov ax, -1
	jmp check_key_ret
	
	
check_key_ret:
	mov sp, bp
	pop bp
	ret
check_key endp


; int is_operator(int symbol_id)
; return AX = 0 if operator, AX = -1 if not operator
is_operator proc near
	push bp
	mov bp, sp
	
	push bx
	mov bx, [bp + 4]
	cmp bx, 10
	jb not_operator
	cmp bx, 14
	ja not_operator
	
	mov ax, 0
	jmp is_operator_ret
	
not_operator:
	mov ax, -1
	
is_operator_ret:
	pop bx
	
	mov sp, bp
	pop bp
	ret
is_operator endp


; void append_expression(int symbol_id)
append_expression proc near
	push bp
	mov bp, sp
	
	push bx
	push si
	push di
	
	; ---------------------------
	; overflow buffer check
	cmp word ptr [input_size], 11
	jae append_fail
	
	mov bx, [bp + 4]
	mov si, offset input_buffer
	add si, word ptr [input_size]
	
	; --------------------------
	; check double operators
	push bx
	call is_operator
	add sp, 2

	cmp ax, -1
	je continue_append
	
	; operator in start?
	cmp word ptr [input_size], 0		; not operator in start
	jne check_prev_operator

	cmp bl, 11							; '-'
	je continue_append
	
	jmp append_fail
	
check_prev_operator:

    ; get previous char
    mov di, offset input_buffer
    add di, [input_size]
    dec di

    mov al, [di]          ; AL = previous char

    ; previous not operator -> OK
    cmp al, '+'
    je prev_is_op
    cmp al, '-'
    je prev_is_op
    cmp al, '*'
    je prev_is_op
    cmp al, '/'
    je prev_is_op
    cmp al, '%'
    je prev_is_op

    jmp continue_append   ; previous is digit -> ok


prev_is_op:
    ; previous IS operator

    ; current must be '-' to allow sign
    cmp bl, 11            ; '-' id
    jne append_fail       ; any other operator --> fail

    ; BUT! previous must NOT be '-'
    cmp al, '-'           ; previous '-'
    je append_fail        ; forbid "--"

    ; else: operator followed by '-' -->allowed
    jmp continue_append
	
continue_append:
	cmp bl, 9
	jbe digit_fill 
	
	cmp bl, 10
	je fill_pls
	cmp bl, 11
	je fill_mns
	cmp bl, 12
	je fill_mul
	cmp bl, 13
	je fill_div
	cmp bl, 14
	je fill_mod
	
	jmp append_fail
	
	fill_pls:
		mov byte ptr [si], '+'
		jmp after_add
	fill_mns:
		mov byte ptr [si], '-'
		jmp after_add
	fill_mul:
		mov byte ptr [si], '*'
		jmp after_add
	fill_div:
		mov byte ptr [si], '/'
		jmp after_add
	fill_mod:
		mov byte ptr [si], '%'
		jmp after_add
		
	
	digit_fill:
		add bl, '0'
		mov byte ptr [si], bl
		jmp after_add

after_add:
	mov byte ptr [si + 1], 0
	inc word ptr [input_size]
	
	mov ax, 0
	jmp append_expression_ret
	
append_fail:
	mov ax, -1		
	jmp append_expression_ret
	
append_expression_ret:
	pop di
	pop si
	pop bx
	
	mov sp, bp
	pop bp
	ret
append_expression endp



; timer for flash_button
delay_ticks proc near
	push bp
	mov bp, sp

	push bx
	push cx
	push dx
	push si

	mov si, word ptr [bp + 4]		; ticks to wait

	mov ah, 0
	int 1Ah

	mov bx, dx				; start tick

wait_loop_delay:
	mov ah, 0
	int 1Ah

	mov ax, dx
	sub ax, bx

	cmp ax, si
	jb wait_loop_delay

	pop si
	pop dx
	pop cx
	pop bx

	mov sp, bp
	pop bp
	ret
delay_ticks endp


flash_button proc near
	push bp
	mov bp, sp
	
	push ax
	push bx
	push cx
	push si
	push di
	
	mov cx, word ptr [buttons_count]
	mov bx, offset btn_1
cycle_find_button:
	mov si, word ptr [bx + 8]
	cmp si, word ptr [bp + 4]
	je find_click
	
	add bx, 10
	loop cycle_find_button
	jmp flash_button_ret
	
find_click:
	push 0fh
	push word ptr [bx + 4]
	push word ptr [bx + 6]
	push word ptr [bx]
	push word ptr [bx + 2]
	call draw_rectangle
	add sp, 10
	
	push 2
	call delay_ticks
	add sp, 2
	
	; return
	push 4h
	push word ptr [bx + 4]
	push word ptr [bx + 6]
	push word ptr [bx]
	push word ptr [bx + 2]
	call draw_rectangle
	add sp, 10
	

flash_button_ret:
	pop di
	pop si
	pop cx 
	pop bx
	pop ax
	
	mov sp, bp
	pop bp
	ret
flash_button endp




