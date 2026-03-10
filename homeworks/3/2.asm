stack segment para stack
db 256 dup(?)
stack ends

data segment para public
	new_line db 0ah,0dh,'$'	; перевод на новую строку
	string db 240 dup(?)
	len dw 0
data ends

code segment para public 

assume cs:code,ds:data,ss:stack

start:
    mov ax, data
    mov ds, ax
    mov ax, stack
    mov ss, ax

; ввод строки
	mov ah, 3fh
	mov bx, 0
	mov cx, 240
	mov dx, offset string
	int 21h

; вывод строки
	mov len, ax
	mov ah ,40h
	mov bx, 1
	mov dx, offset string
	int 21h
    
    mov ah, 4ch
    mov al, 00h
	int 21h
code ends

end start
