stack segment para stack
db 256 dup(?)
stack ends

data segment para public
str1 db "Hello, asm!",0ah,0dh,"$" 
str2 db 250 dup(?)
data ends

code segment para public 

assume cs:code, ds:data, ss:stack

start:
    mov ax, data 
    mov ds, ax
    mov ax, stack
    mov ss, ax
    
	mov dx, offset str1
	mov bx, dx
	mov si, 2
	mov byte ptr [bx+si], "R"
	
	mov dl, offset str1
	mov ah, 09h
	int 21h
	
	
	mov dl, [si+1]  
    mov ah, 02h   ; код команды
    int 21h
	
	mov ah, 02h
    mov dl, 0Ah		; вывод \n
    int 21h

    mov al, 0   
    mov ah, 4ch 
    int 21h     
code ends

end start