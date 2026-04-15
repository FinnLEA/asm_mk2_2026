; file_desc fopen(const str* filename, int mode)
; file opening function (open mode in the low byte of the second argument)
; returns -1 if an error occurred, otherwise returns the file descriptor
_fopen proc near
    push bp
    mov bp, sp
    
    mov ax, word ptr [bp + arg2]			; al - opening mode
    mov ah, 3dh								; ah - opening file descriptor
    mov dx, word ptr [bp + arg1]			; ds:dx - address of the string with the file name
    int 21h
    
    jnc fopenret
    mov ax, -1

fopenret:    
    mov sp, bp
    pop bp
    ret
_fopen endp

; int fclose(file_desc f)
; file closing function
; returns -1 if an error occurred, otherwise returns 0
_fclose proc near
    push bp
    mov bp, sp
    
    mov ah, 3eh							
    mov bx, word ptr [bp + arg1]	
    int 21h
    
    jnc fcloseret0
    mov ax, -1
    jmp fcloseret
    
fcloseret0: 
    mov ax, 0

fcloseret:    
    mov sp, bp
    pop bp
    ret
_fclose endp

; int fread(file_desc f, int size, char* buf)
; function for reading from a file into a buffer
; returns the number of bytes read; in case of an error, returns -1
_fread proc near
    push bp
    mov bp, sp
    
    mov ah, 3fh
    mov bx, word ptr [bp + arg1]	; from
    mov cx, word ptr [bp + arg2]	; how much
    mov dx, word ptr [bp + arg3]	; to
    int 21h
    
    jnc freadret
    mov ax, -1

freadret:    
    mov sp, bp
    pop bp
    ret
_fread endp

; int fwrite(file_desc f, int size, char *buf)
; function for writing to a file
; returns the number of bytes written, and returns -1 in case of an error
_fwrite proc near
    push bp
    mov bp, sp
    
    mov ah, 40h
    mov bx, word ptr [bp + arg1]		; to
    mov cx, word ptr [bp + arg2]		; how much
    mov dx, word ptr [bp + arg3]		; from
    int 21h
    
    jnc fwriteret
    mov ax, -1

fwriteret:    
    mov sp, bp
    pop bp
    ret
_fwrite endp


; DWORD get_filesize(int fd)
; function for reading the file size in DX:AX
; returns the size in bytes, returns -1 in case of an error
_get_filesize proc near
    push bp
    mov bp, sp
    push bx 

    ; move the pointer to the end of the file ----
    mov ah, 42h
    mov al, 2        		; end of file
    mov bx, [bp + arg1]   	; fd
    xor cx, cx
    xor dx, dx
    int 21h
    jc  gfs_error1          ; if the first call fails

    ; res DX:AX
    push dx
    push ax

    ; returned the pointer to the beginning of the file ----
    mov ah, 42h
    mov al, 0       		 ; start of file
    mov bx, [bp + arg1]
    xor cx, cx
    xor dx, dx
    int 21h
    jc  gfs_error2          ; if the second call fails

    ; successful: restore size in DX:AX ----
    pop ax
    pop dx
    jmp gfs_exit

gfs_error2:
    pop ax
    pop dx
gfs_error1:
    mov ax, 0FFFFh
    mov dx, 0FFFFh    ; -1
gfs_exit:
    pop bx
    mov sp, bp
    pop bp
    ret
_get_filesize endp


; char* read_file2buffer(const char* filename)
; function for reading all data from a file into a buffer
; returns the buffer segment, -1 on error
_read_file2buffer proc near
	push bp
	mov bp, sp
	sub sp, 6						; [bp - 2] - fd
									; [bp - 4] - size
									; [bp - 6] - buffer segment			
	push bx
	push cx
	push dx
	push si
	push di
	push ds
	push es
	
	mov word ptr [bp - 6], 0

	; open ----------------------------
	mov bx, [bp + arg1]				; ds already points to the data segment, we get the filename offset
	push 0							; rights
	push bx							; offset
	call _fopen
	add sp, 4
	cmp ax, -1
	je error_open_file
	mov [bp - 2], ax				; write opened fd
	
	; find the size --------------------	
	push ax	
	call _get_filesize
	add sp, 2
	
	 ; (-1 в DX:AX)
    cmp dx, 0FFFFh
    jne check_size_ok       
    cmp ax, 0FFFFh
    je closefile            
	
check_size_ok:
    ; does it fit in 64К (DX == 0)
    cmp dx, 0
    jne file_too_big 
    mov [bp - 4], ax		; save valid size
	
    ; allocate memory ------------------
    mov ax, [bp - 4]    	; filesize
    inc ax              	; +1 for '\0'
    jnc alloc_ok
    jmp file_too_big		; else overflow
	
alloc_ok:
    push ax
    call AllocMem
    add sp, 2
	cmp ax, 0
	je closefile
	
	mov [bp - 6], ax		; safe buffer segment
	
	; ax - segment address of the buffer
    ; read into the buffer -------------
    push ds
    mov ds, ax              ; ds - buffer
    xor dx, dx              ; offset = 0
    mov bx, [bp - 2]        ; fd
    mov cx, [bp - 4]        ; size

    push dx					; to
    push cx					; how much
    push bx					; from
    call _fread
    add sp, 6
    pop ds

    cmp ax, -1
    je error_free_buf      
    cmp ax, [bp - 4]
    jne error_free_buf      

    ; successfully registered ----------
    mov bx, [bp - 2]
    push bx
    call _fclose
    add sp, 2

    ; write final \0
    mov bx, [bp - 4]		; filesize = offset
    push ds
    mov ds, [bp - 6]		; ds on start sg
    mov byte ptr [bx], 0
    pop ds

	; return segment
    mov ax, [bp - 6]
    jmp read_file2buffer_ret

file_too_big:
    jmp closefile

error_free_buf:
    cmp word ptr [bp - 6], 0
    je closefile
    mov bx, [bp - 6]
    push bx
    call FreeMem
    add sp, 2

closefile:
    mov bx, [bp - 2]
    push bx
    call _fclose
    add sp, 2

error_open_file:
    mov ax, -1

read_file2buffer_ret:
    pop es
    pop ds
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	add sp, 6
    mov sp, bp
    pop bp
    ret
_read_file2buffer endp
	
	
; -------------------------------------------
; working with file contents
; ---------------------------------------------
; char** split_lines(char* buffer)
; function for splitting a file into an array of lines
; gets a buffer segment containing the raw text of the file (lines separated by \n(\r))
; returns AX - a segment of an array of pointers to lines, 0 - error
_split_lines proc near
    push bp
    mov bp, sp
	sub sp, 2					; [bp - 2] - address of the beginning of the i-th segment
    
    push bx
    push cx
    push dx
    push si
    push di
    push ds

    ; ES = buffer
    mov ax, [bp + arg1]
    mov es, ax

; -------- count lines --------
    xor bx, bx			; character iterator
    mov cx, 1			; number of lines - minimum 1

count_loop:
    mov al, es:[bx]
    cmp al, 0
    je count_done

    cmp al, 0Ah
    jne count_next
    inc cx

count_next:
    inc bx				; next symbol
    jmp count_loop

count_done:
    ; alloc array (cx + 1 )* 2
    mov ax, cx
	inc ax			; for 0
    shl ax, 1

	; allocated memory for the array
    push ax
    call AllocMem
    add sp, 2

    cmp ax, 0
    je error_split            

    mov dx, ax                ; DX = array segment

; -------- split --------
    xor bx, bx                ; iterator from symbols
    xor si, si                ; start index line
    xor cx, cx                ; index line in array

split_loop:
    mov al, es:[bx]
    cmp al, 0
    je last_line

    cmp al, 0Ah
    je make_line

    inc bx					  ; next symbol
    jmp split_loop

; -------- make line --------
make_line:
    ; bx = \n or 0
    cmp bx, 0				   ; if the last entry
    je no_cr

    mov al, es:[bx-1]		   ; if NOT the last entry
    cmp al, 0Dh
    jne no_cr
    mov byte ptr es:[bx-1], 0
	; dec bx

no_cr:
    mov byte ptr es:[bx], 0

    ; string length in bytes (including the terminating 0)
    mov ax, bx
    sub ax, si
    inc ax					   ; +\0

	; allocate memory for the string
    push ax
    call AllocMem
    add sp, 2
    cmp ax, 0
    je error_split  

	mov word ptr [bp - 2], ax				; saved a line segment

; --- copy ---
    push ds
    mov ax, es
    mov ds, ax					; DS = buffer
	
    mov es, [bp - 2]	        ; ES = newline segment
    xor di, di					; DI = row index dst
								; SI = row index src (buffer)

; теперь копировать мы будем из DS в --> ES
copy_loop:
    mov al, [si]
    mov es:[di], al
    cmp al, 0
    je copy_done
    inc si
    inc di
    jmp copy_loop

copy_done:
    pop ds

; --- save pointer ---
    push ds
	
    mov ds, dx               ; DS = data segment
    mov di, cx				 ; DI = number of elements (lines) already written
    shl di, 1				 
	
	push bx
	mov bx, [bp - 2]
    mov [di], bx              ; we write a string segment from BX
	pop bx
	
    pop ds

    inc cx					 ; we increase the number of written lines
    inc bx                   ; next symbol
    mov si, bx			   	 ; si - beginning of the next segment 
    jmp split_loop

; -------- last line --------
last_line:
    mov ax, bx
    sub ax, si
    inc ax

    push ax
    call AllocMem
    add sp, 2

    cmp ax, 0
    je error_split

	mov word ptr [bp - 2], ax

	; копирование
    push ds
    mov ax, es
    mov ds, ax						; DS = buffer
	
    mov es, [bp - 2]				; ES = begin sg
    xor di, di						; DI = iterator for ES

copy_last:
    mov al, [si]
    mov es:[di], al
    cmp al, 0
    je copy_last_done
    inc si
    inc di
    jmp copy_last

copy_last_done:
    pop ds
	
    ; save in array
    push ds
    mov ds, dx               ; DS = start of array segment
    mov di, cx				 ; DI = number of lines written
    shl di, 1	

	push bx
	mov bx, [bp - 2]
    mov [di], bx				 ; recorded a pointer to the beginning of the segment
    mov word ptr [di + 2], 0	 
	pop bx
    pop ds

	
	; recorded a pointer to the beginning of the segment
    mov ax, dx
    jmp split_lined_ret

error_split:    
    mov ax, -1

split_lined_ret:
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
	
    mov sp, bp
    pop bp
    ret
_split_lines endp


; void free_lines(char** lines)
; function for clearing an ARRAY of row segments
_free_lines proc near
    push bp
    mov bp, sp
    
    push si
    push bx
    push ds

    mov ax, [bp + arg1]
    mov si, 0

free_loop:
    push ds
    mov ds, ax          ; DS = array

    mov bx, [si]        ; read a line segment
    pop ds              ; return DS back

    cmp bx, 0
    je free_all_array

    push bx
    call FreeMem
    add sp, 2

    add si, 2
    jmp free_loop

free_all_array:
    mov ax, [bp + arg1]
    push ax
    call FreeMem
    add sp, 2

    pop ds
    pop bx
    pop si

    mov sp, bp
    pop bp
    ret
_free_lines endp
  
