
; ---------------------------------------------------------------------
; Check if left Alt key is pressed
; Returns: AL = 1 if pressed, 0 otherwise
; ---------------------------------------------------------------------
_is_alt_pressed PROC
    mov ah, 12h
    int 16h
    and al, 00001000b    
    cmp al, 0
    jz _is_alt_pressed_not_pressed
    mov al, 1
    ret
_is_alt_pressed_not_pressed:
    xor al, al
    ret
_is_alt_pressed ENDP

_is_ctrl_pressed PROC
    mov ah, 02h          
    int 16h          
                        
    and al, 00000100b    
    cmp al, 0            
    jz _is_ctrl_pressed_not_pressed     
    mov al, 1            
    ret
_is_ctrl_pressed_not_pressed:
    xor al, al
    ret
_is_ctrl_pressed ENDP

_is_lshift_pressed PROC
    mov ah, 02h          ; BIOS service: read keyboard shift flags
    int 16h              ; returns flags in AL:
                         ; bit 0 = right Shift, bit 1 = left Shift
    and al, 00000010b    ; keep only left Shift bit (bit 1)
    cmp al, 0            ; test if left Shift bit is set
    jz _is_lshift_pressed_not_pressed       ; if zero, not pressed
    mov al, 1            ; else, set return value to 'pressed'
    ret
_is_lshift_pressed_not_pressed:
    xor al, al           ; set return value to 'not pressed' (0)
    ret
_is_lshift_pressed ENDP

; ---------------------------------------------------------------------
; Check if right Shift key is pressed
; Returns: AL = 1 if pressed, 0 otherwise
; Uses BIOS INT 16h, AH=02h to read keyboard shift flags
; ---------------------------------------------------------------------
_is_rshift_pressed PROC
    mov ah, 02h       
    int 16h        
                      
    and al, 00000001b   
    cmp al, 0            
    jz _is_rshift_pressed_not_pressed    
    mov al, 1      
    ret
_is_rshift_pressed_not_pressed:
    xor al, al       
    ret
_is_rshift_pressed ENDP

_read_keys proc
    push bp
    mov bp, sp

    ; вызов функции получения клавиши (al=ASCII, ah=скан-код)
    call _getKey2


    test ax, ax
    jz _read_keys_no_symbol

    ; to clean input queue
    call _getKey

    ; проверка на ESC (скан-код 01h)
    cmp ah, 01h
    je _read_keys_no_ascii_symbol

    cmp ah, 10h; - q
    jne _read_keys_not_q
    mov bx, ax
    call _is_ctrl_pressed      ; after call, AL = 1 if Ctrl pressed, else 0
    cmp al, 1
    mov ax, bx
    jne _read_keys_not_q

    call _exit_button
    ; xor ax, ax          ; возвращаем 0 при ESC
    ; jmp _read_keys_exit_func

_read_keys_not_q:
    cmp ah, 2eh; - c
    jne _read_keys_not_c
    mov bx, ax
    call _is_ctrl_pressed      ; after call, AL = 1 if Ctrl pressed, else 0
    cmp al, 1
    mov ax, bx
    jne _read_keys_not_c

    call _flush_buffer_into_file

    cdecl_call _memset, offset _output_buffer, 0, word ptr [_output_buffer_i]
    mov word ptr [_output_buffer_i],0 
    cdecl_call _memset, offset _f_output_buffer, 0, word ptr [_f_output_buffer_i]
    mov word ptr [_f_output_buffer_i],0 

    call _clear_screen
    call _draw_ui

    jmp _read_keys_no_symbol

_read_keys_not_c:
    cmp ah, 21h; - f
    jne _read_keys_not_f
    mov bx, ax
    call _is_ctrl_pressed      ; after call, AL = 1 if Ctrl pressed, else 0
    cmp al, 1
    mov ax, bx
    jne _read_keys_not_f

    call _flush_buffer_into_file

    jmp _read_keys_no_symbol
_read_keys_not_f:
    ; игнорируем клавиши без символьного представления (al == 0)
    push ax
    call _is_extra_key_pressed
    pop ax

    cmp  ah, 0Fh ; for Tab
    je _read_keys_no_ascii_symbol
    cmp  al, 32
    jb   _read_keys_no_ascii_symbol
    cmp  al, 127
    ja   _read_keys_no_ascii_symbol
    
    ; проверка переполнения буфера (индекс >= 4096)
    mov bx, [_output_buffer_i]
    cmp bx, 4095
    jge _read_keys_buffer_full

    ; запись символа в буфер
    mov [_output_buffer + bx], al
    inc bx
    mov [_output_buffer + bx], ASCII_SEPARATOR   ; Раделитель
    inc bx
    mov [_output_buffer_i], bx

    ; установка завершающего нуля
    mov byte ptr [_output_buffer + bx], 0

    ; успешная запись -> возвращаем 1
    
    mov bx, [_f_output_buffer_i]
    cmp bx, 2047
    jge _read_keys_buffer_full
    mov [_f_output_buffer + bx], al
    inc bx
    mov [_f_output_buffer + bx], ASCII_SEPARATOR
    inc bx
    mov [_f_output_buffer_i], bx
    mov byte ptr [_f_output_buffer + bx], 0
    
    mov ax, 2
    jmp _read_keys_exit_func

_read_keys_buffer_full:
_read_keys_no_symbol:
    ; нет места или символ отсутствует -> возвращаем 1 (продолжить)
    mov ax, 1

_read_keys_exit_func:
	mov sp, bp
    pop bp
    ret

_read_keys_no_ascii_symbol:
    
    push ax
    call _write_non_ascii_key
    add sp, 2
    mov ax, 2
    jmp _read_keys_exit_func
_read_keys endp

; arg1 - scan code
_write_non_ascii_key proc
    push bp
    mov bp, sp
    push si
    push di
    push bx
    push dx

    mov ax, word ptr [bp+arg1]
    mov al, ah
    xor ah, ah

    mov si, ax
    shl si, 1
    add si, offset sym_arr


    mov di, word ptr [si]; we get string ptr
    mov si, word ptr [_output_buffer_i]
    add si, offset _output_buffer

    mov dx, di

    push di
    call _strlen
    pop di
    mov bx, ax

    push es
    mov ax, ds
    mov es, ax

    push bx
    push di
    push si
    call _memcpy
    add sp, 6

    mov si, word ptr [_f_output_buffer_i]
    add si, offset _f_output_buffer


    mov di, dx

    push bx
    push di
    push si
    call _memcpy
    add sp, 6

    pop es

    push bx
    add bx, word ptr [_output_buffer_i]
    mov word ptr[_output_buffer_i], bx
    pop bx

    add bx, word ptr [_f_output_buffer_i]
    mov word ptr[_f_output_buffer_i], bx

    pop dx
    pop bx
    pop di
    pop si
    mov sp, bp
    pop bp
    ret
_write_non_ascii_key endp

_is_extra_key_pressed proc
    ALT_LEN equ 4
    CTRL_LEN equ 5
    LSHIFT_LEN equ 4
    RSHIFT_LEN equ 4

    push bp
    mov bp, sp

    call _is_ctrl_pressed
    cmp al, 1
    jne _is_extra_key_pressed_ctrl_not_pressed

    mov si, word ptr [_output_buffer_i]
    add si, offset _output_buffer

    push es
    mov ax, ds
    mov es, ax

    push CTRL_LEN ; len of string
    push offset esym_ctrl
    push si
    call _memcpy
    add sp, 6

    mov si, word ptr [_f_output_buffer_i]
    add si, offset _f_output_buffer

    push CTRL_LEN ; len of string
    push offset esym_ctrl
    push si
    call _memcpy
    add sp, 6

    pop es

    add word ptr [_output_buffer_i], CTRL_LEN
    add word ptr [_f_output_buffer_i], CTRL_LEN

_is_extra_key_pressed_ctrl_not_pressed:
    call _is_lshift_pressed 
    cmp al, 1
    jne _is_extra_key_pressed_lshift_not_pressed

    mov si, word ptr [_output_buffer_i]
    add si, offset _output_buffer

    push es
    mov ax, ds
    mov es, ax

    push LSHIFT_LEN ; len of string
    push offset esym_lsh
    push si
    call _memcpy
    add sp, 6

    mov si, word ptr [_f_output_buffer_i]
    add si, offset _f_output_buffer

    push LSHIFT_LEN ; len of string
    push offset esym_lsh
    push si
    call _memcpy
    add sp, 6

    pop es

    add word ptr [_output_buffer_i], LSHIFT_LEN
    add word ptr [_f_output_buffer_i], LSHIFT_LEN

_is_extra_key_pressed_lshift_not_pressed:
    call _is_rshift_pressed 
    cmp al, 1
    jne _is_extra_key_pressed_rshift_not_pressed

    call _is_lshift_pressed 
    cmp al, 1
    jne _is_extra_key_pressed_lshift_not_pressed

    mov si, word ptr [_output_buffer_i]
    add si, offset _output_buffer

    push es
    mov ax, ds
    mov es, ax

    push RSHIFT_LEN ; len of string
    push offset esym_rsh
    push si
    call _memcpy
    add sp, 6

    mov si, word ptr [_f_output_buffer_i]
    add si, offset _f_output_buffer

    push RSHIFT_LEN ; len of string
    push offset esym_rsh
    push si
    call _memcpy
    add sp, 6

    pop es

    add word ptr [_output_buffer_i], RSHIFT_LEN
    add word ptr [_f_output_buffer_i], RSHIFT_LEN

_is_extra_key_pressed_rshift_not_pressed:
    call _is_alt_pressed
    cmp al, 1
    jne _is_extra_key_pressed_alt_not_pressed

    mov si, word ptr [_output_buffer_i]
    add si, offset _output_buffer

    push es
    mov ax, ds
    mov es, ax

    push ALT_LEN ; len of string
    push offset esym_alt
    push si
    call _memcpy
    add sp, 6

    mov si, word ptr [_f_output_buffer_i]
    add si, offset _f_output_buffer

    push ALT_LEN ; len of string
    push offset esym_alt
    push si
    call _memcpy
    add sp, 6

    pop es

    add word ptr [_output_buffer_i], ALT_LEN
    add word ptr [_f_output_buffer_i], ALT_LEN
_is_extra_key_pressed_alt_not_pressed:

    mov sp, bp
    pop bp
    ret
_is_extra_key_pressed endp

_read_keys_output_filename proc
    push bp
    mov bp, sp
    ; вызов функции получения клавиши (al=ASCII, ah=скан-код)
    call _getKey

    ; Проверка на enter 
    cmp ah, 1Ch
    je  _read_keys_output_filename_entered_enter
    ; Проверка на backspace
    cmp ah, 0Eh
    je _read_keys_output_filename_entered_bksp

    ; проверка на ESC (скан-код 01h)
    cmp ah, 01h
    jne _read_keys_output_filename_not_esc

    xor ax, ax          ; возвращаем 0 при ESC
    jmp _read_keys_output_filename_exit_func

_read_keys_output_filename_entered_enter: 
    mov ax, 2
    jmp _read_keys_output_filename_exit_func

_read_keys_output_filename_entered_bksp:

    ; проверка на размерность 0
    mov bx, [_output_filename_i]
    test bx, bx
    jz     _read_keys_output_filename_entered_bksp_skip

    dec bx
    ; запись символа в буфер
    mov [_output_filename + bx], 0
    mov [_output_filename_i], bx


_read_keys_output_filename_entered_bksp_skip:
    mov ax, 1
    jmp _read_keys_output_filename_exit_func

_read_keys_output_filename_not_esc:
    ; игнорируем клавиши без символьного представления (ascii)
    cmp  al, 32
    jb   _read_keys_output_filename_no_symbol
    cmp  al, 127
    ja   _read_keys_output_filename_no_symbol

    ; проверка переполнения буфера (индекс >= 120)
    mov bx, [_output_filename_i]
    cmp bx, 120
    jge _read_keys_output_filename_buffer_full

    ; запись символа в буфер
    mov [_output_filename + bx], al
    inc bx
    mov [_output_filename_i], bx

    ; установка завершающего нуля
    mov byte ptr [_output_filename + bx], 0

    ; успешная запись -> возвращаем 1
    mov ax, 1
    jmp _read_keys_output_filename_exit_func

_read_keys_output_filename_buffer_full:
_read_keys_output_filename_no_symbol:
    ; нет места или символ отсутствует -> возвращаем 1 (продолжить)
    mov ax, 1

_read_keys_output_filename_exit_func:
	mov sp, bp
    pop bp
    ret
_read_keys_output_filename endp
