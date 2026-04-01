ERROR_SUCCESS equ 0 		;нет ошибки
ERROR_EMPTY_INPUT equ 1 	;пустая строка
ERROR_INVALID_CHAR equ 2 	;недопустимый символ в числе
ERROR_NO_OPERATOR equ 3 	;не найден оператор
ERROR_INVALID_OPERATOR equ 4 	;оператор не из списка +-*/%
ERROR_NO_SECOND_OPERAND equ 5 	;нет второго числа
ERROR_OVERFLOW_NUM equ 6 	;число вне диапазона -32768..32767
ERROR_DIV_ZERO equ 7 		;деление на ноль
ERROR_DIV_OVERFLOW equ 8 	;переполнение частного
ERROR_FORMAT equ 9 		;общая ошибка формата 
ERROR_MULTIPLE_SIGNS equ 10 	;несколько знаков минуса