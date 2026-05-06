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
    
    mov ah, 3fh
    mov bx, word ptr [bp + 4]
    mov cx, word ptr [bp + 6]
    mov dx, word ptr [bp + 8]
    int 21h
    
    jnc freadret
    mov ax, -1

freadret:    
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
    
    mov ah, 40h
    mov bx, word ptr [bp + 4]
    mov cx, word ptr [bp + 6]
    mov dx, word ptr [bp + 8]
    int 21h
    
    jnc fwriteret
    mov ax, -1

fwriteret:    
    mov sp, bp
    pop bp
    ret
_fwrite endp