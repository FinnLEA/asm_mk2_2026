; ============================================================================
; fileio.inc - DOS File I/O (cdecl, 16-bit)
; ============================================================================

; int _file_getsize(filename_offset)
; DS должен указывать на сегмент с именем файла. Возвращает размер в AX или -1
_file_getsize proc near
    push bp
    mov bp, sp
    push bx
    push cx
    push dx
    push ds

    mov dx, word ptr [bp + 4]
    mov ax, 3D00h
    int 21h
    jc fgs_error

    mov bx, ax
    mov ax, 4202h
    xor cx, cx
    xor dx, dx
    int 21h
    jc fgs_close_err

    cmp dx, 0
    jne fgs_too_big

    mov ax, 4200h
    xor cx, cx
    xor dx, dx
    int 21h
    jc fgs_close_err

    jmp fgs_close

fgs_too_big:
    mov ax, -1
    jmp fgs_close

fgs_close_err:
    push ax
    mov ah, 3Eh
    int 21h
    pop ax
    mov ax, -1
    jmp fgs_done

fgs_close:
    mov ah, 3Eh
    int 21h

fgs_done:
    pop ds
    pop dx
    pop cx
    pop bx
    mov sp, bp
    pop bp
    ret

fgs_error:
    mov ax, -1
    jmp fgs_done
_file_getsize endp

; int _file_readall(filename_offset, buffer_seg, buffer_off, max_size)
; DS должен указывать на сегмент с именем файла. Возвращает кол-во байт или -1
_file_readall proc near
    push bp
    mov bp, sp
    push bx
    push cx
    push dx
    push ds
    push es

    mov dx, word ptr [bp + 4]
    mov ax, 3D00h
    int 21h
    jc fra_error

    mov bx, ax

    push ds
    mov ds, word ptr [bp + 6]
    mov dx, word ptr [bp + 8]
    mov cx, word ptr [bp + 10]
    mov ah, 3Fh
    int 21h
    pop ds

    jc fra_close_err

    push ax
    mov ah, 3Eh
    int 21h
    pop ax
    jmp fra_done

fra_close_err:
    push ax
    mov ah, 3Eh
    int 21h
    pop ax
    mov ax, -1
    jmp fra_done

fra_error:
    mov ax, -1

fra_done:
    pop es
    pop ds
    pop dx
    pop cx
    pop bx
    mov sp, bp
    pop bp
    ret
_file_readall endp