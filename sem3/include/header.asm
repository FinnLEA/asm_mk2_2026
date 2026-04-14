.386

arg1 equ 4
arg2 equ 6
arg3 equ 8
arg4 equ 10
arg5 equ 12

var1 equ -2
var2 equ -4
var3 equ -6
var4 equ -8
var5 equ -10

SSEG segment para stack use16 "STACK"
	db 8192 dup(0)
SSEG ends

pushr macro reg1, reg2, reg3, reg4, reg5, reg6, reg7, reg8, reg9, reg10
	ifnb <reg1>
		push reg1
		pushr reg2, reg3, reg4, reg5, reg6, reg7, reg8, reg9, reg10
	endif
endm

popr macro reg1, reg2, reg3, reg4, reg5, reg6, reg7, reg8, reg9, reg10
	ifnb <reg1>
		pop reg1
		popr reg2, reg3, reg4, reg5, reg6, reg7, reg8, reg9, reg10
	endif
endm

init macro
	mov ax, DSEG
	mov ds, ax
	mov ax, SSEG
	mov ss, ax

	push offset code_end
	push cs
	push es
	call mem_init
	add sp, 6

	mov ax, DSEG
	mov es, ax
endm
