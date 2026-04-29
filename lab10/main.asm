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

draw_pixel proc near
	push bp
	mov bp, sp
	pusha

	mov bh, 0
	mov dx, word ptr [bp + arg1]
	mov cx, word ptr [bp + arg2]
	mov ax, word ptr [bp + arg3]
	mov ah, 0Ch
	int 10h

	popa
	mov sp, bp
	pop bp
	ret
draw_pixel endp

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
	call draw_pixel
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
	call draw_pixel
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

; bresenham algorithm
draw_line proc near
	push bp
	mov bp, sp
	sub sp, 10
	pusha

	; start_x
	mov cx, [bp + arg1]
	; start_y
	mov dx, [bp + arg2]
	; end_x
	mov si, [bp + arg3]
	; end_y
	mov di, [bp + arg4]

	; dx_val = abs(end_x - start_x)
	mov ax, si
	sub ax, cx
	jge bres_dx_pos
	neg ax

bres_dx_pos:
	mov word ptr [bp - 2], ax

	; sx = start_x < end_x ? 1 : -1
	mov ax, 1
	cmp cx, si
	jl bres_sx_pos
	mov ax, -1

bres_sx_pos:
	mov word ptr [bp - 6], ax

	; dy_val = -abs(end_y - start_y)
	mov ax, di
	sub ax, dx
	jge bres_dy_pos
	neg ax

bres_dy_pos:
	neg ax
	mov word ptr [bp - 4], ax

	; sy = start_y < end_y ? 1 : -1
	mov ax, 1
	cmp dx, di
	jl bres_sy_pos
	mov ax, -1

bres_sy_pos:
	mov word ptr [bp - 8], ax

	; err_val = dx_val + dy_val
	mov ax, word ptr [bp - 2]
	add ax, word ptr [bp - 4]
	mov word ptr [bp - 10], ax

bres_loop:
	; draw_pixel(x, y, color)
	mov ax, word ptr [bp + 12]
	push ax
	push cx
	push dx
	call draw_pixel
	add sp, 6

	; if start_x == end_x && start_y == end_y break
	cmp cx, word ptr [bp + arg3]
	jne bres_not_done
	cmp dx, word ptr [bp + arg4]
	je bres_done

bres_not_done:
	; e2 = 2 * err_val
	mov ax, word ptr [bp - 10]
	sal ax, 1

	; if e2 >= dy_val
	cmp ax, word ptr [bp - 4]
	jl bres_check_y
	; err_val += dy_val
	mov bx, word ptr [bp - 4]
	add word ptr [bp - 10], bx
	; start_x += sx
	mov bx, word ptr [bp - 6]
	add cx, bx

bres_check_y:
	; if e2 <= dx_val
	cmp ax, word ptr [bp - 2]
	jg bres_next
	; err_val += dx_val
	mov bx, word ptr [bp - 2]
	add word ptr [bp - 10], bx
	; start_y += sy
	mov bx, word ptr [bp - 8]
	add dx, bx

bres_next:
	jmp bres_loop

bres_done:
	popa
	mov sp, bp
	pop bp
	ret
draw_line endp

start:
	init

	call get_mode
	mov byte ptr [orig_mode], al

	mov dx, 04h
	push dx
	call set_mode
	add sp, 2

	push 2
	push 50
	push 50
	push 25
	call draw_line_x
	add sp, 8

	push 2
	push 50
	push 50
	push 20
	call draw_line_y
	add sp, 8

	; <90 deg triangle
	; A(100, 30), B(60, 90), C(140, 90)

	; line AB
	mov ax, 1
	push ax
	mov ax, 90
	push ax
	mov ax, 60
	push ax
	mov ax, 30
	push ax
	mov ax, 100
	push ax
	call draw_line
	add sp, 10

	; line BC
	mov ax, 1
	push ax
	mov ax, 90
	push ax
	mov ax, 140
	push ax
	mov ax, 90
	push ax
	mov ax, 60
	push ax
	call draw_line
	add sp, 10

	; line CA
	mov ax, 1
	push ax
	mov ax, 30
	push ax
	mov ax, 100
	push ax
	mov ax, 90
	push ax
	mov ax, 140
	push ax
	call draw_line
	add sp, 10

	; =90 deg triangle
	; D(180, 30), E(180, 90), F(240, 90)

	; line DE
	mov ax, 2
	push ax
	mov ax, 90
	push ax
	mov ax, 180
	push ax
	mov ax, 30
	push ax
	mov ax, 180
	push ax
	call draw_line
	add sp, 10

	; line EF
	mov ax, 2
	push ax
	mov ax, 90
	push ax
	mov ax, 240
	push ax
	mov ax, 90
	push ax
	mov ax, 180
	push ax
	call draw_line
	add sp, 10

	; line FD
	mov ax, 2
	push ax
	mov ax, 30
	push ax
	mov ax, 180
	push ax
	mov ax, 90
	push ax
	mov ax, 240
	push ax
	call draw_line
	add sp, 10

	; >90 deg triangle
	; G(140, 130), H(100, 180), I(240, 180)

	; line GH
	mov ax, 3
	push ax
	mov ax, 180
	push ax
	mov ax, 100
	push ax
	mov ax, 130
	push ax
	mov ax, 140
	push ax
	call draw_line
	add sp, 10

	; line HI
	mov ax, 3
	push ax
	mov ax, 180
	push ax
	mov ax, 240
	push ax
	mov ax, 180
	push ax
	mov ax, 100
	push ax
	call draw_line
	add sp, 10

	; line IG
	mov ax, 3
	push ax
	mov ax, 130
	push ax
	mov ax, 140
	push ax
	mov ax, 180
	push ax
	mov ax, 240
	push ax
	call draw_line
	add sp, 10

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
