str_len proc near
	push bp
	mov  bp, sp
	push di

	mov  di, word ptr [bp + 4]
	xor  ax, ax

len_loop:
	cmp  byte ptr [di], 0
	je   len_done

	inc  ax
	inc  di
	jmp  len_loop

len_done:
	pop  di
	pop  bp
	ret

str_len endp



str_chr proc near
	push bp
	mov  bp, sp
	push bx

	mov  di, word ptr [bp + 4]
	mov  al, byte ptr [bp + 6]

chr_loop:
	mov  bl, byte ptr [di]
	cmp  bl, al
	je   chr_found

	test bl, bl
	jz   chr_not_found

	inc  di
	jmp  chr_loop

chr_found:
	mov  ax, di
	pop  bx
	pop  bp
	ret

chr_not_found:
	xor  ax, ax
	pop  bx
	pop  bp
	ret

str_chr endp



str_cmp proc near
	push bp
	mov  bp, sp
	push si
	push di

	mov  si, word ptr [bp + 4]
	mov  di, word ptr [bp + 6]

cmp_loop:
	mov  al, byte ptr [si]
	mov  ah, byte ptr [di]

	cmp  al, ah
	jne  cmp_diff

	test al, al
	jz   cmp_equal

	inc  si
	inc  di
	jmp  cmp_loop

cmp_diff:
	mov  cx, ax
	movzx ax, ch
	movzx bx, cl
	sub  ax, bx
	jmp  cmp_done

cmp_equal:
	xor  ax, ax

cmp_done:
	pop  di
	pop  si
	pop  bp
	ret

str_cmp endp



; char* str_cpy(char* dst, const char* src)
str_cpy proc near
	push bp
	mov  bp, sp
	push si
	push di
	
	mov  di, word ptr [bp + 4]
	mov  si, word ptr [bp + 6]
	mov  ax, di
	
cpy_loop:
	mov  dl, byte ptr [si]
	mov  byte ptr [di], dl
	inc  si
	inc  di
	test dl, dl
	jnz  cpy_loop
	
	pop  di
	pop  si
	mov  sp, bp
	pop  bp
	ret
str_cpy endp



str_cat proc near
	push bp
	mov  bp, sp
	push si
	push di

	mov  di, word ptr [bp + 4]
	mov  si, word ptr [bp + 6]
	mov  ax, di

cat_find_end:
	cmp  byte ptr [di], 0
	je   cat_copy

	inc  di
	jmp  cat_find_end

cat_copy:
	mov  dl, byte ptr [si]
	mov  byte ptr [di], dl

	test dl, dl
	jz   cat_done

	inc  si
	inc  di
	jmp  cat_copy

cat_done:
	pop  di
	pop  si
	mov  sp, bp
	pop  bp
	ret

str_cat endp



str_str proc near
	push bp
	mov  bp, sp
	push si
	push di
	push bx

	mov  di, word ptr [bp + 4]
	mov  si, word ptr [bp + 6]
	mov  bx, di

	cmp  byte ptr [si], 0
	jne  ss_not_empty

	mov  ax, di
	jmp  ss_done

ss_not_empty:
	cmp  byte ptr [di], 0
	je   ss_not_found

ss_search_loop:
	mov  di, bx
	mov  si, word ptr [bp + 6]

ss_compare:
	mov  cl, byte ptr [di]
	mov  ch, byte ptr [si]

	test ch, ch
	jz   ss_found

	cmp  cl, ch
	jne  ss_next_pos

	test cl, cl
	jz   ss_found

	inc  di
	inc  si
	jmp  ss_compare

ss_next_pos:
	inc  bx
	cmp  byte ptr [bx], 0
	jnz  ss_search_loop

ss_not_found:
	xor  ax, ax
	jmp  ss_done

ss_found:
	mov  ax, bx

ss_done:
	pop  bx
	pop  di
	pop  si
	mov  sp, bp
	pop  bp
	ret

str_str endp



str_icmp proc near
	push bp
	mov  bp, sp
	push si
	push di

	mov  si, word ptr [bp + 4]
	mov  di, word ptr [bp + 6]

icmp_loop:
	mov  al, byte ptr [si]
	mov  ah, byte ptr [di]

	cmp  al, 'a'
	jb   icmp_skip_al
	cmp  al, 'z'
	ja   icmp_skip_al
	sub  al, 20h

icmp_skip_al:
	cmp  ah, 'a'
	jb   icmp_skip_ah
	cmp  ah, 'z'
	ja   icmp_skip_ah
	sub  ah, 20h

icmp_skip_ah:
	cmp  al, ah
	jne  icmp_diff

	test al, al
	jz   icmp_equal

	inc  si
	inc  di
	jmp  icmp_loop

icmp_diff:
	mov  cx, ax
	movzx ax, ch
	movzx bx, cl
	sub  ax, bx
	jmp  icmp_done

icmp_equal:
	xor  ax, ax

icmp_done:
	pop  di
	pop  si
	mov  sp, bp
	pop  bp
	ret

str_icmp endp



str_dup proc near
	push bp
	mov  bp, sp
	push di
	push si
	push bx
	push es

	push word ptr [bp + 4]
	call str_len
	add  sp, 2

	test ax, ax
	jz   sd_done

	inc  ax
	push ax
	call mem_alloc
	add  sp, 2

	test ax, ax
	jz   sd_failed

	mov  es, ax

	mov  si, word ptr [bp + 4]
	xor  di, di

sd_copy:
	mov  bl, byte ptr [si]
	mov  byte ptr es:[di], bl

	inc  si
	inc  di

	test bl, bl
	jnz  sd_copy

	mov  ax, es

sd_done:
	pop  es
	pop  bx
	pop  si
	pop  di
	mov  sp, bp
	pop  bp
	ret

sd_failed:
	xor  ax, ax
	jmp  sd_done

str_dup endp



str_to_s proc near
	push bp
	mov  bp, sp
	sub  sp, 10
	push di
	push si
	push cx
	push bx
	push dx


	mov  word ptr [bp - 2], 1      
	mov  word ptr [bp - 6], 0      
	mov  byte ptr [bp - 8], 0      

	mov  di, word ptr [bp + 4]     
	mov  si, word ptr [bp + 6]     
	mov  cx, word ptr [bp + 8]     
	mov  [bp - 10], cx             

sts_skip_ws:
	mov  bl, byte ptr [di]
	test bl, bl
	jz   sts_empty

	push bx
	call is_white_space
	add  sp, 2

	test ax, ax
	jz   sts_sign

	inc  di
	jmp  sts_skip_ws

sts_sign:
	mov  bl, byte ptr [di]

	cmp  bl, '-'
	je   sts_negative
	cmp  bl, '+'
	je   sts_positive

sts_sign_done:
	mov  cx, [bp - 10]
	test cx, cx
	jz   sts_base_zero

	cmp  cx, 16
	jz   sts_base_16

sts_base_check:
	cmp  cx, 2
	jb   sts_invalid_base

	mov  word ptr [bp - 4], di

sts_convert:
	mov  bl, byte ptr [di]
	test bl, bl
	jz   sts_not_digit

	cmp  bl, '0'
	jb   sts_check_upper
	cmp  bl, '9'
	ja   sts_check_upper
	sub  bl, '0'
	jmp  sts_digit_ok

sts_check_upper:
	cmp  bl, 'A'
	jb   sts_check_lower
	cmp  bl, 'Z'
	ja   sts_check_lower
	sub  bl, 'A'
	add  bl, 10
	jmp  sts_digit_ok

sts_check_lower:
	cmp  bl, 'a'
	jb   sts_not_digit
	cmp  bl, 'z'
	ja   sts_not_digit
	sub  bl, 'a'
	add  bl, 10

sts_digit_ok:
	cmp  bl, cl
	jae  sts_invalid_digit

	cmp  byte ptr [bp - 8], 0
	jne  sts_skip_accumulate

	mov  ax, [bp - 6]
	mul  cx
	test dx, dx
	jnz  sts_overflow

	add  ax, bx
	jc   sts_overflow

	cmp  word ptr [bp - 2], -1
	je   sts_neg_limit

	cmp  ax, 32767
	ja   sts_overflow
	jmp  sts_store

sts_neg_limit:
	cmp  ax, 32768
	ja   sts_overflow

sts_store:
	mov  [bp - 6], ax
	jmp  sts_next_digit

sts_overflow:
	mov  byte ptr [bp - 8], 1

sts_skip_accumulate:
sts_next_digit:
	inc  di
	jmp  sts_convert

sts_not_digit:
	mov  ax, [bp - 4]
	cmp  di, ax
	je   sts_no_digit

	; применяем знак
	cmp  byte ptr [bp - 8], 0
	jne  sts_overflow_result

	mov  ax, [bp - 6]
	cmp  word ptr [bp - 2], -1
	jne  sts_positive_result
	neg  ax

sts_positive_result:
	mov  bx, [bp + 6]
	mov  [bx], di
	jmp  sts_done

sts_overflow_result:
	cmp  word ptr [bp - 2], -1
	je   sts_neg_overflow

	mov  ax, 32767
	jmp  sts_set_endptr

sts_neg_overflow:
	mov  ax, -32768

sts_set_endptr:
	mov  bx, [bp + 6]
	mov  [bx], di
	jmp  sts_done

sts_no_digit:
	xor  ax, ax
	mov  bx, [bp + 6]
	mov  cx, [bp + 4]
	mov  [bx], cx
	jmp  sts_done

sts_invalid_digit:
	mov  ax, [bp - 6]
	mov  word ptr [si], di
	jmp  sts_done

sts_invalid_base:
sts_empty:
	xor  ax, ax
	mov  di, [bp + 4]
	mov  word ptr [si], di
	jmp  sts_done

sts_negative:
	inc  di
	mov  word ptr [bp - 2], -1
	jmp  sts_sign_done

sts_positive:
	inc  di
	jmp  sts_sign_done

sts_base_zero:
	mov  bl, byte ptr [di]
	test bl, bl
	jz   sts_empty

	cmp  bl, '0'
	jne  sts_base_zero_dec

	inc  di
	mov  bl, byte ptr [di]
	test bl, bl
	jz   sts_base_zero_ret

	cmp  bl, 'x'
	je   sts_base_zero_hex

	mov  cx, 8
	mov  [bp - 10], cx
	jmp  sts_base_check

sts_base_zero_dec:
	mov  cx, 10
	mov  [bp - 10], cx
	jmp  sts_base_check

sts_base_zero_hex:
	inc  di
	mov  cx, 16
	mov  [bp - 10], cx
	jmp  sts_base_check

sts_base_zero_ret:
	dec  di
	mov  cx, 10
	mov  [bp - 10], cx
	jmp  sts_base_check

sts_base_16:
	cmp  byte ptr [di], '0'
	jne  sts_base_check

	cmp  byte ptr [di + 1], 'x'
	je   sts_base_16_skip

	jmp  sts_base_check

sts_base_16_skip:
	add  di, 2
	jmp  sts_base_check

sts_done:
	pop  dx
	pop  bx
	pop  cx
	pop  si
	pop  di
	mov  sp, bp
	pop  bp
	ret

str_to_s endp


is_white_space proc near
	push bp
	mov  bp, sp

	mov  al, byte ptr [bp + 4]

	cmp  al, ' '
	je   ws_yes
	cmp  al, 09h
	je   ws_yes
	cmp  al, 0Ah
	je   ws_yes
	cmp  al, 0Bh
	je   ws_yes
	cmp  al, 0Ch
	je   ws_yes
	cmp  al, 0Dh
	je   ws_yes

	xor  ax, ax
	jmp  ws_done

ws_yes:
	mov  ax, 1

ws_done:
	pop  bp
	ret

is_white_space endp





put_char proc near
	push bp
	mov  bp, sp

	mov  dx, word ptr [bp + 4]
	mov  ah, 02h
	int  21h

	mov  sp, bp
	pop  bp
	ret
put_char endp



get_char proc near
	push bp
	mov  bp, sp

	mov  ah, 01h
	int  21h

	mov  sp, bp
	pop  bp
	ret
get_char endp



put_str proc near
	push bp
	mov  bp, sp
	push cx
	push dx
	push bx
	push ax

	push word ptr [bp + 4]
	call str_len
	add  sp, 2

	mov  cx, ax
	mov  dx, word ptr [bp + 4]
	mov  ah, 40h
	mov  bx, 1
	int  21h

	pop  ax
	pop  bx
	pop  dx
	pop  cx
	mov  sp, bp
	pop  bp
	ret
put_str endp



get_str proc near
	push bp
	mov  bp, sp
	push bx
	push si

	dec  word ptr [bp + 6]    
	mov  bx, word ptr [bp + 4]
	mov  si, 0

gs_loop:
	cmp  si, word ptr [bp + 6]
	je   gs_done

	call get_char

	cmp  al, 10
	je   gs_done
	cmp  al, 13
	je   gs_done

	mov  byte ptr [bx], al
	inc  bx
	inc  si
	jmp  gs_loop

gs_done:
	mov  byte ptr [bx], 0
	call put_newline

	pop  si
	pop  bx
	mov  sp, bp
	pop  bp
	ret
get_str endp



put_newline proc near
	push bp
	mov  bp, sp

	mov  dx, 10
	push dx
	call put_char
	add  sp, 2

	mov  dx, 13
	push dx
	call put_char
	add  sp, 2

	mov  sp, bp
	pop  bp
	ret
put_newline endp


exit proc near
	push bp
	mov  bp, sp

	mov  ax, word ptr [bp + 4]
	mov  ah, 4ch
	int  21h

	mov  sp, bp
	pop  bp
	ret
exit endp



exit0 proc near
	push bp
	mov  bp, sp

	push 0
	call exit
	add  sp, 2

	mov  sp, bp
	pop  bp
	ret
exit0 endp