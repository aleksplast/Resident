.286
.model tiny
.code
jumps

org 100h
locals @@

Start:

            mov ax, 1111h
            mov bx, 2222h
            mov cx, 3333h
            mov dx, 4444h

@@Str:      push ax
            in al, 60h
            cmp al, 1h
            je @@Done
            pop ax
            jmp @@Str
@@Done:
            mov ax, 4c00h
            int 21h

end start
