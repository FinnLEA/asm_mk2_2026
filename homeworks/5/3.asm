stack segment para stack
db 256 dup (?)
stack ends 

data segment para public
	new_line db 0dh, 0ah, "$"
	
	space db " "
	high_num db "0"
	low_num db "0"
	summ dw 0
	divide db 10
	flag db 0
	
data ends

code segment para public 

assume cs:code,ds:data,ss:stack

start:
	mov ax, data ; инициализация
    mov ds, ax
    mov ax, stack
    mov ss, ax

	mov cx, 10

loop_small1:
	mov dl, byte ptr[low_num]
	mov ah, 02h
	int 21h
	
	mov dl, byte ptr[space]
	mov ah, 02h
	int 21h
	
	mov dl, byte ptr[space]
	mov ah, 02h
	int 21h
	
	mov bl, byte ptr[low_num]
	add bl, 1
	mov byte ptr[low_num], bl
	
	loop loop_small1
	
	mov cx, 90
	
	jmp newline

loop_small2:
	mov dl, byte ptr[space]
	mov ah, 02h
	int 21h

	mov dl, byte ptr[low_num]
	mov ah, 02h
	int 21h
	
	mov dl, byte ptr[space]
	mov ah, 02h
	int 21h
	
	mov bl, byte ptr[low_num]
	add bl, 1
	mov byte ptr[low_num], bl
	
	loop loop_small2
	
	mov cx, 90
	
newline:
	mov dx, offset new_line
	mov ah, 09h
	int 21h
	
	add byte ptr[high_num], 1
	sub byte ptr[low_num], 10
	add cx, -1
	
loop_large:
	mov dl, byte ptr[high_num]
	mov ah, 02h
	int 21h
	
	mov dl, byte ptr[low_num]
	mov ah, 02h
	int 21h
	
	mov dl, byte ptr[space]
	mov ah, 02h
	int 21h

	mov bl, byte ptr[low_num]
	add bl, 1
	mov byte ptr[low_num], bl
	
	add word ptr[summ], 1
	mov ax, word ptr[summ]
	mov bl, byte ptr[divide]
	div bl
	cmp ah, 0
	je newline
	
	loop loop_large

	mov dl, byte ptr[high_num] ; 99
	mov ah, 02h
	int 21h
	
	mov dl, byte ptr[low_num]
	mov ah, 02h
	int 21h
	
	mov dx, offset new_line
	mov ah, 09h
	int 21h
	
	mov dx, offset new_line
	mov ah, 09h
	int 21h
	
	cmp byte ptr[flag], 1
	je exit
	
	mov byte ptr[flag], 1
	mov cx, 10
	mov byte ptr[high_num], "0"
	mov byte ptr[low_num], "0"
	mov byte ptr[summ], 0
	jmp loop_small2
	
exit:
	mov ah, 4ch
	int 21h
	
code ends

end start