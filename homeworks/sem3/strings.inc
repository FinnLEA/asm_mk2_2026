
; void putchar(int c)
; выводит символ на экран (младший байт переданного аргумента)
_putchar proc near
    push bp
    mov bp, sp
    
    mov dx, word ptr [bp + 4]
    mov ah, 02h
    int 21h
    
    mov sp, bp
    pop bp
    ret
_putchar endp    
    
	
; int getchar()
; читает символ с клавиатуры и возвращает его (считанный символ - младший байт (al) регистра ax)
_getchar proc near
    push bp
    mov bp, sp
    
    mov ah, 01h
    int 21h
    
    mov sp, bp
    pop bp
    ret
_getchar endp


; size_t strlen(const char *str)
; находит длинну строки (до завершающего нуля), адрес которой является аргументом
_strlen proc near
    push bp
    mov bp, sp
    
	push bx
    mov bx, word ptr [bp + 4] 
    xor ax, ax ; счётчик (ax)

lencyc:    
    cmp byte ptr [bx], 0
    je lenret
    inc ax
    inc bx
    jmp lencyc
    
lenret:
	pop bx
    mov sp, bp
    pop bp
    ret
_strlen endp

	
; void putstr(const char *str)
; выводит строку на экран (до завершающего нуля), адрес которой передан в качестве аргумента
_putstr proc near
    push bp
    mov bp, sp
    
    ; находим длину строки
    push word ptr [bp + 4] 
    call _strlen
    add sp, 2
    
    ; выводим строку
    mov cx, ax
    mov dx, word ptr [bp + 4]
    mov ah, 40h
    mov bx, 1
    int 21h
    
    mov sp, bp
    pop bp
    ret
_putstr endp


; char* strcpy (char* dst, const char* src)
; copies the string src to dst, returns a pointer to the string dst
_strcpy proc near
	push bp
	mov bp, sp
	
	push di
	push si
	push bx

	mov di, [bp + 4]		; buffer address WHERE to write
	mov si, [bp + 6]		; string address, WHAT to write
	mov ax, di				; saved the beginning of dst in ax
	
cpy_cycle:
	mov bl, byte ptr [si]
	cmp bl, 0
	je cpy_end0
	
	mov byte ptr [di], bl
	inc di
	inc si
	jmp cpy_cycle
	
cpy_end0:
	mov byte ptr [di], 0

cpy_ret:
	pop bx
	pop si
	pop di
	
	mov sp, bp
	pop bp
	ret
_strcpy endp

; char* strchr (const char* str, int c);
; searches for the first occurrence of the character c in the string str and returns
; 1) a pointer to the found character
; 2) a null pointer (0)
_strchr proc near
	push bp
	mov bp, sp
	
	push di
	push bx
	
	mov di, [bp + 4]				; pointer to a string
	mov bl, byte ptr [bp + 6]		; sym
	
strchr_cycle:
	cmp byte ptr [di], bl
	je find_sym
	
	cmp byte ptr [di], 0
	je not_find
	
	inc di
	jmp strchr_cycle
	
not_find:
	xor ax, ax
	jmp strchr_ret

find_sym:
	mov ax, di
	
strchr_ret:
	pop bx
	pop di
	
	mov sp, bp
	pop bp
	ret
_strchr endp
	
	
; int strcmp (const char* string1, const char* string2);
; compares two strings in lexicographic order
; 0 if equal, -1 if 1st comes before 2nd, 1 if 1st comes after 2nd
_strcmp proc near
	push bp
	mov bp, sp
	
	push si
	push di
	push bx
	
	mov si, [bp + 4]
	mov di, [bp + 6]
	
strcmp_cycle:
	mov bl, byte ptr [si]			
	cmp bl, byte ptr [di]		
	jb res_below
	ja res_above
	
	; else next
	cmp bl, 0
	je res_equal
	
	inc si
	inc di
	jmp strcmp_cycle
	
res_below:
	mov ax, -1
	jmp strcmp_ret

res_above:
	mov ax, 1
	jmp strcmp_ret
	
res_equal:
	mov ax, 0
	jmp strcmp_ret
	
strcmp_ret:
	pop bx
	pop di
	pop si
	
	mov sp, bp
	pop bp
	ret
_strcmp endp


; int stricmp (const char* string1, const char* string2);
; compares two strings in lexicographic order, ignoring case
; 0 if equal, -1 if 1st comes before 2nd, 1 if 1st comes after 2nd
_stricmp proc near
	push bp
	mov bp, sp
	
	push si
	push di
	push bx
	push dx
	
	mov si, [bp + 4]
	mov di, [bp + 6]
	
	xor bx, bx
	xor dx, dx
stricmp_cycle:
	mov bl, byte ptr [si]		
	mov dl, byte ptr [di]	

check_registr:
	push bx
	call _convert_reg
	add sp, 2
	mov bl, al
	
	push dx
	call _convert_reg
	add sp, 2
	mov dl, al
	
	cmp bl, dl
	jb resi_below
	ja resi_above
	
	cmp bl, 0
	je resi_equal
	
	inc si
	inc di
	jmp stricmp_cycle
	
resi_below:
	mov ax, -1
	jmp stricmp_ret

resi_above:
	mov ax, 1
	jmp stricmp_ret
	
resi_equal:
	mov ax, 0
	jmp stricmp_ret
	
stricmp_ret:
	pop dx
	pop bx
	pop di
	pop si
	
	mov sp, bp
	pop bp
	ret
_stricmp endp


; char convert_reg(char symbol)
; helper function for stricmp
_convert_reg proc near
	push bp
	mov bp, sp
	
	xor ax, ax
	mov al, byte ptr [bp + 4] 

to_lower:
	cmp al, 65
	jb convert_ret
	cmp al, 90
	ja convert_ret
	add al, 32
	
convert_ret:
	mov sp, bp
	pop bp
	ret
_convert_reg endp


; char* strcat (char* dst, const char* src)
; appends the string src to the end of dst and returns a pointer to the beginning of dst
_strcat proc near
	push bp
	mov bp, sp
	
	push di
	push si
	
	mov di, [bp + 4]	; dst
	mov si, [bp + 6]	; src
	
	push di
	call _strlen
	add sp, 2

	add di, ax 		
	push si
	push di
	call _strcpy
	add sp, 4
	
; ax contains a pointer to the beginning of the APPENDED line
; but we only needed to write and go back
	mov ax, [bp + 4]
	
	pop si
	pop di
	
	mov sp, bp
	pop bp
	ret
_strcat endp


; char* strstr (const char* str, const char* strSearch)
; searches for the first occurrence of the substring strSearch in the string str
; returns a pointer to the first occurrence OR a null pointer
_strstr proc near
	push bp
    mov bp, sp

	push di
	push si
	push bx
	push cx
	push dx
	
	mov di, [bp + 4]		; where
	mov si, [bp + 6]		; what
	
	cmp byte ptr[si], 0		
	je empty_substr
	
	push si
	call _strlen
	add sp, 2
							; ax - the length of the desired substring without 0
	xor cx, cx				; cx - match counter
	
	mov bl, byte ptr [si]	; we fix the character from the SUBSTRING
	
strstr_cycle:
	mov dl, byte ptr [di]	; character from the string WHERE we are looking for
	
	cmp dl, 0
	je unsuccess_find

	cmp bl, 0
	je unsuccess_find
	
	cmp dl, bl
	je next_sym
	
	inc di
	jmp strstr_cycle
	
next_sym:	
	inc cx					
	cmp cx, ax
	je success_find
	
	inc si
	inc di

next_sym_cycle:
	mov bl, byte ptr [si]	; we fix the character from the SUBSTRING
	mov dl, byte ptr [di]	; character from the string WHERE we are looking for
	
	cmp dl, 0
	je unsuccess_find
	
	cmp dl, bl
	je next_sym
	
	; otherwise the chain is broken
	mov si, [bp + 6]			; returned the SUBSTRING pointer to the beginning
	mov bl, byte ptr [si]		; we fix the character from the SUBSTRING
	sub di, cx					; returned a string pointer to the first match
	inc di						; moved to the next character
	xor cx, cx					; returned the match counter
	jmp strstr_cycle
	
success_find:
	sub di, cx					; returned a string pointer to the first match
	inc di
	mov ax, di					
	jmp strstr_ret
	
unsuccess_find:
	mov ax, 0				
	jmp strstr_ret
	
empty_substr:
	mov ax, di
	jmp strstr_ret

strstr_ret:
	pop dx
	pop cx
	pop bx
	pop si
	pop di
	
	mov sp, bp
	pop bp
	ret
_strstr endp


; long strtol (const char* string, char** end_ptr, int base)
; returned a string pointer to the first match
_strtol proc near
    push bp
    mov bp, sp

	sub sp, 8
	
	push di
	push si
	push bx
	push cx
	push dx
	
	mov di, [bp + 4]	; address start of line
	mov si, [bp + 6]	; end_ptr
	mov bx, [bp + 8]	; base

	mov byte ptr [bp - 2], 0			; 1 - neg, 0 - pos
	mov word ptr [bp - 4], 0			; value for counting
	mov byte ptr [bp - 6], 0			; 1 - overflow, 0 - else
	mov byte ptr [bp - 8], 0			; 1 - the numbers have been read, 0 - else
	
	cmp byte ptr [di], 0
	je empty_string
		
firstfl_check:
	; пропуск символов
	cmp byte ptr [di], 32		; space
	je ignor_space
	cmp byte ptr [di], 9		; tab
	je ignor_space
	cmp byte ptr [di], 10		; line feed
	je ignor_space
	cmp byte ptr [di], 13		; carriage return
	je ignor_space
	
	cmp byte ptr [di], '-'
	je sign_neg_state
	
	cmp byte ptr [di], '+'
	je sign_pos_state
	jmp base_manager
	
;-----------------------
sign_pos_state:
	inc di
	jmp base_manager
	
sign_neg_state:
	mov byte ptr [bp - 2], 1			
	inc di
	jmp base_manager

ignor_space:
	inc di
	jmp firstfl_check
;------------------------
	
base_manager:	; the numbers have been read
	cmp bx, 0
	je base_0
	cmp bx, 16
	je base_16
	cmp bx, 1
	jbe base_error
	cmp bx, 36
	ja base_error
	jmp base2_36
	
base_0:
	cmp byte ptr [di], '0'
	jne base_10
	cmp byte ptr [di + 1], 'x'
	je base_16_with_pref
	cmp byte ptr [di + 1], 'X'
	je base_16_with_pref
	jmp base_8

base_16_with_pref:
	mov bx, 16
	add di, 2
	jmp base2_36
	
base_8:
	mov bx, 8
	jmp base2_36 
base_10:
	mov bx, 10
	jmp base2_36
	
base_16:
	mov bx, 16
	cmp byte ptr [di], '0'
	jne base2_36
	cmp byte ptr [di + 1], 'x'
	je base_16_skip_pref
	cmp byte ptr [di + 1], 'X'
	je base_16_skip_pref
	jmp base2_36

base_16_skip_pref:
	add di, 2
	jmp base2_36
	
base2_36:
	xor cx, cx
	mov cl, byte ptr [di]
	cmp cl, 0
	je error_symbol
	cmp cl, '0'
	jb error_symbol
	cmp cl, '9'
	jbe digit_convert
	cmp cl, 'A'
	jb error_symbol
	cmp cl, 'Z'
	jbe upper_symbol
	cmp cl, 'a'
	jb error_symbol
	cmp cl, 'z'
	jbe lower_symbol
	
	jmp error_symbol
	
digit_convert:
	sub cl, '0'
	jmp check_digit
	
upper_symbol:
	sub cl, 'A'
	add cl, 10
	jmp check_digit
	
lower_symbol:
	sub cl, 'a'
	add cl, 10
	jmp check_digit
	
;--------------------------
error_symbol:	
	cmp byte ptr [bp - 8], 0			; if no numbers were read
	je not_read_numbers
	jmp read_numbers
	
not_read_numbers:
	cmp si, 0
	je nr_skip_load_endptr
	mov di, [bp + 4]
	mov [si], di
	mov ax, 0
	jmp strtol_ret

nr_skip_load_endptr:
	mov di, [bp + 4]
	mov ax, 0
	jmp strtol_ret
	
;-----
read_numbers:
	mov ax, [bp - 4]						; recorded the value value	
	cmp byte ptr [bp - 6], 1				; 32767 and -32768 have already taken into
	je pos_digit
	
	cmp byte ptr [bp - 2], 1				; sign check
	jne pos_digit
	neg ax
	
pos_digit:
	cmp si, 0
	je end_read_numbers
	mov [si], di

end_read_numbers:
	jmp strtol_ret
;---------------------------
	
check_digit:
	cmp cl, bl
	jae error_symbol
		
	; overflow check
	cmp byte ptr [bp - 2], 0
	je positive_number
	mov ax, 32768
	jmp limit_check
positive_number:
	mov ax, 32767			
limit_check:
	sub ax, cx
	xor dx, dx
	div bx
	cmp word ptr [bp - 4], ax
	ja overflow_set

after_overflow_check:
	mov ax, [bp - 4]
	imul ax, bx
	add ax, cx				
	jmp load_value
	
overflow_set:
	mov byte ptr [bp - 6], 1			; set the overflow flag
	cmp byte ptr [bp - 2], 1			; corrected value
	je neg_value
	mov word ptr [bp - 4], 32767
	jmp overflow_end
neg_value:
	mov word ptr [bp - 4], -32768
overflow_end:
	jmp read_numbers
	
	
load_value:
	mov byte ptr [bp - 8], 1			
	mov word ptr [bp - 4], ax
	inc di
	jmp base2_36
	
	
base_error:
	mov di, [bp + 4]	
	mov ax, 0
	jmp strtol_exit
	
empty_string:
	mov di, [bp + 4]		
	mov ax, 0
	jmp strtol_exit

strtol_exit:
	cmp si, 0
	je strtol_ret
	mov [si], di
	
strtol_ret:
	pop dx
	pop cx
	pop bx
	pop si
	pop di
	
	mov sp, bp
	pop bp
	ret
_strtol endp


; char* strdup (const char* strSource)
; the function allocates memory and copies the passed string there
_strdup proc near
	push bp
	mov bp, sp
	sub sp, 2					; [bp - 2] - start address
					
	push si
	push di
	push ds
	push es
								
	mov ax, [bp + arg1]
	cmp ax, 0
	je error_alloc_strdup
	
	push ax
	call _strlen
	add sp, 2
		
	inc ax
	
	push ax
	call AllocMem
	add sp, 2
	
	cmp ax, 0
	je error_alloc_strdup
	
	mov [bp - 2], ax			; recorded the beginning of the 
								; allocated space for a new line
	
	mov ax, [bp + arg1]
	mov ds, ax					; ds --> src
	
	mov ax, [bp - 2]
	mov es, ax					; es --> dst
	
	xor si, si					; iterator for src
	xor di, di					; iterator for dst

strdup_copy_loop:
	mov al, [si]
	mov es:[di], al
	
	cmp al, 0
	je strdup_copy_done
	
	inc si
	inc di
	jmp strdup_copy_loop

strdup_copy_done:
	mov ax, [bp - 2]
	jmp strdup_ret
	
error_alloc_strdup:
	mov ax, -1
	jmp strdup_ret
	
strdup_ret:
	pop es
	pop ds
	pop di
	pop si

	mov sp, bp
	pop bp
	ret
_strdup endp


; void getstr(const char *str, int max_len)
; reads a line from the keyboard (either max_len - 1 byte,
; or until a line feed) and stores it in memory,
; while appending a terminating 0 to the end of the line
_getstr proc near
    push bp
    mov bp, sp
    
    dec word ptr [bp + 6] 		; reduce the required length by 1 (max_len - 1)
    mov bx, word ptr [bp + 4] 	; start address of the line	
    mov si, 0 					; count
 
getscyc: 
    cmp si, word ptr [bp + 6]
    je getsret
    
    call _getchar
    
    cmp al, 10
    je getsret
    cmp al, 13
    je getsret
    
    mov byte ptr [bx], al
    inc bx
    inc si
    jmp getscyc
    
getsret:
    mov byte ptr [bx], 0
    call _putnewline
    mov sp, bp
    pop bp
    ret
_getstr endp

; void putnewline()
_putnewline proc near
    push bp
    mov bp, sp
    
    mov dx, 10
    push dx
    call _putchar
    add sp, 2
    
    mov dx, 13
    push dx
    call _putchar
    add sp, 2
    
    mov sp, bp
    pop bp
    ret
_putnewline endp

; void print_number(word num)
_print_number proc near
    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    push dx

    mov ax, [bp+arg1]   ; number to output
    mov cx, 0           ; count
    mov bx, 10          ; base

    ; zero
    test ax, ax
    jnz div_loop
    mov dl, '0'
    push dx
	call _putchar
	add sp, 2
    jmp print_number_ret

div_loop:
    xor dx, dx          
    div bx             
    push dx             
    inc cx             
    test ax, ax
    jnz div_loop

print_loop:
    pop dx             
    push dx
	call _putchar
	add sp, 2
    loop print_loop

print_number_ret:
    pop dx
    pop cx
    pop bx
    pop ax
    mov sp, bp
    pop bp
    ret
_print_number endp



; void exit(int code)
; terminates the program with the passed code
_exit proc near
    push bp
    mov bp, sp
    
    mov ax, word ptr [bp + 4]
    mov ah, 4ch
	int 21h
    
    mov sp, bp
    pop bp
    ret
_exit endp
    
; void exit0()
; terminates the program with code 0
_exit0 proc near
    push bp
    mov bp, sp
    
    mov dx, 0
    push dx
    call _exit
    add sp, 2
    
    mov sp, bp
    pop bp
    ret
_exit0 endp