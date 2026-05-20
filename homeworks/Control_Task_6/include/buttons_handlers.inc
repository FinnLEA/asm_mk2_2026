   ;	
   ;	void clr_button()
   ;	
_clr_button	proc	near
	push bp
	mov	bp, sp

    call _flush_buffer_into_file

    cdecl_call _memset, offset _output_buffer, 0, word ptr [_output_buffer_i]
    mov word ptr [_output_buffer_i],0 
    cdecl_call _memset, offset _f_output_buffer, 0, word ptr [_f_output_buffer_i]
    mov word ptr [_f_output_buffer_i],0 

    ; first button color = 2
    mov word ptr [_is_blink], 1
    mov word ptr [_buttons+24], BUTTONS_BLINK_COLOR

	lea ax, [_blink_currQuants_lo]
	push ax
	push ds
	call getQuants
	add sp, 4

    call _clear_screen
    call _draw_ui

    mov sp, bp
	pop	bp
	ret	
_clr_button	endp
   ;	
   ;	void flush_button()
   ;	
_flush_button	proc	near
	push	bp
	mov	bp,sp
    
    call _flush_buffer_into_file
	
    mov word ptr [_is_blink], 1
    mov word ptr [_buttons+FIRST_BUTTON_OFFSET+24], BUTTONS_BLINK_COLOR

    call _clear_screen
    call _draw_ui

	lea ax, [_blink_currQuants_lo]
	push ax
	push ds
	call getQuants
	add sp, 4

    pop	bp
	ret	
_flush_button	endp
   ;	
   ;	void new_file_button()
   ;	
_new_file_button	proc	near
    push	bp
	mov	bp,sp
    ; clear screen buffer
    cdecl_call _memset, offset _output_buffer, 0, word ptr [_output_buffer_i]
    mov word ptr [_output_buffer_i],0
    ; clear file output buffer 
    cdecl_call _memset, offset _f_output_buffer, 0, word ptr [_f_output_buffer_i]
    mov word ptr [_f_output_buffer_i],0 

	call _clear_screen
    call _draw_file_input_window
    mov  word ptr [_state], INPUT_FILE_STATE

    mov word ptr [_is_blink], 1
    mov word ptr [_buttons+SECOND_BUTTON_OFFSET+24], BUTTONS_BLINK_COLOR

	lea ax, [_blink_currQuants_lo]
	push ax
	push ds
	call getQuants
	add sp, 4

	pop	bp
	ret	
_new_file_button	endp
   ;	
   ;	void exit_button()
   ;	
_exit_button	proc	near
	push	bp
	mov	bp,sp

    mov word ptr [_is_blink], 1
    mov word ptr [_buttons+THIRD_BUTTON_OFFSET+24], BUTTONS_BLINK_COLOR

	call _clear_screen
    call _draw_ui

    call _flush_buffer_into_file

    call k_exit

	pop	bp
	ret	
_exit_button	endp
