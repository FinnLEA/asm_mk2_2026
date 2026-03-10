stack segment para stack
db 256 dup(?)
stack ends


data segment para public

	; 1)
	num_x dw 20
	num_y dw 30

	res_z dw ?,? ; целая, остаток
	res_c1 dw ?,?
	res_c2 dw ?,?
	
	temp dw ?
   
data ends

code segment para public 

assume cs:code,ds:data,ss:stack

start:
	mov ax, data
    mov ds, ax
    mov ax, stack
    mov ss, ax
	
; z = (x * y) / (x + y) 
	mov ax, word ptr[num_x]
	mov si, word ptr[num_y]
	mul si
	mov temp, ax
	
	mov ax, word ptr[num_x]
	mov si, word ptr[num_y]
	add ax, si
	
	mov dx, 0
	mov cx, ax
	mov ax, word ptr[temp]
	idiv cx
	mov word ptr[res_z + 2], ax ; целая
	mov word ptr[res_z], dx 	; остаток
	
; c1 = (a + b)^2	( z = (x + y)^2 )
	mov ax, word ptr[num_x]
	mov si, word ptr[num_y]
	add ax, si
	
	mov si, ax
	mul si
	mov word ptr[res_c1 + 2], ax
	mov word ptr[res_c1], dx
	
; c2 = (a + b)^3	( z = (x + y)^3 )
	mov ax, word ptr[num_x]
	mov si, word ptr[num_y]
	add ax, si
	mov word ptr[temp], ax
	
	mov si, ax
	mul si
	mul si
	mov word ptr[res_c2 + 2], ax
	mov word ptr[res_c2], dx
	
	mov al, 0   
    mov ah, 4ch 
    int 21h   
	
code ends

end start
