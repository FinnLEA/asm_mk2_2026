.386

stack segment para stack use16
	db 4096 dup(?)
stack ends

data segment para public use16
	test_str1	db "Hello", 0
	test_str2	db "Hello, World!", 0
	test_str3	db " World", 0
	test_str4	db "abc", 0
	test_str5	db "abd", 0
	test_str6	db "ab", 0
	test_str7	db "ABC", 0
	test_str8	db "abc", 0
	test_buffer	db 256 dup(0)
	
	msg_dup	db "Duplicating 'Hello' -> ", 0
	msg_dup_ok	db "OK", 13, 10, 0
	msg_dup_fail	db "FAIL (memory allocation)", 13, 10, 0
	
	test_num1	db "123", 0
	test_num2	db "-456", 0
	test_num3	db "0x10", 0
	test_end_ptr	dw 0
	
	msg_tos1	db "String '123' -> number: ", 0
	msg_tos2	db "String '-456' -> number: ", 0
	msg_tos3	db "String '0x10' -> number: ", 0
	
	msg1	db "Length of 'Hello' = ", 0
	msg2	db "Length of 'Hello, World!' = ", 0
	msg_crlf	db 13, 10, 0
	
	msg_find_l	db "Finding 'l' in 'Hello' at position: ", 0
	msg_find_x	db "Finding 'x' in 'Hello': ", 0
	msg_found	db "found", 13, 10, 0
	msg_not_found	db "not found", 13, 10, 0
	msg_icmp1	db "Comparing 'ABC' vs 'abc' (case insensitive): ", 0
	msg_cpy	db "Copy: ", 0
	
	msg_cmp1	db "Comparing 'abc' vs 'abc' result: ", 0
	msg_cmp2	db "Comparing 'abc' vs 'abd' result: ", 0
	msg_cmp3	db "Comparing 'abc' vs 'ab' result: ", 0
	
	msg_cat	db "Concatenating ' World!' to buffer: ", 0
	msg_str	db "Finding 'World' in 'Hello, World!' at position: ", 0
data ends

code segment para public use16
assume cs:code, ds:data, ss:stack

include memory.inc
include strings.inc
include filefunc.inc

print_num proc near
	push ax
	push bx
	push cx
	push dx
	
	cmp  ax, 0
	jge  pn_positive
	
	push ax
	mov  dl, '-'
	mov  ah, 02h
	int  21h
	pop  ax
	neg  ax
	
pn_positive:
	mov  cx, 0
	mov  bx, 10
	
pn_div:
	xor  dx, dx
	div  bx
	push dx
	inc  cx
	cmp  ax, 0
	jne  pn_div
	
pn_write:
	pop  dx
	add  dl, '0'
	mov  ah, 02h
	int  21h
	loop pn_write
	
	pop  dx
	pop  cx
	pop  bx
	pop  ax
	ret
print_num endp

test_str_len proc near
	push offset msg1
	call put_str
	add  sp, 2
	
	push offset test_str1
	call str_len
	add  sp, 2
	
	call print_num
	
	push offset msg_crlf
	call put_str
	add  sp, 2
	
	push offset msg2
	call put_str
	add  sp, 2
	
	push offset test_str2
	call str_len
	add  sp, 2
	
	call print_num
	
	push offset msg_crlf
	call put_str
	add  sp, 2
	
	ret
test_str_len endp

test_str_chr proc near
	push offset msg_find_l
	call put_str
	add  sp, 2
	
	push 'l'
	push offset test_str1
	call str_chr
	add  sp, 4
	
	cmp  ax, 0
	je  sc_not_found
	
	sub  ax, offset test_str1
	call print_num
	push offset msg_crlf
	call put_str
	add  sp, 2
	jmp  sc_cont
	
sc_not_found:
	push offset msg_not_found
	call put_str
	add  sp, 2
	
sc_cont:
	push offset msg_find_x
	call put_str
	add  sp, 2
	
	push 'x'
	push offset test_str1
	call str_chr
	add  sp, 4
	
	cmp  ax, 0
	jne  sc_found
	
	push offset msg_not_found
	call put_str
	add  sp, 2
	jmp  sc_done
	
sc_found:
	push offset msg_found
	call put_str
	add  sp, 2
	
sc_done:
	ret
test_str_chr endp

test_str_cmp proc near
	push offset msg_cmp1
	call put_str
	add  sp, 2
	
	push offset test_str4
	push offset test_str4
	call str_cmp
	add  sp, 4
	
	call print_num
	push offset msg_crlf
	call put_str
	add  sp, 2
	
	push offset msg_cmp2
	call put_str
	add  sp, 2
	
	push offset test_str4
	push offset test_str5
	call str_cmp
	add  sp, 4
	
	call print_num
	push offset msg_crlf
	call put_str
	add  sp, 2
	
	push offset msg_cmp3
	call put_str
	add  sp, 2
	
	push offset test_str4
	push offset test_str6
	call str_cmp
	add  sp, 4
	
	call print_num
	push offset msg_crlf
	call put_str
	add  sp, 2
	
	ret
test_str_cmp endp

test_str_cat proc near
	push offset msg_cat
	call put_str
	add  sp, 2
	
	mov  si, offset test_str1
	mov  di, offset test_buffer
copy_hello:
	mov  al, [si]
	mov  [di], al
	inc  si
	inc  di
	test al, al
	jnz  copy_hello
	
	push offset test_str3
	push offset test_buffer
	call str_cat
	add  sp, 4
	
	push offset test_buffer
	call put_str
	add  sp, 2
	
	push offset msg_crlf
	call put_str
	add  sp, 2
	
	ret
test_str_cat endp

test_str_str proc near
	push offset msg_str
	call put_str
	add  sp, 2
	
	push offset test_str3
	push offset test_str2
	call str_str
	add  sp, 4
	
	cmp  ax, 0
	je   tss_not_found
	
	sub  ax, offset test_str2
	call print_num
	push offset msg_crlf
	call put_str
	add  sp, 2
	jmp  tss_done
	
tss_not_found:
	push offset msg_not_found
	call put_str
	add  sp, 2
	
tss_done:
	ret
test_str_str endp

test_str_icmp proc near
	push offset msg_icmp1
	call put_str
	add  sp, 2
	
	push offset test_str8
	push offset test_str7
	call str_icmp
	add  sp, 4
	
	call print_num
	push offset msg_crlf
	call put_str
	add  sp, 2
	
	ret
test_str_icmp endp

test_str_to_s proc near
	push offset msg_tos1
	call put_str
	add  sp, 2
	
	push 10
	push offset test_end_ptr
	push offset test_num1
	call str_to_s
	add  sp, 6
	
	call print_num
	push offset msg_crlf
	call put_str
	add  sp, 2
	
	push offset msg_tos2
	call put_str
	add  sp, 2
	
	push 10
	push offset test_end_ptr
	push offset test_num2
	call str_to_s
	add  sp, 6
	
	call print_num
	push offset msg_crlf
	call put_str
	add  sp, 2
	
	push offset msg_tos3
	call put_str
	add  sp, 2
	
	push 0
	push offset test_end_ptr
	push offset test_num3
	call str_to_s
	add  sp, 6
	
	call print_num
	push offset msg_crlf
	call put_str
	add  sp, 2
	
	ret
test_str_to_s endp

test_str_dup proc near
	push offset msg_dup
	call put_str
	add  sp, 2
	
	push offset test_str1
	call str_dup
	add  sp, 2
	
	cmp  ax, 0
	je   td_fail
	
	push ds
	mov  ds, ax
	push 0
	call put_str
	add  sp, 2
	pop  ds
	
	push offset msg_crlf
	call put_str
	add  sp, 2
	
	push ax
	call mem_free
	add  sp, 2
	
	push offset msg_dup_ok
	call put_str
	add  sp, 2
	jmp  td_done
	
td_fail:
	push offset msg_dup_fail
	call put_str
	add  sp, 2
	
td_done:
	ret
test_str_dup endp

test_str_cpy proc near
	push offset msg_cpy
	call put_str
	add  sp, 2
	
	push offset test_buffer
	push offset test_str1
	call str_cpy
	add  sp, 4
	
	push offset test_buffer
	call put_str
	add  sp, 2
	
	push offset msg_crlf
	call put_str
	add  sp, 2
	
	ret
test_str_cpy endp

start:
	mov  ax, data
	mov  ds, ax
	mov  ax, stack
	mov  ss, ax
	
	call test_str_len
	call test_str_chr
	call test_str_cmp
	call test_str_cat
	call test_str_str
	call test_str_icmp
	call test_str_to_s
	call test_str_dup
	call test_str_cpy
	
	push 0
	call exit
	add  sp, 2

code ends
end start