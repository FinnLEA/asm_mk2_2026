stack segment para stack
db 256 dup(?)
stack ends

data segment para public
str db "PRINT PRINT string",0Dh,0Ah,"$"
data ends

code segment para public

assume cs:code,ds:data,ss:stack

start:
	mov ax, data
	mov ds, ax
	mov ax, stack
	mov ss, ax
	
	mov dx, offset str
	mov ah, 09h
	int 21h
	
	mov ax, 4c00h
	int 21h
	
code ends
end start