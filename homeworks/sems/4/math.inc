; math.inc - Преобразование чисел

; int atoi(const char *str)
atoi proc near 
    push bp
    mov bp, sp
    push bx
    push cx
    
    mov bx, [bp + 4] ; str
    xor ax, ax
    xor cx, cx
    mov dx, 1 ; sign

    cmp byte ptr [bx], '-'
    jne atoi_loop
    mov dx, -1
    inc bx

atoi_loop:
    mov cl, [bx]
    test cl, cl
    jz atoi_done
    cmp cl, '0'
    jb atoi_done
    cmp cl, '9'
    ja atoi_done
    
    sub cl, '0'
    imul ax, 10
    add ax, cx
    inc bx
    jmp atoi_loop

atoi_done:
    imul ax, dx
    pop cx
    pop bx
    mov sp, bp
    pop bp
    ret
atoi endp

; void itoa(int num, char *str)
itoa proc near
    push bp
    mov bp, sp
    push di
    push bx
    
    mov ax, [bp + 4] ; num
    mov di, [bp + 6] ; str
    
    test ax, ax
    jns itoa_pos
    mov byte ptr [di], '-'
    inc di
    neg ax

itoa_pos:
    xor cx, cx
    mov bx, 10
itoa_split:
    xor dx, dx
    div bx
    push dx
    inc cx
    test ax, ax
    jnz itoa_split

itoa_write:
    pop dx
    add dl, '0'
    mov [di], dl
    inc di
    loop itoa_write
    
    mov byte ptr [di], 0
    
    pop bx
    pop di
    mov sp, bp
    pop bp
    ret
itoa endp