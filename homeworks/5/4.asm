stack segment para stack
db 256 dup (?)
stack ends 

data segment para public
	new_line db 0dh, 0ah, "$"
	
	space db " "
	summ dw 0
	divide db 8
	
	hex_str db "0123456789ABCDEF"
	cur_hex db ?,?,"$"
	
data ends

code segment para public 

assume cs:code,ds:data,ss:stack

start:
	mov ax, data ; инициализация
    mov ds, ax
    mov ax, stack
    mov ss, ax
	
	mov cx, 256
	
	jmp newline
	
num_7:
	mov dl, "\"
	mov ah, 02h
	int 21h
	mov dl, "a"
	mov ah, 02h
	int 21h
	
	jmp mark
num_8:
	mov dl, "\"
	mov ah, 02h
	int 21h
	mov dl, "b"
	mov ah, 02h
	int 21h
	
	jmp mark
	
num_9:
	mov dl, "\"
	mov ah, 02h
	int 21h
	mov dl, "t"
	mov ah, 02h
	int 21h
	
	jmp mark
	
num_10:
	mov dl, "\"
	mov ah, 02h
	int 21h
	mov dl, "n"
	mov ah, 02h
	int 21h
	
	jmp mark
	
num_11:
	mov dl, "\"
	mov ah, 02h
	int 21h
	mov dl, "v"
	mov ah, 02h
	int 21h
	
	jmp mark

num_12:
	mov dl, "\"
	mov ah, 02h
	int 21h
	mov dl, "f"
	mov ah, 02h
	int 21h
	
	jmp mark
	
num_13:
	mov dl, "\"
	mov ah, 02h
	int 21h
	mov dl, "r"
	mov ah, 02h
	int 21h
	
	jmp mark
	
newline:
	mov dx, offset new_line
	mov ah, 09h
	int 21h
	add cx, -1
	jmp loop_large	

loop_large:
; checks
	cmp word ptr[summ], 7
	je num_7
	cmp word ptr[summ], 8
	je num_8
	cmp word ptr[summ], 9
	je num_9
	cmp word ptr[summ], 10
	je num_10
	cmp word ptr[summ], 11
	je num_11
	cmp word ptr[summ], 12
	je num_12
	cmp word ptr[summ], 13
	je num_13

	mov dl, byte ptr[summ]
	mov ah, 02h
	int 21h
	
	mov dl, byte ptr[space]
	mov ah, 02h
	int 21h

	jmp mark
	
proxy_loop: ; чтоб допрыгнуть
	jmp loop_large
	
proxy_newline:
	jmp newline
	
mark:
	mov dl, byte ptr[":"]
	mov ah, 02h
	int 21h
	
	mov dl, byte ptr[space]
	mov ah, 02h
	int 21h
	
; dec to hex
	xor ax, ax
	xor dx, dx
	mov ax, word ptr[summ]
	mov bx, 16
	div bx
	
	mov bx, offset hex_str
	add bx, ax
	mov bl, byte ptr[bx]
	mov byte ptr[cur_hex], bl
	
	mov bx, offset hex_str
	add bx, dx
	mov bl, byte ptr[bx]
	mov byte ptr[cur_hex + 1], bl
	
	mov dx, offset cur_hex
	mov ah, 09h
	int 21h
	
	mov dl, byte ptr[space]
	mov ah, 02h
	int 21h	
	
	add word ptr[summ], 1
	mov ax, word ptr[summ]
	mov bl, byte ptr[divide]
	div bl
	cmp ah, 0
	je proxy_newline
	
	loop proxy_loop
	

	
; last num
	mov dl, byte ptr[summ]
	mov ah, 02h
	int 21h
	
	mov dl, byte ptr[space]
	mov ah, 02h
	int 21h
	
	mov dl, byte ptr[":"]
	mov ah, 02h
	int 21h
	
	mov dl, byte ptr[space]
	mov ah, 02h
	int 21h
	
; dec to hex
	xor ax, ax
	xor dx, dx
	mov ax, word ptr[summ]
	mov bx, 16
	div bx
	
	mov bx, offset hex_str
	add bx, ax
	mov bl, byte ptr[bx]
	mov byte ptr[cur_hex], bl
	
	mov bx, offset hex_str
	add bx, dx
	mov bl, byte ptr[bx]
	mov byte ptr[cur_hex + 1], bl
	
	mov dx, offset cur_hex
	mov ah, 09h
	int 21h
	
exit:
	mov ah, 4ch
	int 21h
	
code ends

end start