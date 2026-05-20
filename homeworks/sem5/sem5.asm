.386

arg1 equ 4
arg2 equ 6
arg3 equ 8
arg4 equ 10

var1 equ -2
var2 equ -4
var3 equ -6
var4 equ -8

COUNT_SYMBS equ 17		

START_X equ 91
START_Y equ 5

START_INPUT_X equ START_X+7
START_INPUT_Y equ START_Y+31

START_OUTPUT_X equ START_X+7
START_OUTPUT_Y equ START_Y+58

START_X_S equ START_X+6
START_Y_S equ START_Y+3

START_X_EQ equ START_X+20


stack segment para stack
	db 65530 dup(?)
stack ends

data segment para public
	buffer_fonts db 2048 dup(?)
	filename db "font.bin", 0
	
	input_buffer db 12 dup(0)
	input_size dw 0
	
	id_symbol dw 0
	
	result_shown db 0
	
	emsg_sizef db "Error with size fonts-file!", 0
	emsg_openf db "Error with opening fonts-file!", 0
	emsg_readf db "Error with reading fonts-file!", 0
	msg_success_open db "Success open!", 0
	
	; ----------------------------------------
	; B_start_x, B_start_y, height, width, id
	btn_1 dw 5  + START_X,  83 + START_Y, 24,24, 1
	btn_2 dw 31 + START_X,  83 + START_Y, 24,24, 2
	btn_3 dw 57 + START_X,  83 + START_Y, 24,24, 3
	btn_4 dw 5  + START_X, 109 + START_Y, 24,24, 4
	btn_5 dw 31 + START_X, 109 + START_Y, 24,24, 5
	btn_6 dw 57 + START_X, 109 + START_Y, 24,24, 6
	btn_7 dw 5  + START_X, 135 + START_Y, 24,24, 7
	btn_8 dw 31 + START_X, 135 + START_Y, 24,24, 8
	btn_9 dw 57 + START_X, 135 + START_Y, 24,24, 9
	btn_0 dw 31 + START_X, 161 + START_Y, 24,24, 0
	
	btn_pls dw 99 + START_X,  83 + START_Y, 24,24, 10
	btn_mns dw 125+ START_X,  83 + START_Y, 24,24, 11
	btn_mul dw 99 + START_X, 109 + START_Y, 24,24, 12
	btn_div dw 125+ START_X, 109 + START_Y, 24,24, 13
	btn_mod dw 99 + START_X, 135 + START_Y, 24,24, 14
	
	btn_ers dw 125+ START_X, 135 + START_Y, 24,24, 20
	
	btn_equ dw 99 + START_X, 161 + START_Y, 24,50, 19
		
	buttons_count dw 17

	
	space_input dw 0
	
	save_mode db ?

	num1 db 6 dup(?)	
	num2 db 6 dup(?)
	
	operator db ?
	res_str db 12 dup(?)
	error_str db "ERROR", 0
	
data ends

code segment para public use16
assume cs:code,ss:stack,ds:data
include strings.inc
include files.inc
include draw.inc
include mouse.inc
include calc.inc
include click.inc
include buttons.inc


; int init_prog()
; return 0 if success, -1 if fail
init_prog proc near
	push bp
	mov bp, sp
	
	; --------------------------
	; remember the original mode
	call _getmode
	mov byte ptr [save_mode], al
	
	; --------------------------
	; set graphic mode
	mov dx, 13h
	push dx
    call _setmode
	add sp, 2
	
	; init mouse
	mov ax,0
	int 33h

	; show cursor
	mov ax,1
	int 33h	
	
	; --------------------------
	; presets
	call load_fonts
	cmp ax, -1
	jne success_load
	
	jmp unssuccess_load
	
	success_load:
		call fill_main_table
		mov ax, 0
		jmp init_prog_ret

unssuccess_load:
	mov ax, -1
	jmp init_prog_ret

init_prog_ret:
	mov sp, bp
	pop bp
	ret
init_prog endp




calculate_and_draw proc near
	push bp
	mov bp, sp

	push offset input_buffer
	call _calc
	add sp, 2
	cmp ax, -1
	je print_error
	
	; else - success
	mov byte ptr [result_shown], 1
	
	push offset res_str
	call draw_result_string
	add sp, 2
	
	jmp calculate_and_draw_ret
	
	
print_error:
	mov byte ptr [result_shown], 1
	
	push offset error_str
	call draw_result_string
	add sp, 2
	
	jmp calculate_and_draw_ret

calculate_and_draw_ret:
	
	mov sp, bp
	pop bp
	ret
calculate_and_draw endp



; void fill_and_draw()
fill_and_draw proc near
	push bp
	mov bp, sp
	
	push si

	; --------------------------
	; check equals
	cmp word ptr [id_symbol], 19
	je equals_button						
	; without append EQLS in input_buffer
	
	; --------------------------
	; check backspace
	cmp word ptr [id_symbol], 20
	je erase_button						
	; without append BKSPC in input_buffer
		
	; --------------------------
	; start a new expression
	cmp byte ptr [result_shown], 1
	jne continue_work
	
	call clear_all	
			
continue_work:
	; --------------------------
	; append a symbol to an expr
	push word ptr [id_symbol]
	call append_expression
	add sp, 2
	
	cmp ax, -1
	je fill_and_draw_ret
	
draw_base:
	mov si, word ptr [id_symbol]
	
	; --------------------------
	; output to the screen
	mov ax, word ptr [space_input]
	add ax, START_INPUT_X
	
	push 4h
	push ax						; x
	push START_INPUT_Y			; y
	push si						; id
	
	call draw_symbol	
	add sp, 8
	
	add word ptr [space_input], 13
	jmp fill_and_draw_ret
	
	
erase_button:
	call back_space
	jmp fill_and_draw_ret

equals_button:
	call calculate_and_draw
	jmp fill_and_draw_ret 

fill_and_draw_ret:
	pop si
	
	mov sp, bp
	pop bp
	ret
fill_and_draw endp


start:
    mov ax, data
    mov ds, ax
    mov ax, stack
    mov ss, ax
	
	call init_prog
	cmp ax, -1
	je exit_program

	; проверка нажатых кнопок
main_loop:
	; -----------------
	; keyboard click
	call click_keyboard
	cmp ax, -1
	je exit_program
	cmp ax, 1
	je processing_symb
    
	; -----------------
	; mouse click
	call click_mouse
	cmp ax, 1
	je processing_symb
	
	jmp main_loop
	
processing_symb:
	call fill_and_draw
	
	jmp main_loop
	

exit_program:
	movzx ax, byte ptr [save_mode]
	push ax
	call _setmode
	add sp, 2
	
	call _exit0
	
	
code ends
end start