stack segment para stack
db 256 dup(?)
stack ends

data segment para public
db 256 dup(?)
data ends

code segment para public

assume cs:code,ds:data,ss:stack

start:
	mov ax, data
	mov ds, ax
	mov ax, stack
	mov ss, ax
	
	mov ah, 01h
	int 21h
	
	mov dl, al
	mov ah, 02h
	int 21h
	
	
	mov ah, 4ch
	int 21h
	
code ends
end start