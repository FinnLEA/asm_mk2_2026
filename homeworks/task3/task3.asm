.386

arg1 equ 4
arg2 equ 6
arg3 equ 8
arg4 equ 10

var1 equ -2
var2 equ -4
var3 equ -6
var4 equ -8
var5 equ -10

stack segment para stack
db 65530 dup(?)
stack ends

data segment para public
	pass1 db 200 dup(0), 0
	str1 db "12345", 0
	
	pass2 db 200 dup(0), 0
	str2 db "1", 0
	
	dynamic_str1 dw ?
	dynamic_str2 dw ?
	
	str_error_alloc db "Error: allocate memory!", 0
	
	result db 256 dup(?)

data ends

code segment para public use16

assume cs:code,ds:data,ss:stack

include strings.inc
include memory.inc
include strstr.inc	
include strchr.inc
include strcpy.inc
include strcat.inc
include errors.inc


; char* static_to_dinamic(const char* static) -> return dynamic segment
_static_to_dinamic proc near
	push bp
	mov bp, sp
	
	mov bx, word ptr[bp + arg1]
	push bx
	call _strlen
	add sp, 2
	
	inc ax
	
	push ax
	call AllocMem
	jc .error_alloc_static_to_dinamic
	add sp, 2
	
	mov es, ax
	mov di, 0
	
	push di
	push word ptr[bp + arg1]
	call _strcpy
	add sp, 4
	
	jmp .finish_static_to_dinamic
	
.error_alloc_static_to_dinamic:
	add sp, 2
	stc
	jmp .finish_static_to_dinamic
	
.finish_static_to_dinamic:
	mov sp, bp
	pop bp
	ret
_static_to_dinamic endp



start:
    mov ax, data
    mov ds, ax
    mov ax, stack
    mov ss, ax
    
	
	push offset str1						; alloc str1
	call _static_to_dinamic
	jc .error_alloc
	add sp, 2
	mov word ptr[dynamic_str1], ax

	push offset str2						; alloc str2
	call _static_to_dinamic
	jc .error_alloc
	add sp, 2
	mov word ptr[dynamic_str2], ax

	
	push word ptr[dynamic_str1]				; print str1
	call _putstr
	add sp, 2

	call _putnewline
	
	push word ptr[dynamic_str2]				; print str2
	call _putstr
	add sp, 2
	
	
	
	push word ptr[dynamic_str2]				; call strstr()
	push word ptr[dynamic_str1]
	call _strstr
	add sp, 4
	
	
	call _putnewline
	
	push ax									; print result
	call _putstr
	add sp, 2
	
	
	push word ptr[dynamic_str1]				; free str1
	call FreeMem
	add sp, 2
	
	push word ptr[dynamic_str1]				; free str2
	call FreeMem
	add sp, 2

	jmp .exit0 
	
	; call _tests
	
.error_alloc:
	add sp, 2
	call _error_alloc
	jmp .exit0
	
.exit0:
    call _exit0

code ends

end start
