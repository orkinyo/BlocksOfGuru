%define JUMP_DIST 0xF800
%define CALL_AMOUNT 0x8
%define GAP 0xD
%define CALL_DIST (CALL_AMOUNT * (GAP + 0x4) + 0x2)
%define ADD_SP (JUMP_DIST + CALL_DIST)
%define MAGIC_SEG 0xFFA


mov si,ax
push ss
add si,@copy
mov di,(@loop_end - @loop)/0x2
pop es

mov cl,(@copy_end - @copy)/0x2
rep movsw

push ss
pop ds

mov al,0xA7
add ah,(JUMP_DIST/0x100)

inc bh
mov [bx],ax
mov word [bx+0x2],MAGIC_SEG

mov word [bx+di],0x3
mov word [bx + (@loop_end - @loop)/0x2],(GAP + 0x4)

push cs
pop es
push cs
pop ss

les di,[bx]
mov bp,CALL_DIST + 0x60
lea sp,[di+bp]
mov cl,(@loop_end - @loop)/0x2
mov si,cx
mov dx,JUMP_DIST
mov ax,0xA5F3

stosw
call far [bx]

@copy:
@loop:
add [bx],dx
les di,[bx]
lea sp,[di+bp]
mov cl,(@loop_end - @loop)/0x2
movsw
movsw
dec word [si]
jz short (@die+0x1)
sub di,[bx+si]
@die:
mov si,cx
call far [bx]
@loop_end:

add sp,[bx+si]
call far [bx]
@copy_end:
