stack segment para stack
db 256 dup (?)
stack ends 

data segment para public
	string db 240,?,240 dup(?)
	new_line db 0dh, 0ah, "$"
	strlen dw ?
	
	enter_range_note db "Enter range (like a-z) (a <= z !!!): ","$"
	enter_string_note db "Enter string: ","$"
	enter_str db 4,3,3 dup(?)
	start_range db ?
	end_range db ?
	
	success_str db "All characters in a string are within the specified range.","$"
	fail_str db "Some characters in a string are not within the specified range.","$"
	
data ends

code segment para public 

assume cs:code,ds:data,ss:stack

start:
	mov ax, data ; инициализация
    mov ds, ax
    mov ax, stack
    mov ss, ax

; ввод диапазона
	mov dx, offset enter_range_note
	mov ah, 09h
	int 21h
	
	mov dx, offset enter_str
	mov ah, 0ah
	int 21h
	
	mov dx, offset new_line
	mov ah, 09h
	int 21h
	
	mov dx, offset new_line
	mov ah, 09h
	int 21h
	
; range
	mov bx, offset enter_str + 2
	mov cl, [bx]
	mov byte ptr[start_range], cl
	add bx, 2
	mov cl, [bx]
	mov byte ptr[end_range], cl
	
; ввод строки
	mov dx, offset enter_string_note
	mov ah, 09h
	int 21h

	mov dx, offset string ; ввод 
	mov ah, 0ah
	int 21h
	
	mov dx, offset new_line
	mov ah, 09h
	int 21h
	
	mov dx, offset new_line
	mov ah, 09h
	int 21h
	
	mov bx, offset string + 1 ; $
	xor cx, cx
	mov cl, byte ptr[bx]
	add bx, cx
	mov word ptr[strlen], cx
	mov byte ptr[bx + 1], "$"
	
; main
	xor cx, cx
	mov bx, offset strlen
	mov cx, word ptr[bx]
	mov bx, offset string + 2
	
loop1:
	mov si, offset start_range
	mov al, byte ptr[si]
	cmp al, byte ptr[bx]
	jg fail
	
	mov si, offset end_range
	mov al, byte ptr[si]
	cmp al, byte ptr[bx]
	jl fail
	
	add bx, 1
	loop loop1
	
success: 
	mov dx, offset success_str
	mov ah, 09h
	int 21h
	
	mov al, 0
	jmp exit
	
fail:
	mov dx, offset fail_str
	mov ah, 09h
	int 21h
	
	mov al, -1
	
exit:
	mov ah, 4ch
	int 21h
	
code ends

end start