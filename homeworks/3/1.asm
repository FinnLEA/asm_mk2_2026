stack segment para stack
db 256 dup(?)
stack ends

data segment para public
	new_line db 0ah,0dh,'$'	; перевод на новую строку
	array_str db 240,?,240 dup(?)
			db 240,?,240 dup(?)
			db 240,?,240 dup(?) ; массив строк
data ends

code segment para public 

assume cs:code,ds:data,ss:stack

start:
    mov ax, data
    mov ds, ax
    mov ax, stack
    mov ss, ax
	
; ввод строк
; 1 блок
	mov dx, offset array_str
	mov ah, 0ah
	int 21h

	mov ah, 09h
	mov dx, offset new_line
	int 21h

; 2 блок
	mov dx, offset array_str + 242
	mov ah, 0ah
	int 21h

	mov ah, 09h
	mov dx, offset new_line
	int 21h

; 3 блок
	mov dx, offset array_str + 484
	mov ah, 0ah
	int 21h

	mov ah, 09h
	mov dx, offset new_line
	int 21h
	
	mov ah, 09h
	mov dx, offset new_line
	int 21h
	
; вывод строк
; 1 блок
	mov bx, offset array_str
	lea bx, [bx + 1]
	xor cx, cx
	mov cl, [bx]
	add bx, cx
	mov byte ptr[bx + 1], "$"
	
	xor bx, bx
	mov bx, offset array_str
	lea bx, [bx + 2]
	mov dx, bx
	mov ah, 09h
	int 21h
	
	mov ah, 09h
	mov dx, offset new_line
	int 21h

; 2 блок
	mov bx, offset array_str
	lea bx, [bx + 243]
	xor cx, cx
	mov cl, [bx]
	add bx, cx
	mov byte ptr[bx + 1], "$"
	
	xor bx, bx
	mov bx, offset array_str
	lea bx, [bx + 244]
	mov dx, bx
	mov ah, 09h
	int 21h
	
	mov ah, 09h
	mov dx, offset new_line
	int 21h

; 3 блок
	mov bx, offset array_str
	lea bx, [bx + 485]
	xor cx, cx
	mov cl, [bx]
	add bx, cx
	mov byte ptr[bx + 1], "$"
	
	xor bx, bx
	mov bx, offset array_str
	lea bx, [bx + 486]
	mov dx, bx
	mov ah, 09h
	int 21h
	
	mov ah, 09h
	mov dx, offset new_line
	int 21h
    
    mov ah, 4ch
    mov al, 00h
	int 21h
code ends

end start
