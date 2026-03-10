stack segment para stack
db 256 dup(?)
stack ends

data segment para public
str db 240, ?, 240 dup(?)
data ends

code segment para public 

assume cs:code,ds:data,ss:stack

start:
	mov ax, data
    mov ds, ax
    mov ax, stack
    mov ss, ax
	
    mov dx, offset str
	mov ah, 0ah
	int 21h
	
	mov dl, 0Dh
	mov ah, 02h
	int 21h

	mov dl, 0Ah
	mov ah, 02h
	int 21h
	
	mov bx, offset str
	mov ax, 0
	mov al, [bx + 1]
	mov si, ax
	add si, 2
	mov byte ptr [bx + si], '$'
	
	mov bx, offset str
	lea dx, [bx + 2]
	mov ah, 09h
	int 21h
	
    mov ah, 4ch
	int 21h
	
code ends

end start