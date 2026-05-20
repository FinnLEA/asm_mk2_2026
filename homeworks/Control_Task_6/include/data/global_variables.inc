    INPUT_FILE_STATE equ 0
    KLOGGER_STATE equ 1

    ASCII_SEPARATOR equ 3Bh ; ';'
    
    FILE_AUTO_WRITE_DELAY equ 40
    BLINK_DELAY equ 50

    _blink_counter dw 0
    _is_blink dw 0
    _blink_nextQuants_lo dw 0
    _blink_nextQuants_hi dw 0
    _blink_currQuants_lo dw 0
    _blink_currQuants_hi dw 0

    MAX_OUTPUT_LINES_COUNT equ 25

    OUTPUT_FIELD_SIZE equ 20
    _output_field db '0', 260 dup(0), 0
    _output_field_i dw 0

	orig_mode db 00h
    new_color_mode dw 03h

    handler_ss dw 0
    handler_sp dw 0 
    hanlder_ds dw 0

    _output_buffer \
    db 4096 dup(0), 0
    _output_buffer_i dw 0

    _f_output_buffer\
    db 2048 dup(0), 0
    _f_output_buffer_i dw 0

    _output_filename db 60 dup(' '), 0
    _output_filename_i dw 0 

    _output_file_path_msg db ' output file path ',0 

    _state dw INPUT_FILE_STATE