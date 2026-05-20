BUTTONS_DEFAULT_COLOR equ 1
BUTTONS_BLINK_COLOR equ 2


BUTTON_STRUCT_SIZE equ 26
FIRST_BUTTON_OFFSET equ BUTTON_STRUCT_SIZE
SECOND_BUTTON_OFFSET equ BUTTON_STRUCT_SIZE * 2
THIRD_BUTTON_OFFSET equ BUTTON_STRUCT_SIZE * 3
FOURTH_BUTTON_OFFSET equ BUTTON_STRUCT_SIZE * 4

_buttons label word
; ---------- Кнопка 0 (ID = 0) ---------- \
    dw 0                ; ID = 0
    ; Строка "Clear screen" (12 символов + 8 нулей)
    db 'C', 'l', 'e', 'a', 'r', ' ', 's', 'c', 'r', 'e', 'e', 'n'
    db 8 dup (0)        ; выравнивание до 20 байт
    dw 9               ; третье поле y = 9
    dw BUTTONS_DEFAULT_COLOR                ; четвёртое поле color = 1

; ---------- Кнопка 1 (ID = 1) ----------
    dw 1                ; ID = 1
    ; Строка "Flush" (5 символов + 15 нулей)
    db 'F', 'l', 'u', 's', 'h'
    db 15 dup (0)       ; выравнивание до 20 байт
    dw 12               ; третье поле y = 12
    dw BUTTONS_DEFAULT_COLOR                ; четвёртое поле color = 1

; ---------- Кнопка 2 (ID = 2) ----------
    dw 2                ; ID = 2
    ; Строка "New File" (8 символов + 12 нулей)
    db 'N', 'e', 'w', ' ', 'F', 'i', 'l', 'e'
    db 12 dup (0)       ; выравнивание до 20 байт
    dw 16               ; третье поле y = 16
    dw BUTTONS_DEFAULT_COLOR                ; четвёртое поле color = 1

; ---------- Кнопка 3 (ID = 3) ----------
    dw 3                ; ID = 3
    ; Строка "Exit" (4 символа + 16 нулей)
    db 'E', 'x', 'i', 't'
    db 16 dup (0)       ; выравнивание до 20 байт
    dw 20               ; третье поле y = 20
    dw BUTTONS_DEFAULT_COLOR                ; четвёртое поле color = 1