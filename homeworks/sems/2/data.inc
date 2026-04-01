;буфферы 
base_buffer db 5 dup(?)				; для ввода СС
itoa_buffer db 16 dup(?)			; для вывода числа-результата
expression_buffer db 128 dup(?)		; для ввода самого выражения

; строки-приглашения				
str_base db "Choose the base (DEC - 1 | HEX - 2): ", 0
str_expression db "Write the expression (Num1 OP Num2): ", 0
str_res_DEC db "Result_DEC: ", 0
str_res_HEX db "Result_HEX: ", 0

; строки-ошибки
msg_success         db "OK", 0
msg_empty_input     db "Error: Empty string", 0
msg_invalid_char    db "Error: Invalid character", 0
msg_no_operator     db "Error: Operator not found", 0
msg_invalid_op      db "Error: Invalid operator", 0
msg_no_second       db "Error: No second operand", 0
msg_overflow_num    db "Error: Number out of range", 0
msg_div_zero        db "Error: Division by zero", 0
msg_div_overflow    db "Error: Quotient overflow", 0
msg_format          db "Error: Invalid input format", 0
msg_mult_signs      db "Error: Multiple minus signs", 0

;таблица строк-ошибок, где каждый индекс соответствует коду ошибки
error_table dw offset msg_success        
            dw offset msg_empty_input    ; индекс 1 = ERROR_EMPTY_INPUT
            dw offset msg_invalid_char   ; индекс 2 = ERROR_INVALID_CHAR
            dw offset msg_no_operator    ; индекс 3 = ERROR_NO_OPERATOR
            dw offset msg_invalid_op     ; индекс 4 = ERROR_INVALID_OPERATOR
            dw offset msg_no_second      ; индекс 5 = ERROR_NO_SECOND_OPERAND
            dw offset msg_overflow_num   ; индекс 6 = ERROR_OVERFLOW_NUM
            dw offset msg_div_zero       ; индекс 7 = ERROR_DIV_ZERO
            dw offset msg_div_overflow   ; индекс 8 = ERROR_DIV_OVERFLOW
            dw offset msg_format         ; индекс 9 = ERROR_FORMAT
            dw offset msg_mult_signs     ; индекс 10 = ERROR_MULTIPLE_SIGNS

num1 dw 0							; первое число
num2 dw 0							; второе число
operator db ?						; оператор
input_base 		dw 10    			; по умолчанию десятичная
result_low      dw 0        		; младшие 16 бит результата
result_high     dw 0        		; старшие 16 бит (для умножения)
is_result_32bit db 0        		; флаг: 1 = результат 32-битный
newline         db 0Dh, 0Ah, '$'   	; перенос строки для вывода
