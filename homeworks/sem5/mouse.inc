


; byte getmode()
; получить текущий видеорежим  (номер в al)
_getmode proc near
	push bp
	mov bp, sp

	mov ah, 0fh
	int 10h
	
	movzx ax, al

	mov sp, bp
	pop bp
	ret
_getmode endp


; word getKey()
getKey proc
	push bp
	mov bp, sp
	
	mov ah, 0
	int 16h
	; возвращает в ax атрибуты нажатой клавиши:
		; в ah  скан-код
		; в al  аски код клавиши (у некоторых служебных клавиш \ комбинации клавиш нет аски кода, тогда al = 0)
	
	mov sp, bp
	pop bp
	ret
getKey endp

; void printKeys(byte color)
printKeys proc
	
	curr_char equ var1
	isExit	equ var2
	
	push bp
	mov bp, sp
	sub sp, 4*2
	
	mov ax, 0B800h
	mov es, ax
	
	mov byte ptr [bp+curr_char], ' '
	mov byte ptr [bp+isExit], 0
	printKeys_while_b:
		xor bx, bx
		mov cx, 80*25
		print_b: ; пишем 80*25 символов
			mov al, byte ptr [bp+curr_char]
			mov ah, byte ptr [bp+arg1]
			mov word ptr es:[bx], ax
			add bx, 2
			loop print_b
		
		cmp byte ptr [bp+isExit], 1
		je printKeys_while_e
		
		call getKey

		cmp ah, 01h	; ESC scan code
		jne next_check
		mov byte ptr [bp+isExit], 1
		jmp set_key
		
		next_check:
		cmp al, 0	;если нажатая клавиша (комбинация клавиш) не имеет символьного отображения
		je printKeys_while_b
		
		set_key:
		mov byte ptr [bp+curr_char], al
		jmp printKeys_while_b
	printKeys_while_e:
	
	mov sp, bp
	pop bp
	ret
printKeys endp


; handler_ss dw ?
; handler_sp dw ?

; mouse_handler proc far
	; int 3
	; pusha
	; pushf
	
	; ; сохранили глобально старый стек
	; mov word ptr [handler_ss], ss
	; mov word ptr [handler_sp], sp

	; ; настроили новый стек
	; mov ax, stack_int
	; mov ss, ax
	; mov sp, 0FFFFh
	
	; ; mov ax, 2
	; ; int 33h		; спрятать курсор
	
	; ; mov ax, 0B800h
    ; ; mov es, ax
	
	; ; push 2
	; ; push cx
	; ; push dx
	; ; call drawpixel2
	; ; add sp, 6
	
	; ; mov ax, 1   ; показать курсор мыши
	; ; int 33h
	
	; ; вернули старый стек
	; mov sp, word ptr [handler_sp]
	; mov ss, word ptr [handler_ss]
	
	; popf
	; popa
	; retf
	
; mouse_handler endp
	
; ; void print_color_str(ds:char* str, byte color)
; print_color_str proc near
	; index equ var1
	; push bp
	; mov bp, sp
	; sub sp, 4 * 2	; 4 local
	; push es
	
	; xor cx, cx
	; mov [bp+index], cx
	
	; push word ptr [bp+arg1]
	; call _strlen
	; add sp, 2
	
	; mov cx, ax
	; mov ax, 0B800h
    ; mov es, ax
	; xor bx, bx
	; mov di, word ptr [bp+arg1]
	; cycle_1:
		; mov al, byte ptr [di]
		; mov ah, byte ptr [bp+arg2]
		; mov word ptr es:[bx], ax
		; inc di
		; add bx, 2
		; loop cycle_1
		
	; pop es
	; mov sp, bp
	; pop bp
	; ret
; print_color_str endp
