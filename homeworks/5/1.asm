stack segment para stack
db 256 dup (?)
stack ends 

data segment para public
	string db 240,?, 240 dup(?)
	new_line db 0dh, 0ah, "$"
	strlen dw ?
	n_times db 10
	
data ends

code segment para public 

assume cs:code,ds:data,ss:stack

start:
	mov ax, data ; инициализация
    mov ds, ax
    mov ax, stack
    mov ss, ax

	mov dx, offset string ; ввод 
	mov ah, 0ah
	int 21h
	
	mov dx, offset new_line
	mov ah, 09h
	int 21h
	
	mov bx, offset string + 1 ; $
	xor cx, cx
	mov cl, [bx]
	add bx, cx
	mov word ptr[strlen], cx
	mov byte ptr[bx + 1], "$"
	
; 1)
	mov bx, offset string + 1
	mov cx, word ptr[strlen]
	add bx, cx
	
	mov dx, offset new_line
	mov ah, 09h
	int 21h
	
loop1:
	mov dl, [bx]
	mov ah, 02h
	int 21h
	sub bx, 1
	loop loop1
	
	mov dx, offset new_line
	mov ah, 09h
	int 21h
	
	mov dx, offset new_line
	mov ah, 09h
	int 21h
	
; 2)
	mov bx, offset n_times
	mov cx, [bx]
	mov bx, offset string + 2
	
loop2:
	mov dx, bx
	mov ah, 09h
	int 21h
	
	mov dx, offset new_line
	mov ah, 09h
	int 21h
	loop loop2
	
exit:
	mov ah, 4ch
	int 21h
	
code ends

end start