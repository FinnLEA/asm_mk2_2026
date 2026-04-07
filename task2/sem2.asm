.386

arg1 equ 4
arg2 equ 6
arg3 equ 8
arg4 equ 10

var1 equ -2
var2 equ -4
var3 equ -6
var4 equ -8

stack segment para stack
    db 65535 dup(?)
stack ends

data segment para public 
    buffer_out db 256 dup(0)
    buffer_in db 1024 dup (?)

    msg_sys db 'Select base (d or h):', 0
    msg_expr db 'Input expression:', 0
    msg_dec db 'Decimal: ', 0
    msg_hex db 'Hexadecimal:', 0

    err_overflow db 'Error: overflow', 0dh, 0ah, 0
    err_format db 'Error: wrong format', 0dh, 0ah, 0
    err_div_zero db 'Error: division by zero', 0dh, 0ah, 0
    
    error_table dw offset err_overflow, offset err_format, offset err_div_zero

    E_OVERFLOW equ 0
    E_FORMAT equ 1
    E_DIV_ZERO equ 2

    parse_func dw 0
    a dw 0
    b dw 0
    oper db 0
data ends

code segment para public use16
    assume cs:code, ds:data, ss:stack

show:
    push bp
    mov bp, sp
    mov si, word ptr [bp+arg1]
    mov ah, 02h
    
show_loop:
    mov dl, byte ptr [si]
    int 21h
    inc si
    test dl, dl
    jnz show_loop
    pop bp
    ret

newline:
    push bp
    mov bp, sp
    mov dl, 0Dh
    mov ah, 02h
    int 21h
    mov dl, 0Ah
    int 21h
    pop bp
    ret

hex_convert:
    push bp
    mov bp, sp
    mov di, word ptr [bp+arg1]
    mov bx, word ptr [bp+arg2]
    test bx, bx
    jnz hc_notzero
    mov byte ptr [di], '0'
    inc di
    jmp hc_done
    
hc_notzero:
    test bx, bx
    jns hc_positive
    mov byte ptr [di], '-'
    inc di
    neg bx
    
hc_positive:
    mov cx, 4
    
hc_loop:
    rol bx, 4
    mov al, bl
    and al, 0Fh
    cmp al, 10
    jl hc_digit
    add al, 'A' - 10
    jmp hc_store
    
hc_digit:
    add al, '0'
    
hc_store:
    mov byte ptr [di], al
    inc di
    loop hc_loop
    
hc_done:
    mov byte ptr [di], 0
    pop bp
    ret

dec_convert:
    push bp
    mov  bp, sp
    mov  di, word ptr [bp+arg1]
    mov  ax, word ptr [bp+arg2]
    test ax, ax
    jnz  dc_notzero
    mov  byte ptr [di], '0'
    mov  byte ptr [di+1], 0
    jmp  dc_done
    
dc_notzero:
    xor  bx, bx
    cmp  ax, 0
    jge  dc_positive
    mov  bx, 1
    neg  ax
    
dc_positive:
    xor  cx, cx
    mov  si, 10
    
dc_div:
    xor  dx, dx
    div  si
    push dx
    inc  cx
    test ax, ax
    jnz  dc_div
    mov  di, word ptr [bp+arg1]
    test bx, bx
    jz   dc_nosign
    mov  byte ptr [di], '-'
    inc  di
    
dc_nosign:
    mov  bx, cx
    jcxz dc_skip
    
dc_write:
    pop  dx
    add  dl, '0'
    mov  byte ptr [di], dl
    inc  di
    loop dc_write
    mov byte ptr [di], 0
    
dc_skip:
dc_done:
    pop  bp
    ret

parse_decimal:
    push bp
    mov  bp, sp
    push si
    push di
    push bx
    push dx
    mov  si, word ptr [bp+arg1]
    mov  cx, word ptr [bp+arg2]
    xor  ax, ax
    xor  di, di
    test cx, cx
    jz   pd_error
    
    mov  bl, byte ptr [si]
    cmp  bl, '-'
    jne  pd_nosign
    inc  di
    inc  si
    dec  cx
    test cx, cx
    jz   pd_error
    
pd_nosign:
    push si
    push cx
    
    mov  bx, 0
    
pd_check_loop:
    mov  dl, byte ptr [si]
    
    cmp  dl, ' '
    je   pd_check_end
    cmp  dl, 0
    je   pd_check_end
    cmp  dl, 0Dh
    je   pd_check_end
    cmp  dl, 0Ah
    je   pd_check_end
    
    cmp  dl, '0'
    jb   pd_format_error
    cmp  dl, '9'
    ja   pd_format_error
    
    inc  bx
    inc  si
    dec  cx
    jnz  pd_check_loop
    jmp  pd_check_end
    
pd_check_end:
    cmp  bx, 0
    je   pd_format_error
    
    cmp  bx, 5
    ja   pd_format_error
    jmp  pd_check_ok
    
pd_check_ok:
    pop  cx
    pop  si
    
    xor  ax, ax
    
pd_convert_loop:
    mov  bl, byte ptr [si]
    
    cmp  bl, ' '
    je   pd_convert_end
    cmp  bl, 0
    je   pd_convert_end
    cmp  bl, 0Dh
    je   pd_convert_end
    cmp  bl, 0Ah
    je   pd_convert_end
    
    sub  bl, '0'
    mov  bh, 0
    
    mov  dx, 10
    mul  dx
    add  ax, bx
    
    inc  si
    dec  cx
    jnz  pd_convert_loop
    
pd_convert_end:
    test di, di
    jz   pd_done
    cmp  ax, 32768
    jne  pd_negnormal
    mov  ax, -32768
    jmp  pd_done
    
pd_negnormal:
    neg  ax
    
pd_done:
    clc
    pop  dx
    pop  bx
    pop  di
    pop  si
    pop  bp
    ret
    
pd_format_error:
    pop  cx
    pop  si
    mov  ax, E_FORMAT
    stc
    pop  dx
    pop  bx
    pop  di
    pop  si
    pop  bp
    ret
    
pd_error:
    mov  ax, E_FORMAT
    stc
    pop  dx
    pop  bx
    pop  di
    pop  si
    pop  bp
    ret

parse_hexnum:
    push bp
    mov  bp, sp
    push si
    push di
    push bx
    push dx
    mov  si, word ptr [bp+arg1]
    mov  cx, word ptr [bp+arg2]
    xor  ax, ax
    xor  di, di
    test cx, cx
    jz   ph_error
    
    mov  bl, byte ptr [si]
    cmp  bl, '-'
    jne  ph_nosign
    inc  di
    inc  si
    dec  cx
    test cx, cx
    jz   ph_error
    
ph_nosign:
    push si
    push cx
    
    mov  bx, 0
    
ph_check_loop:
    mov  dl, byte ptr [si]
    
    cmp  dl, ' '
    je   ph_check_end
    cmp  dl, 0
    je   ph_check_end
    cmp  dl, 0Dh
    je   ph_check_end
    cmp  dl, 0Ah
    je   ph_check_end
    
    cmp  dl, '0'
    jb   ph_format_error
    cmp  dl, '9'
    jbe  ph_check_valid
    cmp  dl, 'A'
    jb   ph_format_error
    cmp  dl, 'F'
    jbe  ph_check_valid
    cmp  dl, 'a'
    jb   ph_format_error
    cmp  dl, 'f'
    jbe  ph_check_valid
    jmp  ph_format_error
    
ph_check_valid:
    inc  bx
    inc  si
    dec  cx
    jnz  ph_check_loop
    jmp  ph_check_end
    
ph_check_end:
    cmp  bx, 0
    je   ph_format_error
    
    cmp  di, 0
    jne  ph_check_neg_len
    cmp  bx, 4
    ja   ph_format_error
    jmp  ph_check_ok
    
ph_check_neg_len:
    cmp  bx, 4
    ja   ph_format_error
    
ph_check_ok:
    pop  cx
    pop  si
    
    xor  ax, ax
    
ph_convert_loop:
    mov  bl, byte ptr [si]
    
    cmp  bl, ' '
    je   ph_convert_end
    cmp  bl, 0
    je   ph_convert_end
    cmp  bl, 0Dh
    je   ph_convert_end
    cmp  bl, 0Ah
    je   ph_convert_end
    
    cmp  bl, '0'
    jb   ph_convert_error
    cmp  bl, '9'
    jbe  ph_convert_digit
    cmp  bl, 'A'
    jb   ph_convert_error
    cmp  bl, 'F'
    jbe  ph_convert_letter
    cmp  bl, 'a'
    jb   ph_convert_error
    cmp  bl, 'f'
    jbe  ph_convert_letter_low
    jmp  ph_convert_error
    
ph_convert_digit:
    sub  bl, '0'
    jmp  ph_convert_add
    
ph_convert_letter:
    sub  bl, 'A'
    add  bl, 10
    jmp  ph_convert_add
    
ph_convert_letter_low:
    sub  bl, 'a'
    add  bl, 10
    
ph_convert_add:
    mov  bh, 0
    
    shl  ax, 4
    add  ax, bx
    
    inc  si
    dec  cx
    jnz  ph_convert_loop
    
ph_convert_end:
    test di, di
    jz   ph_done
    cmp  ax, 8000h
    je   ph_done
    neg  ax
    
ph_done:
    clc
    pop  dx
    pop  bx
    pop  di
    pop  si
    pop  bp
    ret
    
ph_format_error:
    pop  cx
    pop  si
    mov  ax, E_FORMAT
    stc
    pop  dx
    pop  bx
    pop  di
    pop  si
    pop  bp
    ret
    
ph_convert_error:
    mov  ax, E_FORMAT
    stc
    pop  dx
    pop  bx
    pop  di
    pop  si
    pop  bp
    ret
    
ph_error:
    mov  ax, E_FORMAT
    stc
    pop  dx
    pop  bx
    pop  di
    pop  si
    pop  bp
    ret

error_handler:
    push bp
    mov  bp, sp
    call newline
    mov  ax, word ptr [bp+arg1]
    mov  bx, ax
    shl  bx, 1
    mov  dx, word ptr [error_table + bx]
    push dx
    call show
    add sp, 2
    mov ax, 4cFFh
    int 21h
    pop  bp
    ret

tokenize:
    push bp
    mov  bp, sp
    sub sp, 7
    mov di, word ptr [bp+arg1]
    mov cx, word ptr [bp+arg2]
    mov ax, 0
    mov word ptr [bp+var1], ax
    
token_loop:
    inc di
    cmp byte ptr [di], ' '
    je token_white
    cmp byte ptr [di], 0Dh
    je token_end
    cmp byte ptr [di], 0
    je token_end
    loop token_loop
    
token_white:
    mov ax, word ptr [bp+arg1]
    mov si, di
    sub di, ax
    mov ax, di
    mov di, si
    push ax
    push word ptr [bp+arg1]
    call parse_func
    jc token_fail
    add sp, 4
    mov word ptr [a], ax
    inc di
    mov al, byte ptr [di]
    cmp al, '+'
    je token_op_ok
    cmp al, '-'
    je token_op_ok
    cmp al, '*'
    je token_op_ok
    cmp al, '/'
    je token_op_ok
    cmp al, '%'
    je token_op_ok
    jmp token_fail_format
    
token_op_ok:
    mov byte ptr [oper], al
    inc di
    inc di
    mov word ptr [bp+var2], di
    dec di
    mov ax, word ptr [bp+var1]
    cmp ax, 1
    je token_fail_format
    mov ax, 1
    mov word ptr [bp+var1], ax
    loop token_loop
    
token_end:
    mov ax, word ptr [bp+var1]
    cmp ax, 1
    jne token_fail_format
    mov ax, word ptr [bp+var2]
    sub ax, di
    mov di, word ptr [bp+var2]
    cmp ax, 0
    je token_fail_second
    push ax
    push di
    call parse_func
    jc token_fail
    add sp, 4
    mov word ptr [b], ax
    mov  sp, bp
    pop  bp
    xor ax, ax
    clc
    ret
    
token_fail:
    add sp, 4
    stc
    mov  sp, bp
    pop  bp
    ret
    
token_fail_second:
    add sp, 4
    mov ax, E_FORMAT
    stc
    mov sp, bp
    pop bp
    ret
    
token_fail_format:
    mov ax, E_FORMAT
    stc
    mov sp, bp
    pop bp
    ret

execute:
    push bp
    mov  bp, sp
    sub  sp, 2
    mov  ax, word ptr [bp+arg1]
    mov  bx, word ptr [bp+arg2]
    mov  cl, byte ptr [bp+arg3]
    cmp  cl, '+'
    je   exec_add
    cmp  cl, '-'
    je   exec_sub
    cmp  cl, '*'
    je   exec_mul
    cmp  cl, '/'
    je   exec_div
    cmp  cl, '%'
    je   exec_mod
    jmp  exec_format
    
exec_add:
    add  ax, bx
    jo   exec_overflow
    clc
    jmp  exec_done
    
exec_sub:
    sub  ax, bx
    jo   exec_overflow
    clc
    jmp  exec_done
    
exec_mul:
    imul bx
    cmp dx, 0
    jg exec_overflow
    cmp dx, -1
    jl exec_overflow
    cmp dx, 0
    jne mul_neg
    cmp ax, 0
    jl exec_overflow
    jmp mul_ok
    
mul_neg:
    cmp ax, 0
    jge exec_overflow
    
mul_ok:
    clc
    jmp  exec_done
    
exec_div:
    test bx, bx
    jz   exec_divzero
    cmp  bx, -1
    jne  do_div
    cmp  ax, -32768
    je   exec_overflow
    
do_div:
    cwd
    idiv bx
    clc
    jmp  exec_done
    
exec_mod:
    test bx, bx
    jz   exec_divzero
    cmp  bx, -1
    jne  do_mod
    cmp  ax, -32768
    je   exec_overflow
    
do_mod:
    cwd
    idiv bx
    mov  ax, dx
    clc
    jmp  exec_done
    
exec_divzero:
    mov  ax, E_DIV_ZERO
    stc
    jmp  exec_done
    
exec_overflow:
    mov  ax, E_OVERFLOW
    stc
    jmp  exec_done
    
exec_format:
    mov  ax, E_FORMAT
    stc
    
exec_done:
    mov  sp, bp
    pop  bp
    ret

start:
    mov ax, data
    mov ds, ax
    mov ax, stack
    mov ss, ax
    mov bp, sp
    sub sp, 6
    
    push offset msg_sys
    call show
    add sp, 2
    
    mov ah, 01h
    int 21h
    
    cmp al, 'd'
    je decimal_mode
    cmp al, 'h'
    je hex_mode
    cmp al, 'D'
    je decimal_mode
    cmp al, 'H'
    je hex_mode
    
    call newline
    mov ax, E_FORMAT
    push ax
    call error_handler
    add sp, 2
    
decimal_mode:
    mov word ptr [parse_func], offset parse_decimal
    jmp continue
    
hex_mode:
    mov word ptr [parse_func], offset parse_hexnum
    
continue:
    mov dl, 0DH
    mov ah, 02h
    int 21h
    mov dl, 0AH
    int 21h
    
    push offset msg_expr
    call show
    add sp, 2
    
    mov bx, 0
    mov cx, 1023
    lea dx, buffer_in
    mov ah, 3Fh
    int 21h
    
    push ax
    push offset buffer_in
    call tokenize
    jc token_failed
    add sp, 4
    
    mov ax, word ptr [a]
    mov bx, word ptr [b]
    mov cl, byte ptr [oper]
    xor ch, ch
    
    push cx
    push word ptr [b]
    push word ptr [a]
    call execute
    jc exec_failed
    add sp, 6
    
    mov word ptr [bp+var1], ax
    
    push offset msg_dec
    call show
    add sp, 2
    mov ax, word ptr [bp+var1]
    push ax
    push offset buffer_out
    call dec_convert
    add sp, 4
    push offset buffer_out
    call show
    add sp, 2
    call newline
    
    push offset msg_hex
    call show
    add sp, 2
    mov ax, word ptr [bp+var1]
    push ax
    push offset buffer_out
    call hex_convert
    add sp, 4
    push offset buffer_out
    call show
    add sp, 2
    call newline
    
    mov sp, bp
    mov ax, 4c00h
    int 21h

exec_failed:
    add sp, 4
    
token_failed:
    add sp, 4
    push ax
    call error_handler
    add sp, 2
    mov sp, bp
    mov ax, 4cFFh
    int 21h

code ends
end start