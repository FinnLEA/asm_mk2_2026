mem_init proc near
	push bp
	mov bp, sp
	push es

	mov bx, 0FFF0h
	mov ax, word ptr [bp + arg3]
	add ax, 0Fh
	and bx, ax
	shr bx, 4

	mov ax, word ptr [bp + arg2]
	add bx, ax

	mov ax, word ptr [bp + arg1]
	sub bx, ax

	cmp bx, 0
	jbe _mem_init_fail

	mov ah, 4Ah
	int 21h
	jnc _mem_init_success

_mem_init_fail:
	xor ax, ax
	jmp _mem_init_exit

_mem_init_success:
	mov ax, 1

_mem_init_exit:
	pop es
	mov sp, bp
	pop bp
	ret
mem_init endp

mem_alloc proc near
	push bp
	mov bp, sp
	add sp, var1

	mov bx, 0FFF0h
	mov ax, word ptr [bp + arg1]

	cmp ax, 0
	je _mem_alloc_fail

	cmp ax, 0FFF0h
	ja _mem_alloc_fail

	add ax, 0Fh
	and bx, ax
	shr bx, 4
	mov word ptr [bp + var1], bx

	mov bx, 0FFFFh
	mov ah, 48h
	int 21h
	cmp bx, word ptr [bp + var1]
	jb _mem_alloc_fail

	mov bx, word ptr [bp + var1]
	mov ah, 48h
	int 21h
	jnc _mem_alloc_exit

_mem_alloc_fail:
	mov ax, 0

_mem_alloc_exit:
	sub sp, var1
	mov sp, bp
	pop bp
	ret
mem_alloc endp

mem_free proc near
	push bp
	mov bp, sp
	push es

	mov es, word ptr [bp + arg1]

	mov ax, es
	or ax, ax
	jz _mem_free_fail

	mov ah, 49h
	int 21h
	jnc _mem_free_success

_mem_free_fail:
	xor ax, ax
	stc
	jmp _mem_free_exit

_mem_free_success:
	mov ax, 1

_mem_free_exit:
	pop es
	mov sp, bp
	pop bp
	ret
mem_free endp

mem_realloc proc near
	push bp
	mov bp, sp
	add sp, var1
	push es

	mov ax, word ptr [bp + arg2]

	cmp ax, 0FFF0h
	ja _mem_realloc_fail

	mov bx, 0FFF0h
	add ax, 0Fh
	and bx, ax
	shr bx, 4

	mov word ptr [bp + var1], bx
	mov es, word ptr [bp + arg1]

	mov ax, es
	or ax, ax
	jz _mem_realloc_fail

	mov ah, 4Ah
	int 21h
	jnc _mem_realloc_success

_mem_realloc_fail:
	xor ax, ax
	jmp _mem_realloc_exit

_mem_realloc_success:
	mov ax, 1

_mem_realloc_exit:
	pop es
	sub sp, var1
	mov sp, bp
	pop bp
	ret
mem_realloc endp
