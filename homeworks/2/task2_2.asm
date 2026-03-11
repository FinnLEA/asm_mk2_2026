stack_seg segment para stack
db 256 dup(?)
stack_seg ends

data_seg segment para public
str db "This string is for task2, lab2.",0Dh,0Ah,"$"
data_seg ends

code_seg segment para public

assume 	cs:code_seg,ds:data_seg,ss:stack_seg

start:
	mov ax, data_seg
	mov ds, ax
	mov ax, stack_seg
	mov ss, ax
	
	mov dx, offset str
	mov ah, 09h
	int 21h
	
	mov ax, 4c00h
	int 21h

code_seg ends
end start
	
