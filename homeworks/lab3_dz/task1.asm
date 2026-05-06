stack segment para stack
	db 256 dup(?)
stack ends

data segment para public
	array_string db 240,0,240 dup(?)
	             db 240,0,240 dup(?)
				 db 240,0,240 dup(?)
	end_str db 0dh,0ah,'$'
data ends

code segment para public

assume cs:code,ds:data,ss:stack

start:
	mov ax, data
	mov ds, ax
	mov ax, stack
	mov ss, ax
	
	lea dx, array_string
	mov ah,0ah
	int 21h
	mov bl, [array_string+1]
	mov bh,0
	mov byte ptr [array_string+2+bx],'$'
	
	lea dx, array_string+242
	mov ah,0ah
	int 21h
	mov bl, [array_string+243]
	mov bh,0
	mov byte ptr [array_string+244+bx],'$'
	
	lea dx, array_string+484
	mov ah,0ah
	int 21h
	mov bl, [array_string+485]
	mov byte ptr [array_string+486+bx],'$'
	
	lea dx, end_str
	mov ah,09h
	int 21h
	
	lea dx, array_string+2
	mov ah,09h
	int 21h
	lea dx,end_str
	int 21h
	
	lea dx, array_string+244
	mov ah,09h
	int 21h
	lea dx,end_str
	int 21h
	
	lea dx, array_string+486
	mov ah,09h
	int 21h
	lea dx,end_str
	int 21h
	
	mov ax, 4c00h
	int 21h

code ends
end start