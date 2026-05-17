
; void tests()
_tests proc near
	push bp
	mov bp, sp

	
push offset test_strstr
	call _putstr
	add sp, 2
	call _putnewline
	
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
	
	mov word ptr[result], ax
	call _putnewline
	
	push word ptr[result]					; print result strstr()
	call _putstr
	add sp, 2
	
	call _putnewline
	call _putnewline
	
	
	push offset test_strchr
	call _putstr
	add sp, 2
	call _putnewline
	
	push word ptr[dynamic_str1]				; print str1
	call _putstr
	add sp, 2
	call _putnewline
	
	push offset char1						; print char1
	call _putstr
	add sp, 2
	
	mov ax, 0
	mov al, byte ptr[char1]
	push ax
	push word ptr[dynamic_str1]
	call _strchr							; call strchr()
	add sp, 4
	
	mov word ptr[result], ax
	call _putnewline
	
	push word ptr[result]					; print result strchr()
	call _putstr
	add sp, 2
	
	call _putnewline
	call _putnewline
	
	
	push offset test_strcpy
	call _putstr
	add sp, 2
	call _putnewline
	
	push word ptr[dynamic_str1]				; print str1
	call _putstr
	add sp, 2
	call _putnewline
	
	mov ax, data
	mov es, ax
	
	push word ptr[dynamic_str1]
	push word ptr[dynamic_str2]
	call _strcpy							; call strcpy()
	add sp, 4
	
	push word ptr[dynamic_str2]
	call _putstr							; print result strcpy()
	add sp, 2
	
	call _putnewline
	call _putnewline
	
	
	push offset test_strcat
	call _putstr
	add sp, 2
	call _putnewline
	
	push word ptr[dynamic_str1]				; print str1
	call _putstr
	add sp, 2
	call _putnewline
	
	push word ptr[dynamic_str2]				; print str2
	call _putstr
	add sp, 2
	call _putnewline
	
	mov ax, data
	mov es, ax
	
	push word ptr[dynamic_str2]
	push word ptr[dynamic_str1]
	call _strcat							; call strcat()
	add sp, 4
	
	push word ptr[dynamic_str1]
	call _putstr							; print result strcat()
	add sp, 2

	call _putnewline
	
	mov sp, bp
	pop bp
	ret
_tests endp
