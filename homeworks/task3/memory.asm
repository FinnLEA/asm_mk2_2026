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

; макрос для сохранения регистров, указанных в качестве агрументов
; доступно передать до 10-ти регистров (7 общего назначения и 3 сегментных)
pushregs macro reg1, reg2, reg3, reg4, reg5, reg6, reg7, reg8, reg9, reg10
	ifnb <reg1>
		push reg1
		pushregs reg2, reg3, reg4, reg5, reg6, reg7, reg8, reg9, reg10
	endif
endm

; макрос для восстановления регистров из стека
popregs macro reg1, reg2, reg3, reg4, reg5, reg6, reg7, reg8, reg9, reg10
	ifnb <reg1>
		pop reg1
		popregs reg2, reg3, reg4, reg5, reg6, reg7, reg8, reg9, reg10
	endif
endm

stack segment para stack
db 65530 dup (?)
stack ends 

data segment para public
	allocate_size dw 12
	s1_addr	dw ?
	new_line db 13, 10, "$"
data ends

code segment para public use16

assume cs:code,ds:data,ss:stack,es:data

start:
	; инициализация сегментных регистров
	mov ax, data
    mov ds, ax
	;mov es, ax
    mov ax, stack
    mov ss, ax
	nop
		
	; "Инициализация" динамически резервируемой памяти
	; push offset end_code_seg
	; push cs
	; push es
	; call InitMem
	; add sp, 6
	
	; call test_
	; jmp exit_success	
	
	mov ax, data
	mov es, ax
	
	push word ptr [allocate_size]
	call AllocMem
	add sp, 2
	
	test ax, ax
	jz exit_err
	mov word ptr es:[s1_addr], ax

; new allocate segment offsets
s1_max_len 	equ 00h	; db
s1_len		equ 01h	; db
s1_str		equ	02h	; ...

; устройство нового выделенного блока
;+--------------------+ ------
;| s1_max_len |1 byte | + 00h  \
;+--------------------+		    |
;| s1_len     |1 byte | + 01h   |-> новый выделенный блок
;+--------------------+			|
;| s1_str 	  |  ...  | + 02h  /
;+--------------------+ ------
	
	; считываем с консоли строку с помощью функции 0Ah
	mov ds, word ptr es:[s1_addr]
	mov bx, s1_max_len
	mov cl, byte ptr es:[allocate_size]
	sub cl, 2
	mov	byte ptr ds:[bx], cl
	mov dx, s1_max_len
	mov ah, 0ah
	int 21h
	
	; вывод "\r\n" с помощью функции 09h
	push ds		; сохранили в стек текущее значение ds (адресс выделенной памяти)
	mov ax, es	; записали в ds адресс сегмента data (из регистра es)
	mov ds, ax
	mov dx, offset new_line
	mov ah, 09h
	int 21h
	pop ds		; забрали ds из стека
	
	; вывод считанной строки с помощью функции 09h
	mov bx, s1_str
	movzx si, byte ptr ds:[s1_len]
	mov byte ptr ds:[bx + si], '$'
	mov dx, bx
	mov ah, 09h
	int 21h
	
	; пример расширения выделенной области
	push 32
	push word ptr es:[s1_addr]
	call ReallocMem
	add sp, 4
	
	mov word ptr ds:[18h], 4141h
		
free:
	mov ax, word ptr es:[s1_addr]
	push ax
	call FreeMem
	add sp, 2
	mov ax, es
	mov ds, ax
	; ...

	
	jmp exit_success

exit_err:
	mov al, -1
	jmp exit
exit_success:
	mov al, 0
exit:	
	mov ah, 4ch
	int 21h



test_ proc near
; Некоторые константы для удобства именовывания локальных переменных
	Block1 equ var1
	Block2 equ var2
	Block3 equ var3
	_test_localSize equ 5*2
	
	push bp
	mov bp, sp
	sub sp, _test_localSize
	pushregs di, si, ds, es
	
	; последовательное выделение блоков памяти
	push 1*16
	call AllocMem
	add sp, 2
	mov [bp+Block1], ax
	
	push 2*16
	call AllocMem
	add sp, 2
	mov [bp+Block2], ax
	
	push 2*16
	call AllocMem
	add sp, 2
	mov [bp+Block3], ax
	
		; пробуем сделать realloc первого блока
	push 2*16
	push [bp+Block1]
	call ReallocMem
	add sp, 4
	
	push [bp+Block1]
	call FreeMem
	add sp, 2
	
	push [bp+Block2]
	call FreeMem
	add sp, 2
	
	push [bp+Block3]
	call FreeMem
	add sp, 2
	
	; тест realloc на свободных блоках
	; push 100*16
	; call AllocMem
	; add sp, 2
	; mov [bp+Block1], ax
	
	; push 105*16
	; push [bp+Block1]
	; call ReallocMem
	; add sp, 4
	
	; push [bp+Block1]
	; call FreeMem
	; add sp, 2
	
	popregs es, ds, si, di
	add sp, _test_localSize
	mov sp, bp
	pop bp
	ret
test_ endp

; bool InitMem(void* segProgramStartAddress, void* lastSegAddr, void* offsetProgramEnd);
InitMem proc near 
	push bp
	mov bp, sp
	push es
	
	; смещение внутри сегмента переводим в количество параграфов
	; выравниваем смещение по границе параграфа
	mov bx, 0fff0h	; маска для выравнивания
	mov ax, [bp+arg3]
	add ax, 0fh		; граница выравнивания
	and bx, ax
	; байты в параграфы (bytes / 16)
	shr bx, 4
	
	; переводим смещение внутри сегмента(в параграфах) в сегментный адрес
	; адресСегмента + количествоПараграфов = новыйСегментныйАдрес
	mov ax, [bp+arg2]
	add bx, ax
	; segProgStart - segProgEnd
	mov ax, [bp+arg1]
	sub bx, ax
	mov ah, 4ah
	int 21h
	jnc _IM_success
	; handle error
	_IM_fail:
	xor ax, ax
	jmp _IM_exit
	
	_IM_success:
	mov ax, 1
	_IM_exit:
	pop es
	mov sp, bp
	pop bp
	ret
InitMem endp

; void* AllocMem(unsigned word sizeInBytes) -> сегментный адрес выделенного блока;
AllocMem proc near	
	_AllocMem_localSize equ 1*2
	push bp
	mov bp, sp
	sub sp, _AllocMem_localSize
	
	; DWORD AlignToTopByPara (DWORD value) {
		; DWORD mask = ~ (16 - 1);
		; return (value + 16 - 1) & mask;
	; }
	; выравнивание вверх по границе параграфа
	mov bx, 0fff0h	; маска для выравнивания
	mov ax, [bp+arg1]
	add ax, 0fh		; граница выравнивания
	and bx, ax
	; байты в параграфы (bytes / 16)
	shr bx, 4
	mov [bp+var1], bx
	
	mov bx, 0FFFFh
	mov ah, 48h
	int 21h
	cmp bx, [bp+var1]
	jb _AM_fail
	
	mov ah, 48h
	mov bx, [bp+var1]
	int 21h
	jnc _AM_exit
	
	; handle error

	_AM_fail:
	mov ax, 0
	_AM_exit:
	add sp, _AllocMem_localSize
	mov sp, bp
	pop bp
	ret
AllocMem endp

; void FreeMem(void* segAddr)
FreeMem proc near
	push bp
	mov bp, sp
	push es
	
	mov es, [bp+arg1]
	mov ah, 49h
	int 21h
	jnc _FM_exit

	; handle error
	
	_FM_exit:
	pop es
	mov sp, bp
	pop bp
	ret
FreeMem endp

; word ReallocMem(void* pointer, unsigned word newSizeInBytes)
ReallocMem proc near
	_ReallocMem_localSize equ 1*2
	push bp
	mov bp, sp
	sub sp, _ReallocMem_localSize
	push es
	
	; выравнивание вверх по границе параграфа
	mov bx, 0fff0h
	mov ax, [bp+arg2]
	add ax, 0fh
	and bx, ax
	; байты в параграфы (bytes / 16)
	shr bx, 4
	
	mov [bp+var1], bx
	mov es, [bp+arg1]
	mov ah, 4ah
	int 21h
	jnc _RM_exit
	
	; handle
	
	_RM_exit:
	pop es
	add sp, _ReallocMem_localSize
	mov sp, bp
	pop bp
	ret
ReallocMem endp
	
end_code_seg:
code ends

end start
