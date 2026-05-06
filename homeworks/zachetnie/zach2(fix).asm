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

data segment para public

    ERROR_SUCCESS        equ 0
    ERROR_FORMAT         equ 1
    ERROR_INVALID_OP     equ 2
    ERROR_DIV_ZERO       equ 3
    ERROR_DIV_OVERFLOW   equ 4
    ERROR_NUM_RANGE      equ 5
    ERROR_BASE           equ 6
    ERROR_READ_STRING    equ 7
    ERROR_EMPTY          equ 8
    
    msg_prompt_base  db "Select input base: 1 - Decimal, 2 - Hexadecimal: ", 0
    msg_prompt_expr  db "Enter expression: ", 0
    msg_result       db "Result: ", 0
    msg_error_prefix db "Error: ", 0
    msg_newline      db 0Dh, 0Ah, 0
    msg_hex_prefix   db " (0x", 0
    msg_hex_suffix   db ")", 0

    
    msg_error_format     db "Invalid expression format", 0
    msg_error_invalid_op db "Invalid operator. Use + - * / %", 0
    msg_error_div_zero   db "Division by zero", 0
    msg_error_div_ovf    db "Division overflow", 0
    msg_error_num_range  db "Number out of range (-32768..32767)", 0
    msg_error_base       db "Invalid base selection", 0
    msg_error_empty      db "Empty input", 0

    
    input_base  db ?
    num1        dw ?
    num2        dw ?
    operator    db ?
    result_low  dw 0
    result_high dw 0

    str1     db 256 dup(0)
    num1_str db 12  dup(0)
    num2_str db 12  dup(0)
    dec_buf  db 12  dup(0)
    hex_buf  db 9   dup(0)
data ends

code segment para public use16
assume cs:code, ds:data, ss:stack


_putchar:
    push bp
    mov  bp, sp
    mov  dl, byte ptr [bp + arg1]
    mov  ah, 02h
    int  21h
    mov  sp, bp
    pop  bp
    ret
	
_getchar:
    push bp
    mov  bp, sp
    mov  ah, 01h
    int  21h
    mov  sp, bp
    pop  bp
    ret
	
_strlen:
    push bp
    mov  bp, sp
    mov  bx, word ptr [bp + arg1]
    xor  ax, ax
strlen_loop:
    cmp  byte ptr [bx], 0
    je   strlen_ret
    inc  ax
    inc  bx
    jmp  strlen_loop
strlen_ret:
    mov  sp, bp
    pop  bp
    ret
	
_putstr:
    push bp
    mov  bp, sp
    push word ptr [bp + arg1]
    call _strlen
    add  sp, 2
    mov  cx, ax
    cmp  cx, 0
    je   putstr_done
    mov  dx, word ptr [bp + arg1]
    mov  ah, 40h
    mov  bx, 1
    int  21h
putstr_done:
    mov  sp, bp
    pop  bp
    ret
	
_getstr:
    push bp
    mov  bp, sp
    mov  cx, word ptr [bp + arg2]
    mov  dx, word ptr [bp + arg1]
    mov  ah, 3fh
    mov  bx, 0
    int  21h
    cmp  ax, 0
    je   getstr_error
    mov  bx, word ptr [bp + arg1]
    add  bx, ax
    dec  bx
    cmp  byte ptr [bx], 10
    jne  getstr_trim_cr
    mov  byte ptr [bx], 0
    dec  bx
getstr_trim_cr:
    cmp  byte ptr [bx], 13
    jne  getstr_ok
    mov  byte ptr [bx], 0
getstr_ok:
    clc
    jmp  getstr_done
getstr_error:
    stc
    mov  ax, ERROR_READ_STRING
getstr_done:
    mov  sp, bp
    pop  bp
    ret
	
_putnewline:
    push bp
    mov  bp, sp
    push offset msg_newline
    call _putstr
    add  sp, 2
    mov  sp, bp
    pop  bp
    ret
	
_print_string:
    push bp
    mov  bp, sp
    push word ptr [bp + arg1]
    call _putstr
    add  sp, 2
    mov  sp, bp
    pop  bp
    ret
	
_print_error:
    push bp
    mov  bp, sp
    push ax
    push dx
	
    push offset msg_error_prefix
    call _print_string
    add  sp, 2
	
    mov  ax, word ptr [bp + arg1]
	
    cmp  ax, ERROR_FORMAT
    je   pe_format
    cmp  ax, ERROR_INVALID_OP
    je   pe_invop
    cmp  ax, ERROR_DIV_ZERO
    je   pe_divz
    cmp  ax, ERROR_DIV_OVERFLOW
    je   pe_divovf
    cmp  ax, ERROR_NUM_RANGE
    je   pe_range
    cmp  ax, ERROR_BASE
    je   pe_base
    cmp  ax, ERROR_EMPTY
    je   pe_empty
    jmp  pe_newline
	
pe_format:
    push offset msg_error_format
    call _print_string
    add  sp, 2
    jmp  pe_newline
pe_invop:
    push offset msg_error_invalid_op
    call _print_string
    add  sp, 2
    jmp  pe_newline
pe_divz:
    push offset msg_error_div_zero
    call _print_string
    add  sp, 2
    jmp  pe_newline
pe_divovf:
    push offset msg_error_div_ovf
    call _print_string
    add  sp, 2
    jmp  pe_newline
pe_range:
    push offset msg_error_num_range
    call _print_string
    add  sp, 2
    jmp  pe_newline
pe_base:
    push offset msg_error_base
    call _print_string
    add  sp, 2
    jmp  pe_newline
pe_empty:
    push offset msg_error_empty
    call _print_string
    add  sp, 2
	
pe_newline:
    push offset msg_newline
    call _print_string
    add  sp, 2
	
    mov  ax, word ptr [bp + arg1]
    mov  ah, 4ch
    int  21h
	
    pop  dx
    pop  ax
    mov  sp, bp
    pop  bp
    ret
	
_exit:
    push bp
    mov  bp, sp
    mov  al, byte ptr [bp + arg1]
    mov  ah, 4ch
    int  21h
    mov  sp, bp
    pop  bp
    ret
	
_exit0:
    push bp
    mov  bp, sp
    push 0
    call _exit
    add  sp, 2
    mov  sp, bp
    pop  bp
    ret
	
_atoi:
    push bp
    mov  bp, sp
    push bx
    push cx
    push dx
    push si
	
    mov  si, word ptr [bp + arg1]
    xor  ax, ax
    xor  bx, bx
	
atoi_skip:
    mov  dl, byte ptr [si]
    cmp  dl, ' '
    jne  atoi_sign
    inc  si
    jmp  atoi_skip
	
atoi_sign:
    cmp  byte ptr [si], '-'
    jne  atoi_parse
    mov  bl, 1
    inc  si
	
atoi_parse:
    mov  cl, input_base
    mov  dl, byte ptr [si]
    cmp  dl, 0
    je   atoi_error
    cmp  dl, ' '
    je   atoi_error
    cmp  dl, 13
    je   atoi_error
	
atoi_next:
    mov  dl, byte ptr [si]
    cmp  dl, 0
    je   atoi_done
    cmp  dl, ' '
    je   atoi_done
    cmp  dl, 13
    je   atoi_done
	
    cmp  cl, 16
    je   atoi_hex_char
	
    cmp  dl, '0'
    jb   atoi_error
    cmp  dl, '9'
    ja   atoi_error
    sub  dl, '0'
    jmp  atoi_digit_ok
	
atoi_hex_char:
    cmp  dl, '0'
    jb   atoi_error
    cmp  dl, '9'
    jbe  atoi_hex_num
    cmp  dl, 'A'
    jb   atoi_maybe_lower
    cmp  dl, 'F'
    jbe  atoi_hex_big
atoi_maybe_lower:
    cmp  dl, 'a'
    jb   atoi_error
    cmp  dl, 'f'
    ja   atoi_error
    sub  dl, 'a' - 10
    jmp  atoi_digit_ok
atoi_hex_num:
    sub  dl, '0'
    jmp  atoi_digit_ok
atoi_hex_big:
    sub  dl, 'A' - 10
atoi_digit_ok:
    xor  dh, dh
    push dx
    xor  dx, dx
    xor  cx, cx
    mov  cl, input_base
    mul  cx
    jc   atoi_overflow
    cmp  dx, 0
    jne  atoi_overflow
    pop  dx
    add  ax, dx
    jc   atoi_overflow
    inc  si
    mov  cl, input_base
    jmp  atoi_next
	
atoi_done:
    cmp  bx, 0
    je   atoi_pos
    cmp  ax, 8000h
    ja   atoi_overflow
    neg  ax
atoi_pos:
    cmp  bx, 0
    jne  atoi_ok
    cmp  ax, 7FFFh
    ja   atoi_overflow
atoi_ok:
    clc
    jmp  atoi_exit
	
atoi_overflow:
    pop  si
    pop  dx
    pop  cx
    pop  bx
    mov  sp, bp
    pop  bp
    push word ptr ERROR_NUM_RANGE
    call _print_error
    add  sp, 2
    ret
	
atoi_error:
    pop  si
    pop  dx
    pop  cx
    pop  bx
    mov  sp, bp
    pop  bp
    push word ptr ERROR_FORMAT
    call _print_error
    add  sp, 2
    ret
	
atoi_exit:
    pop  si
    pop  dx
    pop  cx
    pop  bx
    mov  sp, bp
    pop  bp
    ret
	
_check:
    push bp
    mov  bp, sp
    push bx
    push si
    push di
    mov  si, word ptr [bp + arg1]
	
chk_skip_lead:
    cmp  byte ptr [si], ' '
    jne  chk_read_num1
    inc  si
    jmp  chk_skip_lead
	
chk_read_num1:
    mov  di, offset num1_str
    mov  al, byte ptr [si]
    cmp  al, '-'
    je   chk_num1_sign
    jmp  chk_num1_loop
chk_num1_sign:
    mov  byte ptr [di], al
    inc  di
    inc  si
chk_num1_loop:
    mov  al, byte ptr [si]
    cmp  al, 0
    je   chk_err_format
    cmp  al, ' '
    je   chk_num1_done
    mov  byte ptr [di], al
    inc  di
    inc  si
    jmp  chk_num1_loop
chk_num1_done:
    mov  byte ptr [di], 0
    cmp  di, offset num1_str
    je   chk_err_format
	
    cmp  byte ptr [si], ' '
    jne  chk_err_format
    inc  si
    cmp  byte ptr [si], ' '
    je   chk_err_format
	
    mov  al, byte ptr [si]
    cmp  al, '+'
    je   chk_op_ok
    cmp  al, '-'
    je   chk_op_ok
    cmp  al, '*'
    je   chk_op_ok
    cmp  al, '/'
    je   chk_op_ok
    cmp  al, '%'
    je   chk_op_ok
    jmp  chk_err_invop
chk_op_ok:
    mov  operator, al
    inc  si
	
    cmp  byte ptr [si], ' '
    jne  chk_err_format
    inc  si
    cmp  byte ptr [si], ' '
    je   chk_err_format
	
chk_read_num2:
    mov  di, offset num2_str
    mov  al, byte ptr [si]
    cmp  al, '-'
    je   chk_num2_sign
    jmp  chk_num2_loop
chk_num2_sign:
    mov  byte ptr [di], al
    inc  di
    inc  si
chk_num2_loop:
    mov  al, byte ptr [si]
    cmp  al, 0
    je   chk_num2_done
    cmp  al, 13
    je   chk_num2_done
    cmp  al, ' '
    je   chk_err_format
    mov  byte ptr [di], al
    inc  di
    inc  si
    jmp  chk_num2_loop
chk_num2_done:
    mov  byte ptr [di], 0
    cmp  di, offset num2_str
    je   chk_err_format
    mov  al, byte ptr [si]
    cmp  al, 0
    jne  chk_err_format
	
    push offset num1_str
    call _atoi
    add  sp, 2
    jc   chk_ret
    mov  num1, ax
	
    push offset num2_str
    call _atoi
    add  sp, 2
    jc   chk_ret
    mov  num2, ax
	
    clc
    xor  ax, ax
    jmp  chk_done

chk_err_format:
    stc
    mov  ax, ERROR_FORMAT
    jmp  chk_done
	
chk_err_invop:
    stc
    mov  ax, ERROR_INVALID_OP
	
chk_ret:
chk_done:
    pop  di
    pop  si
    pop  bx
    mov  sp, bp
    pop  bp
    ret
	
_print_result_32:
    push bp
    mov  bp, sp
    push ax
    push bx
    push cx
    push dx
    push si
    push di
	
    mov  result_low,  ax
    mov  result_high, dx
	
    push offset msg_result
    call _print_string
    add  sp, 2
	
    mov  dx, result_high
    mov  ax, result_low
    cmp  dx, 0
    jge  pr_dec_abs
	
    neg  ax
    neg  dx
    sbb  dx, 0
    push ax
    push dx
    mov  dl, '-'
    push dx
    call _putchar
    add  sp, 2
    pop  dx
    pop  ax
pr_dec_abs:
    mov  si, offset dec_buf + 11
    mov  byte ptr [si], 0
    dec  si
    mov  bx, 10
pr_dec_loop:
    push ax
    mov  ax, dx
    xor  dx, dx
    div  bx
    mov  cx, ax
    pop  ax
    div  bx
    add  dl, '0'
    mov  byte ptr [si], dl
    dec  si
    mov  dx, cx
    cmp  dx, 0
    jne  pr_dec_loop
    cmp  ax, 0
    jne  pr_dec_loop
    inc  si
    push si
    call _print_string
    add  sp, 2
	
    push offset msg_hex_prefix
    call _print_string
    add  sp, 2
	
    mov  dx, result_high
    mov  ax, result_low
    mov  di, offset hex_buf
    add  di, 8
    mov  byte ptr [di], 0
    dec  di
    mov  cx, 8
pr_hex_loop:
    push cx
    mov  bx, ax
    and  bx, 0Fh
    cmp  bl, 9
    jbe  pr_hex_digit
    add  bl, 'A' - 10
    jmp  pr_hex_store
pr_hex_digit:
    add  bl, '0'
pr_hex_store:
    mov  byte ptr [di], bl
    dec  di
    shr  dx, 1
    rcr  ax, 1
    shr  dx, 1
    rcr  ax, 1
    shr  dx, 1
    rcr  ax, 1
    shr  dx, 1
    rcr  ax, 1
    pop  cx
    dec  cx
    jnz  pr_hex_loop
    inc  di
pr_hex_skip_zeros:
    cmp  byte ptr [di], '0'
    jne  pr_hex_print
    mov  al, byte ptr [di+1]
    cmp  al, 0
    je   pr_hex_print
    inc  di
    jmp  pr_hex_skip_zeros
pr_hex_print:
    push di
    call _print_string
    add  sp, 2
	
    push offset msg_hex_suffix
    call _print_string
    add  sp, 2
	
    push offset msg_newline
    call _print_string
    add  sp, 2
	
    pop  di
    pop  si
    pop  dx
    pop  cx
    pop  bx
    pop  ax
    mov  sp, bp
    pop  bp
    ret
	
_calc:
    push bp
    mov  bp, sp
	
ask_base:
    push offset msg_prompt_base
    call _print_string
    add  sp, 2
    call _getchar
    cmp  al, '1'
    je   set_dec
    cmp  al, '2'
    je   set_hex
	
    push offset msg_newline
    call _print_string
    add  sp, 2
    push ERROR_BASE
    call _print_error
    add  sp, 2
	
set_dec:
    mov  input_base, 10
    jmp  base_ok
set_hex:
    mov  input_base, 16
base_ok:
    push offset msg_newline
    call _print_string
    add  sp, 2
	
    push offset msg_prompt_expr
    call _print_string
    add  sp, 2
	
    push 256
    push offset str1
    call _getstr
    add  sp, 4
    jc   calc_read_err
	
    cmp  byte ptr [str1], 0
    je   calc_empty_err
	
    push offset str1
    call _check
    add  sp, 2
    jc   calc_check_err
	
    mov  al, operator
    cmp  al, '+'
    je   op_add
    cmp  al, '-'
    je   op_sub
    cmp  al, '*'
    je   op_mul
    cmp  al, '/'
    je   op_div
    cmp  al, '%'
    je   op_mod
    push ERROR_INVALID_OP
    call _print_error
    add  sp, 2
    jmp  calc_return
	
op_add:
    mov  ax, num1
    add  ax, num2
    jo   calc_range_err
    cwd
    jmp  op_done
	
op_sub:
    mov  ax, num1
    sub  ax, num2
    jo   calc_range_err
    cwd
    jmp  op_done
	
op_mul:
    mov  ax, num1
    imul num2
    jmp  op_done
	
op_div:
    cmp  num2, 0
    je   calc_divz_err
    cmp  num1, -32768
    jne  div_ok
    cmp  num2, -1
    jne  div_ok
    push ERROR_DIV_OVERFLOW
    call _print_error
    add  sp, 2
    jmp  calc_return
div_ok:
    mov  ax, num1
    cwd
    idiv num2
    cwd
    jmp  op_done
	
op_mod:
    cmp  num2, 0
    je   calc_divz_err
    cmp  num1, -32768
    jne  mod_ok
    cmp  num2, -1
    jne  mod_ok
    push ERROR_DIV_OVERFLOW
    call _print_error
    add  sp, 2
    jmp  calc_return
mod_ok:
    mov  ax, num1
    cwd
    idiv num2
    mov  ax, dx
    cwd
	
op_done:
    call _print_result_32
    jmp  calc_return
	
calc_read_err:
    push ERROR_READ_STRING
    call _print_error
    add  sp, 2
    jmp  calc_return
	
calc_empty_err:
    push ERROR_EMPTY
    call _print_error
    add  sp, 2
    jmp  calc_return
	
calc_check_err:
    push ax
    call _print_error
    add  sp, 2
    jmp  calc_return
	
calc_range_err:
    push ERROR_NUM_RANGE
    call _print_error
    add  sp, 2
    jmp  calc_return
	
calc_divz_err:
    push ERROR_DIV_ZERO
    call _print_error
    add  sp, 2
	
calc_return:
    mov  sp, bp
    pop  bp
    ret
	
start:
    mov  ax, data
    mov  ds, ax
    mov  ax, stack
    mov  ss, ax
    call _calc
    call _exit0
	
code ends
end start