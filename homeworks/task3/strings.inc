; Функции для работы со строками

; ============================================================================
; char* strcat(char* dest, const char* src)
; Назначение: Конкатенация (объединение) двух строк. Добавляет строку src 
;            в конец строки dest. Строка dest должна иметь достаточно места
;            для размещения результата.
; Аргументы:
;   [bp+arg1] = dest - указатель на строку-приёмник (куда добавляем)
;   [bp+arg2] = src  - указатель на строку-источник (что добавляем)
; Возвращает:
;   ax = указатель на результирующую строку dest
; ============================================================================
strcat proc near
    push bp
    mov bp, sp
    push di
    push si

    ; Находим конец строки dest (ищем нулевой байт)
    mov di, word ptr [bp+arg1]     ; di = dest
    xor al, al                      ; al = 0 (ищем нулевой байт)
    mov cx, 0FFFFh                 ; максимальное количество байт для поиска
    repne scasb                     ; сканируем пока не найдём 0
    dec di                          ; di теперь указывает на нулевой байт конца dest

    ; Копируем src в конец dest
    mov si, word ptr [bp+arg2]     ; si = src
strcat_loop:
    mov al, byte ptr [si]          ; берём символ из src
    mov byte ptr [di], al          ; копируем в dest
    test al, al                     ; проверяем на конец строки
    jz strcat_done                 ; если 0 - выходим
    inc si                          ; следующий символ src
    inc di                          ; следующая позиция dest
    jmp strcat_loop

strcat_done:
    mov ax, word ptr [bp+arg1]     ; возвращаем указатель на dest
    pop si
    pop di
    mov sp, bp
    pop bp
    ret
strcat endp

; ============================================================================
; int strcmp_idx(const char* s1_seg, const char* s1_off, const char* s2_seg, const char* s2_off)
; Назначение: Посимвольное сравнение двух строк, которые могут находиться 
;            в разных сегментах памяти. Возвращает индекс первого несовпадающего 
;            символа или -1 если строки полностью идентичны.
; Аргументы:
;   [bp+arg1] = s1_seg - сегмент первой строки
;   [bp+arg2] = s1_off - смещение первой строки
;   [bp+arg3] = s2_seg - сегмент второй строки
;   [bp+arg4] = s2_off - смещение второй строки
; Возвращает:
;   ax = индекс первого несовпадающего символа (начиная с 0)
;   ax = -1 если строки полностью равны
; ============================================================================
strcmp_idx proc near
    push bp
    mov bp, sp
    push si
    push di
    push ds
    push es

    ; Загружаем параметры
    mov ax, word ptr [bp+arg1]     ; ax = сегмент первой строки
    mov dx, word ptr [bp+arg3]     ; dx = сегмент второй строки
    mov si, word ptr [bp+arg2]     ; si = смещение первой строки
    mov di, word ptr [bp+arg4]     ; di = смещение второй строки
    xor cx, cx                      ; cx = 0 (счётчик индекса)

strcmp_idx_loop:
    ; Загружаем символы из разных сегментов
    mov ds, ax                      ; ds = сегмент первой строки
    mov es, dx                      ; es = сегмент второй строки
    mov bl, byte ptr [si]          ; bl = символ из первой строки
    mov bh, byte ptr es:[di]       ; bh = символ из второй строки
    
    cmp bl, bh                      ; сравниваем символы
    jne strcmp_idx_found           ; если разные - нашли различие
    
    test bl, bl                     ; проверяем на конец строки
    jz strcmp_idx_equal            ; если 0 - строки равны
    
    inc si                          ; следующий символ в первой строке
    inc di                          ; следующий символ во второй строке
    inc cx                          ; увеличиваем индекс
    jmp strcmp_idx_loop

strcmp_idx_found:
    mov ax, cx                      ; возвращаем индекс различия
    jmp strcmp_idx_done

strcmp_idx_equal:
    mov ax, -1                      ; возвращаем -1 (строки равны)

strcmp_idx_done:
    pop es
    pop ds
    pop di
    pop si
    mov sp, bp
    pop bp
    ret
strcmp_idx endp

; ============================================================================
; word split_to_lines(word seg_str)
; Назначение: Разбивает текст на отдельные строки по символам перевода строки
;            (\n и \r\n). Для каждой строки выделяется память и создаётся 
;            её копия. Указатели на строки сохраняются в массиве.
; Аргументы:
;   [bp+arg1] = seg_str - сегмент исходной строки (текста)
; Возвращает:
;   ax = сегмент массива указателей на строки (каждый элемент - слово)
;   cx = количество найденных строк
; При ошибке: ax = 0, cx = 0
; ============================================================================
split_to_lines proc near
    push bp
    mov bp, sp
    sub sp, 10                     ; резервируем локальные переменные
    pushregs di, si, ds, es

    ; Инициализация локальных переменных
    mov word ptr [bp-2], 0         ; [bp-2] = line_count (счётчик строк)
    mov word ptr [bp-4], 0         ; [bp-4] = start_idx (начало текущей строки)
    mov word ptr [bp-6], 0         ; [bp-6] = curr_idx (текущая позиция)

    mov dx, word ptr [bp+arg1]     ; dx = сегмент текста
    mov ds, dx                      ; ds = сегмент текста

    ; Первый проход: подсчёт количества строк
    xor si, si                      ; si = 0 (текущая позиция)
count_lines_loop:
    mov al, byte ptr [si]          ; читаем символ
    test al, al                     ; конец строки?
    jz count_lines_done            ; если 0 - заканчиваем подсчёт
    cmp al, 0Ah                    ; это \n?
    jne count_lines_skip           ; если нет - пропускаем
    inc word ptr [bp-2]            ; увеличиваем счётчик строк
count_lines_skip:
    inc si                          ; следующий символ
    jmp count_lines_loop
count_lines_done:
    ; Проверяем последнюю строку (если текст не заканчивается на \n)
    cmp si, 0                       ; пустой текст?
    je count_lines_zero
    mov al, byte ptr [si-1]        ; последний символ
    cmp al, 0Ah                    ; это \n?
    je count_lines_zero
    inc word ptr [bp-2]            ; добавляем последнюю строку
count_lines_zero:

    mov cx, word ptr [bp-2]        ; cx = количество строк
    test cx, cx                     ; есть строки?
    jz split_empty                 ; если нет - выходим

    ; Выделяем память под массив указателей (по 2 байта на строку)
    shl cx, 1                       ; cx = cx * 2 (размер массива в байтах)
    push cx                         ; размер для выделения
    call AllocMem                   ; выделяем память
    add sp, 2                       ; очищаем стек
    test ax, ax                     ; проверяем успешность
    jz split_empty                 ; если ошибка - выходим
    mov es, ax                      ; es = сегмент массива
    mov word ptr [bp-8], ax        ; [bp-8] = arr_seg (сохраняем сегмент)
    mov word ptr [bp-10], 0        ; [bp-10] = arr_idx (индекс в массиве)

    ; Второй проход: копирование строк и заполнение массива
    mov ds, dx                      ; восстанавливаем ds
    xor si, si                      ; si = 0
    mov word ptr [bp-4], 0         ; start_idx = 0

split_parse_loop:
    mov al, byte ptr [si]          ; читаем символ
    test al, al                     ; конец текста?
    jz split_end_str               ; обрабатываем последнюю строку
    cmp al, 0Ah                    ; это \n?
    je split_end_str               ; обрабатываем строку

    ; Пропускаем \r
    cmp al, 0Dh                    ; это \r?
    jne split_parse_next           ; если нет - идём дальше
    inc si                          ; пропускаем \r
    jmp split_parse_loop

split_parse_next:
    inc si                          ; следующий символ
    jmp split_parse_loop

split_end_str:
    ; Вычисляем длину строки
    mov cx, si                      ; cx = текущая позиция
    sub cx, word ptr [bp-4]        ; cx = длина строки
    test cx, cx                     ; пустая строка?
    jz split_skip_empty_line       ; пропускаем пустые строки

    ; Выделяем память под копию строки (+1 для нуля)
    inc cx                          ; +1 для завершающего нуля
    push cx                         ; размер
    call AllocMem                   ; выделяем память
    add sp, 2                       ; очищаем стек
    test ax, ax                     ; проверяем успешность
    jz split_alloc_fail            ; если ошибка - выходим
    mov dx, ax                      ; dx = сегмент новой строки

    ; Копируем строку в новую память
    push ds                         ; сохраняем ds
    mov ds, word ptr [bp+arg1]     ; ds = сегмент исходного текста
    mov es, ax                      ; es = сегмент новой строки
    xor di, di                      ; di = 0 (начало новой строки)
    mov si, word ptr [bp-4]        ; si = начало строки в исходном тексте
copy_line_loop:
    mov al, byte ptr [si]          ; читаем символ из исходной строки
    cmp al, 0Dh                    ; это \r?
    je skip_cr_copy                ; пропускаем \r
    mov byte ptr es:[di], al       ; копируем символ
    inc di                          ; следующая позиция
skip_cr_copy:
    inc si                          ; следующий символ
    loop copy_line_loop             ; повторяем cx раз
    mov byte ptr es:[di], 0        ; добавляем завершающий ноль
    pop ds                          ; восстанавливаем ds

    ; Сохраняем указатель на строку в массиве
    mov di, word ptr [bp-10]       ; di = индекс в массиве
    mov es, word ptr [bp-8]        ; es = сегмент массива
    mov word ptr es:[di], dx       ; сохраняем сегмент строки
    add word ptr [bp-10], 2        ; следующий индекс (2 байта)
    inc word ptr [bp-2]            ; увеличиваем счётчик реальных строк

split_skip_empty_line:
    ; Обновляем начальную позицию для следующей строки
    mov ax, si                      ; ax = текущая позиция
    cmp byte ptr [si], 0Ah         ; был \n?
    jne split_check_null
    inc ax                          ; пропускаем \n
split_check_null:
    mov word ptr [bp-4], ax        ; обновляем start_idx
    mov si, ax                      ; обновляем текущую позицию
    
    cmp byte ptr [si-1], 0         ; конец текста?
    jne split_parse_loop           ; если нет - продолжаем

split_done:
    mov cx, word ptr [bp-2]        ; cx = количество строк
    mov ax, word ptr [bp-8]        ; ax = сегмент массива
    jmp split_return

split_empty:
    xor ax, ax                      ; возвращаем 0
    xor cx, cx                      ; возвращаем 0
    jmp split_return

split_alloc_fail:
    xor ax, ax                      ; возвращаем 0 при ошибке
    xor cx, cx

split_return:
    popregs es, ds, si, di         ; восстанавливаем регистры
    mov sp, bp
    pop bp
    ret
split_to_lines endp

; ============================================================================
; char* strdup(char* string)
; Назначение: Создаёт точную копию строки в динамически выделенной памяти.
;            Выделяет ровно столько памяти, сколько нужно для строки + 
;            завершающий ноль.
; Аргументы:
;   [bp+arg1] = string - указатель на исходную строку
; Возвращает:
;   ax = сегментный адрес новой копии строки
;   ax = 0 при ошибке выделения памяти
; ============================================================================
strdup proc near
    push bp
    mov bp, sp
    push di
    push si
    push bx
    push es

    ; Определяем длину исходной строки
    push word ptr [bp+arg1]        ; аргумент для strlen
    call strlen                     ; получаем длину
    add sp, 2                       ; очищаем стек

    test ax, ax                     ; пустая строка?
    jz strdup_done                 ; если да - выходим (возвращаем 0)

    inc ax                          ; +1 для завершающего нуля
    push ax                         ; размер для выделения
    call AllocMem                   ; выделяем память
    add sp, 2                       ; очищаем стек

    test ax, ax                     ; проверяем успешность
    jz strdup_failed               ; если ошибка - выходим
    mov es, ax                      ; es = сегмент новой строки

    ; Копируем строку побайтово
    mov si, word ptr [bp+arg1]     ; si = исходная строка
    xor di, di                      ; di = 0 (начало новой строки)
strdup_loop:
    mov bl, byte ptr [si]          ; читаем символ
    mov byte ptr es:[di], bl       ; копируем в новую строку
    inc si                          ; следующий символ исходной
    inc di                          ; следующая позиция новой
    test bl, bl                     ; конец строки?
    jnz strdup_loop                ; если нет - продолжаем

    mov ax, es                      ; возвращаем сегмент новой строки

strdup_done:
    pop es
    pop bx
    pop si
    pop di
    mov sp, bp
    pop bp
    ret

strdup_failed:
    xor ax, ax                      ; возвращаем 0 при ошибке
    jmp strdup_done
strdup endp

; ============================================================================
; bool is_white_space(char ch)
; Назначение: Проверяет, является ли символ пробельным (пробел, табуляция,
;            перевод строки, возврат каретки).
; Аргументы:
;   [bp+arg1] = ch - проверяемый символ (используется только младший байт)
; Возвращает:
;   ax = 1 - символ является пробельным
;   ax = 0 - символ не является пробельным
; ============================================================================
is_white_space proc near
    push bp
    mov bp, sp
    
    mov al, byte ptr [bp+arg1]     ; загружаем символ
    
    ; Проверяем на пробел
    cmp al, ' '                     ; пробел?
    je is_white_space_detected
    
    ; Проверяем на табуляцию
    cmp al, 09h                    ; горизонтальная табуляция?
    je is_white_space_detected
    
    ; Проверяем на перевод строки
    cmp al, 0Ah                    ; \n?
    je is_white_space_detected
    
    ; Проверяем на возврат каретки
    cmp al, 0Dh                    ; \r?
    je is_white_space_detected

    ; Не пробельный символ
    mov ax, 0
    jmp is_white_space_done

is_white_space_detected:
    mov ax, 1                       ; пробельный символ

is_white_space_done:
    mov sp, bp
    pop bp
    ret
is_white_space endp

; ============================================================================
; short strtol(const char* string, char** end_ptr, short base)
; Назначение: Преобразует строку в целое число (аналог C-функции strtol).
;            Пропускает начальные пробельные символы, обрабатывает знак +/-, 
;            поддерживает системы счисления от 2 до 16. При base=0 определяет 
;            систему счисления автоматически (0x - шестнадцатеричная, 
;            0 - восьмеричная, иначе десятичная).
; Аргументы:
;   [bp+arg1] = string  - указатель на исходную строку
;   [bp+arg2] = end_ptr - указатель на переменную, куда будет записан 
;                         указатель на первый непреобразованный символ
;   [bp+arg3] = base    - основание системы счисления (0, или 2-16)
; Возвращает:
;   ax = преобразованное число
;   При переполнении возвращает SHRT_MAX/SHRT_MIN (32767/-32768)
; ============================================================================
strtol proc near
    push bp
    mov bp, sp
    sub sp, 8                      ; резервируем локальные переменные
    pushregs di, si, cx, bx, dx

    ; Инициализация локальных переменных
    mov word ptr [bp-2], 1         ; [bp-2] = знак (1 = положительное, -1 = отрицательное)
    mov word ptr [bp-4], 0         ; [bp-4] = результат (накапливаемое значение)
    mov word ptr [bp-6], 0         ; [bp-6] = флаг переполнения

    mov si, word ptr [bp+arg1]     ; si = исходная строка
    mov di, word ptr [bp+arg2]     ; di = указатель на end_ptr
    mov cx, word ptr [bp+arg3]     ; cx = основание системы счисления

    ; Пропускаем начальные пробельные символы
strtol_skip_ws:
    mov al, byte ptr [si]          ; читаем символ
    test al, al                     ; конец строки?
    jz strtol_empty
    
    cmp al, ' '                     ; пробел?
    je strtol_ws_next
    cmp al, 9                       ; табуляция?
    je strtol_ws_next
    cmp al, 10                      ; перевод строки?
    je strtol_ws_next
    cmp al, 13                      ; возврат каретки?
    je strtol_ws_next
    jmp strtol_check_sign           ; не пробельный - проверяем знак
    
strtol_ws_next:
    inc si                          ; следующий символ
    jmp strtol_skip_ws

    ; Проверяем знак числа
strtol_check_sign:
    mov al, byte ptr [si]          ; читаем символ
    cmp al, '-'                     ; минус?
    jne strtol_check_plus
    mov word ptr [bp-2], -1        ; устанавливаем отрицательный знак
    inc si                          ; пропускаем минус
    jmp strtol_check_base
    
strtol_check_plus:
    cmp al, '+'                     ; плюс?
    jne strtol_check_base
    inc si                          ; пропускаем плюс

    ; Определяем основание системы счисления (если не задано)
strtol_check_base:
    cmp cx, 0                       ; base == 0 (автоопределение)?
    jne strtol_base_ready
    
    mov al, byte ptr [si]          ; первый символ после знака
    cmp al, '0'                     ; начинается с 0?
    jne strtol_base_10             ; нет - десятичная система
    
    mov al, byte ptr [si+1]        ; следующий символ
    cmp al, 'x'                     ; 0x?
    je strtol_base_16
    cmp al, 'X'                     ; 0X?
    je strtol_base_16
    
    mov cx, 8                       ; восьмеричная система (начинается с 0)
    jmp strtol_base_ready
    
strtol_base_16:
    add si, 2                       ; пропускаем 0x
    mov cx, 16                      ; шестнадцатеричная система
    jmp strtol_base_ready
    
strtol_base_10:
    mov cx, 10                      ; десятичная система

strtol_base_ready:
    ; Проверяем корректность основания
    cmp cx, 2                       ; основание меньше 2?
    jb strtol_invalid
    cmp cx, 16                      ; основание больше 16?
    ja strtol_invalid
    
    mov word ptr [bp-8], si        ; [bp-8] = сохраняем начало числа

    ; Основной цикл преобразования цифр
strtol_convert:
    mov al, byte ptr [si]          ; читаем символ
    test al, al                     ; конец строки?
    jz strtol_done
    
    ; Определяем значение цифры
    cmp al, '0'                     ; меньше '0'?
    jb strtol_not_digit
    cmp al, '9'                     ; цифра 0-9?
    jbe strtol_is_digit
    
    cmp al, 'A'                     ; меньше 'A'?
    jb strtol_not_digit
    cmp al, 'F'                     ; буква A-F?
    jbe strtol_is_upper
    
    cmp al, 'a'                     ; меньше 'a'?
    jb strtol_not_digit
    cmp al, 'f'                     ; буква a-f?
    jbe strtol_is_lower
    
    jmp strtol_not_digit            ; не цифра

strtol_is_digit:
    sub al, '0'                     ; преобразуем ASCII-цифру в число
    jmp strtol_check_digit
    
strtol_is_upper:
    sub al, 'A'                     ; A=0, B=1, ...
    add al, 10                      ; A=10, B=11, ...
    jmp strtol_check_digit
    
strtol_is_lower:
    sub al, 'a'                     ; a=0, b=1, ...
    add al, 10                      ; a=10, b=11, ...

strtol_check_digit:
    cmp al, cl                      ; цифра >= основания?
    jae strtol_not_digit            ; если да - недопустимая цифра
    
    ; Умножаем текущий результат на основание и добавляем цифру
    movzx bx, al                    ; bx = значение цифры (расширение до 16 бит)
    mov ax, word ptr [bp-4]        ; ax = текущий результат
    mul cx                          ; dx:ax = ax * основание
    
    ; Проверяем переполнение (старшее слово должно быть 0)
    cmp dx, 0
    jne strtol_overflow
    
    add ax, bx                      ; добавляем цифру
    jc strtol_overflow             ; если перенос - переполнение
    
    ; Проверяем границы для знаковых чисел
    cmp word ptr [bp-2], 1         ; положительное число?
    jne strtol_check_neg_limit
    
    ; Проверка для положительных чисел (максимум 32767)
    cmp ax, 32767
    ja strtol_overflow
    jmp strtol_store
    
strtol_check_neg_limit:
    ; Проверка для отрицательных чисел (максимум 32768 по модулю)
    cmp ax, 32768
    ja strtol_overflow

strtol_store:
    mov word ptr [bp-4], ax        ; сохраняем результат
    inc si                          ; следующий символ
    jmp strtol_convert

strtol_not_digit:
    ; Проверяем, были ли цифры вообще
    cmp si, word ptr [bp-8]        ; si == начало числа?
    je strtol_no_digits            ; если да - не было цифр
    jmp strtol_done

strtol_overflow:
    mov word ptr [bp-6], 1         ; устанавливаем флаг переполнения
    inc si                          ; пропускаем символ
    jmp strtol_convert             ; продолжаем (чтобы установить end_ptr правильно)

strtol_no_digits:
    xor ax, ax                      ; результат = 0
    mov word ptr [bp-4], ax
    mov si, word ptr [bp+arg1]     ; возвращаем исходный указатель

strtol_done:
    ; Устанавливаем end_ptr (указатель на первый непреобразованный символ)
    mov bx, word ptr [bp+arg2]
    mov word ptr [bx], si
    
    ; Получаем результат
    mov ax, word ptr [bp-4]
    
    ; Обрабатываем переполнение
    cmp word ptr [bp-6], 1
    jne strtol_apply_sign
    
    ; Возвращаем предельное значение в зависимости от знака
    cmp word ptr [bp-2], 1
    je strtol_overflow_pos
    mov ax, 32768                   ; SHRT_MIN
    neg ax                          ; делаем отрицательным
    jmp strtol_return
    
strtol_overflow_pos:
    mov ax, 32767                   ; SHRT_MAX
    jmp strtol_return

strtol_apply_sign:
    cmp word ptr [bp-2], -1        ; нужно применить отрицательный знак?
    jne strtol_return
    neg ax                          ; меняем знак

strtol_return:
    popregs dx, bx, cx, si, di     ; восстанавливаем регистры
    mov sp, bp
    pop bp
    ret

strtol_invalid:
strtol_empty:
    xor ax, ax                      ; возвращаем 0
    mov bx, word ptr [bp+arg2]
    mov word ptr [bx], si           ; end_ptr = string
    jmp strtol_return
    
strtol endp

; ============================================================================
; int stricmp(const char* string1, const char* string2)
; Назначение: Сравнение двух строк без учёта регистра (case-insensitive).
;            Символы приводятся к верхнему регистру перед сравнением.
; Аргументы:
;   [bp+arg1] = string1 - указатель на первую строку
;   [bp+arg2] = string2 - указатель на вторую строку
; Возвращает:
;   ax < 0 - если string1 лексикографически меньше string2
;   ax = 0 - если строки равны
;   ax > 0 - если string1 лексикографически больше string2
; ============================================================================
stricmp proc near
    push bp
    mov bp, sp
    push si
    push di

    mov si, word ptr [bp+arg1]     ; si = первая строка
    mov di, word ptr [bp+arg2]     ; di = вторая строка

stricmp_loop:
    mov al, byte ptr [si]          ; символ из первой строки
    mov ah, byte ptr [di]          ; символ из второй строки
    
    ; Преобразуем AL в верхний регистр (если строчная буква)
    cmp al, 'a'
    jb stricmp_check_ah            ; если меньше 'a' - не строчная
    cmp al, 'z'
    ja stricmp_check_ah            ; если больше 'z' - не строчная
    sub al, 20h                    ; преобразуем в верхний регистр
    
stricmp_check_ah:
    ; Преобразуем AH в верхний регистр (если строчная буква)
    cmp ah, 'a'
    jb stricmp_compare
    cmp ah, 'z'
    ja stricmp_compare
    sub ah, 20h                    ; преобразуем в верхний регистр
    
stricmp_compare:
    cmp al, ah                      ; сравниваем символы
    jne stricmp_diff               ; если разные - возвращаем разницу
    test al, al                     ; конец строки?
    jz stricmp_equal               ; если да - строки равны
    inc si                          ; следующий символ первой строки
    inc di                          ; следующий символ второй строки
    jmp stricmp_loop

stricmp_diff:
    movzx ax, al                    ; расширяем до 16 бит
    movzx bx, ah
    sub ax, bx                      ; разница = al - ah
    jmp stricmp_done

stricmp_equal:
    xor ax, ax                      ; возвращаем 0 (строки равны)

stricmp_done:
    pop di
    pop si
    mov sp, bp
    pop bp
    ret
stricmp endp

; ============================================================================
; char* strchr(char* string, int c)
; Назначение: Поиск первого вхождения символа в строке. Ищет символ c 
;            в строке string, включая поиск завершающего нулевого символа.
; Аргументы:
;   [bp+arg1] = string - указатель на строку для поиска
;   [bp+arg2] = c      - искомый символ (используется младший байт)
; Возвращает:
;   ax = указатель на первое вхождение символа в строке
;   ax = 0 (NULL) если символ не найден
; ============================================================================
strchr proc near
    push bp
    mov bp, sp
    push di
    
    mov di, word ptr [bp+arg1]     ; di = указатель на строку
    mov al, byte ptr [bp+arg2]     ; al = искомый символ
    
strchr_loop:
    cmp byte ptr [di], al          ; нашли символ?
    je strchr_found                ; если да - выходим
    cmp byte ptr [di], 0           ; конец строки?
    je strchr_not_found            ; если да - символ не найден
    inc di                          ; следующий символ
    jmp strchr_loop
    
strchr_found:
    mov ax, di                      ; возвращаем указатель на символ
    jmp strchr_done
    
strchr_not_found:
    xor ax, ax                      ; возвращаем 0 (не найден)
    
strchr_done:
    pop di
    mov sp, bp
    pop bp
    ret
strchr endp

; ============================================================================
; char* strstr(char* string, char* needle)
; Назначение: Поиск первого вхождения подстроки needle в строке string.
;            Если needle - пустая строка, возвращает string.
; Аргументы:
;   [bp+arg1] = needle - указатель на искомую подстроку
;   [bp+arg2] = string - указатель на строку, в которой ищем
; Возвращает:
;   ax = указатель на первое вхождение needle в string
;   ax = 0 (NULL) если подстрока не найдена
; ============================================================================
strstr proc near
    push bp
    mov  bp, sp
    pushregs                      ; сохраняем все регистры
    push si
    push di
    push bx

    mov  di, word ptr [bp+arg2]   ; di = string (где ищем)
    mov  si, word ptr [bp+arg1]   ; si = needle (что ищем)
    mov  bx, di                    ; bx = текущая позиция в string

    ; Проверяем особые случаи
    cmp  byte ptr [di], 0         ; пустая строка?
    je   strstr_di_zero
    cmp  byte ptr es:[si], 0      ; пустая подстрока?
    jne  strstr_not_empty
    mov  ax, di                    ; возвращаем string
    jmp  strstr_done

strstr_not_empty:
strstr_search_loop:
    mov  di, bx                    ; начинаем с текущей позиции
    mov  si, word ptr [bp+arg1]   ; сбрасываем needle на начало

strstr_compare:
    mov  cl, byte ptr [di]        ; символ из string
    mov  ch, byte ptr es:[si]     ; символ из needle

    test ch, ch                    ; конец needle?
    jz   strstr_success            ; если да - нашли подстроку

    cmp  cl, ch                    ; сравниваем символы
    jne  strstr_next_position     ; если разные - идём дальше

    test cl, cl                    ; конец string?
    jz   strstr_success

    inc  di                        ; следующий символ string
    inc  si                        ; следующий символ needle
    jmp  strstr_compare

strstr_next_position:
    inc  bx                        ; следующая начальная позиция
    cmp  byte ptr [bx], 0         ; конец string?
    jnz  strstr_search_loop       ; если нет - продолжаем поиск

    xor  ax, ax                    ; не найдено - возвращаем 0
    jmp  strstr_done

strstr_success:
    mov  ax, bx                    ; возвращаем позицию начала подстроки

strstr_done:
    pop  bx
    pop  di
    pop  si
    mov  sp, bp
    pop  bp
    ret

strstr_di_zero:
    mov ax, di                     ; возвращаем string (пустая строка)
    jmp strstr_done
strstr endp

; ============================================================================
; int strcmp(const char* string1, const char* string2)
; Назначение: Посимвольное сравнение двух строк с учётом регистра.
;            Сравнение происходит до первого несовпадающего символа или
;            до конца одной из строк.
; Аргументы:
;   [bp+arg1] = string1 - указатель на первую строку
;   [bp+arg2] = string2 - указатель на вторую строку
; Возвращает:
;   ax < 0 - если string1 лексикографически меньше string2
;   ax = 0 - если строки равны
;   ax > 0 - если string1 лексикографически больше string2
; ============================================================================
strcmp proc near
    push bp
    mov bp, sp
    push si
    push di
    
    mov si, word ptr [bp+arg1]     ; si = первая строка
    mov di, word ptr [bp+arg2]     ; di = вторая строка
    
strcmp_loop:
    mov al, byte ptr [si]          ; символ из первой строки
    mov ah, byte ptr [di]          ; символ из второй строки
    cmp al, ah                      ; сравниваем
    jne strcmp_diff                ; если разные - возвращаем разницу
    test al, al                     ; конец строки?
    jz strcmp_equal                ; если да - строки равны
    inc si                          ; следующий символ первой
    inc di                          ; следующий символ второй
    jmp strcmp_loop
    
strcmp_diff:
    movzx ax, al                    ; расширяем до 16 бит
    movzx bx, ah
    sub ax, bx                      ; разница
    jmp strcmp_done
    
strcmp_equal:
    xor ax, ax                      ; возвращаем 0
    
strcmp_done:
    pop di
    pop si
    mov sp, bp
    pop bp
    ret
strcmp endp

; ============================================================================
; char* strcpy(char* dest, const char* src)
; Назначение: Копирует строку src в буфер dest, включая завершающий ноль.
;            Буфер dest должен быть достаточно большим для размещения копии.
; Аргументы:
;   [bp+arg1] = dest - указатель на буфер назначения
;   [bp+arg2] = src  - указатель на исходную строку
; Возвращает:
;   ax = указатель на dest
; ============================================================================
strcpy proc near
    push bp
    mov bp, sp
    push di
    push si
    
    mov di, word ptr [bp+arg1]     ; di = dest
    mov si, word ptr [bp+arg2]     ; si = src
    
strcpy_loop:
    mov dl, byte ptr [si]          ; читаем символ из src
    mov byte ptr [di], dl          ; записываем в dest
    test dl, dl                     ; конец строки?
    jz strcpy_done                 ; если да - выходим
    inc si                          ; следующий символ src
    inc di                          ; следующая позиция dest
    jmp strcpy_loop
    
strcpy_done:
    mov ax, word ptr [bp+arg1]     ; возвращаем dest
    pop si
    pop di
    mov sp, bp
    pop bp
    ret
strcpy endp

; ============================================================================
; int strlen(const char *str)
; Назначение: Вычисляет длину строки в байтах (без учёта завершающего нуля).
; Аргументы:
;   [bp+arg1] = str - указатель на строку
; Возвращает:
;   ax = длина строки (количество символов до завершающего нуля)
; ============================================================================
strlen proc near
    push bp
    mov bp, sp
    push di
    
    mov di, word ptr [bp+arg1]     ; di = указатель на строку
    xor ax, ax                      ; ax = 0 (счётчик длины)
    
strlen_loop:
    cmp byte ptr [di], 0           ; конец строки?
    jz strlen_done                 ; если да - выходим
    inc ax                          ; увеличиваем счётчик
    inc di                          ; следующий символ
    jmp strlen_loop
    
strlen_done:
    pop di
    mov sp, bp
    pop bp
    ret
strlen endp

; ============================================================================
; word split_to_lines_v2(word seg_str)
; Назначение:Разбивает текст на строки
;            по символам \n. Удаляет \r если он присутствует перед \n.
;            Каждая строка копируется в отдельный блок памяти.
; Аргументы:
;   [bp+arg1] = seg_str - сегмент исходного текста
; Возвращает:
;   ax = сегмент массива указателей (слов) на строки
;   cx = количество строк
;   ax = 0, cx = 0 при ошибке или пустом тексте
; ============================================================================

split_to_lines_v2 proc near
    push bp
    mov bp, sp
    sub sp, 8                      ; [bp-2] = line_count
                                   ; [bp-4] = start_pos
                                   ; [bp-6] = arr_seg
                                   ; [bp-8] = arr_idx
    pushregs si, di, ds, es, bx, cx, dx
    
    ; Инициализация
    mov word ptr [bp-2], 0         ; line_count = 0
    mov word ptr [bp-4], 0         ; start_pos = 0
    mov word ptr [bp-6], 0         ; arr_seg = 0
    mov word ptr [bp-8], 0         ; arr_idx = 0
    
    mov es, word ptr [bp+arg1]     ; es = сегмент текста
    
    ; Проверяем, не пустой ли текст
    cmp byte ptr es:[0], 0
    je sl2_empty
    
    ; --- ПЕРВЫЙ ПРОХОД: считаем количество строк ---
    xor di, di                     ; di = текущая позиция
    xor cx, cx                     ; cx = счетчик строк (пока 0)
    
count_loop:
    mov al, byte ptr es:[di]
    test al, al                    ; конец текста?
    jz count_done
    cmp al, 0Ah                    ; \n ?
    jne count_next
    inc cx                         ; увеличиваем счетчик строк
count_next:
    inc di
    jmp count_loop
    
count_done:
    ; Если текст не пустой, минимум 1 строка
    cmp di, 0
    je sl2_empty
    inc cx                         ; +1 за последнюю строку
    mov word ptr [bp-2], cx        ; сохраняем количество строк
    
    ; --- Выделяем память под массив указателей ---
    shl cx, 1                      ; умножаем на 2 (размер слова)
    push cx
    call AllocMem
    add sp, 2
    test ax, ax
    jz sl2_empty
    
    mov word ptr [bp-6], ax        ; сохраняем сегмент массива
    
    ; --- ВТОРОЙ ПРОХОД: копируем строки ---
    xor di, di                     ; di = текущая позиция в тексте
    mov word ptr [bp-4], 0         ; start_pos = 0
    mov word ptr [bp-8], 0         ; arr_idx = 0
    
parse_loop:
    mov al, byte ptr es:[di]
    test al, al                    ; конец текста?
    jz process_last
    
    cmp al, 0Ah                    ; \n ?
    je process_current
    
    inc di
    jmp parse_loop
    
process_current:
    ; Нашли \n, обрабатываем текущую строку
    mov cx, di                     ; cx = позиция \n
    sub cx, word ptr [bp-4]        ; cx = длина строки (включая возможный \r)
    
    ; Проверяем на \r перед \n
    cmp cx, 0
    je skip_empty_line
    
    push di
    dec di
    cmp byte ptr es:[di], 0Dh      ; \r ?
    pop di
    jne no_cr_skip
    dec cx                         ; убираем \r
no_cr_skip:
    
    ; Выделяем память под строку
    push cx                        ; сохраняем длину
    inc cx                         ; +1 для нуля
    push cx
    call AllocMem
    add sp, 2
    pop cx                         ; восстанавливаем длину
    test ax, ax
    jz sl2_error
    
    ; Копируем строку
    push es
    push ds
    
    mov es, ax                     ; es = сегмент новой строки
    mov ds, word ptr [bp+arg1]     ; ds = сегмент исходного текста
    mov si, word ptr [bp-4]        ; si = начало строки
    xor di, di                     ; di = 0 в новой строке
    
    push cx                        ; сохраняем счетчик
    jcxz copy_done
copy_loop:
    mov al, byte ptr [si]
    mov byte ptr es:[di], al
    inc si
    inc di
    loop copy_loop
copy_done:
    mov byte ptr es:[di], 0        ; завершающий ноль
    pop cx                         ; восстанавливаем счетчик
    
    pop ds
    pop es                         ; es = сегмент исходного текста
    
    ; Сохраняем указатель в массив
    push ds
    mov ds, word ptr [bp-6]        ; ds = массив указателей
    mov bx, word ptr [bp-8]        ; bx = индекс в массиве
    mov word ptr [bx], ax          ; сохраняем сегмент строки
    add word ptr [bp-8], 2         ; следующий индекс
    pop ds
    
skip_empty_line:
    ; Переходим к следующей строке
    inc di                         ; пропускаем \n
    mov word ptr [bp-4], di        ; новое начало
    jmp parse_loop
    
process_last:
    ; Обрабатываем последнюю строку (после последнего \n)
    mov cx, di
    sub cx, word ptr [bp-4]        ; длина последней строки
    jz sl2_done                    ; если 0 - выходим
    
    ; Выделяем память
    push cx
    inc cx
    push cx
    call AllocMem
    add sp, 2
    pop cx
    test ax, ax
    jz sl2_error
    
    ; Копируем
    push es
    push ds
    
    mov es, ax
    mov ds, word ptr [bp+arg1]
    mov si, word ptr [bp-4]
    xor di, di
    
    jcxz last_copy_done
last_copy_loop:
    mov al, byte ptr [si]
    mov byte ptr es:[di], al
    inc si
    inc di
    loop last_copy_loop
last_copy_done:
    mov byte ptr es:[di], 0
    
    pop ds
    pop es
    
    ; Сохраняем в массив
    push ds
    mov ds, word ptr [bp-6]
    mov bx, word ptr [bp-8]
    mov word ptr [bx], ax
    pop ds
    
sl2_done:
    mov cx, word ptr [bp-2]        ; количество строк
    mov ax, word ptr [bp-6]        ; сегмент массива
    jmp sl2_exit
    
sl2_empty:
    xor ax, ax
    xor cx, cx
    jmp sl2_exit
    
sl2_error:
    ; Ошибка выделения памяти
    xor ax, ax
    xor cx, cx
    
sl2_exit:
    popregs dx, cx, bx, es, ds, di, si
    mov sp, bp
    pop bp
    ret
split_to_lines_v2 endp