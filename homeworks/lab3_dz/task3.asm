stack segment para stack
	db 256 dup(?)
stack ends

data segment para public
	x dw 6
	y dw 6
	z dw ?
	a dw 4
	b dw 4
	c dw ?
	
data ends

code segment para public

assume cs:code,ds:data,ss:stack

start:
	mov ax, data
	mov ds, ax
	mov ax, stack
	mov ss, ax

; 1 подзадание	
	mov ax, x
	imul y
	mov bx, ax
	mov ax,x
	add ax,y
	mov cx,ax
	
	mov ax,bx
	cwd
	idiv cx
	mov z,ax
	
; 2 подзадание	
	mov ax,a
    add ax,b
    mov bx,ax
    imul bx
    mov c,ax

; 3 подзадание
    mov ax,a
    add ax,b
    mov bx,ax
    imul bx
    imul bx
    mov c,ax

	mov ax, 4c00h
	int 21h
	
code ends
end start