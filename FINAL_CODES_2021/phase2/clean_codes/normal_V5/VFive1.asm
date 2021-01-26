%define JUMP_DIST 0xF900
%define CALL_AMOUNT 0x55
%define GAP 0x19
%define CALL_DIST (CALL_AMOUNT * (GAP + 0x4)-0x6)
%define MAGIC_SEG 0xFFA

%define SHARE_LOC 0x8101

mov si,ax
push ss
add si,@copy
mov di,(@loop_end - @loop)/0x2
pop es

mov cl,(@copy_end - @copy)/0x2
rep movsw

mov al,0xA7
mov [SHARE_LOC],ah
add ah,(JUMP_DIST/0x100)

push ss
pop ds

inc bh
mov [bx],ax
mov word [bx+0x2],MAGIC_SEG

mov word [bx+di],0x3
mov word [bx + (@loop_end - @loop)/0x2],(GAP + 0x8)

push cs
pop es
push cs
pop ss

mov dx,JUMP_DIST
mov ax,0xA5F3
mov bp, -CALL_DIST-0x60
lea si,[di-0x4]


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
dec di
@die:
mov si,cx
call far [bx]
db 0x64
@loop_end:

add sp,[bx+si]
call far [bx]
@copy_end:
