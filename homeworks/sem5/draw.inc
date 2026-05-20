

; функции для работы с отрисовкой

load_fonts proc near
	push bp
    mov bp, sp
	sub sp, 2						; [bp - 2] = fd

	push 0
	push offset filename
	call _fopen
	add sp, 4
	cmp ax, -1
	je error_openf
	
	mov [bp - 2], ax
	
	; filesize
	push ax
	call _get_filesize
	add sp, 2
	cmp ax, -1
	je error_sizef
	
	push offset buffer_fonts
	push ax
	push word ptr [bp - 2]
	call _fread
	add sp, 6
	cmp ax, -1
	je error_readf
	
	; else success read
	push word ptr [bp -2]
	call _fclose
	add sp, 2
	
	jmp load_fonts_done
	
error_openf:
	push offset emsg_openf
	call _putstr
	add sp, 2
	mov ax, -1
	jmp load_fonts_done
	
error_sizef:
	push offset emsg_sizef
	call _putstr
	add sp, 2
	
	push word ptr [bp -2]
	call _fclose
	add sp, 2
	
	mov ax, -1
	jmp load_fonts_done
	
error_readf:
	push offset emsg_readf
	call _putstr
	add sp, 2
	
	push word ptr [bp -2]
	call _fclose
	add sp, 2
	
	mov ax, -1
	jmp load_fonts_done
	
load_fonts_done:
	mov sp, bp
    pop bp
    ret
load_fonts endp


; draw_symbol(symbol_id, start_y, start_x, color)
draw_symbol proc near
    push bp
    mov bp, sp
	sub sp, 12						; [bp - 2] color				; [bp - 10] = 18 strings
									; [bp - 4] x					; [bp - 12] = 12 bit for 1 string
									; [bp - 6] y					 
									; [bp - 8] offset_sym								
	push bx
	push cx
	push dx
	push di
	push si
	
	mov bx, [bp + 4]				; symbol_id
	mov cx, [bp + 6]				; start_y
	mov dx, [bp + 8]				; start_x
	mov di, [bp + 10]				; color
	
	mov [bp - 2], di				; color
	mov [bp - 4], dx				; x
	mov [bp - 6], cx				; y
	
	; offset_sym = offset buffer_fonts + (symbol_id * 36)
	mov ax, bx
	mov cx, 36
	mul cx
	mov dx, offset buffer_fonts
	add ax, dx						; ax = res_value
	mov [bp - 8], ax				; offset_sym
	
	mov word ptr [bp - 10], 18
	
	; всего 18 строчек, из 16 бит надо рассмотреть лишь 12
	; в каждой два байта засунем в ah al
	
	mov bx, [bp - 8]					; start_offset
	_cycle_i:
		mov dx, [bp - 10]
		cmp dx, 0
		je end_cycle_i
		
		mov si, [bp - 4]				; start_x
		mov word ptr [bp - 12], 12				; need checked bits
		mov ah, byte ptr [bx]
		mov al, byte ptr [bx + 1]		; upload bin string
			
		parc_variable:
			mov cx, [bp - 12]
			cmp cx, 0
			je done_parc
		
			test ax, 8000h
			jz skip_draw_pix
			
			; else --> draw
			push ax
			
			push word ptr [bp - 2]			; color
			push si							; x
			push word ptr [bp - 6]			; y
			call _drawpixel
			add sp, 6
			
			pop ax
			
			skip_draw_pix: 
				shl ax, 1
				dec word ptr [bp - 12]				; count of checked bits
				inc si						; inner string
				jmp parc_variable
		
		done_parc:
			dec word ptr [bp - 10]					; count remaining strings 
			add bx, 2						; next string
			inc word ptr [bp - 6]
			jmp _cycle_i

		
	end_cycle_i:
	; success draw
	pop si
	pop di
	pop dx
	pop cx
	pop bx
	
	mov sp, bp
    pop bp
    ret
draw_symbol endp


; void setmode(int mode)
; установка видеорежима (номер режима в младшем байте аргумента)    
_setmode proc near
    push bp
    mov bp, sp
    
    mov ax, word ptr [bp + arg1]
    mov ah, 00h
    int 10h
    
    mov sp, bp
    pop bp
    ret
_setmode endp 

; void drawpixel(int y, int x, int color)
; рисование пикселя (код цвета в младшем байте аргумента)    
_drawpixel proc near
    push bp
    mov bp, sp
	
	push ax
	push bx
	push cx
	push dx
    
    mov bh, 0
    mov dx, word ptr [bp + arg1]			; y
    mov cx, word ptr [bp + arg2]			; x
    mov ax, word ptr [bp + arg3]			; color
    mov ah, 0ch
    int 10h
	
	pop dx
	pop cx
	pop bx
	pop ax
    
    mov sp, bp
    pop bp
    ret
_drawpixel endp  
    

;void draw_line_x(int start_x, int start_y, int len, int color).
draw_line_x proc near
	push bp
	mov bp, sp
	sub sp, 8
	
	push bx
	push cx
	push dx
	push di
	
	mov bx, [bp + 10]				; color
	mov dx, [bp + 8]				; len
	mov cx, [bp + 6]				; start_y
	mov di, [bp + 4]				; start_x
	
	mov [bp - 2], di				; start_x	
	mov [bp - 4], cx				; start_y
	mov [bp - 6], dx				; len
	mov [bp - 8], bx				; color
	
	mov cx, [bp - 6]
	_line_x:
		push cx

		mov bx, [bp - 2]			; start_x
		add bx, cx					; move --> end_x
		dec bx
		push word ptr [bp - 8]					; color
		push bx							; x
		push word ptr [bp - 4]					; y
		call _drawpixel
		add sp, 6

		pop cx
		dec cx
		jnz _line_x
	
draw_line_x_ret:
	pop di
	pop dx
	pop cx
	pop bx
	
	mov sp, bp
    pop bp
    ret
draw_line_x endp

; void draw_line_y(int start_x, int start_y, int len, int color).
draw_line_y proc near
	push bp
	mov bp, sp
	sub sp, 8
	
	push bx
	push cx
	push dx
	push di
	
	mov bx, [bp + 10]				; color
	mov dx, [bp + 8]				; len
	mov cx, [bp + 6]				; start_y
	mov di, [bp + 4]				; start_x
	
	mov [bp - 2], di				; start_x	
	mov [bp - 4], cx				; start_y
	mov [bp - 6], dx				; len
	mov [bp - 8], bx				; color
	
	mov cx, [bp - 6]
	_line_y:
		push cx

		mov bx, [bp - 4]			; start_y
		add bx, cx
		dec bx
		push word ptr [bp - 8]					; color
		push word ptr [bp - 2]					; x
		push bx							; y
		call _drawpixel
		add sp, 6

		pop cx
		dec cx
		jnz _line_y
	
draw_line_y_ret:
	pop di
	pop dx
	pop cx
	pop bx
	
	mov sp, bp
    pop bp
    ret
draw_line_y endp

; void draw_rectangle(int start_y, int start_x, int weigth, int height, int color)
draw_rectangle proc near
	push bp
	mov bp, sp
	
	push bx
	push cx
	push dx
	push di
	push si
	
	mov bx, [bp + 4]			; start_y
	mov cx, [bp + 6]			; start_x
	mov dx, [bp + 8] 			; weigth
	mov di, [bp + 10]			; height
	mov si, [bp + 12]			; color

	push si
	push dx
	push bx
	push cx
	call draw_line_x
	add sp, 8
	
	push si
	push dx
	mov ax, bx
	add ax, di
	push ax
	push cx
	call draw_line_x
	add sp, 8
	
	push si
	push di
	push bx
	push cx
	call draw_line_y
	add sp, 8
	
	push si
	push di
	push bx
	mov ax, cx
	add ax, dx
	push ax
	call draw_line_y
	add sp, 8
	
draw_rectangle_ret:
	pop si
	pop di
	pop dx
	pop cx
	pop bx
	
	mov sp, bp
    pop bp
    ret	
draw_rectangle endp


; void fill_rectangle(int start_y, int start_x, int weigth, int height, int color)
fill_rectangle proc near
	push bp
	mov bp, sp
	
	push ax
	push bx
	push cx
	push dx
	push di
	push si
	
	mov bx, [bp + 4]			; start_y
	mov ax, [bp + 6]			; start_x
	mov dx, [bp + 8] 			; weigth
	mov di, [bp + 10]			; height
	mov si, [bp + 12]			; color
	
	mov cx, di					; height
	_lines_x:
		push cx
		
		push si						; color
		push dx						; len = height(for || x)
		
		mov di, bx					; end_y = start_y + height - 1
		add di, cx	
		dec di
		push di						; end_y (end --> start)

		push ax						; x
		call draw_line_x
		add sp, 8
		
		pop cx
		dec cx
		jnz _lines_x
	
fill_rectangle_ret:
	pop si
	pop di
	pop dx
	pop cx
	pop bx
	pop ax
	
	mov sp, bp
    pop bp
    ret	
fill_rectangle endp


fill_main_table proc near
	push bp
	mov bp, sp

	; wallp
	push 0eh
	push 190-24
	push 155
	push START_X
	push START_Y+24
	call fill_rectangle
	add sp, 10
	
	push 4h
	push 190-24
	push 155
	push START_X
	push START_Y+24
	call draw_rectangle
	add sp, 10
	
	; ---------------------
	; buttons 1 col
	push 4h
	push 24
	push 24
	push 5 + START_X
	push 83 + START_Y
	call draw_rectangle
	add sp, 10
	
	push 4h
	push 24
	push 24
	push 5 + START_X
	push 109 + START_Y
	call draw_rectangle
	add sp, 10
	
	push 4h
	push 24
	push 24
	push 5 + START_X
	push 135 + START_Y
	call draw_rectangle
	add sp, 10
	
	push 4h
	push 24
	push 24
	push 5 + START_X
	push 161 + START_Y
	call draw_rectangle
	add sp, 10
	
	
	; ---------------------
	; buttons 2 col
	push 4h
	push 24
	push 24
	push 31 + START_X
	push 83 + START_Y
	call draw_rectangle
	add sp, 10
	
	push 4h
	push 24
	push 24
	push 31 + START_X
	push 109 + START_Y
	call draw_rectangle
	add sp, 10
	
	push 4h
	push 24
	push 24
	push 31 + START_X
	push 135 + START_Y
	call draw_rectangle
	add sp, 10
	
	push 4h
	push 24
	push 24
	push 31 + START_X
	push 161 + START_Y
	call draw_rectangle
	add sp, 10
	
	; ---------------------
	; buttons 3 col
	push 4h
	push 24
	push 24
	push 57 + START_X
	push 83 + START_Y
	call draw_rectangle
	add sp, 10
	
	push 4h
	push 24
	push 24
	push 57 + START_X
	push 109 + START_Y
	call draw_rectangle
	add sp, 10
	
	push 4h
	push 24
	push 24
	push 57 + START_X
	push 135 + START_Y
	call draw_rectangle
	add sp, 10
	
	push 4h
	push 24
	push 24
	push 57 + START_X
	push 161 + START_Y
	call draw_rectangle
	add sp, 10
	
	; ---------------------
	; buttons 4 col
	push 4h
	push 24
	push 24
	push 99 + START_X
	push 83 + START_Y
	call draw_rectangle
	add sp, 10
	
	push 4h
	push 24
	push 24
	push 99 + START_X
	push 109 + START_Y
	call draw_rectangle
	add sp, 10
	
	push 4h
	push 24
	push 24
	push 99 + START_X
	push 135 + START_Y
	call draw_rectangle
	add sp, 10
	
	push 4h
	push 24
	push 50
	push 99 + START_X
	push 161 + START_Y
	call draw_rectangle
	add sp, 10
	
	; ---------------------
	; buttons 5 col
	push 4h
	push 24
	push 24
	push 125 + START_X
	push 83 + START_Y
	call draw_rectangle
	add sp, 10
	
	push 4h
	push 24
	push 24
	push 125 + START_X
	push 109 + START_Y
	call draw_rectangle
	add sp, 10
	
	push 4h
	push 24
	push 24
	push 125 + START_X
	push 135 + START_Y
	call draw_rectangle
	add sp, 10
		
	; ---------------------
	; input block
	push 0fh
	push 22
	push 145
	push 5 + START_X
	push 29 + START_Y
	call fill_rectangle
	add sp, 10
	
	push 4h
	push 22
	push 145
	push 5 + START_X
	push 29 + START_Y
	call draw_rectangle
	add sp, 10
	
	; ---------------------
	; result block
	push 43h
	push 22
	push 145
	push 5 + START_X
	push 56 + START_Y
	call fill_rectangle
	add sp, 10
	
	push 0h
	push 22
	push 145
	push 5 + START_X
	push 56 + START_Y
	call draw_rectangle
	add sp, 10
	
	call draw_symbols

	mov sp, bp
    pop bp
    ret	
fill_main_table endp

draw_symbols proc near
	push bp
	mov bp, sp
		
	; ------------------
	; buttons 4-5 col
	push 4h
	push 99 + START_X_S
	push 83 + START_Y_S
	push 10
	call draw_symbol
	add sp, 8
	
	push 4h
	push 125 + START_X_S
	push 83 + START_Y_S
	push 11
	call draw_symbol
	add sp, 8
	
	push 4h
	push 99 + START_X_S
	push 109 + START_Y_S
	push 12
	call draw_symbol
	add sp, 8
	
	push 4h
	push 125 + START_X_S
	push 109 + START_Y_S
	push 13
	call draw_symbol
	add sp, 8
	
	push 4h
	push 99 + START_X_S
	push 135 + START_Y_S
	push 14
	call draw_symbol
	add sp, 8
	
	; мышь
	push 4h
	push 125 + START_X_S
	push 135 + START_Y_S
	push 20
	call draw_symbol
	add sp, 8
	
	; = 
	push 4h
	push 99 + START_X_EQ
	push 161 + START_Y_S
	push 19
	call draw_symbol
	add sp, 8
	

	; ---------------------
	; 0-9
	push 4h
	push 5 + START_X_S
	push 83 + START_Y_S
	push 1
	call draw_symbol
	add sp, 8
	
	push 4h
	push 31 + START_X_S
	push 83 + START_Y_S
	push 2
	call draw_symbol
	add sp, 8
	
	push 4h
	push 57 + START_X_S
	push 83 + START_Y_S
	push 3
	call draw_symbol
	add sp, 8
	
	push 4h
	push 5 + START_X_S
	push 109 + START_Y_S
	push 4
	call draw_symbol
	add sp, 8
	
	push 4h
	push 31 + START_X_S
	push 109 + START_Y_S
	push 5
	call draw_symbol
	add sp, 8
	
	push 4h
	push 57 + START_X_S
	push 109 + START_Y_S
	push 6
	call draw_symbol
	add sp, 8
	
	push 4h
	push 5 + START_X_S
	push 135 + START_Y_S
	push 7
	call draw_symbol
	add sp, 8
	
	push 4h
	push 31 + START_X_S
	push 135 + START_Y_S
	push 8
	call draw_symbol
	add sp, 8
	
	push 4h
	push 57 + START_X_S
	push 135 + START_Y_S
	push 9
	call draw_symbol
	add sp, 8
	
	push 4h
	push 31 + START_X_S
	push 161 + START_Y_S
	push 0
	call draw_symbol
	add sp, 8
	

	mov sp, bp
    pop bp
    ret	
draw_symbols endp





; void back_space()
back_space proc near
	push bp
	mov bp, sp

	push ax
	push bx
	push cx
	
	cmp byte ptr [result_shown], 1
	je erase_all
	
	cmp word ptr [space_input], 0
	je back_space_ret
	
	dec word ptr [input_size]
	mov bx, offset input_buffer
	mov ax, word ptr [input_size]
	add bx, ax							; offset for last write
	mov byte ptr [bx], 0 
	
	; cleanup
	sub word ptr [space_input], 13		; for the last write symbol
	
	mov ax, word ptr [space_input]
	add ax, START_INPUT_X 
	
	push 0fh
	push 18
	push 12
	push ax
	push START_INPUT_Y
	call fill_rectangle
	add sp, 10
	jmp back_space_ret
	
erase_all:
	call clear_all
	jmp back_space_ret
	
back_space_ret:	
	pop cx
	pop bx
	pop ax

	mov sp, bp
	pop bp
	ret
back_space endp


clear_all proc near
	push bp
	mov bp, sp
	
	push ax
	push cx
	push di
	
	; -------------------------
	; CLEAR input buffer
	mov di, offset input_buffer
	mov cx, 12

	clear_input_loop:
		mov byte ptr [di], 0
		inc di
		loop clear_input_loop

	; -------------------------
	; CLEAR result buffer
	mov di, offset res_str
	mov cx, 12

	clear_result_loop:
		mov byte ptr [di], 0
		inc di
		loop clear_result_loop

	; -------------------------
	; RESET variables
	mov word ptr [input_size], 0
	mov word ptr [space_input], 0
	mov byte ptr [result_shown], 0

	; CLEAR RECTANGLE
	; INPUT BLOCK -------------
	push 0fh
	push 18
	push 143
	push START_INPUT_X
	push START_INPUT_Y
	call fill_rectangle
	add sp, 10
	
	; OUTPUT BLOCK ------------
	push 43h
	push 18
	push 143
	push START_OUTPUT_X
	push START_OUTPUT_Y
	call fill_rectangle
	add sp, 10
	
clear_all_ret:
	pop di
	pop cx
	pop ax
	
	mov sp, bp
	pop bp
	ret
clear_all endp




; void draw_result_string(char* string)
draw_result_string proc near
	push bp
	mov bp, sp

	push ax
	push bx
	push si

	mov si, word ptr [bp + 4]			; input_buffer
	mov bx, START_OUTPUT_X

draw_loop:
	mov al, byte ptr [si]

	cmp al, 0
	je draw_end

	; ==========================
	; digit?
	cmp al, '0'
	jb check_minus

	cmp al, '9'
	ja check_error_letters

	; ==========================
	; draw symbol 
	sub al, '0'
	mov ah, 0

	push 4h
	push bx							; x
	push START_OUTPUT_Y				; y
	push ax							; id
	call draw_symbol
	add sp, 8

	jmp next_char

; ==========================
; MINUS
check_minus:
	cmp al, '-'
	jne next_char

	mov ax, 11						; id of '-'

	push 4h
	push bx							; x
	push START_OUTPUT_Y				; y
	push ax							; if
	call draw_symbol
	add sp, 8
	
	jmp next_char
	
check_error_letters:
; ==========================
; ERROR
	cmp al, 'E'
	je draw_E
	cmp al, 'R'
	je draw_R
	cmp al, 'O'
	je draw_O
	
	jmp next_char

draw_E:
	mov ax, 15		; id for 'E'

	push 4h
	push bx
	push START_OUTPUT_Y
	push ax
	call draw_symbol
	add sp, 8

	jmp next_char

draw_R:
	mov ax, 16		; id for 'R'

	push 4h
	push bx
	push START_OUTPUT_Y
	push ax
	call draw_symbol
	add sp, 8

	jmp next_char

draw_O:
	mov ax, 17		; id for 'O'

	push 4h
	push bx
	push START_OUTPUT_Y
	push ax
	call draw_symbol
	add sp, 8

	jmp next_char
	
; ==========================
next_char:
	add bx, 13
	inc si
	jmp draw_loop

draw_end:
	pop si
	pop bx
	pop ax

	mov sp, bp
	pop bp
	ret
draw_result_string endp




