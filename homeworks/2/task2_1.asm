stack_seg segment para stack
db 256 dup(?)
stack_seg ends

data_seg segment para public
db 256 dup(?)
data_seg ends

code_seg segment para public

assume 	cs:code_seg,ds:data_seg,ss:stack_seg

start:
	mov ax, data_seg
	mov ds, ax
	mov ax, stack_seg
	mov ss, ax
	
	mov ah,08h
	int 21h

	mov dl,al

	mov ah,02h
	int 21h
	
	mov ax, 4c00h
	int 21h

code_seg ends
end start
	
