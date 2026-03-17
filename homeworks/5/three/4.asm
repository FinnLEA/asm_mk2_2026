.386

stack segment para stack use16
    db 256 dup(?)
stack ends

data segment para use16

hex db "0123456789ABCDEF"
space db ' $'
dv db ': $'
new_line db 0Dh,0Ah,'$'


bel_str db '(BEL)$'
bs_str  db '(BS)$'
tab_str db '(TAB)$'
lf_str  db '(LF)$'
vt_str  db '(VT)$'
ff_str  db '(FF)$'
cr_str  db '(CR)$'

data ends

code segment para use16
assume cs:code, ds:data, ss:stack

start:

    mov ax,data
    mov ds,ax
  
    mov ax,stack
    mov ss,ax

    mov cx,256        
    xor si,si         
    xor di,di        

next:
    mov ax, si   
    mov al, al 
    cmp al, 07h
    je bel_handler
    cmp al, 08h
    je bs_handler
    cmp al, 09h
    je tab_handler
    cmp al, 0Ah
    je lf_handler  
    cmp al, 0Bh
    je vt_handler  
    cmp al, 0Ch
    je ff_handler 
    cmp al, 0Dh
    je cr_handler
	cmp al,07h
	jb output
	ja output
hex_zn:
    mov dx,offset dv
    mov ah,09h
    int 21h
    mov ax,si
    mov bl,al
    mov bh,bl
    shr bh,4
    mov bl,bh
    xor bh,bh
    mov dl,hex[bx]
    mov ah,02h
    int 21h
    mov ax,si
    and al,0Fh
    xor bx,bx
    mov bl,al
    mov dl,hex[bx]
    mov ah,02h
    int 21h
    mov dx,offset space
    mov ah,09h
    int 21h
    inc si
    inc di
    cmp di,8
    jne newline
    mov di,0
    mov dx,offset new_line
    mov ah,09h
    int 21h
newline:
    loop next
	jmp exit

bel_handler:
    mov dx, offset bel_str  
    mov ah, 09h
    int 21h
    jmp hex_zn
bs_handler:
    mov dx, offset bs_str   
    mov ah, 09h
    int 21h
    jmp hex_zn
tab_handler:
    mov dx, offset tab_str  
    mov ah, 09h
    int 21h
    jmp hex_zn
lf_handler:
    mov dx, offset lf_str   
    mov ah, 09h
    int 21h
    jmp hex_zn
vt_handler:
    mov dx, offset vt_str   
    mov ah, 09h
    int 21h
    jmp hex_zn
ff_handler:
    mov dx, offset ff_str   
    mov ah, 09h
    int 21h
    jmp hex_zn
cr_handler:
    mov dx, offset cr_str   
    mov ah, 09h
    int 21h
    jmp hex_zn
output:
    mov dl,al
    mov ah,02h
    int 21h
    jmp hex_zn  
  
exit:
    mov ax,4C00h
    int 21h

code ends
end start
