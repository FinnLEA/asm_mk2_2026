mem_alloc proc near	
	_alloc_local equ 2
	
	push bp
	mov  bp, sp
	sub  sp, _alloc_local
	
	mov  bx, 0FFF0h
	mov  ax, word ptr [bp + 4]
	add  ax, 0Fh
	and  bx, ax
	
	shr  bx, 4
	mov  word ptr [bp - 2], bx
	
	mov  bx, 0FFFFh
	mov  ah, 48h
	int  21h
	
	cmp  bx, word ptr [bp - 2]
	jb   ma_fail
	
	mov  ah, 48h
	mov  bx, word ptr [bp - 2]
	int  21h
	
	jnc  ma_done

ma_fail:
	xor  ax, ax

ma_done:
	add  sp, _alloc_local
	mov  sp, bp
	pop  bp
	ret

mem_alloc endp


mem_free proc near
	push bp
	mov  bp, sp
	push es

	mov  es, word ptr [bp + 4]
	mov  ah, 49h
	int  21h

	jnc  mf_done

	stc

mf_done:
	pop  es
	mov  sp, bp
	pop  bp
	ret

mem_free endp


mem_init proc near 
	push bp
	mov  bp, sp
	push es

	mov  bx, 0FFF0h
	mov  ax, word ptr [bp + 8]
	add  ax, 0Fh
	and  bx, ax

	shr  bx, 4

	mov  ax, word ptr [bp + 6]
	add  bx, ax

	mov  ax, word ptr [bp + 4]
	sub  bx, ax

	mov  ah, 4Ah
	int  21h

	jnc  mi_ok

mi_fail:
	xor  ax, ax
	jmp  mi_done

mi_ok:
	mov  ax, 1

mi_done:
	pop  es
	mov  sp, bp
	pop  bp
	ret

mem_init endp


mem_realloc proc near
	_realloc_local equ 2
	
	push bp
	mov  bp, sp
	sub  sp, _realloc_local
	push es

	mov  bx, 0FFF0h
	mov  ax, word ptr [bp + 6]
	add  ax, 0Fh
	and  bx, ax
	
	shr  bx, 4
	mov  word ptr [bp - 2], bx

	mov  es, word ptr [bp + 4]
	mov  ah, 4Ah
	int  21h

mr_done:
	pop  es
	add  sp, _realloc_local
	mov  sp, bp
	pop  bp
	ret

mem_realloc endp