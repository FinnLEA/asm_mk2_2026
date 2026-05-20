_mouse_init proc near
    push bp
    mov bp, sp

    mov ax, 0         ; инициализировать мышь
	int 33h
	
	mov ax, 1         ; показать курсор мыши
	int 33h
	
    mov ax, cs
    mov es, ax
	mov ax, 000Ch     ; установить обработчик событий мыши
	mov cx, 0002h     ; событие - нажатие левой кнопки
	mov dx, offset _mouse_handler ; ES:DX - адрес обработчика
	int 33h

    mov sp, bp
    pop bp
    ret
_mouse_init endp


_mouse_handler proc far
   pusha
   pushf

   mov bx, ds ; save ds segment

   mov ax, data
   mov ds, ax

   ; сохранили старый стек
   mov word ptr [handler_ss], ss
   mov word ptr [handler_sp], sp
   mov word ptr [hanlder_ds], bx

   ; настроили новый стек
   mov ax, mstack
   mov ss, ax
   mov sp, 0FFFFh

   cmp word ptr [_state], KLOGGER_STATE
   jne _mouse_handler_exit

    ; ПРЕОБРАЗОВАНИЕ ПИКСЕЛЕЙ В ТЕКСТОВЫЕ КООРДИНАТЫ
    ; CX = X пиксель (0..639), DX = Y пиксель (0..399)
    mov ax, cx
    mov bl, 8          ; ширина символа в пикселях (для 80×25)
    div bl             ; AL = столбец (0..79), AH = остаток
    mov cl, al         ; сохраняем столбец в CL (младший байт CX)

    mov ax, dx
    mov bl, 8         ; высота символа в пикселях
    div bl             ; AL = строка (0..24)
    mov dl, al         ; сохраняем строку в DL (младший байт DX)

    ; обнуляем старшие байты, чтобы в CX/DX были только наши значения
    xor ch, ch
    xor dh, dh
    ; теперь передаём в C-функцию текстовые координаты
    push dx            ; Y (строка)
    push cx            ; X (столбец)
    call near ptr _button_click
    pop cx
    pop cx

    ; вернули старый стек
   mov sp, word ptr [handler_sp]
   mov ss, word ptr [handler_ss]

   mov ax, word ptr [hanlder_ds]
   mov ds, ax

_mouse_handler_exit:
   popf
   popa
   retf
_mouse_handler endp

	
_button_click	proc	near
   push	bp
	mov	bp,sp
	sub	sp,12
	push	si
	push	di
   
	xor	si,si
	jmp	_button_click_loop_cond
_button_click_loop_body:
  
	xor	di,di
  
	mov	ax,si
	mov	dx,26
	imul	dx
	add	ax,offset _buttons+2
	mov	word ptr [bp+var1],ax
	jmp	short _button_click_strlen_cond
_button_click_strlen_increment:

	inc	di
_button_click_strlen_cond:
	mov	bx,word ptr [bp-2]
	inc	word ptr [bp-2]
	cmp	byte ptr [bx],0
	jne	short _button_click_strlen_increment

	mov	ax,di
	add	ax,2
	mov	word ptr [bp-4],ax
	
	mov	ax,word ptr [bp-4]
	add	ax,2
	mov	word ptr [bp-6],ax

	mov	ax,19
	sub	ax,word ptr [bp-6]
	mov	bx,2
	cwd	
	idiv	bx
	add	ax,61
	mov	word ptr [bp-8],ax
	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	ax,word ptr _buttons[bx+22]
	mov	word ptr [bp-10],ax
	
	mov	ax,word ptr [bp-10]
	add	ax,2
	mov	word ptr [bp-12],ax
	
	mov	ax,word ptr [bp+4]
	cmp	ax,word ptr [bp-8]
	jl	short _button_click_next_button
	mov	ax,word ptr [bp-8]
	add	ax,word ptr [bp-6]
	dec	ax
	cmp	ax,word ptr [bp+4]
	jl	short _button_click_next_button
	mov	ax,word ptr [bp+6]
	cmp	ax,word ptr [bp-10]
	jl	short _button_click_next_button
	mov	ax,word ptr [bp+6]
	cmp	ax,word ptr [bp-12]
	jg	short _button_click_next_button

	mov	ax,si
	mov	dx,BUTTON_STRUCT_SIZE
	imul	dx
	mov	bx,ax
	cmp	word ptr _buttons[bx],0
	jne	short _button_click_flush

	call	near ptr _clr_button
	
	jmp	short _button_click_click_handled
_button_click_flush:
	
	mov	ax,si
	mov	dx,BUTTON_STRUCT_SIZE
	imul	dx
	mov	bx,ax
	cmp	word ptr _buttons[bx],1
	jne	short _button_click_new_file
	
	call	near ptr _flush_button
	
	jmp	short _button_click_click_handled
_button_click_new_file:
	
	mov	ax,si
	mov	dx,BUTTON_STRUCT_SIZE
	imul	dx
	mov	bx,ax
	cmp	word ptr _buttons[bx],2
	jne	short _button_click_exit
	
	call	near ptr _new_file_button
	
	jmp	short _button_click_click_handled
_button_click_exit:
	
	mov	ax,si
	mov	dx,BUTTON_STRUCT_SIZE
	imul	dx
	mov	bx,ax
	cmp	word ptr _buttons[bx],3
	jne	short _button_click_click_handled

	call	near ptr _exit_button
_button_click_click_handled:

	jmp	short _button_click_return
_button_click_next_button:
	inc	si
_button_click_loop_cond:
	cmp	si,4
	jge	_button_click_loop_end
	jmp	_button_click_loop_body
_button_click_loop_end:
_button_click_return:

	pop	di
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_button_click	endp