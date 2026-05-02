include <include/header.asm>

DSEG segment para public use16 "DATA"
	orig_mode db 00h
DSEG ends

CSEG segment readonly para public use16 "CODE"
include <include/all.asm>

get_mode proc near
	push bp
	mov bp, sp

	mov ah, 0Fh
	int 10h

	movzx ax, al

	mov sp, bp
	pop bp
	ret
get_mode endp

set_mode proc near
	push bp
	mov bp, sp

	mov ax, word ptr [bp + arg1]
	mov ah, 00h
	int 10h

	mov sp, bp
	pop bp
	ret
set_mode endp

draw_pixel_raw proc near
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
draw_pixel_raw endp

draw_line_x proc near
	push bp
	mov bp, sp
	pusha

	; x
	mov cx, [bp + arg1]
	; y
	mov dx, [bp + arg2]
	; len
	mov si, [bp + arg3]
	; color
	mov di, [bp + arg4]

dlx_loop:
	cmp si, 0
	jle dlx_done

	push di
	push cx
	push dx
	call draw_pixel_raw
	add sp, 6

	inc cx
	dec si
	jmp dlx_loop

dlx_done:
	popa
	mov sp, bp
	pop bp
	ret
draw_line_x endp

draw_line_y proc near
	push bp
	mov bp, sp
	pusha

	; x
	mov cx, [bp + arg1]
	; y
	mov dx, [bp + arg2]
	; len
	mov si, [bp + arg3]
	; color
	mov di, [bp + arg4]

dly_loop:
	cmp si, 0
	jle dly_done

	push di
	push cx
	push dx
	call draw_pixel_raw
	add sp, 6

	inc dx
	dec si
	jmp dly_loop

dly_done:
	popa
	mov sp, bp
	pop bp
	ret
draw_line_y endp

; algorithm: https://en.wikipedia.org/wiki/Midpoint_circle_algorithm
draw_circle proc near
	push bp
	mov bp, sp
	sub sp, 6
	pushr si, di

	cmp word ptr [bp + arg3], 0
	jge short skip_negative_radius
	mov ax, word ptr [bp + arg3]
	neg ax
	mov word ptr [bp + arg3], ax

skip_negative_radius:
	mov ax, word ptr [bp + arg1]
	mov word ptr [bp + var1], ax

	mov ax, word ptr [bp + arg2]
	mov word ptr [bp + var2], ax

	xor si, si

	mov di, word ptr [bp + arg3]

	mov ax, 1
	sub ax, word ptr [bp + arg3]
	mov word ptr [bp + var3], ax
	jmp draw_circle_check_while_condition

	; MID POINT = (X_0 ; Y_0)
	; NEW POINTS (total: 8):
	;   (X_0 +- X ; Y_0 +- Y)
	;   (Y_0 +- X ; X_0 +- Y)
while_loop:
	; +x +y
	mov al, byte ptr [bp + arg4]
	push ax
	mov ax, word ptr [bp + var1]
	add ax, si
	push ax
	mov ax, word ptr [bp + var2]
	add ax, di
	push ax
	call near ptr draw_pixel_raw
	add	sp, 6

	; -x +y
	mov	al, byte ptr [bp + arg4]
	push ax
	mov	ax, word ptr [bp + var1]
	sub	ax, si
	push ax
	mov	ax, word ptr [bp + var2]
	add	ax, di
	push ax
	call near ptr draw_pixel_raw
	add	sp, 6

	; +x -y
	mov	al, byte ptr [bp + arg4]
	push ax
	mov ax, word ptr [bp + var1]
	add ax, si
	push ax
	mov ax, word ptr [bp + var2]
	sub ax, di
	push ax
	call near ptr draw_pixel_raw
	add	 sp, 6

	; -x -y
	mov al, byte ptr [bp + arg4]
	push ax
	mov ax, word ptr [bp + var1]
	sub ax, si
	push ax
	mov ax, word ptr [bp + var2]
	sub ax, di
	push ax
	call near ptr draw_pixel_raw
	add sp, 6

	; +y +x
	mov al, byte ptr [bp + arg4]
	push ax
	mov ax, word ptr [bp + var1]
	add ax, di
	push ax
	mov ax, word ptr [bp + var2]
	add ax, si
	push ax
	call near ptr draw_pixel_raw
	add sp, 6

	; -y +x
	mov al, byte ptr [bp + arg4]
	push ax
	mov ax, word ptr [bp + var1]
	sub ax, di
	push ax
	mov ax, word ptr [bp + var2]
	add ax, si
	push ax
	call near ptr draw_pixel_raw
	add sp, 6

	; +y -x
	mov al, byte ptr [bp + arg4]
	push ax
	mov ax, word ptr [bp + var1]
	add ax, di
	push ax
	mov ax, word ptr [bp + var2]
	sub ax, si
	push ax
	call near ptr draw_pixel_raw
	add sp, 6

	; -y -x
	mov al, byte ptr [bp + arg4]
	push ax
	mov ax, word ptr [bp + var1]
	sub ax, di
	push ax
	mov ax, word ptr [bp + var2]
	sub ax, si
	push ax
	call near ptr draw_pixel_raw
	add sp, 6

	inc si

	cmp word ptr [bp + var3], 0
	jge short draw_circle_d_ge_zero

	mov ax, si
	jmp short draw_circle_update_d

draw_circle_d_ge_zero:
	dec di

	mov ax, si
	sub ax, di

draw_circle_update_d:
	shl ax, 1
	inc ax
	add word ptr [bp + var3], ax

draw_circle_check_while_condition:
	cmp si,di
	jg draw_circle_exit
	jmp while_loop

draw_circle_exit:
	popr di, si
	mov sp,bp
	pop bp
	ret
draw_circle	 endp

draw_window proc near
	push bp
	mov bp, sp
	sub sp, 10
	pushr si, di

	mov ax, [bp + arg1]
	mov bx, [bp + arg2]
	mov cx, [bp + arg3]
	mov dx, [bp + arg4]

	sub cx, ax
	inc cx
	sub dx, bx
	inc dx
	mov [bp + var1], cx
	mov [bp + var2], dx

	mov si, [bp + arg5]

	mov al, [bp + arg6]
	mov ah, 0
	mov [bp + var3], ax
	mov al, [bp+16]
	mov ah, 0
	mov [bp + var4], ax

	xor di, di

draw_window_frame_loop:
	cmp di, si
	jge draw_window_frame_done

	push word ptr [bp + var3]
	mov ax, [bp + var1]
	sub ax, di
	sub ax, di
	jle draw_window_skip_top
	push ax
	mov ax, [bp + arg2]
	add ax, di
	push ax
	mov ax, [bp + arg1]
	add ax, di
	push ax
	call draw_line_x
	add sp, 8

draw_window_skip_top:
	push word ptr [bp + var3]
	mov ax, [bp + var1]
	sub ax, di
	sub ax, di
	jle draw_window_skip_bottom
	push ax
	mov ax, [bp + arg4]
	sub ax, di
	push ax
	mov ax, [bp + arg1]
	add ax, di
	push ax
	call draw_line_x
	add sp, 8

draw_window_skip_bottom:
	push word ptr [bp + var3]
	mov ax, [bp + var2]
	sub ax, di
	sub ax, di
	dec ax
	jle draw_window_skip_left
	push ax
	mov ax, [bp + arg2]
	add ax, di
	inc ax
	push ax
	mov ax, [bp + arg1]
	add ax, di
	push ax
	call draw_line_y
	add sp, 8

draw_window_skip_left:
	push word ptr [bp + var3]
	mov ax, [bp + var2]
	sub ax, di
	sub ax, di
	dec ax
	jle draw_window_skip_right
	push ax
	mov ax, [bp + arg2]
	add ax, di
	inc ax
	push ax
	mov ax, [bp + arg3]
	sub ax, di
	push ax
	call draw_line_y
	add sp, 8

draw_window_skip_right:
	inc di
	jmp draw_window_frame_loop

draw_window_frame_done:
	mov ax, [bp + var1]
	sub ax, si
	sub ax, si
	jle draw_window_fill_done
	mov [bp + var5], ax

	mov ax, [bp + var2]
	sub ax, si
	sub ax, si
	jle draw_window_fill_done

	mov cx, [bp + arg2]
	add cx, si
	mov bx, [bp + arg4]
	sub bx, si
	mov dx, [bp + arg1]
	add dx, si

draw_window_fill_y_loop:
	cmp cx, bx
	jg draw_window_fill_done

	push word ptr [bp + var4]
	push word ptr [bp + var5]
	push cx
	push dx
	call draw_line_x
	add sp, 8

	inc cx
	jmp draw_window_fill_y_loop

draw_window_fill_done:
	popr di, si
	mov sp, bp
	pop bp
	ret
draw_window endp

start:
	init

	call get_mode
	mov byte ptr [orig_mode], al

	mov dx, 04h
	push dx
	call set_mode
	add sp, 2

	mov ax, 0B800H
	mov es, ax

	; draw window
	; fill color
	push 1
	; border color
	push 2
	; border depth
	push 2
	; y end
	push 80
	; x end
	push 100
	; y start
	push 0
	; x start
	push 0
	call draw_window
	add sp, 14

	; draw black horizontal line
	; color
	push 0
	; len
	push 50
	; y start
	push 5
	; x start
	push 5
	call draw_line_x
	add sp, 8

	; draw red vertical line
	; color
	push 2
	; len
	push 50
	; y start
	push 10
	;x start
	push 5
	call draw_line_y
	add sp, 8

	; draw white circle (mid-point algorithm)
	; color
	push 3
	; radius
	push 30
	; center y
	push 40
	; center x
	push 50
	call draw_circle
	add sp, 8

	call getchar
	call crlf

	movzx dx, byte ptr [orig_mode]
	push dx
	call set_mode
	add sp, 2

	call exit_zero

code_end:
CSEG ends
end start
