.386

arg1 equ 4
arg2 equ 6
arg3 equ 8
arg4 equ 10

var1 equ -2
var2 equ -4
var3 equ -6
var4 equ -8
var5 equ -10
var6 equ -12
var7 equ -14
var8 equ -16

WIN_LEFT 	equ 15
WIN_TOP 	equ	5
WIN_WIDTH 	equ	50
WIN_HEIGHT 	equ	15

stack segment para stack
db 65530 dup(?)
stack ends

data segment para public
	save_mode 	db ?
	
	filename 	db 50 dup(?),0
	filehandle 	dw ?
	
	log_buff 	db 50*20 dup(?),0
	crlf		db 0dh,0ah
	
; Buttons
	button_save db "Save",0
	button_del	db "Delete",0
	
; Errors
	Err_openFile 	db "Err: opening file",0
	Err_closeFile 	db "Err: closing file",0
	Err_wrongsymb 	db "Err: wrong symbol",0
	
; Strings for each key:
	str_0       db "0",0
	str_1       db "1",0
	str_2       db "2",0
	str_3       db "3",0
	str_4       db "4",0
	str_5       db "5",0
	str_6       db "6",0
	str_7       db "7",0
	str_8       db "8",0
	str_9       db "9",0

	str_exclam  db "!",0
	str_at      db "@",0
	str_hash    db "#",0
	str_dollar  db "$",0
	str_percent db "%",0
	str_caret   db "^",0
	str_amp     db "&",0
	str_star    db "*",0
	str_lparen  db "(",0
	str_rparen  db ")",0

	str_minus   db "-",0
	str_under   db "_",0
	str_equal   db "=",0
	str_plus    db "+",0

	str_lbrack  db "[",0
	str_lbrace  db "{",0
	str_rbrack  db "]",0
	str_rbrace  db "}",0
	str_semi    db ";",0
	str_colon   db ":",0
	str_quote   db "'",0
	str_dquote  db '"',0
	str_backtick db "`",0
	str_tilde   db "~",0
	str_backslash db "\\",0
	str_bar     db "|",0
	str_comma   db ",",0
	str_lt      db "<",0
	str_dot     db ".",0
	str_gt      db ">",0
	str_slash   db "/",0
	str_question db "?",0

	str_a1       db "a",0
	str_a2       db "A",0
	str_b1       db "b",0
	str_b2       db "B",0
	str_c1       db "c",0
	str_c2       db "C",0
	str_d1       db "d",0
	str_d2       db "D",0
	str_e1       db "e",0
	str_e2       db "E",0
	str_f1       db "f",0
	str_f2       db "F",0
	str_g1       db "g",0
	str_g2       db "G",0
	str_h1       db "h",0
	str_h2       db "H",0
	str_i1       db "i",0
	str_i2       db "I",0
	str_j1       db "j",0
	str_j2       db "J",0
	str_k1       db "k",0
	str_k2       db "K",0
	str_l1       db "l",0
	str_l2       db "L",0
	str_m1       db "m",0
	str_m2       db "M",0
	str_n1       db "n",0
	str_n2       db "N",0
	str_o1       db "o",0
	str_o2       db "O",0
	str_p1       db "p",0
	str_p2       db "P",0
	str_q1       db "q",0
	str_q2       db "Q",0
	str_r1       db "r",0
	str_r2       db "R",0
	str_s1       db "s",0
	str_s2       db "S",0
	str_t1       db "t",0
	str_t2       db "T",0
	str_u1       db "u",0
	str_u2       db "U",0
	str_v1       db "v",0
	str_v2       db "V",0
	str_w1       db "w",0
	str_w2       db "W",0
	str_x1       db "x",0
	str_x2       db "X",0
	str_y1       db "y",0
	str_y2       db "Y",0
	str_z1       db "z",0
	str_z2       db "Z",0

	str_esc     db "ESC",0
	str_bksp    db "BKSP",0
	str_tab     db "Tab",0
	str_enter   db "Enter",0
	str_ctrl    db "Ctrl",0
	str_lshift  db "L SH",0
	str_rshift  db "R SH",0
	str_alt     db "Alt",0
	str_space   db "Spc",0
	str_caps    db "CpsLk",0
	str_numlk   db "Num Lk",0
	str_scrl    db "Scrl Lk",0
	str_home    db "Home",0
	str_up      db "Up Arrow",0
	str_pgup    db "Pg Up",0
	str_left    db "Left Arrow",0
	str_right   db "Rt Arrow",0
	str_end     db "End",0
	str_down    db "Dn Arrow",0
	str_pgdn    db "Pg Dn",0
	str_ins     db "Ins",0
	str_del     db "Del",0
	str_ptscr   db "PtScr",0

	str_num_minus   db "-(num)",0
	str_num_plus    db "+(num)",0
	str_num_5       db "5(num)",0
	str_num_4_left  db "4 Left Arrow",0
	str_num_6_right db "6 Rt Arrow",0
	str_num_1_end   db "1 End",0
	str_num_2_down  db "2 Dn Arrow",0
	str_num_3_pgdn  db "3 Pg Dn",0
	str_num_0_ins   db "0 Ins",0
	str_num_dot_del db "Del .",0

	str_f1_spec 	db "F1",0
	str_f2_spec 	db "F2",0
	str_f3      	db "F3",0
	str_f4      	db "F4",0
	str_f5      	db "F5",0
	str_f6      	db "F6",0
	str_f7      	db "F7",0
	str_f8      	db "F8",0
	str_f9      	db "F9",0
	str_f10     	db "F10",0
	str_f11     	db "F11",0
	str_f12     	db "F12",0

	str_sh_f1   db "SH F1",0
	str_sh_f2   db "SH F2",0
	str_sh_f3   db "SH F3",0
	str_sh_f4   db "SH F4",0
	str_sh_f5   db "SH F5",0
	str_sh_f6   db "SH F6",0
	str_sh_f7   db "SH F7",0
	str_sh_f8   db "SH F8",0
	str_sh_f9   db "SH F9",0
	str_sh_f10  db "SH F10",0
	str_sh_f11  db "SH F11",0
	str_sh_f12  db "SH F12",0
	str_shift_tab db "SH Tab",0

	str_ctrl_f1 db "Ctrl F1",0
	str_ctrl_f2 db "Ctrl F2",0
	str_ctrl_f3 db "Ctrl F3",0
	str_ctrl_f4 db "Ctrl F4",0
	str_ctrl_f5 db "Ctrl F5",0
	str_ctrl_f6 db "Ctrl F6",0
	str_ctrl_f7 db "Ctrl F7",0
	str_ctrl_f8 db "Ctrl F8",0
	str_ctrl_f9 db "Ctrl F9",0
	str_ctrl_f10 db "Ctrl F10",0
	str_ctrl_f11 db "Ctrl F11",0
	str_ctrl_f12 db "Ctrl F12",0

	str_alt_f1  db "Alt F1",0
	str_alt_f2  db "Alt F2",0
	str_alt_f3  db "Alt F3",0
	str_alt_f4  db "Alt F4",0
	str_alt_f5  db "Alt F5",0
	str_alt_f6  db "Alt F6",0
	str_alt_f7  db "Alt F7",0
	str_alt_f8  db "Alt F8",0
	str_alt_f9  db "Alt F9",0
	str_alt_f10 db "Alt F10",0
	str_alt_f11 db "Alt F11",0
	str_alt_f12 db "Alt F12",0

	str_ctrl_ptscr db "Ctrl PtScr",0
	str_ctrl_l     db "Ctrl L",0
	str_ctrl_r     db "Ctrl R",0
	str_ctrl_end   db "Ctrl End",0
	str_ctrl_pgdn  db "Ctrl PgDn",0
	str_ctrl_home  db "Ctrl Home",0
	str_ctrl_pgup  db "Ctrl PgUp",0
	str_ctrl_up_arrow db "Ctrl Up Arrow",0
	str_ctrl_minus_num db "Ctrl -(num)",0
	str_ctrl_5_num    db "Ctrl 5(num)",0
	str_ctrl_plus_num db "Ctrl +(num)",0
	str_ctrl_dn_arrow db "Ctrl Dn Arrow",0
	str_ctrl_ins      db "Ctrl Ins",0
	str_ctrl_del      db "Ctrl Del",0
	str_ctrl_tab      db "Ctrl Tab",0
	str_ctrl_slash_num db "Ctrl /(num)",0
	str_ctrl_star_num db "Ctrl *(num)",0

	str_alt_1    db "Alt 1",0
	str_alt_2    db "Alt 2",0
	str_alt_3    db "Alt 3",0
	str_alt_4    db "Alt 4",0
	str_alt_5    db "Alt 5",0
	str_alt_6    db "Alt 6",0
	str_alt_7    db "Alt 7",0
	str_alt_8    db "Alt 8",0
	str_alt_9    db "Alt 9",0
	str_alt_0    db "Alt 0",0
	str_alt_minus db "Alt -",0
	str_alt_equal db "Alt =",0

	str_alt_home    db "Alt Home",0
	str_alt_up      db "Alt Up Arrow",0
	str_alt_pgup    db "Alt PgUp",0
	str_alt_left    db "Alt Left Arrow",0
	str_alt_right   db "Alt Rt Arrow",0
	str_alt_end     db "Alt End",0
	str_alt_down    db "Alt Dn Arrow",0
	str_alt_pgdn    db "Alt PgDn",0
	str_alt_ins     db "Alt Ins",0
	str_alt_del     db "Alt Del",0
	str_alt_slash_num db "Alt /(num)",0
	str_alt_tab     db "Alt Tab",0
	str_alt_enter_num db "Alt Enter(num)",0



; Table of scan_codes with two pointers (normal, shift)
; 	dw scan_code, dw offset normal, dw offset shift
scan_table label word
	dw 011Bh, offset str_esc      ; ESC (скан 01, ascii ESC 1Bh)
	dw 0231h, offset str_1        ; 1
	dw 0221h, offset str_exclam   ; ! (Shift+1)
	dw 0332h, offset str_2
	dw 0340h, offset str_at       ; @ (Shift+2)
	dw 0433h, offset str_3
	dw 0423h, offset str_hash     ; # (Shift+3)
	dw 0534h, offset str_4
	dw 0524h, offset str_dollar   ; $ (Shift+4)
	dw 0635h, offset str_5
	dw 0625h, offset str_percent  ; % (Shift+5)
	dw 0736h, offset str_6
	dw 075Eh, offset str_caret    ; ^ (Shift+6)
	dw 0837h, offset str_7
	dw 0826h, offset str_amp      ; & (Shift+7)
	dw 0938h, offset str_8
	dw 092Ah, offset str_star     ; * (Shift+8)
	dw 0A39h, offset str_9
	dw 0A28h, offset str_lparen   ; ( (Shift+9)
	dw 0B30h, offset str_0
	dw 0B29h, offset str_rparen   ; ) (Shift+0)
	dw 0C2Dh, offset str_minus    ; -
	dw 0C5Fh, offset str_under    ; _ (Shift+-)
	dw 0D3Dh, offset str_equal    ; =
	dw 0D2Bh, offset str_plus     ; + (Shift+=)
	dw 0E08h, offset str_bksp     ; BKSP (ascii 08)
	dw 0F00h, offset str_shift_tab  ; (Shift+tab)
	dw 0F09h, offset str_tab      ; Tab (ascii 09)

	dw 1071h, offset str_q1
	dw 1051h, offset str_q2
	dw 1177h, offset str_w1
	dw 1157h, offset str_w2
	dw 1265h, offset str_e1
	dw 1245h, offset str_e2
	dw 1372h, offset str_r1
	dw 1352h, offset str_r2
	dw 1474h, offset str_t1
	dw 1454h, offset str_t2
	dw 1579h, offset str_y1
	dw 1559h, offset str_y2
	dw 1675h, offset str_u1
	dw 1655h, offset str_u2
	dw 1769h, offset str_i1
	dw 1749h, offset str_i2
	dw 186Fh, offset str_o1
	dw 184Fh, offset str_o2
	dw 1970h, offset str_p1
	dw 1950h, offset str_p2
	dw 1A5Bh, offset str_lbrack   ; [
	dw 1A7Bh, offset str_lbrace   ; {
	dw 1B5Dh, offset str_rbrack   ; ]
	dw 1B7Dh, offset str_rbrace   ; }
	dw 1C0Dh, offset str_enter    ; Enter (ascii CR)
	dw 1D00h, offset str_ctrl     ; Ctrl (не генерирует ascii)
	dw 1E61h, offset str_a1
	dw 1E41h, offset str_a2
	dw 1F73h, offset str_s1
	dw 1F53h, offset str_s2

	dw 2064h, offset str_d1
	dw 2044h, offset str_d2
	dw 2166h, offset str_f1
	dw 2146h, offset str_f2
	dw 2267h, offset str_g1
	dw 2247h, offset str_g2
	dw 2368h, offset str_h1
	dw 2348h, offset str_h2
	dw 246Ah, offset str_j1
	dw 244Ah, offset str_j2
	dw 256Bh, offset str_k1
	dw 254Bh, offset str_k2
	dw 266Ch, offset str_l1
	dw 264Ch, offset str_l2
	dw 273Bh, offset str_semi     ; ";"
	dw 273Ah, offset str_colon     ; :
	dw 2827h, offset str_quote     ; '
	dw 2822h, offset str_dquote    ; "
	dw 2960h, offset str_backtick  ; `
	dw 297Eh, offset str_tilde     ; ~
	dw 2A00h, offset str_lshift    ; Left Shift
	dw 2B5Ch, offset str_backslash ; "\"
	dw 2B7Ch, offset str_bar       ; |
	dw 2C7Ah, offset str_z1
	dw 2C5Ah, offset str_z2
	dw 2D78h, offset str_x1
	dw 2D58h, offset str_x2
	dw 2E63h, offset str_c1
	dw 2E43h, offset str_c2
	dw 2F76h, offset str_v1
	dw 2F56h, offset str_v2
	dw 3062h, offset str_b1
	dw 3042h, offset str_b2
	dw 316Eh, offset str_n1
	dw 314Eh, offset str_n2
	dw 326Dh, offset str_m1
	dw 324Dh, offset str_m2
	
	dw 332Ch, offset str_comma    ; ,
	dw 333Ch, offset str_lt       ; <
	dw 342Eh, offset str_dot      ; .
	dw 343Eh, offset str_gt       ; >
	dw 352Fh, offset str_slash    ; /
	dw 353Fh, offset str_question ; ?
	dw 3600h, offset str_rshift   ; Right Shift
	dw 3700h, offset str_ptscr    ; Print Screen
	dw 3800h, offset str_alt      ; Alt
	dw 3920h, offset str_space    ; Space (ascii 0x20)
	dw 3A00h, offset str_caps     ; Caps Lock
	
	dw 3B00h, offset str_f1_spec
	dw 3C00h, offset str_f2_spec
	dw 3D00h, offset str_f3
	dw 3E00h, offset str_f4
	dw 3F00h, offset str_f5
	dw 4000h, offset str_f6
	dw 4100h, offset str_f7
	dw 4200h, offset str_f8
	dw 4300h, offset str_f9
	dw 4400h, offset str_f10
	dw 4500h, offset str_numlk
	dw 4600h, offset str_scrl
	dw 4700h, offset str_home
	dw 4800h, offset str_up
	dw 4900h, offset str_pgup
	dw 4A2Dh, offset str_num_minus   ; - на numpad (ascii '-')
	dw 4B00h, offset str_num_4_left  ; 4 с выключенным NumLock
	dw 4C35h, offset str_num_5       ; 5 на numpad (ascii '5')
	dw 4D00h, offset str_num_6_right ; 6 с выключенным NumLock
	dw 4E2Bh, offset str_num_plus    ; + на numpad (ascii '+')
	dw 4F00h, offset str_num_1_end   ; 1 End
	dw 5000h, offset str_num_2_down  ; 2 Down
	dw 5100h, offset str_num_3_pgdn  ; 3 PgDn
	dw 5200h, offset str_ins		 ; Ins
	dw 5230h, offset str_num_0_ins   ; 0 Ins (ascii '0')
	dw 5300h, offset str_del		 ; Del
	; dw 5300h, offset str_num_dot_del 	 ; Del (ascii '.')
	
	
	dw 5400h, offset str_sh_f1
	dw 5500h, offset str_sh_f2
	dw 5600h, offset str_sh_f3
	dw 5700h, offset str_sh_f4
	dw 5800h, offset str_sh_f5
	dw 5900h, offset str_sh_f6
	dw 5A00h, offset str_sh_f7
	dw 5B00h, offset str_sh_f8
	dw 5C00h, offset str_sh_f9
	dw 5D00h, offset str_sh_f10
	
	dw 5E00h, offset str_ctrl_f1
	dw 5F00h, offset str_ctrl_f2
	dw 6000h, offset str_ctrl_f3
	dw 6100h, offset str_ctrl_f4
	dw 6200h, offset str_ctrl_f5
	dw 6300h, offset str_ctrl_f6
	dw 6400h, offset str_ctrl_f7
	dw 6500h, offset str_ctrl_f8
	dw 6600h, offset str_ctrl_f9
	dw 6700h, offset str_ctrl_f10
	
	dw 6800h, offset str_alt_f1
	dw 6900h, offset str_alt_f2
	dw 6A00h, offset str_alt_f3
	dw 6B00h, offset str_alt_f4
	dw 6C00h, offset str_alt_f5
	dw 6D00h, offset str_alt_f6
	dw 6E00h, offset str_alt_f7
	dw 6F00h, offset str_alt_f8
	dw 7000h, offset str_alt_f9
	dw 7100h, offset str_alt_f10
	
	dw 7200h, offset str_ctrl_ptscr
	dw 7300h, offset str_ctrl_l
	dw 7400h, offset str_ctrl_r
	dw 7500h, offset str_ctrl_end
	dw 7600h, offset str_ctrl_pgdn
	dw 7700h, offset str_ctrl_home
	
	dw 7800h, offset str_alt_1
	dw 7900h, offset str_alt_2
	dw 7A00h, offset str_alt_3
	dw 7B00h, offset str_alt_4
	dw 7C00h, offset str_alt_5
	dw 7D00h, offset str_alt_6
	dw 7E00h, offset str_alt_7
	dw 7F00h, offset str_alt_8
	dw 8000h, offset str_alt_9
	dw 8100h, offset str_alt_0
	; First 82h: Alt - (скан 82, ascii '-')
	dw 822Dh, offset str_alt_minus
	; Second 82h: Alt = (скан 82, ascii '=')
	dw 823Dh, offset str_alt_equal
	dw 8400h, offset str_ctrl_pgup
	dw 8500h, offset str_f11
	dw 8600h, offset str_f12
	dw 8700h, offset str_sh_f11
	dw 8800h, offset str_sh_f12
	dw 8900h, offset str_ctrl_f11
	dw 8A00h, offset str_ctrl_f12
	dw 8B00h, offset str_alt_f11
	; First 8Ch: Alt F12
	dw 8C00h, offset str_alt_f12
	; Second 8Ch: Ctrl Up Arrow (скан 8C, ascii 0)
	dw 8C00h, offset str_ctrl_up_arrow   ; ВНИМАНИЕ: дубликат скан-кода 8C, будет найдена первая запись (Alt F12)
	dw 8E00h, offset str_ctrl_minus_num
	dw 8F00h, offset str_ctrl_5_num
	dw 9000h, offset str_ctrl_plus_num
	dw 9100h, offset str_ctrl_dn_arrow
	dw 9200h, offset str_ctrl_ins
	dw 9300h, offset str_ctrl_del
	dw 9400h, offset str_ctrl_tab
	dw 9500h, offset str_ctrl_slash_num
	dw 9600h, offset str_ctrl_star_num
	
	dw 9700h, offset str_alt_home
	dw 9800h, offset str_alt_up
	dw 9900h, offset str_alt_pgup
	dw 9B00h, offset str_alt_left
	dw 9D00h, offset str_alt_right
	dw 9F00h, offset str_alt_end
	dw 0A000h, offset str_alt_down
	dw 0A100h, offset str_alt_pgdn
	dw 0A200h, offset str_alt_ins
	dw 0A300h, offset str_alt_del
	dw 0A400h, offset str_alt_slash_num
	dw 0A500h, offset str_alt_tab
	dw 0A600h, offset str_alt_enter_num

	dw 0, 0

data ends

code segment para public use16

assume cs:code,ss:stack,ds:data

include strings.inc
include files.inc


; void setmode(int mode)
; установка видеорежима (номер режима в младшем байте аргумента)
_setmode proc near
    push bp
    mov bp, sp
    
    mov ax, word ptr [bp + arg1]
    mov ah, 00h
    int 10h
    
    mov sp, bp
    pop bp
    ret
_setmode endp 


; byte getmode()
; получить текущий видеорежим
_getmode proc near
	push bp
	mov bp, sp

	mov ah, 0fh
	int 10h
	
	movzx ax, al

	mov sp, bp
	pop bp
	ret
_getmode endp


; void print_color_str(es:[di] dst, ds:char* str, byte color)
print_color_str proc near
	push bp
	mov bp, sp
	
	push word ptr [bp+arg2]
	call _strlen
	add sp, 2
	
	mov cx, ax
	mov di, word ptr [bp+arg1]
	mov bx, word ptr [bp+arg2]
	xor dx, dx
	mov dx, word ptr [bp+arg3]
	mov ah, dl
	cycle_1:
		mov al, byte ptr [bx]
		stosw
		inc bx
		loop cycle_1

	mov sp, bp
	pop bp
	ret
print_color_str endp


; word getKey()
getKey proc
	push bp
	mov bp, sp
	
	mov ah, 0
	int 16h
	; возвращает в ax атрибуты нажатой клавиши:
		; в ah  скан-код
		; в al  аски код клавиши (у некоторых служебных клавиш \ комбинации клавиш нет аски кода, тогда al = 0)
	
	mov sp, bp
	pop bp
	ret
getKey endp


; void drawBackground(byte color)
drawBackground proc
	push bp
	mov bp, sp
	pusha 
	pushf
	push es

	mov ax, 0B800h
	mov es, ax
	
	xor ax, ax
	mov ah, byte ptr [bp+arg1]
	shl ah, 4
	
	cld
	xor di, di
	mov cx, 80*25
	rep stosw	; повторить CX раз :
				; 	mov word ptr es:[di], ax
				;   add di, 2
	
	pop es
	popf
	popa
	mov sp, bp
	pop bp
	ret
drawBackground endp


; void drawFrame()
; drawing frame
; WIN_LEFT eq 	15
; WIN_TOP eq 	5
; WIN_WIDTH eq	50
; WIN_HEIGHT eq	15
drawFrame proc
	push bp
	mov bp, sp
	push es
	pusha
	
	mov ax, 0B800h
	mov es, ax
	mov di, 0
	
	add di, 80*10							; 80 * WIN_TOP * 2 bytes
	add di, 14*2							; (WIN_HEIGHT - 1) * 2 bytes
	
	mov ah, 0F0h
	mov al, 0C9h							; top-left frame angle
	stosw
	
	mov cx, WIN_WIDTH
	mov al, 0C4h
.loop1_drawFrame:
	stosw
	loop .loop1_drawFrame

	mov al, 0BBh							; top-right frame angle
	stosw
	
	mov al, 0B3h
	mov cx, WIN_HEIGHT
.loop2_drawFrame:
	add di, 28*2							; (WIN_LEFT * 2 - 1) * 2 bytes
	stosw
	add di, 50*2							; WIN_WIDTH * 2 bytes
	stosw
	loop .loop2_drawFrame
	
	add di, 28*2
	mov al, 0C8h
	stosw									; bottom-right angle
	
	mov cx, WIN_WIDTH
	mov al, 0C4h
.loop3_drawFrame:
	stosw
	loop .loop3_drawFrame
	
	mov al, 0BCh							; bottom-left angle
	stosw
	
	popa
	pop es
	mov sp, bp
	pop bp
	ret
drawFrame endp


; void clearScreen(byte backGroundColor)
clearScreen proc
	push bp
	mov bp, sp
	push es
	pusha

	mov ax, 0B800h
	mov es, ax
	
	mov bx, 0
	mov cx, 80*25
	mov ax, 0
	mov ah, byte ptr[bp + arg1]
	
.loop_clearScreen:
	mov ah, 0F0h
	mov word ptr es:[bx], ax
	add bx, 2
	
	loop .loop_clearScreen
	
	popa
	pop es
	mov sp, bp
	pop bp
	ret
clearScreen endp


; void clearLog(char* es:offset first_string)
clearLog proc
	push bp
	mov bp, sp
	pusha
	push es
	
	mov ax, 0B800h
	mov es, ax
	
	mov di, word ptr[bp + arg1]				; startlog
	mov ax, 0FF20h
	mov cx, WIN_HEIGHT
.loop1_clearLog:
	push cx
	mov cx, WIN_WIDTH
.loop2_clearLog:
	stosw
	loop .loop2_clearLog
	
	pop cx
	add di, 30*2
	
	loop .loop1_clearLog

.end_clearLog:
	pop es
	popa	
	mov sp, bp
	pop bp
	ret
clearLog endp


; int searchKey(int key(scan_code:ascii_code))
; return offset string for key
searchKey proc
	push bp
	mov bp, sp
	
	push bx
	push dx
	push es
	
	mov bx, offset scan_table
	mov ax, word ptr[bp + arg1]
.next_searchKey:
	mov dx, word ptr[bx]			; indicator of current key
	cmp word ptr[bx], ax
	je .found_searchKey
	cmp word ptr[bx], 0
	je .notfound_searchKey
	
	add bx, 4
	jmp .next_searchKey
	
.found_searchKey:
	mov ax, word ptr[bx+2]
	jmp .end_searchKey

.notfound_searchKey:
	mov ax, 0
	
.end_searchKey:
	pop es
	pop dx
	pop bx
	
	mov sp, bp
	pop bp
	ret
searchkey endp


; void scrollLog(char* offset first_string)
scrollLog proc
	push bp
	mov bp, sp
	pusha
	push es
	push ds
	
	mov ax, 0B800h
	mov es, ax
	mov ds, ax
	
	mov di, word ptr[bp + arg1]				; str1
	mov si, di								; str2
	add si, 80*2
	
	mov cx, 14								; WIN_HEIGHT - 1
.loop1_scrollLog:
	push cx
	mov cx, WIN_WIDTH
.loop2_scrollLog:
	movsw
	loop .loop2_scrollLog
	
	pop cx
	add di, 30*2
	add si, 30*2
	loop .loop1_scrollLog
	
	mov di, 160*14
	add di, word ptr[bp + arg1]
	
	mov cx, WIN_WIDTH
	mov ax, 0FF20h
.loop3_scrollLog:
	stosw
	loop .loop3_scrollLog
	
	pop ds
	pop es
	popa
	mov sp, bp
	pop bp
	ret
scrollLog endp


; void saveLogToBuff(char* offset first_string)
saveLogToBuff proc
	push bp
	mov bp, sp
	pusha
	push es
	push ds
	
	mov ax, 0B800h
	mov es, ax
	mov ax, data
	mov ds, ax
	
	mov si, word ptr[bp + arg1]
	mov di, offset log_buff
	
	mov cx, WIN_HEIGHT
.loop1_saveLogToBuff:
	push cx
	mov cx, WIN_WIDTH
.loop2_saveLogToBuff:
	mov al, byte ptr es:[si]
	mov byte ptr[di], al
	add si, 2
	inc di

	loop .loop2_saveLogToBuff

	add si, 30*2
	pop cx

	loop .loop1_saveLogToBuff
	
	pop ds
	pop es
	popa
	mov sp, bp
	pop bp
	ret
saveLogToBuff endp


; void writeLogToFile()
writeLogToFile proc
	push bp
	mov bp, sp
	pusha
	push ds
	
	mov ax, data
	mov ds, ax
	
	; int fwrite(file_desc f, int size, char *buf)
	mov si, offset log_buff
 	mov cx, WIN_HEIGHT
;	mov cx, 2
.loop_writeLogToFile:
	push cx
	
	push si
	push WIN_WIDTH
	push word ptr[filehandle]
	call _fwrite
	add sp, 6
	
	push offset crlf
	push 2
	push word ptr[filehandle]
	call _fwrite
	add sp, 6
	
	add si, WIN_WIDTH
	pop cx
	
	loop .loop_writeLogToFile

	push offset crlf
	push 2
	push word ptr[filehandle]
	call _fwrite
	add sp, 6
	
	pop ds
	popa
	mov sp, bp
	pop bp
	ret
writeLogToFile endp


; void drawFrame_enterFilename
drawFrame_enterFilename proc
	push bp
	mov bp, sp
	pusha
	push es
	
	mov ax, 0B800h
	mov es, ax
	
	mov di, 0
	
	add di, 80*6							; 80 * (WIN_TOP - 2) * 2 bytes
	add di, 14*2							; (WIN_LEFT - 1) * 2 bytes
	
	mov ah, 0F0h
	mov al, 0C9h							; top-left frame angle
	stosw
	
	mov cx, WIN_WIDTH
	mov al, 0C4h
.loop1_drawFrame_enterFilename:
	stosw
	loop .loop1_drawFrame_enterFilename

	mov al, 0BBh							; top-right frame angle
	stosw
	
	mov al, 0B3h
	mov cx, 1
.loop2_drawFrame_enterFilename:
	add di, 28*2							; (WIN_LEFT * 2 - 1) * 2 bytes
	stosw
	add di, 50*2							; WIN_WIDTH * 2 bytes
	stosw
	loop .loop2_drawFrame_enterFilename
	
	add di, 28*2
	mov al, 0C8h
	stosw									; bottom-left angle
	
	mov cx, WIN_WIDTH
	mov al, 0C4h
.loop3_drawFrame_enterFilename:
	stosw
	loop .loop3_drawFrame_enterFilename
	
	mov al, 0BCh							; bottom-right angle
	stosw

	pop es
	popa
	mov sp, bp
	pop bp
	ret
drawFrame_enterFilename endp


; void getFilename()
getFilename proc
	push bp
	mov bp, sp
	pusha
	push es
	push ds
	
	mov ax, 0B800h
	mov es, ax
	mov ax, data
	mov ds, ax
	
	mov di, 0
	
	add di, 80*8							; 80 * (WIN_TOP - 1) * 2 bytes
	add di, 15*2							; WIN_LEFT * 2 bytes
	mov bx, offset filename
.loop_getFilename:
	call getKey
	; в ah  scan code
	; в al  ascii code (у некоторых служебных клавиш \ комбинации клавиш нет аски кода, тогда al = 0)	
	cmp ax, 1C0Dh							; if 1C0Dh => finish of writing
	je .finish_getFilename
	
	cmp al, 0
	je .err_getFilename
	
	mov ah, 0F0h
	stosw
	mov byte ptr[bx], al
	inc bx

	jmp .loop_getFilename

.finish_getFilename:
	mov byte ptr[bx], 0
	jmp .end_getFilename
	
.err_getFilename:
	stc
	
.end_getFilename:
	pop ds
	pop es
	popa
	mov sp, bp
	pop bp
	ret
getFilename endp


; void 	drawErr_openFile()
drawErr_openFile proc
	push bp
	mov bp, sp
	pusha
	push es
	push ds
	
	mov ax, 0B800h
	mov es, ax
	mov ax, data
	mov ds, ax
	
	mov di, 0
	
	add di, 80*8							; 80 * (WIN_TOP - 1) * 2 bytes
	add di, 15*2							; WIN_LEFT * 2 bytes
	
	; void print_color_str(es:[di] dst, ds:char* str, byte color)
	push 0F4h
	push offset Err_openFile
	push di
	call print_color_str
	add sp, 6

	pop ds
	pop es
	popa
	mov sp, bp
	pop bp
	ret
drawErr_openFile endp


; void 	drawErr_openFile()
drawErr_closeFile proc
	push bp
	mov bp, sp
	pusha
	push es
	push ds
	
	mov ax, 0B800h
	mov es, ax
	mov ax, data
	mov ds, ax
	
	mov di, 0
	
	add di, 80*8							; 80 * (WIN_TOP - 1) * 2 bytes
	add di, 15*2							; WIN_LEFT * 2 bytes
	
	; void print_color_str(es:[di] dst, ds:char* str, byte color)
	push 0F4h
	push offset Err_closeFile
	push di
	call print_color_str
	add sp, 6

	pop ds
	pop es
	popa
	mov sp, bp
	pop bp
	ret
drawErr_closeFile endp


; void 	drawErr_openFile()
drawErr_wrongsymb proc
	push bp
	mov bp, sp
	pusha
	push es
	push ds
	
	mov ax, 0B800h
	mov es, ax
	mov ax, data
	mov ds, ax
	
	mov di, 0
	
	add di, 80*8							; 80 * (WIN_TOP - 1) * 2 bytes
	add di, 15*2							; WIN_LEFT * 2 bytes
	
	; void print_color_str(es:[di] dst, ds:char* str, byte color)
	push 0F4h
	push offset Err_wrongsymb
	push di
	call print_color_str
	add sp, 6

	pop ds
	pop es
	popa
	mov sp, bp
	pop bp
	ret
drawErr_wrongsymb endp


; void drawButtons()
drawButtons proc
	push bp
	mov bp, sp
	pusha
	push es
	push ds
	
	mov ax, 0B800h
	mov es, ax
	mov ax, data
	mov ds, ax
	
	mov di, 160*5
	add di, 6*2
	
; save button
	mov ah, 0F0h
	mov al, 0C9h							; top-left frame angle
	stosw
	
	mov cx, 6
	mov al, 0C4h
.loop1_drawButtons:
	stosw
	loop .loop1_drawButtons

	mov al, 0BBh							; top-right frame angle
	stosw
	
	mov al, 0B3h
	add di, 72*2							; (WIN_LEFT * 2 - 1) * 2 bytes
	stosw
	
	add di, 2
	push 0F2h
	push offset button_save
	push di
	call print_color_str
	add sp, 6

	mov ah, 0F0h
	add di, 2
	mov al, 0B3h
	stosw
	
	add di, 72*2
	mov al, 0C8h
	stosw									; bottom-left angle
	
	mov cx, 6
	mov al, 0C4h
.loop2_drawButtons:
	stosw
	loop .loop2_drawButtons
	
	mov al, 0BCh							; bottom-right angle
	stosw

;delete button
	add di, 72*2
	mov ah, 0F0h
	mov al, 0C9h							; top-left frame angle
	stosw
	
	mov cx, 6
	mov al, 0C4h
.loop3_drawButtons:
	stosw
	loop .loop3_drawButtons

	mov al, 0BBh							; top-right frame angle
	stosw
	
	mov al, 0B3h
	add di, 72*2							; (WIN_LEFT * 2 - 1) * 2 bytes
	stosw
	
	push 0F4h
	push offset button_del
	push di
	call print_color_str
	add sp, 6

	mov ah, 0F0h
	mov al, 0B3h
	stosw
	
	add di, 72*2
	mov al, 0C8h
	stosw									; bottom-left angle
	
	mov cx, 6
	mov al, 0C4h
.loop4_drawButtons:
	stosw
	loop .loop4_drawButtons
	
	mov al, 0BCh							; bottom-right angle
	stosw

	pop ds
	pop es
	popa
	mov sp, bp
	pop bp
	ret
drawButtons endp


; void mainLoop()
mainLoop proc
	push bp
	pusha
	push es
	mov bp, sp
	
	sub sp, 8*2
	once_esc equ var1
	len_string equ var2
	level_log equ var3
	offset_cur_string equ var4
	start_cur_level equ var5
	start_log equ var6
	
	; mov word ptr[bp + comma], offset str_comma
	mov word ptr[bp + once_esc], 0
	mov word ptr[bp + len_string], 0
	mov word ptr[bp + level_log], 0
	
	mov ax, 0B800h
	mov es, ax
	
.start_mainLoop:
	mov di, 0
	add di, 80*12							; 80 * ((WIN_TOP + 1) * 2)
	add di, 15*2							; WIN_LEFT - 1
	
	mov word ptr[bp + start_cur_level], di
	mov word ptr[bp + start_log], di
	
	push word ptr[bp + start_log]
	call clearLog
	add sp, 2

.loop1:
	call getKey
	; в ah  scan code
	; в al  ascii code (у некоторых служебных клавиш \ комбинации клавиш нет аски кода, тогда al = 0)
	
	cmp ax, 011Bh							; if 011Bh (esc) pressed twice => exit
	jne .not_esc_loop1

	cmp word ptr[bp + once_esc], 1
	je .end_mainLoop
	
	mov word ptr[bp + once_esc], 1
	jmp .continue2_loop1
	
.not_esc_loop1:
	mov word ptr[bp + once_esc], 0
	
	cmp ax, 5300h							; if 5300h (del) pressed once => clear window (log)
	jne .continue1_loop1
	
	push word ptr[bp + start_log]
	call clearLog
	add sp, 2
	
	mov di, word ptr[bp + start_log]
	mov word ptr[bp + start_cur_level], di
	mov word ptr[bp + len_string], 0
	mov word ptr[bp + level_log], 0
	jmp .loop1
	
.continue1_loop1:
	cmp ax, 5200h							; if 5230h (ins) pressed once => seve log to buffer
	jne .continue2_loop1
	
	push word ptr[bp + start_log]
	call saveLogToBuff
	add sp, 2
	
	call writeLogToFile
	
	jmp .loop1
	
.continue2_loop1:
	push ax
	call searchKey 							; ax - offset string for key
	add sp, 2
	mov word ptr[bp + offset_cur_string], ax
	
	push ax
	call _strlen							; ax - strlen for cur_string
	add sp, 2
	
	add word ptr[bp + len_string], ax			; cur string
	inc word ptr[bp + len_string]				; + comma
	
	cmp word ptr[bp + len_string], WIN_WIDTH	; WIN_WIDTH == 50
	jbe .main_print_loop1
	
	mov word ptr[bp + len_string], 0
	push word ptr[bp + offset_cur_string]
	call _strlen
	add sp, 2
	
	add word ptr[bp + len_string], ax
	inc word ptr[bp + len_string]
	
	inc word ptr[bp + level_log]
	add word ptr[bp + start_cur_level], 80*2
	mov di, word ptr[bp + start_cur_level]
	
	cmp word ptr[bp + level_log], WIN_HEIGHT
	jb .main_print_loop1
	
	push word ptr[bp + start_log]
	call scrollLog
	add sp, 2
	
	dec word ptr[bp + level_log]
	sub word ptr[bp + start_cur_level], 80*2
	mov di, word ptr[bp + start_cur_level]
	
.main_print_loop1:
	push 0F0h
	push word ptr[bp + offset_cur_string]
	push di
	call print_color_str
	add sp, 6
	
	push 0F0h
	push offset str_comma
	push di
	call print_color_str
	add sp, 6
	
	jmp .loop1

.end_mainLoop:
	mov sp, bp	
	pop es
	popa
	pop bp
	ret
mainLoop endp


start:
    mov ax, data
    mov ds, ax
    mov ax, stack
    mov ss, ax
    nop
	
	call _getmode
	mov [save_mode], al
	
    mov dx, 3     ; текст 80х25 символов
    push dx
    call _setmode
    add sp, 2
    
	mov dx, 0Fh
	push dx
	call drawBackground						; fill background
	add sp, 2

	call drawFrame_enterFilename			; draw frame for fileInput	
	call getFilename						; get filename
	jc exit3
	
	call clearScreen
	
	push 2									; clear and write file
	push offset filename
	call _fopen								; open file
	add sp, 4
	
	cmp ax, -1
	je exit1
	mov word ptr[filehandle], ax
	
	call drawFrame							; draw frame
	
	call drawButtons						; draw buttons (clear, save)

;	call getKey							; for tests
	
	call mainLoop							; main logging
	
	call clearScreen						; clear screen
	
	push word ptr[filehandle]
	call _fclose							; close file
	add sp, 2
	
	cmp ax, -1
	je exit2
	
	jmp exit								; => exit
	
exit1:
	call clearScreen
	call drawFrame_enterFilename
	call drawErr_openFile
	call getKey
	jmp exit
	
exit2:
	call clearScreen
	call drawFrame_enterFilename
	call drawErr_closeFile
	call getKey
	jmp exit
	
exit3:
	call clearScreen
	call drawFrame_enterFilename
	call drawErr_wrongsymb
	call getKey
	
exit:
	; Возвращаем изначальный видеорежим
    movzx dx, byte ptr [save_mode]
    push dx
    call _setmode
    add sp, 2

    call _exit0
code ends

end start

    ; mov al, '-'    ; на каждый символ - 2 байта, младший байт - код символа
    ; mov ah, 0E4h   ; страший байт - цвет фона/текста: старшие 4 бита - цвет фона, младшие 4 бита - цвет текста
    
    ; mov word ptr es:[bx], ax 
    ; mov word ptr es:[bx+2], ax   ; символ в следующей позиции
    ; mov word ptr es:[bx+160], ax ; символ в начале следующей строки
