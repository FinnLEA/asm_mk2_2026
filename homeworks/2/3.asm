stack segment para stack
	db 256 dup(?)
stack ends

data segment para public
	buff db 241, ?, 241 dup(?)
data ends

code segment para public
	assume cs:code, ds:data, ss:stack
	
start:
	mov ax, data
	mov ds, ax
	mov ax, stack
	mov ss, ax
	
	mov dx, offset buff
	mov ah, 0Ah
	int 21h
	
    mov dl, 0Dh
	mov ah, 02h
	int 21h
	mov dl, 0Ah
	mov ah, 02h
	int 21h
	
	xor bh, bh
	mov bl, byte ptr [buff + 1]
	mov byte ptr [buff + bx + 2], '$'
	
	mov dx, offset buff+2
	mov ah, 09h
	int 21h
	
	mov ax, 4c00h
	int 21h

code ends
end start