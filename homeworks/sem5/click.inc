

; int click_keyboard()
; return:
; AX = -1 -> exit program
; AX =  0 -> nothing
; AX =  1 -> symbol processed
click_keyboard proc near
	push bp
	mov bp, sp

    mov ah, 1
    int 16h
    jz keyboard_no_event
	; this --> key is ready
	
	; recieve AX --> AH - scan_code, AL - symbols
    mov ah, 0
    int 16h
	
	; linking a click to a specific button
	push ax
	call check_key
	add sp, 2
	
	cmp ax, -1					; no link
	je keyboard_no_event	
	
	cmp ax, -2					; escape
	je keyboard_exit

	mov word ptr [id_symbol], ax 	
	
	push ax
	call flash_button
	add sp, 2
	
	mov ax,  1					; processed
	jmp click_keyboard_ret

	
keyboard_exit:
	mov ax, -1
	jmp click_keyboard_ret
	
keyboard_no_event:
	mov ax, 0
	
click_keyboard_ret:
	mov sp, bp
	pop bp
	ret
click_keyboard endp


; int click_mouse()
; AX = 0 -> nothing
; AX = 1 -> event processed
click_mouse proc near
    push bp
    mov bp, sp

    ; -------------------
    ; get the mouse state
    mov ax, 3
    int 33h
    shr cx, 1                ; CX = x, DX = y
	
    test bx, 1               ; left button pressed?
    jz mouse_no_event        ; no

	push cx
	push dx
    ; ----------------------------------------
    ; 1) BUTTON IS PRESSED --> WAIT FOR RELEASE
    ; ----------------------------------------
	wait_release:
		mov ax, 3
		int 33h
		test bx, 1
		jnz wait_release         ; still pressed --> keep waiting

		
	pop dx
	pop cx
    ; ----------------------------------------
    ; 2) NOW PROCESS THE CLICK
    ; ----------------------------------------
    push cx
    push dx
    call check_button
    add sp, 4

    cmp ax, -1
    je mouse_no_event              ; clicked outside buttons

    ; normal button
    push ax
    call flash_button
    add sp, 2

    mov word ptr [id_symbol], ax
    mov ax, 1
    jmp ret_click

mouse_no_event:
    mov ax, 0

ret_click:
    mov sp, bp
    pop bp
    ret
click_mouse endp

