stack segment para stack
	db 256 dup(?)
stack ends

data segment para public
	buffer db 240 dup(?)
data ends

code segment para public

assume cs:code,ds:data,ss:stack

start:
	mov ax,data
	mov ds,ax
	mov ax,stack
	mov ss,ax
	
	mov ah, 3fh
	mov bx,0
	mov cx,240
	mov dx, offset buffer
	int 21h
	
	mov cx, ax
	mov ah, 40h
	mov bx,1
	mov dx, offset buffer
	int 21h
	
	mov ax, 4c00h
	int 21h

code ends
end start