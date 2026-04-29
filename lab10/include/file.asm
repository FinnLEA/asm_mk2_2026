fopen proc near
	push bp
	mov bp, sp
	push dx

	mov dx, word ptr [bp + arg1]
	mov al, byte ptr [bp + arg2]
	mov ah, 3Dh
	int 21h
	jnc _fopen_exit

_fopen_fail:
	mov ax, -1

_fopen_exit:
	pop dx
	mov sp, bp
	pop bp
	ret
fopen endp

fclose proc near
	push bp
	mov bp, sp
	push bx

	mov bx, word ptr [bp + arg1]
	mov ah, 3Eh
	int 21h
	jnc _fclose_success

_fclose_fail:
	mov ax, 26
	jmp _fclose_exit

_fclose_success:
	xor ax, ax

_fclose_exit:
	pop bx
	mov sp, bp
	pop bp
	ret
fclose endp

fread proc near
	push bp
	mov bp, sp
	pushr bx, cx, dx

	mov bx, word ptr [bp + arg1]
	mov dx, word ptr [bp + arg2]
	mov cx, word ptr [bp + arg3]
	mov ah, 3Fh
	int 21h
	jnc _fread_success

_fread_fail:
	mov ax, -1
	cwd
	jmp _fread_exit

_fread_success:
	xor dx, dx

_fread_exit:
	popr dx, cx, bx
	mov sp, bp
	pop bp
	ret
fread endp

fwrite proc near
	push bp
	mov bp, sp
	pushr bx, cx, dx

	mov bx, word ptr [bp + arg1]
	mov dx, word ptr [bp + arg2]
	mov cx, word ptr [bp + arg3]
	mov ah, 40h
	int 21h
	jnc _fwrite_success

_fwrite_fail:
	mov ax, -1
	cwd
	jmp _fwrite_exit

_fwrite_success:
	xor dx, dx

_fwrite_exit:
	popr dx, cx, bx
	mov sp, bp
	pop bp
	ret
fwrite endp

lseek proc near
	push bp
	mov bp, sp
	pushr bx, cx

	mov bx, word ptr [bp + arg1]
	mov dx, word ptr [bp + arg2]
	mov cx, word ptr [bp + arg3]
	mov al, byte ptr [bp + arg4]
	mov ah, 42h
	int 21h

	popr cx, bx
	mov sp, bp
	pop bp
	ret
lseek endp

fsize proc near
	push bp
	mov bp, sp
	pushr bx, cx

	mov bx, [bp + arg1]

	mov ax, 4201h
	xor cx, cx
	xor dx, dx
	int 21h
	jc _fsize_fail

	pushr dx, ax

	mov ax, 4202h
	xor cx, cx
	xor dx, dx
	int 21h
	jc _fsize_restore_only

	pushr dx, ax

_fsize_restore:
	popr ax, dx, cx, bx
	pushr dx, ax
	mov dx, cx
	mov cx, bx
	mov ax, 4200h
	int 21h
	popr ax, dx
	jmp _fsize_exit

_fsize_restore_only:
	popr cx, bx
	mov dx, cx
	mov cx, bx
	mov ax, 4200h
	int 21h

_fsize_fail:
	mov ax, -1
	cwd

_fsize_exit:
	popr cx, bx
	mov sp, bp
	pop bp
	ret
fsize endp
