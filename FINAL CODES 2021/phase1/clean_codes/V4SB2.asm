%define JUMP_DIST 0x7100
%define CALL_AMOUNT 0x80
%define CALL_DIST (CALL_AMOUNT * 0x4)
%define MAGIC_SEG 0x1002
%define ADD_SP (JUMP_DIST + CALL_DIST)


push ss
pop es

mov si,ax
add si,@copy
mov cl,(@copy_end - @copy)/0x2
rep movsw

mov al,0xA8
xchg ah,[0x34EA]
add ah,(JUMP_DIST/0x100 + 0x4)

push ss
pop ds

lea si,[di-0x2]

mov bx,di
stosw
mov word [di],MAGIC_SEG

mov word [bx+si],ADD_SP

mov dx,JUMP_DIST
mov al,0xA5

les di,[bx]

push cs
pop ss

mov sp,[bx]
add sp,(CALL_DIST + 0x20)
mov cl,(@loop_end - @loop)/0x2

movsw
xor si,si
dec di

call far [bx]

@copy:
rep movsw

@loop:
add [bx],dx
les di,[bx]
add sp,[bx+si]
mov cl,(@loop_end - @loop)/0x2
movsw
xor si,si
dec di
dec bp
db 0x75
db 0xFF
db 0x1F

@loop_end:
call far [bx]
@copy_end:
