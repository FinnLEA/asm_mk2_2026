; Функции для ввода-вывода строк/символов (используется соглашение cdecl)
.386                            ; разрешаем инструкции 386 процессора

; Константы для режимов доступа к файлам
ACCESS_READ     EQU 0           ; только чтение

; Константы для позиционирования в файле
SEEK_START equ 0                ; от начала файла
SEEK_CURRENT_POS equ 1          ; от текущей позиции
SEEK_END equ 2                  ; от конца файла

; Смещения аргументов в стеке при вызове процедур
arg1 equ 4                      ; первый аргумент
arg2 equ 6                      ; второй аргумент
arg3 equ 8                      ; третий аргумент
arg4 equ 10                     ; четвёртый аргумент
arg5 equ 12                     ; пятый аргумент
arg6 equ 14                     ; шестой аргумент

; Смещения локальных переменных в стеке
var1 equ -2                     ; первая локальная переменная
var2 equ -4                     ; вторая локальная переменная
var3 equ -6                     ; третья локальная переменная
var4 equ -8                     ; четвёртая локальная переменная
var5 equ -10                    ; пятая локальная переменная
var6 equ -12                    ; шестая локальная переменная

; Константы для предельных значений типа short
SHRT_MAX equ 32767              ; максимальное значение short
SHRT_MIN equ -32768             ; минимальное значение short

; Сегмент стека
stack segment para stack use16
db 65530 dup(?)                 ; резервируем ~64Кб для стека
stack ends

; Сегмент данных
data segment para public use16

    ; Коды ошибок для внутреннего использования
    ERROR_ALLOC equ 0           ; ошибка выделения памяти
    ERROR_OPEN equ 1            ; ошибка открытия файла
    ERROR_LSEEK equ 2           ; ошибка позиционирования в файле

    ; Сообщения об ошибках
    err_alloc db "failed to allocate memory", 0dh, 0ah, 0
    err_open db "failed to open file", 0dh, 0ah, 0
    err_lseek db "failed to lseek file", 0dh, 0ah, 0
    err_vec dw offset err_alloc, offset err_open, offset err_lseek  ; вектор ошибок

    ; Сообщения об ошибках DOS (для файловых операций)
    fio_err_no_error        db " ", 0                                    ; нет ошибки
    fio_err_invalid_func    db "The specified function is not supported", 0dh, 0ah, 0
    fio_err_not_found       db "The requested file could not be located", 0dh, 0ah, 0
    fio_err_path_not_found  db "The specified directory path does not exist", 0dh, 0ah, 0
    fio_err_too_many_open   db "The system has reached the limit of simultaneously open files", 0dh, 0ah, 0
    fio_err_access_denied   db "You do not have permission to perform this operation", 0dh, 0ah, 0
    fio_err_invalid_handle  db "The provided file handle is not recognized", 0dh, 0ah, 0
    fio_err_mcb_destroyed   db "The internal memory control structure has been corrupted", 0dh, 0ah, 0
    fio_err_insufficient_mem db "There is not enough free memory to complete this request", 0dh, 0ah, 0
    fio_err_invalid_mem_block db "The memory block address supplied is incorrect", 0dh, 0ah, 0
    fio_err_invalid_env     db "The program environment block appears to be invalid", 0dh, 0ah, 0
    fio_err_invalid_format  db "The file or data format is not recognized", 0dh, 0ah, 0
    fio_err_invalid_access  db "The specified access mode code is invalid", 0dh, 0ah, 0
    fio_err_invalid_data    db "The provided data is malformed or corrupted", 0dh, 0ah, 0
    fio_err_reserved        db "A reserved system error has occurred", 0dh, 0ah, 0
    fio_err_invalid_drive   db "The drive letter you specified is not valid", 0dh, 0ah, 0
    fio_err_remove_cur_dir  db "It is not possible to delete the current working directory", 0dh, 0ah, 0
    fio_err_not_same_device db "The source and destination paths refer to different devices", 0dh, 0ah, 0
    fio_err_no_more_files   db "There are no additional files matching the search criteria", 0dh, 0ah, 0
    fio_err_write_protected db "The target disk or media is currently write-protected", 0dh, 0ah, 0
    fio_err_unknown_unit    db "The requested disk drive or unit does not exist", 0dh, 0ah, 0
    fio_err_drive_not_ready db "The drive is not ready; please check the disk and try again", 0dh, 0ah, 0
    fio_err_unknown_cmd     db "The device does not recognize the command that was sent", 0dh, 0ah, 0
    fio_err_crc_error       db "A cyclic redundancy check (CRC) error has been detected", 0dh, 0ah, 0
    fio_err_bad_req_len     db "The length of the request structure is invalid", 0dh, 0ah, 0
    fio_err_seek_error      db "Unable to reposition the file pointer to the desired location", 0dh, 0ah, 0
    fio_err_unknown_media   db "The type of media in the drive cannot be determined", 0dh, 0ah, 0
    fio_err_sector_not_found db "The requested disk sector was not found on the media", 0dh, 0ah, 0
    fio_err_printer_out_paper db "The printer is out of paper and cannot continue", 0dh, 0ah, 0
    fio_err_invalid_device_req db "The requested operation is not supported for this device type", 0dh, 0ah, 0
    fio_err_read_fault      db "A critical error occurred while attempting to read data", 0dh, 0ah, 0
    fio_err_general_failure db "An unspecified general hardware or system failure has occurred", 0dh, 0ah, 0
    fio_err_unknown         db "An unrecognized DOS error condition has been encountered", 0dh, 0ah, 0

    ; Вектор сообщений об ошибках DOS (индексируется кодом ошибки)
    fio_err_vec dw offset fio_err_no_error
                dw offset fio_err_invalid_func
                dw offset fio_err_not_found
                dw offset fio_err_path_not_found
                dw offset fio_err_too_many_open
                dw offset fio_err_access_denied
                dw offset fio_err_invalid_handle
                dw offset fio_err_mcb_destroyed
                dw offset fio_err_insufficient_mem
                dw offset fio_err_invalid_mem_block
                dw offset fio_err_invalid_env
                dw offset fio_err_invalid_format
                dw offset fio_err_invalid_access
                dw offset fio_err_invalid_data
                dw offset fio_err_reserved
                dw offset fio_err_invalid_drive
                dw offset fio_err_remove_cur_dir
                dw offset fio_err_not_same_device
                dw offset fio_err_no_more_files
                dw offset fio_err_write_protected
                dw offset fio_err_unknown_unit
                dw offset fio_err_drive_not_ready
                dw offset fio_err_unknown_cmd
                dw offset fio_err_crc_error
                dw offset fio_err_bad_req_len
                dw offset fio_err_seek_error
                dw offset fio_err_unknown_media
                dw offset fio_err_sector_not_found
                dw offset fio_err_printer_out_paper
                dw offset fio_err_invalid_device_req
                dw offset fio_err_read_fault
                dw offset fio_err_general_failure


    str1 db 256 dup(?)           ; буфер 256 байт
    str2 db "Hello, World!", 0   ; тестовая строка

    test_str1       db "Hello", 0
    test_str2       db "Hello, World!", 0
    test_str3       db "world", 0
    test_str4       db 0
    test_str5       db "abc", 0
    test_str6       db "abd", 0
    test_str7       db "ab", 0
    test_str8       db "abcdef", 0
    test_str9       db "cde", 0
    test_buffer     db 256 dup(?)

    test_str_upper db "ABC", 0
    test_str_apple db "apple", 0
    test_str_banana db "BANANA", 0
    test_str_cat_res db "Helloabd", 0

    ; Тестовые строки для strtol
    test_strtol1   db "123",0
    test_strtol2   db "-456",0
    test_strtol3   db "  +789",0
    test_strtol4   db "FF",0
    test_strtol5   db "0x10",0
    test_strtol6   db "077",0
    test_strtol7   db "10",0
    test_strtol8   db "123abc",0
    test_strtol9   db "abc",0
    test_strtol10  db "32767",0
    test_strtol11  db "-32768",0
    test_end_ptr   dw ?           ; для сохранения end_ptr после strtol


    msg_pass        db " PASS", 13, 10, 0     ; тест пройден
    msg_fail        db " FAIL", 13, 10, 0     ; тест не пройден
    msg_strlen      db "Test strlen", 0
    msg_strchr      db "Test strchr", 0
    msg_strstr      db "Test strstr", 0
    msg_strcmp      db "Test strcmp", 0
    msg_strcpy      db "Test strcpy", 0
    msg_stricmp     db "Test stricmp", 0
    msg_strtol      db "Test strtol ", 0
    msg_strdup      db "Test strdup", 0
    msg_strcat      db "Test strcat", 0

    msg_loaded_str  db "Loaded string from file: ", 13, 10, 0
    msg_filed_to_find_delimiter  db "failed to find delimiter '|' in string!", 13, 10, 0

    filepath1 db 128 dup(?)      ; путь к первому файлу
    filepath2 db 128 dup(?)      ; путь ко второму файлу
    
    msg_enter_file1 db "Enter path to first file: ", 0
    msg_enter_file2 db "Enter path to second file: ", 0
    msg_reading_file db "Reading file...", 13, 10, 0
    msg_file_size db "File size: ", 0
    msg_lines_count db " lines", 13, 10, 0
    msg_case_sensitive db 13, 10, "--- Case-sensitive comparison (strcmp) ---", 13, 10, 0
    msg_case_insensitive db 13, 10, "--- Case-insensitive comparison (stricmp) ---", 13, 10, 0
    msg_diff_line db "Line ", 0
    msg_diff_char db ", char ", 0
    msg_no_diff db "Files are identical!", 13, 10, 0
    msg_error_reading db "Error reading file!", 13, 10, 0
    msg_error_empty db "File is empty!", 13, 10, 0
    msg_diff_line_count db "Files have different number of lines!", 13, 10, 0
    msg_bytes_read db " bytes read", 13, 10, 0
    
    num_buffer db 16 dup(?)      ; буфер для преобразования числа в строку

data ends


code segment para public use16


assume cs:code,ds:data,ss:stack, es:data

include macro.inc               ; макросы (pushregs, popregs и др.)
include strings.inc             ; функции работы со строками
include memory.inc              ; функции управления памятью
include misc.inc                ; вспомогательные функции
include io.inc                  ; функции ввода-вывода
include fio.inc                 ; функции работы с файлами
include error.inc               ; функции обработки ошибок
include tests.inc               ; функции тестирования

; ============================================================================
; void print_number(int num)
; Назначение: Преобразует целое число в строку и выводит на экран.
;            Обрабатывает отрицательные числа.
; Аргументы:
;   [bp+arg1] = num - число для вывода
; ============================================================================
print_number proc near
    push bp                       
    mov bp, sp                    
    push ax                     
    push bx
    push cx
    push dx
    push si
    
    mov ax, word ptr [bp+arg1]    ; загружаем число
    mov si, offset num_buffer     ; si = начало буфера
    add si, 15                    ; переходим в конец буфера
    mov byte ptr [si], 0          ; записываем завершающий ноль
    dec si                        ; предыдущая позиция
    
    test ax, ax                   ; проверяем знак числа
    jge pn_convert                ; если >= 0 - пропускаем
    neg ax                        ; делаем положительным
    push ax                       ; сохраняем ax
    push '-'                      ; выводим минус
    call putchar
    add sp, 2                     ; очищаем стек
    pop ax                        ; восстанавливаем ax
    
pn_convert:
    mov bx, 10                    ; основание системы счисления (десятичная)
    
pn_loop:
    xor dx, dx                    ; очищаем dx перед делением
    div bx                        ; делим ax на 10, dx = остаток
    add dl, '0'                   ; преобразуем в ASCII
    mov byte ptr [si], dl         ; сохраняем цифру
    dec si                        ; предыдущая позиция
    test ax, ax                   ; число закончилось?
    jnz pn_loop                   ; если нет - продолжаем
    
    inc si                        ; корректируем указатель
    push si                       ; выводим строку
    call putstr
    add sp, 2                     ; очищаем стек
    
    pop si                        ; восстанавливаем регистры
    pop dx
    pop cx
    pop bx
    pop ax
    mov sp, bp                    ; восстанавливаем sp
    pop bp                        ; восстанавливаем bp
    ret
print_number endp

; ============================================================================
; word split_text_to_lines(word seg_text)
; Назначение: Разбивает текст на отдельные строки, заменяя \r и \n на \0.
;            Создаёт массив смещений начал строк в исходном тексте.
;            В отличие от split_to_lines, не создаёт копии строк.
; Аргументы:
;   [bp+arg1] = seg_text - сегмент текста для разбора
; Возвращает:
;   ax = сегмент массива смещений строк
;   cx = количество строк
; ============================================================================
split_text_to_lines proc near
    push bp                     
    mov bp, sp                    
    sub sp, 6                     ; локальные переменные:
                                   ; [bp-2] = line_count
                                   ; [bp-4] = array_seg
                                   ; [bp-6] = text_len
    push es                       ; сохраняем регистры
    push ds
    push si
    push di
    push bx
    push dx
    
    mov es, word ptr [bp+arg1]    ; es = сегмент текста
    
    cmp byte ptr es:[0], 0        ; текст пустой?
    jne stl_not_empty             ; если нет - продолжаем
    jmp stl_empty                 ; если да - выходим
    
stl_not_empty:
    ; Первый проход: заменяем \r и \n на \0, считаем строки
    xor si, si                    ; si = 0 (индекс)
    xor cx, cx                    ; cx = 0 (счётчик строк)
    xor dx, dx                    ; dx = 0 (длина текста)
    
stl_clean_loop:
    mov al, byte ptr es:[si]      ; читаем символ
    test al, al                   ; конец текста?
    jz stl_clean_done             ; если да - выходим
    
    inc dx                        ; увеличиваем длину
    
    cmp al, 0Dh                   ; возврат каретки?
    jne stl_check_nl              ; если нет - проверяем \n
    mov byte ptr es:[si], 0       ; заменяем \r на 0
    inc si                        ; следующий символ
    jmp stl_clean_loop
    
stl_check_nl:
    cmp al, 0Ah                   ; перевод строки?
    jne stl_clean_next            ; если нет - идём дальше
    mov byte ptr es:[si], 0       ; заменяем \n на 0
    inc cx                        ; увеличиваем счётчик строк
    
stl_clean_next:
    inc si                        ; следующий символ
    jmp stl_clean_loop
    
stl_clean_done:
    mov word ptr [bp-6], dx       ; сохраняем длину текста
    inc cx                        ; +1 за последнюю строку
    mov word ptr [bp-2], cx       ; сохраняем количество строк
    
    ; Выделяем память под массив смещений (по 2 байта на строку)
    shl cx, 1                     ; умножаем на 2 (размер элемента)
    push cx                       ; размер для выделения
    call AllocMem                 ; выделяем память
    add sp, 2                     ; очищаем стек
    test ax, ax                   ; успешно?
    jz stl_empty                  ; если нет - выходим
    
    mov word ptr [bp-4], ax       ; сохраняем сегмент массива
    
    ; Второй проход: находим начала строк
    xor si, si                    ; si = 0
    xor di, di                    ; di = 0 (индекс в массиве)
    
    ; Первая строка всегда начинается с 0 (если текст не пустой)
    push ds                       ; сохраняем ds
    mov ds, word ptr [bp-4]       ; ds = сегмент массива
    mov word ptr [di], 0          ; первый элемент = 0
    add di, 2                     ; следующий индекс
    pop ds                        ; восстанавливаем ds
    
    ; Ищем остальные строки
    mov si, 1                     ; начинаем со второго символа
    
stl_find_loop:
    ; Проверяем, не вышли ли за пределы текста
    mov ax, si                    ; ax = si
    cmp ax, word ptr [bp-6]       ; si >= длина текста?
    jae stl_done                  ; если да - заканчиваем
    
    ; Проверяем, что текущий символ не 0, а предыдущий - 0
    cmp byte ptr es:[si], 0       ; текущий символ = 0?
    je stl_find_next              ; если да - пропускаем
    
    cmp byte ptr es:[si-1], 0     ; предыдущий символ = 0?
    jne stl_find_next             ; если нет - пропускаем
    
    ; Нашли начало новой строки
    push ds                       ; сохраняем ds
    mov ds, word ptr [bp-4]       ; ds = сегмент массива
    mov word ptr [di], si         ; сохраняем смещение начала строки
    add di, 2                     ; следующий индекс
    pop ds                        ; восстанавливаем ds
    
stl_find_next:
    inc si                        ; следующий символ
    jmp stl_find_loop
    
stl_done:
    mov cx, word ptr [bp-2]       ; cx = количество строк
    mov ax, word ptr [bp-4]       ; ax = сегмент массива
    jmp stl_exit
    
stl_empty:
    xor ax, ax                    ; возвращаем 0
    xor cx, cx                    ; возвращаем 0
    
stl_exit:
    pop dx                        ; восстанавливаем регистры
    pop bx
    pop di
    pop si
    pop ds
    pop es
    mov sp, bp                    
    pop bp                        
    ret
split_text_to_lines endp

; ============================================================================
; int compare_lines_by_offset(word seg1, word off1, word seg2, word off2, int case_insensitive)
; Назначение: Сравнивает две строки, заданные через сегмент и смещение.
;            Поддерживает сравнение с учётом и без учёта регистра.
; Аргументы:
;   [bp+arg1] = seg1 - сегмент первой строки
;   [bp+arg2] = off1 - смещение первой строки
;   [bp+arg3] = seg2 - сегмент второй строки
;   [bp+arg4] = off2 - смещение второй строки
;   [bp+arg5] = case_insensitive - 0 = с учётом регистра, 1 = без учёта
; Возвращает:
;   ax = -1 если строки равны
;   ax = индекс первого несовпадающего символа (начиная с 0)
; ============================================================================
compare_lines_by_offset proc near
    push bp                       
    mov bp, sp                   
    sub sp, 2                     ; [bp-2] = char_index (индекс символа)
    push si                      
    push di
    push es
    push ds
    
    mov es, word ptr [bp+arg1]    ; es = сегмент первой строки
    mov si, word ptr [bp+arg2]    ; si = смещение первой строки
    
    mov ds, word ptr [bp+arg3]    ; ds = сегмент второй строки
    mov di, word ptr [bp+arg4]    ; di = смещение второй строки
    
    mov word ptr [bp-2], 0        ; char_index = 0
    
clbo_loop:
    mov al, byte ptr es:[si]      ; символ из первой строки
    mov ah, byte ptr [di]         ; символ из второй строки
    
    cmp word ptr [bp+arg5], 0     ; сравниваем с учётом регистра?
    jne clbo_case_insensitive     ; если нет - переходим
    
    cmp al, ah                    ; сравниваем символы
    jne clbo_diff                 ; если разные - возвращаем индекс
    jmp clbo_check_end            ; иначе проверяем конец строки
    
clbo_case_insensitive:
    ; Приводим al к верхнему регистру
    cmp al, 'a'                   
    jb clbo_check_ah             
    cmp al, 'z'                   
    ja clbo_check_ah              
    sub al, 20h                   ; преобразуем в верхний регистр
    
clbo_check_ah:
    ; Приводим ah к верхнему регистру
    cmp ah, 'a'                  
    jb clbo_compare               
    cmp ah, 'z'                   
    ja clbo_compare              
    sub ah, 20h                   ; преобразуем в верхний регистр
    
clbo_compare:
    cmp al, ah                    ; сравниваем символы
    jne clbo_diff                 ; если разные - возвращаем индекс
    
clbo_check_end:
    test al, al                   ; конец строки?
    jz clbo_equal                 ; если да - строки равны
    
    inc si                        ; следующий символ первой строки
    inc di                        ; следующий символ второй строки
    inc word ptr [bp-2]           ; увеличиваем индекс
    jmp clbo_loop                 ; продолжаем сравнение
    
clbo_diff:
    mov ax, word ptr [bp-2]       ; возвращаем индекс различия
    jmp clbo_exit
    
clbo_equal:
    mov ax, -1                    ; возвращаем -1 (строки равны)
    
clbo_exit:
    pop ds                        
    pop es
    pop di
    pop si
    mov sp, bp                    
    pop bp                       
    ret
compare_lines_by_offset endp

; ============================================================================
; int read_file_to_memory(char* filename)
; Назначение: Читает содержимое файла в динамически выделенную память.
;            Определяет размер файла, выделяет нужный объём памяти,
;            читает данные и добавляет завершающий ноль.
; Аргументы:
;   [bp+arg1] = filename - указатель на имя файла
; Возвращает:
;   ax = сегментный адрес буфера с данными файла
;   ax = 0 при ошибке
; ============================================================================
read_file_to_memory proc near
    push bp                       
    mov bp, sp                    
    sub sp, 4                     ; локальные переменные:
                                   ; [bp-2] = file_handle
                                   ; [bp-4] = file_size
    push bx                    
    push cx
    push dx
    push si
    push di
    push ds
    
    ; Открываем файл для чтения
    push word ptr [bp+arg1]       ; имя файла
    push ACCESS_READ              ; режим доступа (чтение)
    call fopen                    ; открываем файл
    add sp, 4                     
    jc rfm_error                  ; если ошибка - выходим
    
    mov word ptr [bp-2], ax       ; сохраняем дескриптор файла
    
    ; Определяем размер файла
    push ax                       ; дескриптор
    call fsize                    ; получаем размер
    add sp, 2                     
    jc rfm_error_close            ; если ошибка 
    
    ; Проверяем размер (должен помещаться в 64Кб)
    cmp dx, 0                     ; старшее слово = 0?
    jne rfm_too_big               ; если нет - файл слишком большой
    test ax, ax                   ; размер = 0?
    jz rfm_empty                  ; если да - файл пустой
    
    mov word ptr [bp-4], ax       ; сохраняем размер
    
    ; Выводим информацию о размере
    push offset msg_file_size     
    call putstr
    add sp, 2
    push word ptr [bp-4]          ; выводим размер
    call print_number
    add sp, 2
    push offset msg_bytes_read   
    call putstr
    add sp, 2
    
    ; Выделяем память под содержимое файла (+1 для нуля)
    mov ax, word ptr [bp-4]       ; размер файла
    add ax, 1                     ; +1 для завершающего нуля
    push ax                       
    call AllocMem                 ; выделяем память
    add sp, 2                     
    test ax, ax                   ; успешно?
    jz rfm_error_close            ; если нет - закрываем и выходим
    
    ; Читаем файл в выделенную память
    push ax                       ; сохраняем сегмент буфера
    push ds                       ; сохраняем ds
    mov ds, ax                    ; ds = сегмент буфера
    
    push word ptr [bp-4]          ; количество байт для чтения
    push 0                        ; смещение в буфере = 0
    push word ptr [bp-2]          ; дескриптор файла
    call fread                    ; читаем данные
    add sp, 6                     ; очищаем стек
    
    pop ds                        ; восстанавливаем ds
    pop es                        ; es = сегмент буфера
    
    ; Добавляем завершающий ноль
    mov di, word ptr [bp-4]       ; смещение = размер файла
    mov byte ptr es:[di], 0       ; записываем 0 в конец
    
    ; Закрываем файл
    push word ptr [bp-2]          ; дескриптор файла
    call fclose                   ; закрываем
    add sp, 2                     ; очищаем стек
    
    mov ax, es                    ; возвращаем сегмент буфера
    jmp rfm_exit
    
rfm_too_big:
    ; Файл слишком большой
    push offset msg_error_reading ; сообщение об ошибке
    call putstr
    add sp, 2
    jmp rfm_error_close           ; закрываем и выходим
    
rfm_empty:
    ; Файл пустой
    push offset msg_error_empty   ; сообщение "File is empty!"
    call putstr
    add sp, 2
    jmp rfm_error_close           ; закрываем и выходим
    
rfm_error_close:
    ; Закрываем файл при ошибке
    push word ptr [bp-2]          ; дескриптор файла
    call fclose                   ; закрываем
    add sp, 2                     ; очищаем стек
    
rfm_error:
    xor ax, ax                    ; возвращаем 0 (ошибка)
    
rfm_exit:
    pop ds                        ; восстанавливаем регистры
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    mov sp, bp                    
    pop bp                        
    ret
read_file_to_memory endp

; ============================================================================
; void free_lines_array(void* lines_array)
; Назначение: Освобождает память, выделенную под массив смещений строк.
; Аргументы:
;   [bp+arg1] = lines_array - сегмент массива для освобождения
; Возвращает: ничего
; ============================================================================
free_lines_array proc near
    push bp                       ; сохраняем bp
    mov bp, sp                    ; настраиваем кадр стека
    
    push word ptr [bp+arg1]       ; сегмент памяти
    call FreeMem                  ; освобождаем
    add sp, 2                     ; очищаем стек
    
    mov sp, bp                    ; восстанавливаем sp
    pop bp                        ; восстанавливаем bp
    ret
free_lines_array endp

; ============================================================================
; void compare_files(char* file1_path, char* file2_path)
; Назначение: Сравнивает два текстовых файла построчно. Выполняет
;            сравнение с учётом и без учёта регистра. Выводит номера
;            строк и позиции символов, в которых найдены различия.
; Аргументы:
;   [bp+arg1] = file1_path - путь к первому файлу
;   [bp+arg2] = file2_path - путь ко второму файлу
; Возвращает: ничего (результат выводится на экран)
; ============================================================================
compare_files proc near
    push bp                       ; сохраняем bp
    mov bp, sp                    ; настраиваем кадр стека
    sub sp, 14                    ; резервируем локальные переменные:
                                   ; [bp-2]  = text1_seg
                                   ; [bp-4]  = text2_seg
                                   ; [bp-6]  = lines1_seg
                                   ; [bp-8]  = lines2_seg
                                   ; [bp-10] = lines1_count
                                   ; [bp-12] = lines2_count
                                   ; [bp-14] = diff_found
    push si                       ; сохраняем регистры
    push di
    push bx
    
    ; Инициализация локальных переменных
    mov word ptr [bp-2], 0        ; text1_seg = 0
    mov word ptr [bp-4], 0        ; text2_seg = 0
    mov word ptr [bp-6], 0        ; lines1_seg = 0
    mov word ptr [bp-8], 0        ; lines2_seg = 0
    mov word ptr [bp-10], 0       ; lines1_count = 0
    mov word ptr [bp-12], 0       ; lines2_count = 0
    
    ; Читаем первый файл
    push offset msg_reading_file  ; "Reading file..."
    call putstr
    add sp, 2
    
    push word ptr [bp+arg1]       ; путь к первому файлу
    call read_file_to_memory      ; читаем файл в память
    add sp, 2
    test ax, ax                   ; успешно?
    jz cf_error                   ; если нет - выходим
    mov word ptr [bp-2], ax       ; сохраняем сегмент текста
    
    ; Читаем второй файл
    push offset msg_reading_file  ; "Reading file..."
    call putstr
    add sp, 2
    
    push word ptr [bp+arg2]       ; путь ко второму файлу
    call read_file_to_memory      ; читаем файл в память
    add sp, 2
    test ax, ax                   ; успешно?
    jz cf_error                   ; если нет - выходим
    mov word ptr [bp-4], ax       ; сохраняем сегмент текста
    
    ; Разбираем первый файл на строки
    push word ptr [bp-2]          ; сегмент текста
    call split_text_to_lines      ; разбираем на строки
    add sp, 2
    mov word ptr [bp-6], ax       ; сохраняем сегмент массива смещений
    mov word ptr [bp-10], cx      ; сохраняем количество строк
    
    ; Разбираем второй файл на строки
    push word ptr [bp-4]          ; сегмент текста
    call split_text_to_lines      ; разбираем на строки
    add sp, 2
    mov word ptr [bp-8], ax       ; сохраняем сегмент массива смещений
    mov word ptr [bp-12], cx      ; сохраняем количество строк
    
    ; Выводим количество строк в каждом файле
    push word ptr [bp-10]         ; количество строк в первом файле
    call print_number
    add sp, 2
    push offset msg_lines_count   ; " lines"
    call putstr
    add sp, 2
    
    push word ptr [bp-12]         ; количество строк во втором файле
    call print_number
    add sp, 2
    push offset msg_lines_count   ; " lines"
    call putstr
    add sp, 2
    
    ; Проверяем, что есть строки для сравнения
    cmp word ptr [bp-10], 0       ; первый файл пустой?
    je cf_no_lines
    cmp word ptr [bp-12], 0       ; второй файл пустой?
    je cf_no_lines
    
    ; --- Сравнение с учётом регистра ---
    push offset msg_case_sensitive ; заголовок секции
    call putstr
    add sp, 2
    
    ; Определяем, сколько строк сравнивать (минимум из двух)
    mov cx, word ptr [bp-10]      ; строк в первом файле
    cmp cx, word ptr [bp-12]      ; сравниваем со вторым
    jbe cf_cs_start               ; если первый <= второго - ок
    mov cx, word ptr [bp-12]      ; иначе берём второй
    
cf_cs_start:
    xor bx, bx                    ; bx = 0 (индекс строки)
    mov word ptr [bp-14], 0       ; diff_found = 0
    
cf_cs_loop:
    cmp bx, cx                    ; все строки сравнили?
    jae cf_cs_done                ; если да - заканчиваем
    
    push cx                       ; сохраняем счётчик
    push bx                       ; сохраняем индекс
    
    mov si, bx                    ; si = индекс строки
    shl si, 1                     ; умножаем на 2 (размер элемента)
    
    push ds                       ; сохраняем ds
    mov ds, word ptr [bp-6]       ; ds = массив смещений первого файла
    mov di, word ptr [si]         ; di = смещение строки в первом файле
    pop ds                        ; восстанавливаем ds
    
    push es                       ; сохраняем es
    mov es, word ptr [bp-8]       ; es = массив смещений второго файла
    mov si, word ptr es:[si]      ; si = смещение строки во втором файле
    pop es                        ; восстанавливаем es
    
    ; Сравниваем строки
    push 0                        ; case_insensitive = 0
    push si                       ; смещение во втором файле
    push word ptr [bp-4]          ; сегмент второго текста
    push di                       ; смещение в первом файле
    push word ptr [bp-2]          ; сегмент первого текста
    call compare_lines_by_offset  ; сравниваем
    add sp, 10                    ; очищаем стек
    
    cmp ax, -1                    ; строки равны?
    je cf_cs_next                 ; если да - следующая строка
    
    ; Нашли различие
    mov word ptr [bp-14], 1       ; diff_found = 1
    
    push offset msg_diff_line     ; "Line "
    call putstr
    add sp, 2
    push bx                       ; номер строки
    call print_number
    add sp, 2
    push offset msg_diff_char     ; ", char "
    call putstr
    add sp, 2
    push ax                       ; номер символа
    call print_number
    add sp, 2
    call putnewline               ; перевод строки
    
cf_cs_next:
    pop bx                        ; восстанавливаем индекс
    inc bx                        ; следующая строка
    pop cx                        ; восстанавливаем счётчик
    jmp cf_cs_loop
    
cf_cs_done:
    ; Проверяем разницу в количестве строк
    mov ax, word ptr [bp-10]      ; строк в первом файле
    cmp ax, word ptr [bp-12]      ; сравниваем со вторым
    je cf_cs_check_no_diff        ; если равны - проверяем
    jmp cf_cs_ci_mid              ; если разные - выводим сообщение
    
cf_cs_check_no_diff:
    ; Различий не найдено
    cmp word ptr [bp-14], 0       ; был ли diff?
    jne cf_ci_section             ; если да - переходим к следующей секции
    
    push offset msg_no_diff       ; "Files are identical!"
    call putstr
    add sp, 2
    jmp cf_ci_section             ; переходим к следующей секции
    
cf_cs_ci_mid:
    mov word ptr [bp-14], 1       ; diff_found = 1
    push offset msg_diff_line_count ; "Files have different number of lines!"
    call putstr
    add sp, 2
    
    ; --- Сравнение без учёта регистра ---
cf_ci_section:
    push offset msg_case_insensitive ; заголовок секции
    call putstr
    add sp, 2
    
    ; Определяем, сколько строк сравнивать
    mov cx, word ptr [bp-10]      ; строк в первом файле
    cmp cx, word ptr [bp-12]      ; сравниваем со вторым
    jbe cf_ci_start               ; если первый <= второго - ок
    mov cx, word ptr [bp-12]      ; иначе берём второй
    
cf_ci_start:
    xor bx, bx                    ; bx = 0 (индекс строки)
    mov word ptr [bp-14], 0       ; diff_found = 0
    
cf_ci_loop:
    cmp bx, cx                    ; все строки сравнили?
    jae cf_ci_done                ; если да - заканчиваем
    
    push cx                       ; сохраняем счётчик
    push bx                       ; сохраняем индекс
    
    mov si, bx                    ; si = индекс строки
    shl si, 1                     ; умножаем на 2
    
    push ds
    mov ds, word ptr [bp-6]       ; ds = массив смещений первого файла
    mov di, word ptr [si]         ; di = смещение строки
    pop ds
    
    push es
    mov es, word ptr [bp-8]       ; es = массив смещений второго файла
    mov si, word ptr es:[si]      ; si = смещение строки
    pop es
    
    ; Сравниваем строки (без учёта регистра)
    push 1                        ; case_insensitive = 1
    push si                       ; смещение во втором файле
    push word ptr [bp-4]          ; сегмент второго текста
    push di                       ; смещение в первом файле
    push word ptr [bp-2]          ; сегмент первого текста
    call compare_lines_by_offset  ; сравниваем
    add sp, 10                    ; очищаем стек
    
    cmp ax, -1                    ; строки равны?
    je cf_ci_next                 ; если да - следующая строка
    
    ; Нашли различие
    mov word ptr [bp-14], 1       ; diff_found = 1
    
    push offset msg_diff_line     ; "Line "
    call putstr
    add sp, 2
    push bx                       ; номер строки
    call print_number
    add sp, 2
    push offset msg_diff_char     ; ", char "
    call putstr
    add sp, 2
    push ax                       ; номер символа
    call print_number
    add sp, 2
    call putnewline               ; перевод строки
    
cf_ci_next:
    pop bx                        ; восстанавливаем индекс
    inc bx                        ; следующая строка
    pop cx                        ; восстанавливаем счётчик
    jmp cf_ci_loop
    
cf_ci_done:
    ; Проверяем разницу в количестве строк
    mov ax, word ptr [bp-10]      ; строк в первом файле
    cmp ax, word ptr [bp-12]      ; сравниваем со вторым
    je cf_ci_check_no_diff        ; если равны - проверяем
    
    mov word ptr [bp-14], 1       ; diff_found = 1
    push offset msg_diff_line_count ; "Files have different number of lines!"
    call putstr
    add sp, 2
    jmp cf_cleanup                ; переходим к очистке
    
cf_ci_check_no_diff:
    ; Различий не найдено
    cmp word ptr [bp-14], 0       ; был ли diff?
    jne cf_cleanup                ; если да - переходим к очистке
    
    push offset msg_no_diff       ; "Files are identical!"
    call putstr
    add sp, 2
    jmp cf_cleanup                ; переходим к очистке
    
cf_no_lines:
    ; Один из файлов пустой
    push offset msg_error_empty   ; "File is empty!"
    call putstr
    add sp, 2
    jmp cf_cleanup                ; переходим к очистке
    
cf_cleanup:
    ; Освобождаем память: массив смещений первого файла
    cmp word ptr [bp-6], 0        ; есть что освобождать?
    je cf_free2
    push word ptr [bp-6]          ; сегмент массива
    call free_lines_array         ; освобождаем
    add sp, 2
    
cf_free2:
    ; Освобождаем память: массив смещений второго файла
    cmp word ptr [bp-8], 0        ; есть что освобождать?
    je cf_free3
    push word ptr [bp-8]          ; сегмент массива
    call free_lines_array         ; освобождаем
    add sp, 2
    
cf_free3:
    ; Освобождаем память: текст первого файла
    cmp word ptr [bp-2], 0        ; есть что освобождать?
    je cf_free4
    push word ptr [bp-2]          ; сегмент текста
    call FreeMem                  ; освобождаем
    add sp, 2
    
cf_free4:
    ; Освобождаем память: текст второго файла
    cmp word ptr [bp-4], 0        ; есть что освобождать?
    je cf_done
    push word ptr [bp-4]          ; сегмент текста
    call FreeMem                  ; освобождаем
    add sp, 2
    jmp cf_done
    
cf_error:
    ; Ошибка при чтении файлов - освобождаем что успели
    cmp word ptr [bp-2], 0        ; первый файл прочитан?
    je cf_err1
    push word ptr [bp-2]          ; освобождаем
    call FreeMem
    add sp, 2
    
cf_err1:
    cmp word ptr [bp-4], 0        ; второй файл прочитан?
    je cf_done
    push word ptr [bp-4]          ; освобождаем
    call FreeMem
    add sp, 2
    
cf_done:
    pop bx                       
    pop di
    pop si
    mov sp, bp                  
    pop bp                       
    ret
compare_files endp

main_process proc near
    push bp                       
    mov bp, sp                   
    
    call putnewline               
    
    ; Запрашиваем путь к первому файлу
    push offset msg_enter_file1   ; "Enter path to first file: "
    call putstr                   ; выводим подсказку
    add sp, 2
    push 128                      ; максимальная длина
    push offset filepath1         ; буфер 
    call getstr                   ; читаем строку
    add sp, 4
    
    ; Запрашиваем путь ко второму файлу
    push offset msg_enter_file2   
    call putstr                   
    add sp, 2
    push 128                      
    push offset filepath2         
    call getstr                   
    add sp, 4
    
    call putnewline              
    
    ; оба пути не пустые
    cmp byte ptr filepath1, 0    
    je mp_empty                  
    cmp byte ptr filepath2, 0    
    je mp_empty                   
    
    ; Сравниваем файлы
    push offset filepath2         
    push offset filepath1         
    call compare_files            ; сравнение
    add sp, 4                     
    jmp mp_done
    
mp_empty:
    ; Один из путей пустой
    push offset msg_error_empty   ; "File is empty!"
    call putstr
    add sp, 2
    
mp_done:
    mov sp, bp                    
    pop bp                       
    ret
main_process endp

_test proc near
    push bp                       
    mov bp, sp                   

    call test_strtol             
    call test_strlen             
    call test_strchr             
    call test_strstr             
    call test_strcmp             
    call test_stricmp            
    call test_strcpy              
    call test_strcat              

    mov sp, bp                   
    pop bp                       
    ret
_test endp
 

start:
   
    mov ax, data                  
    mov ds, ax                    
    mov es, ax                    
    mov ax, stack                
    mov ss, ax                   
    nop                          
    
  
    call _test                    

    call main_process             
    
    call exit0                    
    
end_code_seg:                     
code ends                       

end start                        