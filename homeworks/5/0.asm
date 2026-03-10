.386

stack segment para stack
db 256 dup (?)
stack ends 

data segment para public
	src_string db "Try find symbol!"
	new_line db 0dh, 0ah, "$"
	src_len dw ?
	success_str db " was found!", 0dh, 0ah, "$"
	error_str db " wasn't found (((", 0dh, 0ah, "$"
	reserved db 256 dup (?)
	
	enter_counter db 0
	request_counter db 0
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

	mov ah, 01h
	int 21h
	mov byte ptr [reserved], al
	
	cmp byte ptr [reserved], 0dh
	je enter_search
	
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
	
	mov dx, offset error_str
	jmp print
found:
	mov dx, offset success_str
print:
	mov ah, 09h
	int 21h
	
	mov dx, offset new_line
	mov ah, 09h
	int 21
	
	inc byte ptr[request_counter]
	mov cl, byte ptr[request_counter]
	cmp cl, 5
	je print_string
	jmp start

print_string:
	mov dl, byte ptr[offset src_string]
	mov ah, 09h
	int 21h

	mov dx, offset new_line
	mov ah, 09h
	int 21
	
	mov byte ptr[request_counter], 0
	jmp start
	
enter_search:
	inc byte ptr[enter_counter]
	mov cl, byte ptr[enter_counter]
	cmp cl, 2
	je exit
	jne start
	
exit:
	mov ax, 4c00h
	int 21h
	
code ends

end start