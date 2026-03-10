stack segment para stack
db 256 dup (?)
stack ends 

data segment para public
	divider dw 16
	num dw 100
	hex_str db "0123456789ABCDEF"
	hex_num db ?,?,?,?,"$"
	
data ends

code segment para public 

assume cs:code,ds:data,ss:stack

start:
	mov ax, data ; инициализация
    mov ds, ax
    mov ax, stack
    mov ss, ax
	
	xor ax, ax
	mov ax, word ptr[num]
	mov cx, 4
	
label_1:
	xor dx, dx
	mov bx, word ptr[divider]
	div bx
	
	mov bx, offset hex_num
	add bx, cx
	mov si, offset hex_str
	add si, dx
	mov dl, byte ptr[si]
	mov byte ptr[bx - 1], dl
	
	loop label_1
	
	mov dx, offset hex_num
	mov ah, 09h
	int 21h
	
exit:
	mov ah, 4ch
	int 21h
	
code ends

end start