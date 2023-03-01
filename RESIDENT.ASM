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
                push di
                push ax

                mov bx, 0b800h
                mov es, bx
                mov ah, 4eh
                mov bx, 160d * 5 + 80d

                in al, 60h
                mov di, ax
                mov cl, ah

                pop ax

                push dx bx si
                call NumToHex
                pop si bx dx

                mov ax, di
                in al, 61h
                or al, 80h
                out 61h, al
                and al, not 80h
                out 61h, al

                mov al, 20h
                out 20h, al

                pop di
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
; Destroys:	DX, BX, SI
;------------------------------------------------

NumToHex	proc

			push ax
			xor dx, dx

@@Next:		cmp dx, 4d
			je @@Done

			mov si, ax
			and si, 0F000h
			shr si, 12

			cmp si, 0Ah

			jae @@PrtSym

			add si, 30h
			mov byte ptr es:[bx], si
			jmp @@PrtColor

@@PrtSym:	sub si, 0Ah
			add si, 41h
			mov byte ptr es:[bx], si

@@PrtColor:	inc bx
			mov byte ptr es:[bx], cl
			inc bx

			add dx, 1
			shl ax, 4

			jmp @@Next


@@Done:		pop ax
			ret
			endp

EOP:

end             start

