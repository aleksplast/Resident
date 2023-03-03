.286
.model tiny
.code

org 100h
locals @@


Start:          cli

                xor ax, ax
                xor bx, bx
                xor cx, cx
                xor dx, dx
                xor si, si
                xor di, di
                mov es, bx
                mov bx, 4 * 9

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

                push ax bx cx dx si di es


                push dx
                push cx
                push bx
                push ax

                xor ax, ax
                xor bx, bx
                xor cx, cx
                xor dx, dx
                xor si, si
                xor di, di

                mov bx, 0b800h
                mov es, bx
                mov ah, 4eh
                mov al, 01h
                mov di, 148d + 160d
                push di
                mov dx, 6d
                mov cx, 6d
                mov si, offset style1
                call DrawFrame

                pop bx
                add bx, 162d
                mov cl, ah

                pop ax
                push dx bx si
                call NumToHex
                pop si bx dx

                pop ax
                add bx, 160d
                push dx bx si
                call NumToHex
                pop si bx dx

                pop ax
                add bx, 160d
                push dx bx si
                call NumToHex
                pop si bx dx

                pop ax
                add bx, 160d
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

                pop es di si dx cx bx ax

                db 0eah
                Old09ofs dw 0
                Old09Seg dw 0

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
;------------------------------------------------
; Draws frame
;------------------------------------------------
; Entry:	AH = color
;           AL = frame style
;			CX = width of the frame
;			DX = height of the frame
;           DI = coordinates of the top left corner
; Exit:		none
; Expects:	ES = 0b800h
; Destroys: AL, SI, DI
;------------------------------------------------

DrawFrame   proc

            push ax                     ; save style and color
            push cx                     ; save width
            push dx                     ; save height
            push di                     ; save starting coordinates
            push si                     ; save style or message ptr
            push di                     ; save coords
            push dx                     ; save height

            cmp al, 0h
            je @@StlDone

@@StlDone:
            mov al, 0dah                       ; top left corner in al
            mov dh, 0c4h                ; top sym in dh
            mov dl, 0bfh                ; top right corner in dl

            call DrawLine

            pop dx                      ; return dx
            sub dx, 2
            pop di
            add di, 160d

@@Height:   cmp dx, 0h                  ; check for end
            je @@Done

            push di                     ; saves coords, width
            push dx

            mov al, 0b3h                ; top left corner in al
            mov dh, ' '                 ; top sym in dh
            mov dl, 0b3h                ; top right corner in dl

            call DrawLine

            pop dx                      ; coords to the next line
            pop di
            add di, 160d

            dec dx                      ; reduce height remaining
            jmp @@Height

@@Done:
            mov al, 0c0h                      ; bottom left corner in al
            mov dh, 0c4h                ; bottom sym in dh
            mov dl, 0d9h                ; bottom right corner in dl
            call DrawLine

            pop si                      ; start of message
            pop di                      ; starting coords
            pop dx                      ; height in dx
            pop cx                      ; width in cx

            add di, 162d                ; start of the text

            pop ax

            ret
            endp


style1:     db 0dah, 0c4h, 0bfh, 0b3h, ' ', 0b3h, 0c0h, 0c4h, 0d9h
;------------------------------------------------
; Draws line
;------------------------------------------------
; Entry:	AH = color
;           AL = left symbol
;			CX = width of the frame
;           DH = mid symbol
;           DL = right symbol
;           DI = coordinates of the start of line
; Exit:		none
; Expects:	ES = 0b800h
; Destroys: AL, DH, DL, DI
;------------------------------------------------

DrawLine    proc

            push cx                 ; save cx
            stosw                   ; draw right symbol
            mov al, dh

            sub cx, 2

            rep stosw               ; draws middle symbols

            mov al, dl              ; draws left symbol
            stosw

            pop cx

            endp
            ret


EOP:
end             start

