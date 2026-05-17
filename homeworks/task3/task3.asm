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
	pass1 db 100 dup(0), 0
	str1 db "123456", 0
	
	pass2 db 100 dup(0), 0
	str2 db "345", 0
	
	pass3 db 100 dup(0), 0
	char1 db "4", 0
	
	dynamic_str1 dw ?
	dynamic_str2 dw ?
	
	result dw ?
	
	buffer db 1024 dup(?),0
	
	test_strstr db "	Test strstr():",0
	test_strchr db "	Test strchr():",0
	test_strcpy db "	Test strcpy():",0
	test_strcat db "	Test strcat():",0
	
	
	str_error_alloc db "Error: allocate memory!", 0

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
include tests.inc


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

	call _tests								; call tests
	
	push word ptr[dynamic_str1]				; free str1
	call FreeMem
	add sp, 2
	
	push word ptr[dynamic_str1]				; free str2
	call FreeMem
	add sp, 2

	jmp .exit0 
	
.error_alloc:
	add sp, 2
	call _error_alloc
	jmp .exit0
	
.exit0:
    call _exit0

code ends

end start
