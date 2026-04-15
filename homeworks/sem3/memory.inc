
; bool InitMem(void* segProgramStartAddress, void* lastSegAddr, void* offsetProgramEnd)
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


; ------------------------------------------------------------
; void* AllocMem(unsigned word sizeInBytes)
; выделяет блок памяти размером sizeInBytes байт.
; возвращает сегментный адрес блока или 0 при ошибке.
; ------------------------------------------------------------
AllocMem proc near
    _AllocMem_localSize equ 2
    push bp
    mov bp, sp
    sub sp, _AllocMem_localSize

    ; Выравнивание размера до границы параграфа (16 байт)
    mov ax, [bp+arg1]   ; размер в байтах
    add ax, 15
    mov bx, 0FFF0h
    and bx, ax          ; bx = (size+15) & 0xFFF0
    shr bx, 4           ; перевод в параграфы
    mov [bp+var1], bx   ; сохранили количество параграфов

    ; Проверяем, достаточно ли памяти
    mov ah, 48h
    mov bx, 0FFFFh
    int 21h
    ; bx теперь содержит максимальное доступное число параграфов
    cmp bx, [bp+var1]
    jb _AM_fail         ; недостаточно памяти

    ; Реально выделяем память
    mov ah, 48h
    mov bx, [bp+var1]
    int 21h
    jnc _AM_exit        ; успех, ax = сегмент

_AM_fail:
    xor ax, ax          ; возвращаем 0 при ошибке
_AM_exit:
    add sp, _AllocMem_localSize
    mov sp, bp
    pop bp
    ret
AllocMem endp

; ------------------------------------------------------------
; void FreeMem(void* segAddr)
; освобождает блок памяти по сегментному адресу segAddr.
FreeMem proc near
    push bp
    mov bp, sp
    push es

    mov ax, [bp+arg1]
    test ax, ax
    jz _FM_exit         ; если передан 0, ничего не делаем

    mov es, ax
    mov ah, 49h
    int 21h
    ; результат не проверяем (можно добавить обработку ошибок при желании)

_FM_exit:
    pop es
    mov sp, bp
    pop bp
    ret
FreeMem endp

; ------------------------------------------------------------
; void* ReallocMem(void* segAddr, unsigned word newSizeInBytes)
; изменяет размер блока по адресу segAddr до newSizeInBytes байт.
; возвращает сегментный адрес блока (обычно тот же) или 0 при ошибке.
ReallocMem proc near
    push bp
    mov bp, sp
    push es

    mov ax, [bp+arg1]   ; старый сегмент
    test ax, ax
    jz _RM_fail         ; если NULL, ошибка

    ; Выравнивание размера до границы параграфа
    mov ax, [bp+arg2]   ; новый размер в байтах
    add ax, 15
    mov bx, 0FFF0h
    and bx, ax
    shr bx, 4           ; bx = параграфы

    mov es, [bp+arg1]
    mov ah, 4Ah
    int 21h
    jnc _RM_success

_RM_fail:
    xor ax, ax          ; возвращаем 0 при ошибке
    jmp _RM_exit
_RM_success:
    mov ax, es          ; возвращаем сегмент блока
_RM_exit:
    pop es
    mov sp, bp
    pop bp
    ret
ReallocMem endp
