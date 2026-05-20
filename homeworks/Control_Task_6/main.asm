.386

include include/macro.inc

mstack segment para stack use16
db 65530 dup(?)
mstack ends

stack segment para stack use16
db 65530 dup(?)
stack ends

data segment para public use16

include include/data/fio_errors.inc
include include/data/sym_name.inc
include include/data/global_variables.inc

include include/buttons.inc

data ends

code segment para public use16

assume cs:code,ds:data,ss:stack, es:data

include include/misc.inc

include include/strings.inc
include include/memory.inc

;io headers
include include/io.inc
include include/fio.inc

; error handling function 
include include/error.inc

include include/gfx.inc
include include/mouse.inc
include include/kb.inc

include include/main.inc
include include/exit.inc

include include/file_logic.inc
include include/buttons_handlers.inc






_main proc near 
    push bp
    mov bp, sp

    call _get_mode
	mov byte ptr ds:[orig_mode], al			;Получ. и сохр реж. для выхода

    mov byte ptr ds:[new_color_mode], 03h	;Уст. наш реж 03h
	mov dx, 03h
	push dx
	call _set_mode
	add sp, 2

    call _mouse_init

	mov ax, 0B800H
	mov es, ax						;Указ. на видеопамять

    call _maing

    call getchar

	movzx dx, byte ptr ds:[orig_mode]
	push dx
	call _set_mode					;Восст. реж
	add sp, 2
main_done:
    mov sp, bp
    pop bp
    ret

_main endp 

start proc near
    app_init							;Прис. сегменты
	nop
	
    call _main

    call exit0

start endp

end_code_seg:
code ends

end start
