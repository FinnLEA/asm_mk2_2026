data segment para public
	x dw 2
	y dw 2
	z dw ?
	
	a dw 3
	b dw 4
	res_c dw 0
data ends

stack segment para stack
	db 256 dup(?)
stack ends

code segment para public

assume ds:data,ss:stack,cs:code

start:
	mov ax, data
	mov ds, ax
	mov ax, stack
	mov ss, ax
	
	; z = (x*y) / (x + y)
	mov ax, [x]
	imul [y]
	mov bx, [x]
	add bx, [y]
	
	xor dx, dx
    	idiv bx 
	mov [z], ax	
	
	; c = (a + b) ^ 2
    	mov     ax, [a]
    	add     ax, [b]  ; ax = a + b
	imul    ax
    	mov     [res_c], ax
	
	; c = (a + b) ^ 3
    	mov     ax, [a]
    	add     ax, [b]  ; ax = a + b
    	mov     cx, ax
	imul    ax      ; ax = ax * ax = (a+b)^2
    	imul    cx      ; ax = cx * ax = (a+b) ^3 

    	mov [res_c], ax

    	; terminate program with return code 0
    	mov ax, 4c00h           
    	int 21h

code ends
end start
