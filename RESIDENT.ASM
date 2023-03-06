.286
.model tiny
.code
jumps

org 100h
locals @@

WIDTHS = 6d
HEIGHT = 6d
COLOR = 4eh


Start:
                cli

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

                mov es, cx
                mov bx, 4 * 8

                mov ax, es:[bx]
                mov Old08ofs, ax

                mov es:[bx], offset New08

                mov ax, es:[bx + 2]
                mov Old08Seg, ax

                mov ax, cs
                mov es:[bx + 2], ax

                sti

                mov ax, 3100h
                mov dx, offset EOP
                shr dx, 4
                inc dx
                int 21h


New09           proc
                jmp @@Data

                SaveBuff db 72 dup (0)
                CurBuff  db 72 dup (0)


@@Data:
                push ax bx cx dx si di es

                in al, 60h
                cmp al, 3bh
                jne @@Nothing

                cmp cs:[Flag], 0h
                je @@Change1
                jmp @@Change2

@@Change1:      mov ax, 1h
                mov cs:[Flag], ax
                jmp @@Done

@@Change2:      mov ax, 0h
                mov cs:[Flag], ax

@@Done:         in al, 61h
                or al, 80h
                out 61h, al
                and al, not 80h
                out 61h, al

                mov al, 20h
                out 20h, al

                pop es di si dx cx bx ax

                iret

@@Nothing:
                pop es di si dx cx bx ax

                db 0eah
                Old09ofs dw 0
                Old09Seg dw 0

                endp

New08           proc

                push ax bx cx dx si di es

                push dx
                push cx
                push bx
                push ax

                mov bx, 0b800h
                mov es, bx
                mov di, offset SaveBuff
                mov bx, offset CurBuff
                mov si, 160d + 148d
                call MemCmp

                cmp cs:[Flag], 1h
                je @@Draw

                cmp cs:[Flag], 0h
                je @@RestoreFrame

@@Draw:

                xor ax, ax
                xor bx, bx
                xor cx, cx
                xor dx, dx
                xor si, si
                xor di, di

                push cs
                pop es
                mov ah, COLOR
                mov al, 01h
                mov di, offset CurBuff
                push di
                mov dx, WIDTHS
                mov cx, HEIGHT
                mov si, offset style1
                call DrawFrame

                pop bx
                add bx, WIDTHS * 2d + 2d
                mov cl, ah

                pop ax
                push dx bx si
                call NumToHex
                pop si bx dx

                pop ax
                add bx, WIDTHS * 2d
                push dx bx si
                call NumToHex
                pop si bx dx

                pop ax
                add bx, WIDTHS * 2d
                push dx bx si
                call NumToHex
                pop si bx dx

                pop ax
                add bx, WIDTHS * 2d
                push dx bx si
                call NumToHex
                pop si bx dx

                mov bx, 0b800h
                mov es, bx
                mov si, offset CurBuff
                mov di, 160d * 2d - WIDTHS * 2d
                call DrawRegs

                pop es di si dx cx bx ax

                jmp @@End

@@RestoreFrame:
                pop dx cx bx ax
                mov bx, 0b800h
                mov es, bx
                mov si, offset SaveBuff
                mov di, 160d * 2d - WIDTHS * 2d
                call RestoreMem

                pop es di si dx cx bx ax

                jmp @@End

@@End:
                db 0eah
                Old08ofs dw 0
                Old08Seg dw 0

                endp


Flag dw 0h

;------------------------------------------------
; Saving videomem into buffer
;------------------------------------------------
; Entry:	SI = ptr of save buf
;			DI = ptr of videomem
; Exit:		none
; Expects:	EX = 0b800h
; Destroys: BX, CX, SI, DI
;------------------------------------------------
RestoreMem      proc
                xor bx, bx

@@Restore:
                mov cx, WIDTHS * 2d
                push di

@@Copy3:        mov byte ptr al, cs:[si]
                inc si
                mov byte ptr es:[di], al
                inc di
                loop @@Copy3

                pop di
                add di, 160d
                inc bx
                cmp bx, HEIGHT
                jne @@Restore

                ret
                endp

;------------------------------------------------
; Saving videomem into buffer
;------------------------------------------------
; Entry:	SI = ptr of videomem
;			DI = ptr of save buf
; Exit:		none
; Expects:	EX = 0b800h
; Destroys: BX, CX, SI, DI
;------------------------------------------------
SaveMem         proc

                xor bx, bx

@@SaveMem:
                mov cx, WIDTHS * 2d
                push si

@@Copy:        mov byte ptr al, es:[si]
                inc si
                mov byte ptr cs:[di], al
                inc di
                loop @@Copy

                pop si
                add si, 160d
                inc bx
                cmp bx, HEIGHT
                jne @@SaveMem

                ret
                endp

;------------------------------------------------
; Saving videomem into buffer
;------------------------------------------------
; Entry:	SI = ptr of videomem
;			DI = ptr of save buf
; Exit:		none
; Expects:	EX = 0b800h
; Destroys: BX, CX, SI, DI
;------------------------------------------------
DrawRegs        proc
                xor bx, bx

@@DrawRegs:
                mov cx, WIDTHS * 2d
                push di

@@Copy:         mov byte ptr al, cs:[si]
                inc si
                mov byte ptr es:[di], al
                inc di
                loop @@Copy

                pop di
                add di, 160d
                inc bx
                cmp bx, HEIGHT
                jne @@DrawRegs

                ret
                endp

;------------------------------------------------
; Comparing one memory to another
;------------------------------------------------
; Entry:	SI = ptr of videomem
;			DI = ptr of save buf
;           DX = ptr of draw buf
; Exit:		AX = 1, 0, -1
; Expects:	none
; Destroys: BX, CX, SI
;------------------------------------------------
MemCmp		proc

			push di
			push si
            xor dx, dx

@@NextL:    mov cx, WIDTHS * 2d

@@NextS:    cmp cx, 0
            je @@LineDone
            mov byte ptr al, cs:[bx]
            mov byte ptr ah, es:[si]
            cmp al, ah
            jne @@ChangeS
            inc di
            inc si
            inc bx
            dec cx
            jmp @@NextS

@@ChangeS:  mov byte ptr cs:[di], ah
            dec cx
            inc di
            inc bx
            inc si
            jmp @@NextS

@@LineDone: inc dx
            add si, 160d
            sub si, WIDTHS * 2d
            cmp dx, HEIGHT
            je @@Done
            jmp @@NextL

@@Done:		sub al, ah
			xor ah, ah

			pop si
			pop di

			ret
			endp



;------------------------------------------------
; Print number in hex format
;------------------------------------------------
; Entry:	AX = number
;			BX = coordinates
;			CX = color
; Exit:		None
; Expects:	ES = CS
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
; Expects:	ES = CS
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
            add di, 12d

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
            add di, 12d

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

            add di, 12d                  ; start of the text

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
; Expects:	ES = CS
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

