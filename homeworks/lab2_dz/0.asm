stack segment para stack
db 256 dup(?)
stack ends

data segment para public
str db "Hello, asm!",0Dh,0Ah,"$"
data ends

code segment para public

assume cs:code,ds:data,ss:stack

start:
	mov ax, data
	mov ds, ax
	mov ax, stack
	mov ss, ax
	
	lea bx, str
	add bx, 3
	mov byte ptr [bx], "D"
	
	mov dx, offset str
	mov ah,09h
	int 21h
	
	mov dl, [bx+1]
	mov ah, 02h
	int 21h
	
	mov ah, 4ch
	int 21h
	
code ends

end start