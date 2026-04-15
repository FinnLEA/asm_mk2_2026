stack segment para stack
	db 256 dup(?)
stack ends

data segment para public
	minmess db "Enter min of the range ASCII(0-127): $"
	maxmess db "Enter max of the range ASCII(0-127): $"
	stren db "Enter string: $"
	
	new_line db 0dh, 0ah, "$"
	
	error_numb db "ERROR: Enter number from 0-127$"
	error_mm db "ERROR: min > max$"
	erro db "Some characters in the string is not within the specified range.$"
	succ db "All characters in a string within the specified range.$"
	
	min db ?
	max db ?
	
	buffer db 240,?,240 dup(?)
	
data ends

code segment para public

assume cs:code,ds:data,ss:stack

start:
	mov ax, data
	mov ds, ax
	mov ax, stack
	mov ss, ax

	mov dx, offset minmess
	mov ah, 09h
	int 21h
	xor bx,bx
	
gen_min:
	mov ah, 08h
	int 21h
	
	cmp al, 0dh
	je got_min
	
	cmp al, '0'
	jb err_numb
	cmp al, '9'
	ja err_numb
	
	mov dl, al
	mov ah, 02h
	int 21h
	
	sub al, '0'
	mov ah,0
	mov cx, ax
	mov ax, bx
	mov dx, 10
	mul dx
	add ax, cx
	mov bx, ax
	
	cmp bx, 127
	ja err_numb
	
	jmp gen_min

got_min:
	mov min,bl
	
	mov dx, offset new_line
	mov ah, 09h
	int 21h
	
	mov dx, offset maxmess
	mov ah, 09h
	int 21h
	xor bx,bx
	
gen_max:

	mov ah, 08h
	int 21h
	
	cmp al, 0dh
	je got_max
	
	cmp al, '0'
	jb err_numb
	cmp al, '9'
	ja err_numb
	
	mov dl, al
	mov ah, 02h
	int 21h
	
	sub al, '0'
	mov ah,0
	mov cx, ax
	mov ax, bx
	mov dx, 10
	mul dx
	add ax, cx
	mov bx, ax
	
	cmp bx, 127
	ja err_numb
	
	jmp gen_max

err_numb:
	mov dx, offset new_line
	mov ah, 09h
	int 21h

	mov dx, offset error_numb
	mov ah, 09h
	int 21h
	
	mov ax, 4cffh
	int 21h	
	
got_max:
	mov max,bl
	
	mov al, min
	cmp al, max
	ja err_range
	
	mov dx, offset new_line
	mov ah, 09h
	int 21h
	
	mov dx, offset stren
	mov ah, 09h
	int 21h
	
	mov dx, offset buffer
	mov ah, 0ah
	int 21h
	
	mov dx, offset new_line
	mov ah, 09h
	int 21h
	
	mov cl, buffer+1
	xor ch, ch
	mov si, offset buffer+2
	jmp check

err_range:
	mov dx, offset new_line
	mov ah, 09h
	int 21h
	
	mov dx, offset error_mm
	mov ah, 09h
	int 21h
	
	mov ax, 4cffh
	int 21h
	
check:
	cmp cx, 0
	je nice
	mov al, [si]
	
	cmp al, min
	jb not_nice
	
	cmp al, max
	ja not_nice
	
	inc si
	dec cx
	jmp check
	
nice:
	mov dx, offset succ
	mov ah, 09h
	int 21h
	
	mov ax, 4c00h
	int 21h

not_nice:
	mov dx, offset erro
	mov ah, 09h
	int 21h
	
	mov ax, 4cffh
	int 21h
	

code ends
end start