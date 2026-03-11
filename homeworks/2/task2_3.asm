stack segment para stack
db 256 dup(?)
stack ends

data segment para public

	str_max db 241         	; максимальная длина строки
	str_len db ?           	; реальная длина строки
	str_str db 256 dup(?)  	; байты считанной строки
	new_line db 0ah,0dh,'$'	; перевод на новую строку

data ends

code segment para public 

assume cs:code,ds:data,ss:stack

start:
    mov ax, data			; инициализируем дату
    mov ds, ax				; двигаем стэк в регистр стэка
    mov ax, stack			; инициализируем стэк	
    mov ss, ax				; двигаем стэк в регистр стэка
    
    mov ah, 0ah				; принимаем строку с клавиатуры
    mov dx, offset str_max 	; dx = &str_max;
    int 21h
    
    mov ah, 09h
    mov dx, offset new_line	; переносим строку для вывода строки
    int 21h
    
    mov bx, 0 ; xor bx, bx
    mov bl, byte ptr[str_len] ; в bx - реальная длина строки
    lea si, str_str
    mov byte ptr[si+bx], '$' ; помещаем в конец строки $
    mov ah, 09h
    mov dx, offset str_str
    int 21h
    
    mov ah, 4ch
    mov al, 00h
	int 21h
code ends

end start