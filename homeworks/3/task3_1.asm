stack segment para public
	db 256 dup(?)
stack ends

data segment para public
	array_str1_max db 241
	array_str1_len db ?
	array_str1_str db 241 dup(?)
	
	array_str2_max db 241
	array_str2_len db ?
	array_str2_str db 241 dup(?)
	
	array_str3_max db 241
	array_str3_len db ?
	array_str3_str db 241 dup(?)
	
	new_line db 0ah,0dh,'$'	; перевод на новую строку
data ends

code segment para public

assume ds:data,ss:stack,cs:code

start:
	mov ax, data
	mov ds, ax
	mov ax, stack
	mov ss, ax
	
	;read the first string
	mov dx, offset array_str1_max
	mov ah, 0Ah
	int 21h
	
	mov ah, 09h
	mov dx, offset new_line
	int 21h
	
	;read the second string
	mov dx, offset array_str2_max
	mov ah, 0Ah
	int 21h
	
	mov ah, 09h
	mov dx, offset new_line
	int 21h
	
	;read the third string
	mov dx, offset array_str3_max
	mov ah, 0Ah
	int 21h
	
	mov ah, 09h
	mov dx, offset new_line
	int 21h
	mov ah, 09h
	mov dx, offset new_line
	int 21h
	
	;print the first string
	mov bx, 0 ; xor bx, bx
    mov bl, byte ptr[array_str1_len] ; в bx - реальная длина строки
    mov si, offset array_str1_str
    mov byte ptr[si+bx], '$' ; помещаем в конец строки $
    mov ah, 09h
    mov dx, offset array_str1_str
    int 21h
	
	mov ah, 09h
	mov dx, offset new_line
	int 21h
	
	;print the second string
	mov bx, 0 ; xor bx, bx
    mov bl, byte ptr[array_str2_len] ; в bx - реальная длина строки
    mov si, offset array_str2_str
    mov byte ptr[si+bx], '$' ; помещаем в конец строки $
    mov ah, 09h
    mov dx, offset array_str2_str
    int 21h
	
	mov ah, 09h
	mov dx, offset new_line
	int 21h
	
	;print the third string
	mov bx, 0 ; xor bx, bx
    mov bl, byte ptr[array_str3_len] ; в bx - реальная длина строки
    mov si, offset array_str3_str
    mov byte ptr[si+bx], '$' ; помещаем в конец строки $
    mov ah, 09h
    mov dx, offset array_str3_str
    int 21h
	
	mov ah, 09h
	mov dx, offset new_line
	int 21h
	
	mov ax, 4c00h
	int 21h

code ends
end start
