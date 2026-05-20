_get_mode proc near
	push bp
	mov bp, sp

	mov ah, 0Fh		;Пол. видеорежим
	int 10h

	movzx ax, al

	mov sp, bp
	pop bp
	ret
_get_mode endp

_set_mode proc near
	push bp
	mov bp, sp

	mov ax, word ptr [bp + arg1]
	mov ah, 00h						;Уст. режим
	int 10h

	mov sp, bp
	pop bp
	ret
_set_mode endp

_setpixel proc near
	push bp
	mov bp, sp
	pusha

	mov cx, word ptr [bp + arg1]
	test cl, 1
	jz draw_pixel_raw_even_row
	mov bx, 2000h
	jmp short draw_pixel_raw_continue

draw_pixel_raw_even_row:
	xor bx, bx

draw_pixel_raw_continue:
	shr cx, 1
	mov al, 80
	mul cl

	mov dx, word ptr [bp + arg2]
	mov cx, dx
	not cl
	and cl, 00000011b
	shl cl, 1

	shr dx, 1
	shr dx, 1

	add ax, dx
	add bx, ax

	mov ah, es:[bx]
	ror ah, cl
	and ah, 11111100b
	mov al, byte ptr [bp + arg3]
	or ah, al
	rol ah, cl
	mov es:[bx], ah

	popa
	mov sp, bp
	pop bp
	ret
_setpixel endp


_clear_screen	proc	near
	push	bp
	mov	bp,sp

	movzx dx, byte ptr ds:[orig_mode]
	cdecl_call _set_mode, dx				;Перекл. в сох реж

	movzx dx, byte ptr ds:[new_color_mode]
	cdecl_call _set_mode, dx				;Обрат.

    call _mouse_init

	mov sp, bp
	pop	bp
	ret	
_clear_screen	endp


_getKey2	proc	near
	push	bp
	mov	bp,sp
	sub	sp,2
   
	mov	 ah, 1
   
	int	 16h
   
	je	short _getKey2_no_key
   	
	mov	 [bp-2], ax
   	
	jmp _getKey2_done
_getKey2_no_key:
  
	xor	ax,ax
	jmp _getKey2_return_result
_getKey2_done:
   
	mov	ax,word ptr [bp-2]
	jmp _getKey2_return_result
_getKey2_return_result:
   	
	mov	sp,bp
	pop	bp
	ret	
_getKey2	endp

_getKey	proc	near
	push	bp
	mov	bp,sp
	sub	sp,2
  
	mov	 ah, 0
  
	int	 16h
  
	mov	 [bp-2], ax
   
	mov	ax,word ptr [bp-2]
	jmp	short return_result_key
return_result_key:
   	
	mov	sp,bp
	pop	bp
	ret	
_getKey	endp


_draw_char proc
    push bp
    mov  bp, sp
    push ax
    push bx
    push cx
    push es

    mov  ax, 0B800h        ; Сегмент видеопам.
    mov  es, ax

    ; calculate offset = (row * 80 + col) * 2
    mov  al, byte ptr [bp+arg1]		; row
    mov  ah, 80
    mul  ah                    			; ax = row * 80
    mov  bl, byte ptr [bp+arg2]			; col
    xor  bh, bh
    add  ax, bx                			; ax = row*80 + col
    shl  ax, 1                 
    mov  bx, ax                			; bx = offset

    ; write character and attribute 
    mov  al, byte ptr [bp+8]   ; char
    mov  ah, byte ptr [bp+arg4]  ; attr (fon, color, text)
    mov  word ptr es:[bx], ax

    pop  es
    pop  cx
    pop  bx
    pop  ax
    pop  bp
    ret
_draw_char endp


_draw_string	proc	near
	push	bp
	mov	bp,sp
	sub	sp,2
	push	si
	mov	si,word ptr [bp+arg1]
   
	mov	al,byte ptr [bp+arg3]
	mov	byte ptr [bp-1],al
   	
	mov	al,byte ptr [bp+arg2]
	jmp	short _draw_string_cond
_draw_string_loop:
   
	mov	al,byte ptr [bp+arg4]
	push	ax
	mov	al,byte ptr [si]
	push	ax
	mov	al,byte ptr [bp-2]
	push	ax
	mov	al,byte ptr [bp-1]
	push	ax
	call	near ptr _draw_char
	add	sp,8
   
	inc	si
  
	mov	al,byte ptr [bp-2]
	inc	al
_draw_string_cond:
	mov	byte ptr [bp-2],al
	cmp	byte ptr [si],0
	jne	short _draw_string_loop
   
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_draw_string	endp


_draw_button	proc	near
	push	bp
	mov	bp,sp
	sub	sp,14
	push	si
	push	di
	mov	si,word ptr [bp+4]
  	
	xor	di,di
  	
	mov	ax,si
	add	ax,2
	mov	word ptr [bp-14],ax
	jmp	short _draw_button_strlen_test
_draw_button_strlen_body:
   	
	inc	di
_draw_button_strlen_test:
	mov	bx,word ptr [bp-14]
	inc	word ptr [bp-14]
	cmp	byte ptr [bx],0
	jne	short _draw_button_strlen_body
  
	mov	ax,di
	add	ax,2
	mov	word ptr [bp-2],ax
  	
	mov	ax,word ptr [bp-2]
	add	ax,2
	mov	word ptr [bp-4],ax
  	
	mov	ax,19
	sub	ax,word ptr [bp-4]
	mov	bx,2
	cwd	
	idiv	bx
	add	ax,61
	mov	word ptr [bp-6],ax
  
	mov	ax,word ptr [si+22]
	mov	word ptr [bp-8],ax
   	
	mov	al,byte ptr [si+24]
	mov	byte ptr [bp-11],al
   	
	mov	al,byte ptr [bp-11]
	push	ax
	mov	al,43
	push	ax
	mov	al,byte ptr [bp-6]
	push	ax
	mov	al,byte ptr [bp-8]
	push	ax
	call	near ptr _draw_char
	add	sp,8
  	
	mov	word ptr [bp-10],1
	jmp	short _draw_button_top_dash_test
_draw_button_top_dash_body:
   	
	mov	al,byte ptr [bp-11]
	push	ax
	mov	al,45
	push	ax
	mov	al,byte ptr [bp-6]
	add	al,byte ptr [bp-10]
	push	ax
	mov	al,byte ptr [bp-8]
	push	ax
	call	near ptr _draw_char
	add	sp,8
	inc	word ptr [bp-10]
_draw_button_top_dash_test:
	mov	ax,word ptr [bp-4]
	add	ax,65534
	cmp	ax,word ptr [bp-10]
	jge	short _draw_button_top_dash_body
   	
	mov	al,byte ptr [bp-11]
	push	ax
	mov	al,43
	push	ax
	mov	al,byte ptr [bp-6]
	add	al,byte ptr [bp-4]
	add	al,255
	push	ax
	mov	al,byte ptr [bp-8]
	push	ax
	call	near ptr _draw_char
	add	sp,8
  	
	mov	al,byte ptr [bp-8]
	inc	al
	mov	byte ptr [bp-12],al
  	
	mov	al,byte ptr [bp-11]
	push	ax
	mov	al,124
	push	ax
	mov	al,byte ptr [bp-6]
	push	ax
	mov	al,byte ptr [bp-12]
	push	ax
	call	near ptr _draw_char
	add	sp,8
  	
	mov	al,byte ptr [bp-11]
	push	ax
	mov	ax,word ptr [bp-8]
	inc	ax
	push	ax
	mov	ax,word ptr [bp-6]
	add	ax,2
	push	ax
	mov	ax,si
	add	ax,2
	push	ax
	call	near ptr _draw_string
	add	sp,8
   	
	mov	al,byte ptr [bp-11]
	push	ax
	mov	al,124
	push	ax
	mov	al,byte ptr [bp-6]
	add	al,byte ptr [bp-4]
	add	al,255
	push	ax
	mov	al,byte ptr [bp-12]
	push	ax
	call	near ptr _draw_char
	add	sp,8
   	
	mov	al,byte ptr [bp-8]
	add	al,2
	mov	byte ptr [bp-12],al
  	
	mov	al,byte ptr [bp-11]
	push	ax
	mov	al,43
	push	ax
	mov	al,byte ptr [bp-6]
	push	ax
	mov	al,byte ptr [bp-12]
	push	ax
	call	near ptr _draw_char
	add	sp,8
   	
	mov	word ptr [bp-10],1
	jmp	short _draw_button_bottom_dash_test
_draw_button_bottom_dash_body:
  	
	mov	al,byte ptr [bp-11]
	push	ax
	mov	al,45
	push	ax
	mov	al,byte ptr [bp-6]
	add	al,byte ptr [bp-10]
	push	ax
	mov	al,byte ptr [bp-12]
	push	ax
	call	near ptr _draw_char
	add	sp,8
	inc	word ptr [bp-10]
_draw_button_bottom_dash_test:
	mov	ax,word ptr [bp-4]
	add	ax,65534
	cmp	ax,word ptr [bp-10]
	jge	short _draw_button_bottom_dash_body
   	
	mov	al,byte ptr [bp-11]
	push	ax
	mov	al,43
	push	ax
	mov	al,byte ptr [bp-6]
	add	al,byte ptr [bp-4]
	add	al,255
	push	ax
	mov	al,byte ptr [bp-12]
	push	ax
	call	near ptr _draw_char
	add	sp,8
   	
	pop	di
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_draw_button	endp


_draw_ui	proc	near
	push	bp
	mov	bp,sp
	sub	sp,10
	push	si
   
	mov	byte ptr [bp-3],1

	xor	si,si
  	
	mov	word ptr [bp-6],0
  	
	mov	word ptr [bp-8],0
  	
	mov	word ptr [bp-2],0
	jmp	short _draw_ui_vertical_line_cond
_draw_ui_vertical_line_draw:
   	
	mov	al,byte ptr [bp-3]
	push	ax
	mov	al,124
	push	ax
	mov	al,60
	push	ax
	mov	al,byte ptr [bp-2]
	push	ax
	call	near ptr _draw_char
	add	sp,8
	inc	word ptr [bp-2]
_draw_ui_vertical_line_cond:
	cmp	word ptr [bp-2],25
	jl	short _draw_ui_vertical_line_draw
  	
	mov	ax,offset _buttons
	push	ax
	call	near ptr _draw_button
	pop	cx
  	
	mov	ax,offset _buttons+FIRST_BUTTON_OFFSET
	push	ax
	call	near ptr _draw_button
	pop	cx
   	
	mov	ax,offset _buttons+SECOND_BUTTON_OFFSET
	push	ax
	call	near ptr _draw_button
	pop	cx
  	
	mov	ax,offset _buttons+THIRD_BUTTON_OFFSET
	push	ax
	call	near ptr _draw_button
	pop	cx

	jmp	short _draw_ui_output_loop_cond
_draw_ui_output_loop_start:
   
	mov	al,byte ptr _output_buffer[si]
	mov	byte ptr [bp-9],al
  	
	cmp	byte ptr [bp-9],10
	jne	short _draw_ui_not_newline
   	
	inc	word ptr [bp-6]
   	
	mov	word ptr [bp-8],0
   
	jmp	short _draw_ui_after_char
_draw_ui_not_newline:
	cmp	byte ptr [bp-9],13
	jne	short _draw_ui_not_cr
   
	jmp	short _draw_ui_after_char
_draw_ui_not_cr:
   	
	cmp	word ptr [bp-8],60
	jl	short _draw_ui_draw_char_branch
  	
	inc	word ptr [bp-6]
  	
	mov	word ptr [bp-8],0
   	
	cmp	word ptr [bp-6],25
	jl	short _draw_ui_draw_char_branch
  	
	jmp	short _draw_ui_output_loop_end
_draw_ui_draw_char_branch:
  
	mov	al,byte ptr [bp-3]
	push	ax
	mov	al,byte ptr [bp-9]
	push	ax
	mov	al,byte ptr [bp-8]
	push	ax
	mov	al,byte ptr [bp-6]
	push	ax
	call	near ptr _draw_char
	add	sp,8
   
	inc	word ptr [bp-8]
_draw_ui_after_char:
  	
	inc	si
_draw_ui_output_loop_cond:
	cmp	si,word ptr _output_buffer_i
	jae	short _draw_ui_output_loop_end
	cmp	word ptr [bp-6],25
	jl	short _draw_ui_output_loop_start
_draw_ui_output_loop_end:
  
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_draw_ui	endp


_draw_file_input_window	proc	near
	push	bp
	mov	bp,sp
	sub	sp,176
	push	si
	push	di
   
	mov	word ptr [bp-2],50
   	
	mov	word ptr [bp-4],3
  
	mov	ax,80
	sub	ax,word ptr [bp-2]
	mov	bx,2
	cwd	
	idiv	bx
	mov	word ptr [bp-6],ax
  
	mov	ax,25
	sub	ax,word ptr [bp-4]
	mov	bx,2
	cwd	
	idiv	bx
	mov	word ptr [bp-8],ax
   
	mov	word ptr [bp-10],offset _output_file_path_msg
  	
	push	word ptr [bp-10]
	call	near ptr _strlen
	pop	cx
	mov	word ptr [bp-12],ax
	
	mov	ax,word ptr [bp-2]
	add	ax,65534
	sub	ax,word ptr [bp-12]
	mov	bx,2
	cwd	
	idiv	bx
	mov	word ptr [bp-14],ax
	
	mov	ax,word ptr [bp-2]
	add	ax,65534
	sub	ax,word ptr [bp-12]
	sub	ax,word ptr [bp-14]
	mov	word ptr [bp-16],ax
	
	xor	di,di
	
	mov	byte ptr [bp+di-72],43
	inc	di
	
	xor	si,si
	jmp	short _draw_file_input_window_left_dashes_cond
_draw_file_input_window_left_dashes_body:

	mov	byte ptr [bp+di-72],45
	inc	di
	inc	si
_draw_file_input_window_left_dashes_cond:
	cmp	si,word ptr [bp-14]
	jl _draw_file_input_window_left_dashes_body
	
	xor	si,si
	jmp	_draw_file_input_window_title_cond
_draw_file_input_window_title_body:
	
	mov	bx,word ptr [bp-10]
	mov	al,byte ptr [bx+si]
	mov	byte ptr [bp+di-72],al
	inc	di
	inc	si
_draw_file_input_window_title_cond:
	cmp	si,word ptr [bp-12]
	jl	short _draw_file_input_window_title_body

	xor	si,si
	jmp	short _draw_file_input_window_right_dashes_cond
_draw_file_input_window_right_dashes_body:
	
	mov	byte ptr [bp+di-72],45
	inc	di
	inc	si
_draw_file_input_window_right_dashes_cond:
	cmp	si,word ptr [bp-16]
	jl	short _draw_file_input_window_right_dashes_body
	
	mov	byte ptr [bp+di-72],43
	inc	di
	
	mov	byte ptr [bp+di-72],0
	

	push ds
	mov ax, ss
	mov ds, ax

	mov	al,1
	push	ax
	push	word ptr [bp-8]
	push	word ptr [bp-6]
	lea	ax,word ptr [bp-72]
	push	ax
	call	near ptr _draw_string
	add	sp,8

	pop ds
	
	mov	byte ptr [bp-124],124
	
	mov	si,1
	jmp	short _draw_file_input_window_content_init_cond
_draw_file_input_window_content_init_body:
	
	mov	byte ptr [bp+si-124],32
	inc	si
_draw_file_input_window_content_init_cond:
	mov	ax,word ptr [bp-2]
	dec	ax
	cmp	ax,si
	jg	short _draw_file_input_window_content_init_body
	
	lea	ax,word ptr [bp-125]
	mov	bx,word ptr [bp-2]
	
	add	bx,ax

	push bx
	push di

	mov di, bx
	mov	byte ptr ss:[di], 124
	
	pop di
	pop bx
   
	
	lea	ax,word ptr [bp-124]
	mov	bx,word ptr [bp-2]
	add	bx,ax
	push bx
	push di

	mov di, bx
	mov	byte ptr ss:[di], 0
	
	pop di
	pop bx
	
	mov	ax,offset _output_filename
	push	ax
	call	near ptr _strlen
	pop	cx
	mov	word ptr [bp-18],ax
	
	mov	ax,word ptr [bp-2]
	add	ax,65534
	cmp	ax,word ptr [bp-18]
	jle	short _draw_file_input_window_copy_len_else
	mov	ax,word ptr [bp-18]
	jmp	short _draw_file_input_window_copy_len_merge
_draw_file_input_window_copy_len_else:
	mov	ax,word ptr [bp-2]
	add	ax,65534
_draw_file_input_window_copy_len_merge:
	mov	word ptr [bp-20],ax
	
	xor	si,si
	jmp	short _draw_file_input_window_copy_filename_cond
_draw_file_input_window_copy_filename_body:

	mov	al,byte ptr _output_filename[si]
	mov	byte ptr [bp+si-123],al
	inc	si
_draw_file_input_window_copy_filename_cond:
	cmp	si,word ptr [bp-20]
	jl	short _draw_file_input_window_copy_filename_body
	
   	push ds
	mov ax, ss
	mov ds, ax

	mov	al,1
	push	ax
	mov	ax,word ptr [bp-8]
	inc	ax
	push	ax
	push	word ptr [bp-6]
	lea	ax,word ptr [bp-124]
	push	ax
	call	near ptr _draw_string
	add	sp,8

	pop ds
	
	mov	byte ptr [bp-176],43
	
	mov	si,1
	jmp _draw_file_input_window_bottom_dashes_cond
_draw_file_input_window_bottom_dashes_body:
	
	mov	byte ptr [bp+si-176],45
	inc	si
_draw_file_input_window_bottom_dashes_cond:
	mov	ax, word ptr [bp-2]
	dec	ax
	cmp	ax,si
	jg	_draw_file_input_window_bottom_dashes_body
	
	lea	ax, word ptr [bp-177]
	mov	bx, word ptr [bp-2]
	add	bx,ax

	push bx
	push di

	mov di, bx
	mov	byte ptr ss:[di], 43
	
	pop di
	pop bx


	lea	ax,word ptr [bp-176]
	mov	bx,word ptr [bp-2]
	add	bx,ax
	push bx
	push di

	mov bx, di
	mov	byte ptr ss:[di],0
	
	pop di
	pop bx
	
	push ds
	mov ax, ss
	mov ds, ax

	mov	al,1
	push	ax
	mov	ax,word ptr [bp-8]
	add	ax,2
	push	ax
	push	word ptr [bp-6]
	lea	ax,word ptr [bp-176]
	push	ax
	call	near ptr _draw_string
	add	sp,8

	pop ds

	pop	di
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_draw_file_input_window	endp


_up_text	proc	near
	push	bp
	mov	bp,sp
	sub	sp,2
	push	si
	push	di
  
	xor	di,di
  
	mov	ax,word ptr _output_buffer_i
	mov	word ptr [bp-2],ax
  
	xor	si,si
	jmp	short _up_text_loop_condition
_up_text_search_loop_start:
  	
	cmp	byte ptr _output_buffer[si],10
	jne	short _up_text_increment_i
   	
	mov	ax,si
	inc	ax
	mov	di,ax
   
	jmp	short _up_text_check_remove_count
_up_text_increment_i:
	inc	si
_up_text_loop_condition:
	cmp	si,word ptr _output_buffer_i
	jae	short _up_text_check_remove_count
	cmp	si,60
	jb	short _up_text_search_loop_start
_up_text_check_remove_count:
   	
	or	di,di
	jne	short _up_text_after_set_remove
  
	cmp	word ptr _output_buffer_i,60
	jb	short _up_text_short_buffer_no_newline
   	
	mov	di,60
  	
	jmp	short _up_text_after_set_remove
_up_text_short_buffer_no_newline:
   	
	mov	di,word ptr _output_buffer_i
_up_text_after_set_remove:
   
	or	di,di
	jne	short _up_text_compare_remove
   	
	jmp	short _up_text_return
_up_text_compare_remove:
   
	cmp	di,word ptr _output_buffer_i
	jae	short _up_text_else_clear_all
   	
	mov	ax,word ptr _output_buffer_i
	sub	ax,di
	mov	dx,ax
   	
	xor	si,si
	jmp	short _up_text_copy_condition
_up_text_copy_loop:
   	
	mov	bx,si
	mov	al,byte ptr _output_buffer[bx+di]
	mov	byte ptr _output_buffer[si],al
	inc	si
_up_text_copy_condition:
	cmp	si,dx
	jb	short _up_text_copy_loop
   
	mov	ax,dx
	mov	word ptr _output_buffer_i,ax
   	
	jmp	short _up_text_start_clear_tail
_up_text_else_clear_all:
   	
	mov	word ptr _output_buffer_i,0
_up_text_start_clear_tail:
  	
	mov	si,word ptr _output_buffer_i
	jmp	short _up_text_clear_condition
_up_text_clear_loop:
  	
	mov	byte ptr _output_buffer[si],0
	inc	si
_up_text_clear_condition:
	cmp	si,word ptr [bp-2]
	jb	short _up_text_clear_loop
_up_text_return:
  
	pop	di
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_up_text	endp


getQuants proc
	push bp
	mov bp, sp
	push es
	push bx
	
	mov ah, 0
	int 1Ah
	
	mov es, word ptr [bp+arg1]
	mov bx, word ptr [bp+arg2]
	mov word ptr es:[bx], dx
	mov word ptr es:[bx+2], cx
	
	pop bx
	pop es
	mov sp, bp
	pop bp
	ret
getQuants endp


getKey2 proc
	push bp
	mov bp, sp
	
	mov ah, 1
	int 16h
	
	jz getKey2_exit_z
	jmp getKey2_exit
	
	getKey2_exit_z:
	xor ax, ax
	
	getKey2_exit:
	mov sp, bp
	pop bp
	ret
getKey2 endp

