file_open proc near
	push bp
	mov  bp, sp
	push cx
	push dx

	mov  cx, word ptr [bp + 4]
	mov  dx, word ptr [bp + 6]
	mov  al, cl
	mov  ah, 3Dh
	int  21h

	pop  dx
	pop  cx
	pop  bp
	ret

file_open endp



file_close proc near
	push bp
	mov  bp, sp
	push bx

	mov  ah, 3Eh
	mov  bx, word ptr [bp + 4]
	int  21h

	jc   fc_error
	xor  ax, ax

fc_error:
	pop  bx
	mov sp, bp
	pop  bp
	ret

file_close endp



file_seek proc near
	push bp
	mov  bp, sp
	push cx
	push bx

	mov  bx, word ptr [bp + 10]
	mov  dx, word ptr [bp + 6]
	mov  cx, word ptr [bp + 8]

	mov  ah, 42h
	mov  al, byte ptr [bp + 4]
	int  21h

	pop  bx
	pop  cx
	mov sp, bp
	pop  bp
	ret

file_seek endp



file_size proc near
	push bp
	mov  bp, sp

	push word ptr [bp + 4]
	push 0
	push 0
	push 2
	call file_seek
	jc   fs_error
	add  sp, 8

	push dx
	push ax

	push word ptr [bp + 4]
	push 0
	push 0
	push 0
	call file_seek
	add  sp, 8

	pop  ax
	pop  dx

fs_error:
	pop  bp
	ret

file_size endp



file_read proc near
	push bp
	mov  bp, sp
	push bx
	push cx
	push dx

	mov  cx, word ptr [bp + 8]
	mov  ah, 3Fh
	mov  bx, word ptr [bp + 4]
	mov  dx, word ptr [bp + 6]
	int  21h

	pop  dx
	pop  cx
	pop  bx
	pop  bp
	ret

file_read endp



file_read_str proc near
	push bp
	mov  bp, sp
	push ds
	push bx
	push cx
	push dx

	mov  bx, word ptr [bp + 4]
	inc  bx

	push bx
	call mem_alloc
	jc   frs_alloc_fail
	add  sp, 2

	mov  es, ax

	push ds
	push es
	pop  ds

	push word ptr [bp + 4]
	push 0
	push word ptr [bp + 6]
	call file_read
	jc   frs_read_fail
	add  sp, 6

	pop  ds
	mov  ax, es
	clc

frs_done:
	pop  dx
	pop  cx
	pop  bx
	pop  ds
	pop  bp
	ret

frs_read_fail:
	pop  ds
	push es
	call mem_free
	add  sp, 2
	xor  ax, ax
	stc
	jmp  frs_done

frs_alloc_fail:
	add  sp, 2
	xor  ax, ax
	stc
	jmp  frs_done

file_read_str endp