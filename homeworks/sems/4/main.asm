.386
arg1 equ 4
arg2 equ 6
arg3 equ 8

stack segment para stack
    db 65530 dup(?)
stack ends

data1 segment para public
    n1 dw ?
    m1 dw ?
    matr1 dw 8000 dup(?)
    
    ; Буферы
    fname1 db 64 dup(0)
    fname2 db 64 dup(0)
    fout   db 64 dup(0)
    op     db 4 dup(0)
    tmp_buf db 32 dup(0)
    
    ; Сообщения
    msg_f1 db "Matrix 1: ", 0
    msg_f2 db "Matrix 2: ", 0
    msg_f3 db "Result: ", 0
    msg_op db "Op (+ - *): ", 0
    msg_err_file db "Error: File not found", 10, 13, 0
    msg_err_dim  db "Error: Bad dimensions", 10, 13, 0
    msg_err_op   db "Error: Bad operation", 10, 13, 0
data1 ends

data2 segment para public
    n2 dw ?
    m2 dw ?
    matr2 dw 8000 dup(?)
data2 ends

code segment para public use16
    assume cs:code, ss:stack, ds:data1, es:data2

include strings.inc
include files.inc
include math.inc
include matrix.inc

; Запись числа и пробела в файл
WriteIntToFile proc near
    push bp
    mov bp, sp
    
    push offset tmp_buf
    push word ptr [bp + 6] ; val
    call itoa
    add sp, 4
    
    push offset tmp_buf
    call _strlen
    add sp, 2
    
    push offset tmp_buf
    push ax
    push word ptr [bp + 4] ; fd
    call _fwrite
    add sp, 6
    
    mov byte ptr [tmp_buf], ' '
    push offset tmp_buf
    push 1
    push word ptr [bp + 4]
    call _fwrite
    add sp, 6
    
    pop bp
    ret
WriteIntToFile endp

Calc proc near
    push bp
    mov bp, sp
    sub sp, 2 ; [bp-2] = fd_out

    ; Ввод данных
    push offset msg_f1
    call _putstr
    push 64
    push offset fname1
    call _getstr
    add sp, 6

    push offset msg_f2
    call _putstr
    push 64
    push offset fname2
    call _getstr
    add sp, 6

    push offset msg_f3
    call _putstr
    push 64
    push offset fout
    call _getstr
    add sp, 6

    push offset msg_op
    call _putstr
    push 4
    push offset op
    call _getstr
    add sp, 6

    ; Загрузка матриц
    push data1
    push offset fname1
    call ReadMatrix
    add sp, 4

    push data2
    push offset fname2
    call ReadMatrix
    add sp, 4

    ; Создание файла результата через прерывание DOS
    mov ah, 3Ch
    xor cx, cx
    mov dx, offset fout
    int 21h
    jnc out_ok
    push offset msg_err_file
    call _putstr
    call _exit0
out_ok:
    mov [bp-2], ax

    mov al, [op]
    cmp al, '+'
    je do_add
    cmp al, '-'
    je do_sub
    cmp al, '*'
    je do_mul
    
    push offset msg_err_op
    call _putstr
    call _exit0

do_add:
do_sub:
    mov ax, ds:n1
    cmp ax, es:n2
    jne err_dim
    mov ax, ds:m1
    cmp ax, es:m2
    jne err_dim
    
    push word ptr ds:n1
    push word ptr [bp-2]
    call WriteIntToFile
    push word ptr ds:m1
    push word ptr [bp-2]
    call WriteIntToFile
    add sp, 8

    mov cx, ds:n1
    imul cx, ds:m1
    xor si, si
as_loop:
    push cx
    mov ax, ds:matr1[si]
    cmp byte ptr [op], '+'
    jne is_minus
    add ax, es:matr2[si]
    jmp as_save
is_minus:
    sub ax, es:matr2[si]
as_save:
    push ax
    push word ptr [bp-2]
    call WriteIntToFile
    add sp, 4
    add si, 2
    pop cx
    loop as_loop
    jmp done

do_mul:
    mov ax, ds:m1
    cmp ax, es:n2
    jne err_dim
    
    push word ptr ds:n1
    push word ptr [bp-2]
    call WriteIntToFile
    push word ptr es:m2
    push word ptr [bp-2]
    call WriteIntToFile
    add sp, 8

    xor bx, bx ; i
mul_i:
    xor cx, cx ; j
mul_j:
    xor dx, dx ; k
    xor di, di ; sum
mul_k:
    ; A[i][k]
    mov ax, bx
    imul ax, ds:m1
    add ax, dx
    shl ax, 1
    mov si, ax
    mov ax, ds:matr1[si]
    
    ; B[k][j]
    push ax
    mov ax, dx
    imul ax, es:m2
    add ax, cx
    shl ax, 1
    mov si, ax
    pop ax
    
    imul ax, es:matr2[si]
    add di, ax
    
    inc dx
    cmp dx, ds:m1
    jl mul_k
    
    push bx
    push cx
    push di
    push word ptr [bp-2]
    call WriteIntToFile
    add sp, 4
    pop cx
    pop bx
    
    inc cx
    cmp cx, es:m2
    jl mul_j
    inc bx
    cmp bx, ds:n1
    jl mul_i
    jmp done

err_dim:
    push offset msg_err_dim
    call _putstr
done:
    push word ptr [bp-2]
    call _fclose
    add sp, 2
    mov sp, bp
    pop bp
    ret
Calc endp

start:
    mov ax, data1
    mov ds, ax
    mov ax, data2
    mov es, ax
    mov ax, stack
    mov ss, ax
    call Calc
    call _exit0
code ends
end start