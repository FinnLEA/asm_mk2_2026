; Функции для файлового ввода-вывода (используется соглашение cdecl)

; file_desc fopen(const str *filename, int mode)
; функция открытия файла (режим открытия в младшем байте второго аргумента)
; возвращает -1, если произошла ошибка, иначе возвращает дескриптор файла
_fopen proc near
    push bp
    mov bp, sp
    
    mov ax, word ptr [bp + 6]
    mov ah, 3dh
    mov dx, word ptr [bp + 4]
    int 21h
    
    jnc fopenret
    mov ax, -1

fopenret:    
    mov sp, bp
    pop bp
    ret
_fopen endp

; int fclose(file_desc f)
; функция закрытия файла
; возвращает -1, если произошла ошибка, иначе возвращает 0
_fclose proc near
    push bp
    mov bp, sp
    
    mov ah, 3eh
    mov bx, word ptr [bp + 4]
    int 21h
    
    jnc fcloseret0
    mov ax, -1
    jmp fcloseret
    
fcloseret0: 
    mov ax, 0

fcloseret:    
    mov sp, bp
    pop bp
    ret
_fclose endp

; int fread(file_desc f, int size, char *buf)
; функция чтения из фалйа
; возвращает число прочитанных байт, в случае ошибки возвращает -1
_fread proc near
    push bp
    mov bp, sp

    push bx
    push cx
    push dx
    
    mov ah, 3fh
    mov bx, word ptr [bp + 4]
    mov cx, word ptr [bp + 6]
    mov dx, word ptr [bp + 8]
    int 21h
    
    jnc freadret
    mov ax, -1

freadret: 
    pop dx
    pop cx
    pop bx    
    mov sp, bp
    pop bp
    ret
_fread endp

; int fwrite(file_desc f, int size, char *buf)
; функция записи в файл
; возвращает число записаных байт, в случае ошибки возвращает -1
_fwrite proc near
    push bp
    mov bp, sp
    push bx
    push cx
    push dx
    
    mov ah, 40h
    mov bx, word ptr [bp + 4]
    mov cx, word ptr [bp + 6]
    mov dx, word ptr [bp + 8]
    int 21h
    
    jnc fwriteret
    mov ax, -1

fwriteret:   
    pop dx
    pop cx
    pop bx 
    mov sp, bp
    pop bp
    ret
_fwrite endp



; DWORD get_filesize(int fd)
; function for reading the file size in DX:AX
; returns the size in bytes, returns -1 in case of an error
_get_filesize proc near
    push bp
    mov bp, sp
    push bx 

    ; move the pointer to the end of the file ----
    mov ah, 42h
    mov al, 2        		; end of file
    mov bx, [bp + arg1]   	; fd
    xor cx, cx
    xor dx, dx
    int 21h
    jc  gfs_error1          ; if the first call fails

    ; res DX:AX
    push dx
    push ax

    ; returned the pointer to the beginning of the file ----
    mov ah, 42h
    mov al, 0       		 ; start of file
    mov bx, [bp + arg1]
    xor cx, cx
    xor dx, dx
    int 21h
    jc  gfs_error2          ; if the second call fails

    ; successful: restore size in DX:AX ----
    pop ax
    pop dx
    jmp gfs_exit

gfs_error2:
    pop ax
    pop dx
gfs_error1:
    mov ax, 0FFFFh
    mov dx, 0FFFFh    ; -1
gfs_exit:
    pop bx
    mov sp, bp
    pop bp
    ret
_get_filesize endp