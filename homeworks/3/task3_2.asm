stack segment para public
	db 256 dup(?)
stack ends

data segment para public
	buffer db 241 dup(?)
data ends

code segment para public 

assume cs:code,ds:data,ss:stack

start:
	;initialize segments
	mov ax, data
	mov ds, ax
	mov ax, stack
	mov ss, ax
	
	; read into input descriptor
	mov bx, 0
	mov cx, 240
	lea dx, buffer
	mov ah, 3Fh
	int 21h
	
	; write into output descriptor
	mov cx, ax
	mov bx, 1
	lea dx, buffer
	mov ah, 40h
	int 21h
	
	; terminate with return code 0
	mov ax, 4c00h
	int 21h

code ends
end start
