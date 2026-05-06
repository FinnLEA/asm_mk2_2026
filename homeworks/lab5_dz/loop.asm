.386

stack segment para stack
db 256 dup (?)
stack ends 

data segment para public
	src_string db "Try find symbol!"
	new_line db 0dh, 0ah, "$"
	src_len dw ?
	dopi db " - $"
	success_str db "Found!", 0dh, 0ah, "$"
	error_str db "Not found", 0dh, 0ah, "$"
	reserved db 256 dup (?)
	
	ncount dw 0
	count_enter db 0
data ends

code segment para public use16

assume cs:code,ds:data,ss:stack

start:
	; инициализация сегментных регистров
	mov ax, data
    mov ds, ax
    mov ax, stack
    mov ss, ax
	nop

main:

	mov ax, ncount
	cmp ax, 0
	je skip
	mov dx,0
	mov bx,5
	div bx
	cmp dx,0
	jne skip
	
	mov dx, offset new_line
	mov ah, 09h
	int 21h
	
	mov dx, offset src_string
	mov ah, 09h
	int 21h
	
	mov dx, offset new_line
	mov ah, 09h
	int 21h
	
skip:
	
	mov ah, 08h
	int 21h
	mov byte ptr [reserved], al
	
	cmp al, 0dh
	jne not_empty
	inc count_enter
	cmp count_enter, 2
	je exit
	jmp next

not_empty:
	
	mov count_enter, 0
	
	mov al, byte ptr [reserved]
	mov cx, offset new_line
	mov bx, offset src_string
	sub cx, bx	; cx = длина строки
	mov word ptr [src_len], cx
	
	dec bx
search:
	inc bx
	cmp al, byte ptr [bx]
	loopne search			
		; cx--; завершение цикла, если cx == 0 или al == byte ptr [bx] (ZF==1)
	
	je found
	
	mov si, offset error_str
	
	jmp print
found:
	mov si, offset success_str
	
print:
	mov dl, byte ptr [reserved]
	mov ah, 02h
	int 21h
	
	mov dx, offset dopi
	mov ah, 09h
	int 21h
	
	mov dx, si
	mov ah,09h
	int 21h

next:
	inc ncount
	jmp main
	
exit:
	mov ax, 4c00h
	int 21h
	
code ends

end start