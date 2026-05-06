_malloc proc near
    push bp
    mov bp, sp
    push bx
    mov bx, word ptr [bp + arg1]
    test bx, bx
    jz malloc_zero
    mov ax, bx
    add ax, 15
    shr ax, 4
    jmp malloc_alloc
malloc_zero:
    mov ax, 1
malloc_alloc:
    mov bx, ax
    mov ah, 48h
    int 21h
    jc malloc_fail
    jmp malloc_done
malloc_fail:
    xor ax, ax
malloc_done:
    pop bx
    mov sp, bp
    pop bp
    ret
_malloc endp

_free proc near
    push bp
    mov bp, sp
    push ax
    push es
    mov ax, word ptr [bp + arg1]
    mov es, ax
    cmp ax, 0
    je free_done
    mov ah, 49h
    int 21h
free_done:
    pop es
    pop ax
    mov sp, bp
    pop bp
    ret
_free endp