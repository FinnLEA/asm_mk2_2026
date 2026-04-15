.386

arg1 equ 4
arg2 equ 6
arg3 equ 8
arg4 equ 10

var1 equ -2
var2 equ -4
var3 equ -6
var4 equ -8

ERROR_OPENFILE		equ -1
ERROR_READFILE		equ -2
ERROR_ALLOC			equ -3
ERROR_SPLITLINES    equ -4

max_size equ 20

stack segment para stack
	db 100h dup(?)
stack ends

data segment para public	
	prompt1    db "Enter first filename: ", 0
	prompt2    db "Enter second filename: ", 0
	msg_equal  db "Files are identical.", 0

	emsg_overflow 		db "Error overflow", 0
	emsg_openfile 		db "Error opening file", 0
	emsg_allocmem 		db "Out of memory", 0
	emsg_splitlines 	db "Error split lines in file", 0

	filename1 db 20 dup(0) 
	filename2 db 20 dup(0) 

    t_hello     db "Hello, kitty!", 0        
    t_world     db "kitty", 0                  
    t_hello_w   db "Hello, kitty! Meow~", 0    
    t_HELLO_UPPER     db "HELLO, KITTY!", 0          
    t_empty     db 0
    t_num_dec   db "  -123", 0
    t_num_hex   db "0x2A", 0
    t_num_bin   db "1010", 0
    t_helloworld db "Hello, kitty!kitty", 0    ; strcat

    t_buf1      db 40 dup(0)
    t_buf2      db 40 dup(0)

    msg_t_strlen    db "[strlen] ", 0
    msg_t_strstr    db "[strstr] ", 0
    msg_t_strchr    db "[strchr] ", 0
    msg_t_strcpy    db "[strcpy] ", 0
    msg_t_strcat    db "[strcat] ", 0
    msg_t_strcmp    db "[strcmp] ", 0
    msg_t_stricmp   db "[stricmp]", 0
    msg_t_strtol    db "[strtol] ", 0
    msg_t_strdup    db "[strdup] ", 0
    
    msg_ok          db " OK! ", 0
    msg_fail        db " FAIL! ", 0
    msg_sep         db "==================", 0
    msg_passed      db "Passed: ", 0
    msg_failed      db "Failed: ", 0
    msg_test_start  db "Starting string tests...", 0
    msg_test_end    db "All tests completed!", 0
	
data ends

code segment para public use16

assume cs:code,ds:data,ss:stack

include strings.inc
include memory.inc
include file.inc
include testf.inc
include compare.inc


start:
    mov ax, data
    mov ds, ax
    mov ax, stack
    mov ss, ax
    mov sp, 100h

    lea dx, msg_test_start
    push dx
    call _putstr
    add sp, 2
    call _putnewline

    call run_string_tests			; all string fync
	;call _tests					; try to cmp arrays strings
    call _exit0

end_code_seg:
code ends
end start