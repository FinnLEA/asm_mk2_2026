
_maing	proc	near
	currQuants_lo equ var1; 2
	currQuants_hi equ var2; 2
	nextQuants_lo equ var3; 2
	nextQuants_hi equ var4; 2

	push bp
	mov	bp,sp
	sub	sp,2 * 8

	lea ax, [bp+currQuants_lo]
	push ax
	push ss
	call getQuants
	add sp, 4

	mov	word ptr [_state],INPUT_FILE_STATE

_maing_loop_start:
	cmp	word ptr [_state], INPUT_FILE_STATE
	jne _maing_state_nonzero

	call _draw_file_input_window
   	call _read_keys_output_filename
	cmp ax, 2
	jne _maing_else1

	mov word ptr [_state], KLOGGER_STATE
	call _clear_screen
	call _draw_ui

	_maing_else1:
	jmp	short _maing_continue
_maing_state_nonzero:
    
	lea ax, [bp+nextQuants_lo]
	push ax
	push ss
	call getQuants
	add sp, 4

	mov ax, word ptr [bp+nextQuants_lo]
	sub ax, word ptr [bp+currQuants_lo]
	cmp ax, FILE_AUTO_WRITE_DELAY
	jg _maing_flush_buffer_into_file ; move!

_maing_loop_blink_timer_check:

	lea ax, [_blink_nextQuants_lo]
	push ax
	push ds
	call getQuants
	add sp, 4

	cmp word ptr [_is_blink], 0
	je _maing_skip_blink_check

	mov ax, word ptr [ _blink_nextQuants_lo]
	sub ax, word ptr [_blink_currQuants_lo]
	cmp ax, BLINK_DELAY
	jg _maing_clear_buttons_color ; move!

_maing_skip_blink_check:


	call	near ptr _read_keys
	cmp ax, 2
	jne _maing_skip_ui_redraw
   ;	
   ;	            clear_screen();
   ;	
	call	near ptr _clear_screen
   ;	
   ;	            draw_ui();
   ;	
	call	near ptr _draw_ui



_maing_skip_ui_redraw:
   ;	
   ;	            /* When the buffer gets too large, remove the oldest line */
   ;	            if (output_buffer_i >= 1500)
   ;	
	cmp	word ptr _output_buffer_i,1500
	jb	short _maing_continue
   ;	
   ;	            {
   ;	                up_text();
   ;	
	call	near ptr _up_text
	call	near ptr _clear_screen
	call 	near ptr _draw_ui
_maing_continue:
    jmp _maing_loop_start

_maing_flush_buffer_into_file:

	mov dx, word ptr [bp+nextQuants_lo]
	mov word ptr [bp+currQuants_lo], dx
	mov dx, word ptr [bp+nextQuants_hi]
	mov word ptr [bp+currQuants_hi], dx

    call _flush_buffer_into_file

    jmp _maing_loop_blink_timer_check

_maing_clear_buttons_color:

	mov dx, word ptr [_blink_nextQuants_lo]
	mov word ptr [_blink_currQuants_lo], dx
	mov dx, word ptr [_blink_nextQuants_hi]
	mov word ptr [_blink_currQuants_hi], dx

	mov word ptr [_buttons+24], 1
	mov word ptr [_buttons+FIRST_BUTTON_OFFSET+24], 1
	mov word ptr [_buttons+SECOND_BUTTON_OFFSET+24], 1
	mov word ptr [_buttons+THIRD_BUTTON_OFFSET+24], 1
	mov word ptr [_is_blink], 0
	call _clear_screen
	call _draw_ui

	jmp _maing_continue

   ;	
   ;	            }
   ;	        }
   ;	
   ;	    }
   ;	}
   ;	
	mov	sp,bp
	pop	bp
	ret	
_maing	endp
