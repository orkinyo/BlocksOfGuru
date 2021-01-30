%define JUMP_DIST 0x5200
%define CALL_AMOUNT 0x84
%define CALL_DIST (0x4 * CALL_AMOUNT)
%define SHARE_LOC 0xA7FB


mov si,ax
add si,@copy

mov cl,0xF
div cx
add dx,0xFF6
mov [SHARE_LOC],dx

mov cl,(@copy_end - @copy)/0x2
push ss
pop es
movsb
rep movsw


mov bp,dx

push ss
pop ds

mov cl,0x4
shl bp,cl

lea bx,[bp + CALL_DIST + 0x1]
add ax,JUMP_DIST
mov al,0xA2

mov [bx],ax
mov [bx+0x2],dx
mov ax,bx

push ds
pop es
push cs
pop ss

mov dx,JUMP_DIST
mov cl,(@loop_end - @loop)/0x2
xor si,si
les di,[bx]
dec di

lea sp,[di+bx]

movsw
movsw

mov word [bx+si],0x2
sub di,[bx+si]

call far [bx]


@copy:
@call_far:
db 0x66
call far [bx]
db 0x68

@loader:
movsw
rep movsw
@loop:
add [bx],dx
add di,[si]
lea sp,[di+bx]
mov cl,(@loop_end - @loop)/0x2
xor si,si
movsw
movsw
sub di,[bx+si]
call far [bx]
@loop_end:
dw (JUMP_DIST - (@loop_end - @loader) - 0x2)
@copy_end: