.286
.model tiny
.code

org 100h
locals @@

;------------------------------------------------
; EXIT to DOS
;------------------------------------------------
; Entry:	None
; Exit: 	(not defined)
; Expects:	(none)
; Destroys:	...
;------------------------------------------------
EXIT		    macro
			    nop
			    mov ax, 4c00h
			    int 21h
			    nop
			    endm


Start:          cli

                xor bx, bx
                mov es, bx
                mov bx, 4d * 9d

                mov ax, es:[bx]
                mov Old09ofs, ax

                mov es:[bx], offset New09

                mov ax, es:[bx + 2]
                mov Old09Seg, ax

                mov ax, cs
                mov es:[bx + 2], ax

                sti

                mov ax, 3100h
                mov dx, offset EOP
                shr dx, 4
                inc dx
                int 21h


New09           proc

                push ax
                push bx
                push es

                mov bx, 0b800h
                mov es, bx
                mov cl, 4eh
                mov bx, 160d * 5 + 80d

                push dx bx si
                call NumToHex
                pop si bx dx

                in al, 61h
                or al, 80h
                out 61h, al
                and al, not 80h
                out 61h, al

                mov al, 20h
                out 20h, al

                pop es
                pop bx
                pop ax

                db 0eah
                Old09ofs dw 0
                Old09Seg dw 0

                iret
                endp

;------------------------------------------------
; Print number in hex format
;------------------------------------------------
; Entry:	AX = number
;			BX = coordinates
;			CX = color
; Exit:		None
; Expects:	ES = 0b800h
; Destroys:	BX, DX, SI
;------------------------------------------------

NumToHex	proc

			push ax
			xor si, si

@@Next:		cmp si, 4d
			je @@Done

			mov dx, ax
			and dx, 0F000h
			shr dx, 12

			cmp dx, 0Ah

			jae @@PrtSym

			add dx, 30h
			mov byte ptr es:[bx], dl
			jmp @@PrtColor

@@PrtSym:	sub dx, 0Ah
			add dx, 41h
			mov byte ptr es:[bx], dl

@@PrtColor:	inc bx
			mov byte ptr es:[bx], cl
			inc bx

			add si, 1
			shl ax, 4

			jmp @@Next


@@Done:		pop ax

			ret
			endp

EOP:

end             start

