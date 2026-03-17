.386

stack segment para stack
	db 256 dup (?)
stack ends 

data segment para public
	string db 240,?,240 dup(?)
	strlen dw ?
	new_line db 0dh, 0ah, "$"
	
	divider dw 16
	hex_alph db "0123456789ABCDEF"
	hex_crc16 db ?,?,?,?,"$"
	hex_crc32 db 8 dup(?),"$"
	buffer16 dw ?
	buffer32 DD ?
	index dw ?
	
	crc_16 dw 0FFFFh
	crc_32l dw 0FFFFh
	crc_32h dw 0FFFFh
	
crc16_table  DW 0000h,0C0C1h,0C181h,0140h,0C301h,03C0h,0280h,0C241h
            DW 0C601h,06C0h,0780h,0C741h,0500h,0C5C1h,0C481h,0440h
            DW 0CC01h,0CC0h,0D80h,0CD41h,0F00h,0CFC1h,0CE81h,0E40h
            DW 0A00h,0CAC1h,0CB81h,0B40h,0C901h,09C0h,0880h,0C841h
            DW 0D801h,18C0h,1980h,0D941h,1B00h,0DBC1h,0DA81h,1A40h
            DW 1E00h,0DEC1h,0DF81h,1F40h,0DD01h,1DC0h,1C80h,0DC41h
            DW 1400h,0D4C1h,0D581h,1540h,0D701h,17C0h,1680h,0D641h
            DW 0D201h,12C0h,1380h,0D341h,1100h,0D1C1h,0D081h,1040h
            DW 0F001h,30C0h,3180h,0F141h,3300h,0F3C1h,0F281h,3240h
            DW 3600h,0F6C1h,0F781h,3740h,0F501h,35C0h,3480h,0F441h
            DW 3C00h,0FCC1h,0FD81h,3D40h,0FF01h,3FC0h,3E80h,0FE41h
            DW 0FA01h,3AC0h,3B80h,0FB41h,3900h,0F9C1h,0F881h,3840h
            DW 2800h,0E8C1h,0E981h,2940h,0EB01h,2BC0h,2A80h,0EA41h
            DW 0EE01h,2EC0h,2F80h,0EF41h,2D00h,0EDC1h,0EC81h,2C40h
            DW 0E401h,24C0h,2580h,0E541h,2700h,0E7C1h,0E681h,2640h
            DW 2200h,0E2C1h,0E381h,2340h,0E101h,21C0h,2080h,0E041h
            DW 0A001h,60C0h,6180h,0A141h,6300h,0A3C1h,0A281h,6240h
            DW 6600h,0A6C1h,0A781h,6740h,0A501h,65C0h,6480h,0A441h
            DW 6C00h,0ACC1h,0AD81h,6D40h,0AF01h,6FC0h,6E80h,0AE41h
            DW 0AA01h,6AC0h,6B80h,0AB41h,6900h,0A9C1h,0A881h,6840h
            DW 7800h,0B8C1h,0B981h,7940h,0BB01h,7BC0h,7A80h,0BA41h
            DW 0BE01h,7EC0h,7F80h,0BF41h,7D00h,0BDC1h,0BC81h,7C40h
            DW 0B401h,74C0h,7580h,0B541h,7700h,0B7C1h,0B681h,7640h
            DW 7200h,0B2C1h,0B381h,7340h,0B101h,71C0h,7080h,0B041h
            DW 5000h,90C1h,9181h,5140h,9301h,53C0h,5280h,9241h
            DW 9601h,56C0h,5780h,9741h,5500h,95C1h,9481h,5440h
            DW 9C01h,5CC0h,5D80h,9D41h,5F00h,9FC1h,9E81h,5E40h
            DW 5A00h,9AC1h,9B81h,5B40h,9901h,59C0h,5880h,9841h
            DW 8801h,48C0h,4980h,8941h,4B00h,8BC1h,8A81h,4A40h
            DW 4E00h,8EC1h,8F81h,4F40h,8D01h,4DC0h,4C80h,8C41h
            DW 4400h,84C1h,8581h,4540h,8701h,47C0h,4680h,8641h
            DW 8201h,42C0h,4380h,8341h,4100h,81C1h,8081h,4040h

crc32_table  DD 00000000h,77073096h,0EE0E612Ch,0990951BAh
            DD 076DC419h,0706AF48Fh,0E963A535h,09E6495A3h
            DD 00EDB8832h,079DCB8A4h,0E0D5E91Eh,097D2D988h
            DD 009B64C2Bh,07EB17CBDh,0E7B82D07h,090BF1D91h
            DD 01DB71064h,06AB020F2h,0F3B97148h,084BE41DEh
            DD 01ADAD47Dh,06DDDE4EBh,0F4D4B551h,083D385C7h
            DD 0136C9856h,0646BA8C0h,0FD62F97Ah,08A65C9ECh
            DD 014015C4Fh,063066CD9h,0FA0F3D63h,08D080DF5h
            DD 03B6E20C8h,04C69105Eh,0D56041E4h,0A2677172h
            DD 03C03E4D1h,04B04D447h,0D20D85FDh,0A50AB56Bh
            DD 035B5A8FAh,042B2986Ch,0DBBBC9D6h,0ACBCF940h
            DD 032D86CE3h,045DF5C75h,0DCD60DCFh,0ABD13D59h
            DD 026D930ACh,051DE003Ah,0C8D75180h,0BFD06116h
            DD 021B4F4B5h,056B3C423h,0CFBA9599h,0B8BDA50Fh
            DD 02802B89Eh,05F058808h,0C60CD9B2h,0B10BE924h
            DD 02F6F7C87h,058684C11h,0C1611DABh,0B6662D3Dh
            DD 076DC4190h,001DB7106h,098D220BCh,0EFD5102Ah
            DD 071B18589h,006B6B51Fh,09FBFE4A5h,0E8B8D433h
            DD 07807C9A2h,00F00F934h,09609A88Eh,0E10E9818h
            DD 07F6A0DBBh,0086D3D2Dh,091646C97h,0E6635C01h
            DD 06B6B51F4h,01C6C6162h,0856530D8h,0F262004Eh
            DD 06C0695EDh,01B01A57Bh,08208F4C1h,0F50FC457h
            DD 065B0D9C6h,012B7E950h,08BBEB8EAh,0FCB9887Ch
            DD 062DD1DDFh,015DA2D49h,08CD37CF3h,0FBD44C65h
            DD 04DB26158h,03AB551CEh,0A3BC0074h,0D4BB30E2h
            DD 04ADFA541h,03DD895D7h,0A4D1C46Dh,0D3D6F4FBh
            DD 04369E96Ah,0346ED9FCh,0AD678846h,0DA60B8D0h
            DD 044042D73h,033031DE5h,0AA0A4C5Fh,0DD0D7CC9h
            DD 05005713Ch,0270241AAh,0BE0B1010h,0C90C2086h
            DD 05768B525h,0206F85B3h,0B966D409h,0CE61E49Fh
            DD 05EDEF90Eh,029D9C998h,0B0D09822h,0C7D7A8B4h
            DD 059B33D17h,02EB40D81h,0B7BD5C3Bh,0C0BA6CADh
            DD 0EDB88320h,09ABFB3B6h,003B6E20Ch,074B1D29Ah
            DD 0EAD54739h,09DD277AFh,004DB2615h,073DC1683h
            DD 0E3630B12h,094643B84h,00D6D6A3Eh,07A6A5AA8h
            DD 0E40ECF0Bh,09309FF9Dh,00A00AE27h,07D079EB1h
            DD 0F00F9344h,08708A3D2h,01E01F268h,06906C2FEh
            DD 0F762575Dh,0806567CBh,0196C3671h,06E6B06E7h
            DD 0FED41B76h,089D32BE0h,010DA7A5Ah,067DD4ACCh
            DD 0F9B9DF6Fh,08EBEEFF9h,017B7BE43h,060B08ED5h
            DD 0D6D6A3E8h,0A1D1937Eh,038D8C2C4h,04FDFF252h
            DD 0D1BB67F1h,0A6BC5767h,03FB506DDh,048B2364Bh
            DD 0D80D2BDAh,0AF0A1B4Ch,036034AF6h,041047A60h
            DD 0DF60EFC3h,0A867DF55h,0316E8EEFh,04669BE79h
            DD 0CB61B38Ch,0BC66831Ah,0256FD2A0h,05268E236h
            DD 0CC0C7795h,0BB0B4703h,0220216B9h,05505262Fh
            DD 0C5BA3BBEh,0B2BD0B28h,02BB45A92h,05CB36A04h
            DD 0C2D7FFA7h,0B5D0CF31h,02CD99E8Bh,05BDEAE1Dh
            DD 09B64C2B0h,0EC63F226h,0756AA39Ch,0026D930Ah
            DD 09C0906A9h,0EB0E363Fh,072076785h,005005713h
            DD 095BF4A82h,0E2B87A14h,07BB12BAEh,00CB61B38h
            DD 092D28E9Bh,0E5D5BE0Dh,07CDCEFB7h,00BDBDF21h
            DD 086D3D2D4h,0F1D4E242h,068DDB3F8h,01FDA836Eh
            DD 081BE16CDh,0F6B9265Bh,06FB077E1h,018B74777h
            DD 088085AE6h,0FF0F6A70h,066063BCAh,011010B5Ch
            DD 08F659EFFh,0F862AE69h,0616BFFD3h,0166CCF45h
            DD 0A00AE278h,0D70DD2EEh,04E048354h,03903B3C2h
            DD 0A7672661h,0D06016F7h,04969474Dh,03E6E77DBh
            DD 0AED16A4Ah,0D9D65ADCh,040DF0B66h,037D83BF0h
            DD 0A9BCAE53h,0DEBB9EC5h,047B2CF7Fh,030B5FFE9h
            DD 0BDBDF21Ch,0CABAC28Ah,053B39330h,024B4A3A6h
            DD 0BAD03605h,0CDD70693h,054DE5729h,023D967BFh
            DD 0B3667A2Eh,0C4614AB8h,05D681B02h,02A6F2B94h
            DD 0B40BBE37h,0C30C8EA1h,05A05DF1Bh,02D02EF8Dh
	
data ends

code segment para public use16

assume cs:code,ds:data,ss:stack

printstrf:
	mov ah, 09h
	int 21h
	ret

newlinef:
	mov dx, offset new_line
	call printstrf
	ret

inputstrf:
	mov dx, offset string
	mov ah, 0Ah
	int 21h
	
	mov bx, offset string
	inc bx
	mov bl, byte ptr[bx]
	mov word ptr[strlen], bx
	
	mov bx, offset string
	add bx, 2
	xor dx, dx
	mov dx, word ptr[strlen]
	
	add bx, dx
	mov byte ptr[bx + 1], "$"
	ret

	
crc16f:                  				; crc16
	mov bx, offset string    
	add bx, 2
	xor cx, cx
	mov cx, word ptr[strlen]
	
label1:
	mov dx, word ptr[crc_16]
	mov word ptr[buffer16], dx
	
	and word ptr[crc_16], 0FFh
	xor dx, dx
	mov dl, byte ptr[bx]
	xor word ptr[crc_16], dx
	
	mov dx, word ptr[crc_16]
	mov word ptr[index], dx
	
	mov si, word ptr[index]
	add si, si              			; word (2 bytes)
	mov ax, word ptr[crc16_table + si]
	mov dx, word ptr[buffer16]
	
	push cx
	xor cx, cx
	mov cl, 8
	shr dx, cl
	pop cx
	
	xor dx, ax
	mov word ptr[crc_16], dx
	
	inc bx
	loop label1

	ret

crc16_to_hex:
	xor ax, ax
	mov ax, word ptr[crc_16]
	mov cx, 4
	
label2:
	xor dx, dx
	mov bx, word ptr[divider]
	div bx
	
	mov bx, offset hex_crc16
	add bx, cx
	
	mov si, offset hex_alph
	add si, dx
	mov dl, [si]
	mov byte ptr[bx - 1], dl
	loop label2

	ret

crc32f:
	mov bx, offset string
	add bx, 2
	xor cx, cx
	mov cx, word ptr[strlen]

label3:
	mov ax, word ptr[crc_32l]			; crc_lower ^ char
	xor dx, dx							
	mov dl, byte ptr[bx]
	xor ax, dx
	and ax, 0FFh						; & 0FFh

	mov si, ax							; index
	shl si, 1
	shl si, 1
	
	push cx
	push bx

	mov bx, offset crc32_table			; take value from table
	add bx, si
	mov dx, word ptr[bx]
	mov ax, word ptr[bx + 2]
	
	mov bx, offset buffer32				; put value in buffer
	mov si, ax
	mov word ptr[bx], si
	
	add bx, 2
	mov si, dx
	mov word ptr[bx], si
	
	mov ax, word ptr[buffer32]
	mov dx, word ptr[buffer32 + 2]

	jmp proxy2_label3
	
proxy1_label3:							; proxy jump
	jmp label3
proxy2_label3:

	mov dx, word ptr[crc_32h]			; crc >> 8
	mov ax, word ptr[crc_32l]
	
	xor cx, cx
	mov cl, 8
	shrd ax, dx, cl
	shr dx, cl
	
	mov word ptr[crc_32h], dx
	mov word ptr[crc_32l], ax
	
	mov bx, word ptr[crc_32h]
	mov dx, word ptr[buffer32]
	xor bx, dx
	mov word ptr[crc_32h], bx
	
	mov bx, word ptr[crc_32l]
	mov dx, word ptr[buffer32 + 2]
	xor bx, dx
	mov word ptr[crc_32l], bx
	
	pop bx
	pop cx
	inc bx
	loop proxy1_label3
	
	mov bx, word ptr[crc_32h] 			; return crc ^ 0FFFFFFFFh
	mov dx, 0FFFFh
	xor bx, dx
	mov word ptr[crc_32h], bx
	
	mov bx, word ptr[crc_32l]
	mov dx, 0FFFFh
	xor bx, dx
	mov word ptr[crc_32l], bx

	ret
	
crc32_to_hex:
	xor ax, ax
	mov ax, word ptr[crc_32h]
	mov cx, 4
	
label4:
	xor dx, dx
	mov bx, word ptr[divider]
	div bx
	
	mov bx, offset hex_crc32
	add bx, cx
	
	mov si, offset hex_alph
	add si, dx
	mov dl, [si]
	mov [bx - 1], dl
	loop label4
	
	xor ax, ax
	mov ax, word ptr[crc_32l]
	mov cx, 4
	
label5:
	xor dx, dx
	mov bx, word ptr[divider]
	div bx
	
	mov bx, offset hex_crc32 + 4
	add bx, cx
	
	mov si, offset hex_alph
	add si, dx
	mov dl, [si]
	mov [bx - 1], dl
	loop label5
	
	ret
	
start:
	mov ax, data
    mov ds, ax
    mov ax, stack
    mov ss, ax
	
	call inputstrf
	call newlinef
	
	call crc16f
	call crc16_to_hex
	
	mov dx, offset hex_crc16
	call printstrf
	call newlinef	
	
	call crc32f
	call crc32_to_hex
	
	mov dx, offset hex_crc32
	call printstrf	
	
exit:
	mov ah, 4ch
	int 21h
	
code ends

end start
