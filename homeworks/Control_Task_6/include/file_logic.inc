
_flush_buffer_into_file proc
    push bp
    mov bp, sp

    push offset _output_filename
    call near ptr fopen_or_create
    jc   _flush_buffer_into_file_fio_error
    add sp, 2

    mov bx, ax

    ; move file cursor to file end, to append to symbols 
    push bx
    call _fappend_mode
    add sp, 2

    push word ptr [_f_output_buffer_i]
    push offset _f_output_buffer
    push bx                      ; file handle
    call _fwrite
    add  sp, 6

    push bx
    call _fclose
    add  sp, 2

    cdecl_call _memset, offset _f_output_buffer, 0, word ptr [_f_output_buffer_i]

    mov word ptr [_f_output_buffer_i], 0

    mov ax, 0
_flush_buffer_into_file_exit:
    mov sp, bp
    pop bp
    ret

_flush_buffer_into_file_fio_error:
    add sp, 2

    mov bx, ax

    push word ptr [orig_mode]
    call _set_mode
    add sp, 2

    push bx
    call fio_error_handler
    add sp, 2

    ; push offset _output_filename
    ; call _putstr 
    ; add sp, 2

    mov ax, 1
    jmp _flush_buffer_into_file_exit
_flush_buffer_into_file endp