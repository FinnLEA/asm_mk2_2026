stack segment para stack
db 256 dup(?)
stack ends

code segment para public 

assume cs:code,ss:stack

start:
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