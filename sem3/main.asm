include <include/header.asm>

ERR_OPEN_FIRST   equ 1
ERR_OPEN_SECOND  equ 2
ERR_SIZE_FIRST   equ 3
ERR_SIZE_SECOND  equ 4
ERR_ALLOC_FIRST  equ 5
ERR_ALLOC_SECOND equ 6
ERR_READ_FIRST   equ 7
ERR_READ_SECOND  equ 8
ERR_ALLOC_LINES1 equ 9
ERR_ALLOC_LINES2 equ 10
ERR_ALLOC_LINE   equ 11

DSEG segment para public use16 "DATA"
	; test data
	test_str1    db "Hello", 0
	test_str2    db "World", 0
	test_str3    db "HelloWorld", 0
	test_str4    db "HELLO", 0
	test_str5    db "hello", 0
	test_str6    db "Test string for search", 0
	test_str7    db "string", 0
	test_str8    db "12345", 0
	test_str9    db "   -123abc", 0
	test_null    db 0
	test_hex1    db "2A", 0
	test_hex2    db "0x1F4", 0
	test_invalid db "42abc", 0
	test_empty   db 0
	test_mixed1  db "AsSeMbLy", 0
	test_mixed2  db "assembly", 0
	test_decimal db "123", 0
	test_octal   db "77", 0

	; test buffer
	test_buf db 256 dup(0)

	; test messages
	msg_test_header  db "=== TEST ===", 0
	msg_ok           db "OK", 0
	msg_fail         db "FAIL", 0
	msg_strlen       db "strlen: ", 0
	msg_strcpy       db "strcpy: ", 0
	msg_strcat       db "strcat: ", 0
	msg_strcmp       db "strcmp: ", 0
	msg_stricmp      db "stricmp: ", 0
	msg_strchr       db "strchr: ", 0
	msg_strstr       db "strstr: ", 0
	msg_strtol       db "strtol: ", 0
	msg_strdup       db "strdup: ", 0
	msg_puts         db "puts: ", 0
	msg_crlf         db "crlf: ", 0
	msg_strtol_adv   db "strtol advanced: ", 0
	msg_strchr_null  db "strchr null: ", 0
	msg_strstr_empty db "strstr empty needle: ", 0
	msg_strcat_empty db "strcat empty source: ", 0
	msg_stricmp_case db "stricmp case mix: ", 0
	msg_mem_alloc    db "mem_alloc: ", 0
	msg_mem_free     db "mem_free: ", 0
	msg_mem_realloc  db "mem_realloc: ", 0

	; task messages
	msg_task_header   db "TODO: do task", 13, 10, "=== TASK ===", 0
	msg_prompt1       db "enter file1 path: ", 0
	msg_prompt2       db "enter file2 path: ", 0
	msg_open_err      db "error: failed to open file", 0
	msg_size_err      db "error: failed to get size of file", 0
	msg_alloc_err     db "error: memory allocation failed", 0
	msg_read_err      db "error: failed to read file", 0
	msg_identical     db "files are identical", 0
	msg_line_count    db "line count differs: file1 has ", 0
	msg_lines         db " lines.", 0
	msg_line_count2   db " lines, file2 has ", 0
	msg_line_mismatch db "line ", 0
	msg_char_mismatch db " differs at character ", 0
	msg_newline       db 13, 10, 0
	msg_colon_space   db ": ", 0

	endptr_storage dw 0
DSEG ends

CSEG segment readonly para public use16 "CODE"
include <include/all.asm>

start:
	init

	call do_test
	call do_task

	call exit_zero

code_end:
CSEG ends
end start
