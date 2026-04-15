stack segment para stack
db 256 dup(?)
stack ends

data segment para public
buffer db 240,0,240 dup(?)
data ends

code segment para public

assume cs:code,ds:data,ss:stack

start:
	mov ax, data
	mov ds, ax
	mov ax, stack
	mov ss, ax
	
	lea dx, buffer
	mov ah, 0Ah
	int 21h
	
	lea bx, buffer+2
	mov cl, [buffer+1]
	xor ch, ch
	add bx, cx
	mov byte ptr [bx], '$'
	
	lea dx, buffer+2
	mov ah, 09h
	int 21h
	
	mov ax, 4c00h
	int 21h
	
code ends
end start