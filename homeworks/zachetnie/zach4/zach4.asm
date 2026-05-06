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
    db 65530 dup(?)
stack ends

data1 segment para public
n1          dw ?
m1          dw ?
matr1       dw 30000 dup(?)

msg_nofile  db "Error: file not found",13,10,0
msg_size    db "Error: incompatible matrix sizes",13,10,0
msg_op      db "Error: unknown operation",13,10,0

prompt_f1   db "Enter first file name: ", 0
prompt_f2   db "Enter second file name: ", 0
prompt_f3   db "Enter output file name: ", 0
prompt_op   db "Enter operation (+, -, *): ", 0

fname1      db 128 dup(0)
fname2      db 128 dup(0)
fname3      db 128 dup(0)
op_buf      db   4 dup(0)

num_buf     db  10 dup(0)
io_buf      db   2 dup(0)
data1 ends

data2 segment para public
n2          dw ?
m2          dw ?
matr2       dw 30000 dup(?)
data2 ends

code segment para public use16
assume cs:code, ss:stack, ds:data1, es:data2

include strings.inc
include files.inc


atoi proc near
    push bp
    mov  bp, sp
    push bx
    push cx
    push si
	
    mov  si, word ptr [bp + arg1]
    xor  ax, ax
    xor  cx, cx
	
    cmp  byte ptr [si], '-'
    jne  atoi_cyc
    inc  cx
    inc  si
	
atoi_cyc:
    xor  bx, bx
	mov  bl, byte ptr [si]
	cmp  bx, '0'
    jb   atoi_fin
    cmp  bx, '9'
    ja   atoi_fin
    sub  bx, '0'
    push bx
    mov  bx, 10
    imul bx
    pop  bx
    add  ax, bx
    inc  si
    jmp  atoi_cyc
	
atoi_fin:
    test cx, cx
    jz   atoi_ret
    neg  ax
	
atoi_ret:
    pop  si
    pop  cx
    pop  bx
    mov  sp, bp
    pop  bp
    ret
atoi endp

itoa proc near
    push bp
    mov  bp, sp
    push bx
    push cx
    push dx
    push si
    push di
	
    mov  ax, word ptr [bp + arg1]
    mov  di, word ptr [bp + arg2]
	
    xor  si, si
    test ax, ax
    jns  itoa_pos
    inc  si
    neg  ax
	
itoa_pos:
    xor  cx, cx
	
itoa_div:
    xor  dx, dx
    mov  bx, 10
    div  bx
    push dx
    inc  cx
    test ax, ax
    jnz  itoa_div
	
    test si, si
    jz   itoa_digs
    mov  byte ptr [di], '-'
    inc  di
	
itoa_digs:
    pop  dx
    add  dl, '0'
    mov  byte ptr [di], dl
    inc  di
    loop itoa_digs
	
    mov  byte ptr [di], 0
	
    pop  di
    pop  si
    pop  dx
    pop  cx
    pop  bx
    mov  sp, bp
    pop  bp
    ret
itoa endp

ReadByte proc near
    push cx
    push dx
    mov  ah, 3Fh
    mov  cx, 1
    mov  dx, offset io_buf
    int  21h
    jnc  rb_ok
    xor  ax, ax
rb_ok:
    pop  dx
    pop  cx
    ret
ReadByte endp

ReadNumber proc near
    push cx
    mov  si, offset num_buf
rn_skip:
    call ReadByte
    test ax, ax
    jz   rn_cvt
    mov  al, byte ptr [io_buf]
    cmp  al, ' '
    je   rn_skip
    cmp  al, 13
    je   rn_skip
    cmp  al, 10
    je   rn_skip
	
    mov  byte ptr [si], al
    inc  si
	
rn_acc:
    call ReadByte
    test ax, ax
    jz   rn_cvt
    mov  al, byte ptr [io_buf]
    cmp  al, ' '
    je   rn_cvt
    cmp  al, 13
    je   rn_cvt
    cmp  al, 10
    je   rn_cvt
    mov  byte ptr [si], al
    inc  si
    jmp  rn_acc
	
rn_cvt:
    mov  byte ptr [si], 0
	
    push offset num_buf
    call atoi
    add  sp, 2
	
    pop  cx
    ret
ReadNumber endp

ReadMatrix proc near
    push bp
    mov  bp, sp
    sub  sp, 4
	
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push es
	
    push 0
    push word ptr [bp + arg1]
    call _fopen
    add  sp, 4
	
    cmp  ax, -1
    jne  rm_ok
	
    push offset msg_nofile
    call _putstr
    add  sp, 2
	
    mov  ax, word ptr [bp + arg2]
    mov  es, ax
    mov  word ptr es:[0], 0
    jmp  rm_exit
	
rm_ok:
    mov  word ptr [bp + var1], ax
    mov  ax, word ptr [bp + arg2]
    mov  es, ax
	
    mov  bx, word ptr [bp + var1]
	
    call ReadNumber
    mov  word ptr es:[0], ax
    mov  cx, ax
	
    call ReadNumber
    mov  word ptr es:[2], ax
    
    mov  ax, cx
    mul  word ptr es:[2]
    mov  cx, ax
	
    mov  di, 4
	
rm_loop:
    jcxz rm_close
    call ReadNumber
    mov  word ptr es:[di], ax
    add  di, 2
    dec  cx
    jmp  rm_loop
	
rm_close:
    push word ptr [bp + var1]
    call _fclose
    add  sp, 2
	
rm_exit:
    pop  es
    pop  di
    pop  si
    pop  dx
    pop  cx
    pop  bx
    pop  ax
    mov  sp, bp
    pop  bp
    ret
ReadMatrix endp

WriteNum proc near
    push bp
    mov  bp, sp
    push ax
    push cx

    push offset num_buf
    push word ptr [bp + arg2]
    call itoa
    add  sp, 4

    push offset num_buf
    call _strlen
    add  sp, 2

    push offset num_buf
    push ax
    push word ptr [bp + arg1]
    call _fwrite
    add  sp, 6

    pop  cx
    pop  ax
    mov  sp, bp
    pop  bp
    ret
WriteNum endp

WriteCh proc near
    push bp
    mov  bp, sp
    push ax

    mov  al, byte ptr [bp + arg2]
    mov  byte ptr [io_buf], al

    push offset io_buf
    push 1
    push word ptr [bp + arg1]
    call _fwrite
    add  sp, 6

    pop  ax
    mov  sp, bp
    pop  bp
    ret
WriteCh endp

MulElem proc near
    push bp
    mov  bp, sp
    push bx
    push cx
    push dx
    push si
    push di

    mov  cx, word ptr [m1]
    xor  di, di
    xor  bx, bx
me_loop:
    test cx, cx
    jz   me_done
	
    mov  ax, word ptr [bp + arg1]
    mul  word ptr [m1]
    add  ax, bx
    shl  ax, 1
    mov  si, ax
    mov  ax, word ptr ds:[matr1 + si]

    push ax
    mov  ax, bx
    mul  word ptr es:[2]
    add  ax, word ptr [bp + arg2]
    shl  ax, 1
    mov  si, ax
    mov  ax, word ptr es:[matr2 + si]

    pop  si
    imul si
    add  di, ax

    inc  bx
    dec  cx
    jmp  me_loop

me_done:
    mov  ax, di

    pop  di
    pop  si
    pop  dx
    pop  cx
    pop  bx
    mov  sp, bp
    pop  bp
    ret
MulElem endp

Calc proc near
    push bp
    mov  bp, sp
    sub  sp, 8

    push bx
    push cx
    push dx
    push si
    push di
    push es

	push offset prompt_f1
	call _putstr
	add sp, 2
	push 128
	push offset fname1
	call _getstr
	add sp, 4

	push offset prompt_f2
	call _putstr
	add sp, 2
	push 128
	push offset fname2
	call _getstr
	add sp, 4

	push offset prompt_f3
	call _putstr
	add sp, 2
	push 128
	push offset fname3
	call _getstr
	add sp, 4

	push offset prompt_op
	call _putstr
	add sp, 2
	push 4
	push offset op_buf
	call _getstr
	add sp, 4
	
    mov  al, byte ptr [op_buf]
    cmp  al, '+'
    je   calc_op_ok
    cmp  al, '-'
    je   calc_op_ok
    cmp  al, '*'
    je   calc_op_ok
	
    push offset msg_op
    call _putstr
    add  sp, 2
    jmp  calc_fin
	
calc_op_ok:
    xor  ah, ah
    mov  word ptr [bp + var2], ax

    push data1
    push offset fname1
    call ReadMatrix
    add  sp, 4

    cmp  word ptr [n1], 0
    je   calc_fin

    push data2
    push offset fname2
    call ReadMatrix
    add  sp, 4

    mov  ax, data2
    mov  es, ax

    cmp  word ptr es:[0], 0
    je   calc_fin

    cmp  word ptr [bp + var2], '*'
    je   calc_chk_mul

    mov  ax, word ptr [n1]
    cmp  ax, word ptr es:[0]
    jne  calc_size_err
    mov  ax, word ptr [m1]
    cmp  ax, word ptr es:[2]
    je   calc_compat
    jmp  calc_size_err

calc_chk_mul:
    mov  ax, word ptr [m1]
    cmp  ax, word ptr es:[0]
    je   calc_compat

calc_size_err:
    push offset msg_size
    call _putstr
    add  sp, 2
    jmp  calc_fin

calc_compat:
    cmp  word ptr [bp + var2], '*'
    je   calc_sz_mul
	
    mov  ax, word ptr [n1]
    mov  word ptr [bp + var3], ax
    mov  ax, word ptr [m1]
    mov  word ptr [bp + var4], ax
    jmp  calc_create

calc_sz_mul:
    mov  ax, word ptr [n1]
    mov  word ptr [bp + var3], ax
    mov  ax, word ptr es:[2]
    mov  word ptr [bp + var4], ax

calc_create:
    mov  ah, 3Ch
    xor  cx, cx
    mov  dx, offset fname3
    int  21h
    jc   calc_fin
    mov  word ptr [bp + var1], ax   ; fd_out

    push word ptr [bp + var3]
    push word ptr [bp + var1]
    call WriteNum
    add  sp, 4

    push ' '
    push word ptr [bp + var1]
    call WriteCh
    add  sp, 4

    push word ptr [bp + var4]
    push word ptr [bp + var1]
    call WriteNum
    add  sp, 4

    push 13
    push word ptr [bp + var1]
    call WriteCh
    add  sp, 4

    push 10
    push word ptr [bp + var1]
    call WriteCh
    add  sp, 4

    cmp  word ptr [bp + var2], '+'
    je   calc_add
    cmp  word ptr [bp + var2], '-'
    je   calc_sub
    jmp  calc_mul

calc_add:
    mov  cx, word ptr [bp + var3]
    imul cx, word ptr [bp + var4]

    mov  si, offset matr1
    mov  di, 4
    xor  dx, dx

calc_add_lp:
    test cx, cx
    jnz  calc_add_continue
    jmp  calc_done

calc_add_continue:
    mov  ax, word ptr ds:[si]
    add  ax, word ptr es:[di]

    push cx
    push si
    push di
    push dx

    push ax
    push word ptr [bp + var1]
    call WriteNum
    add  sp, 4

    pop  dx
    pop  di
    pop  si
    pop  cx

    add  si, 2
    add  di, 2
    dec  cx
    inc  dx

    cmp  dx, word ptr [bp + var4]
    jb   calc_add_sp

    push cx
    push si
    push di
    push dx 
    
    push 13
    push word ptr [bp + var1]
    call WriteCh
    add  sp, 4
    
    push 10
    push word ptr [bp + var1]
    call WriteCh
    add  sp, 4
    
    pop  dx
    pop  di
    pop  si
    pop  cx
    
    xor  dx, dx
    jmp  calc_add_lp

calc_add_sp:
    push cx
    push si
    push di
    push dx
    
    push ' '
    push word ptr [bp + var1]
    call WriteCh
    add  sp, 4
    
    pop  dx
    pop  di
    pop  si
    pop  cx
    jmp  calc_add_lp
	
calc_sub:
    mov  cx, word ptr [bp + var3]
    imul cx, word ptr [bp + var4]

    mov  si, offset matr1
    mov  di, 4
    xor  dx, dx

calc_sub_lp:
    test cx, cx
    jnz  calc_sub_continue
    jmp  calc_done

calc_sub_continue:
    mov  ax, word ptr ds:[si]
    sub  ax, word ptr es:[di]

    push cx
    push si
    push di
    push dx

    push ax
    push word ptr [bp + var1]
    call WriteNum
    add  sp, 4

    pop  dx
    pop  di
    pop  si
    pop  cx

    add  si, 2
    add  di, 2
    dec  cx
    inc  dx

    cmp  dx, word ptr [bp + var4]
    jb   calc_sub_sp

    push cx
    push si
    push di
    push dx
    
    push 13
    push word ptr [bp + var1]
    call WriteCh
    add  sp, 4
    push 10
    push word ptr [bp + var1]
    call WriteCh
    add  sp, 4
    
    pop  dx
    pop  di
    pop  si
    pop  cx
    xor  dx, dx
    jmp  calc_sub_lp

calc_sub_sp:
    push cx
    push si
    push di
    push dx
    
    push ' '
    push word ptr [bp + var1]
    call WriteCh
    add  sp, 4
    
    pop  dx
    pop  di
    pop  si
    pop  cx
    jmp  calc_sub_lp

calc_mul:
    xor  si, si

calc_mul_row:
    cmp  si, word ptr [bp + var3]
    jae  calc_done

    xor  di, di

calc_mul_col:
    cmp  di, word ptr [bp + var4]
    jae  calc_mul_nxt_row

    
    push si
    push di

    push di
    push si
    call MulElem
    add  sp, 4

    pop  di
    pop  si

    push si
    push di
    push ax
    push word ptr [bp + var1]
    call WriteNum
    add  sp, 4
    pop  di
    pop  si
	
    mov  ax, di
    inc  ax
    cmp  ax, word ptr [bp + var4]
    jb   calc_mul_sp

    push si
    push di
    push 13
    push word ptr [bp + var1]
    call WriteCh
    add  sp, 4
    push 10
    push word ptr [bp + var1]
    call WriteCh
    add  sp, 4
    pop  di
    pop  si
    inc  di
    jmp  calc_mul_col

calc_mul_sp:
    push si
    push di
    push ' '
    push word ptr [bp + var1]
    call WriteCh
    add  sp, 4
    pop  di
    pop  si
    inc  di
    jmp  calc_mul_col

calc_mul_nxt_row:
    inc  si
    jmp  calc_mul_row

calc_done:
    push word ptr [bp + var1]
    call _fclose
    add  sp, 2

calc_fin:
    pop  es
    pop  di
    pop  si
    pop  dx
    pop  cx
    pop  bx
    mov  sp, bp
    pop  bp
    ret
Calc endp

start:
    mov  ax, data1
    mov  ds, ax
    mov  ax, data2
    mov  es, ax
    mov  ax, stack
    mov  ss, ax

    call Calc
    call _exit0

code ends
end start