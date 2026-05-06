ReadToken proc near
    push bp
    mov bp, sp
    push di
    
    mov bx, [bp + 4] ; fd
    mov di, offset tmp_buf
    
rt_skip:
    push di
    push 1
    push bx
    call _fread
    add sp, 6
    cmp ax, 1
    jne rt_eof
    
    mov al, [di]
    cmp al, 32
    jbe rt_skip
    
rt_read:
    inc di
    push di
    push 1
    push bx
    call _fread
    add sp, 6
    cmp ax, 1
    jne rt_term
    
    mov al, [di]
    cmp al, 32
    ja rt_read

rt_term:
    mov byte ptr [di], 0
    mov ax, 1
    jmp rt_end
rt_eof:
    xor ax, ax
rt_end:
    pop di
    pop bp
    ret
ReadToken endp

; void ReadMatrix(const char *filename, word segmentAddr)
ReadMatrix proc near
    push bp
    mov bp, sp
    
    push 0 ; mode: read
    push word ptr [bp + 4]
    call _fopen
    add sp, 4
    
    cmp ax, -1
    jne rm_ok
    push offset msg_err_file
    call _putstr
    call _exit0

rm_ok:
    mov bx, ax ; bx = fd
    mov fs, [bp + 6]

    push bx
    call ReadToken
    add sp, 2
    push offset tmp_buf
    call atoi
    add sp, 2
    mov fs:[0], ax ; n

    push bx
    call ReadToken
    add sp, 2
    push offset tmp_buf
    call atoi
    add sp, 2
    mov fs:[2], ax ; m

    mov cx, fs:[0]
    imul cx, fs:[2]
    mov di, 4
rm_loop:
    push cx
    push bx
    call ReadToken
    add sp, 2
    push offset tmp_buf
    call atoi
    add sp, 2
    mov fs:[di], ax
    add di, 2
    pop cx
    loop rm_loop

    push bx
    call _fclose
    add sp, 2
    pop bp
    ret
ReadMatrix endp