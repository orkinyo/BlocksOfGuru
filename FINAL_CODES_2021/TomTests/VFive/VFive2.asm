%define JUMP_DIST 0x5200
%define CALL_AMOUNT 0x55
%define GAP 0x19
%define CALL_DIST (CALL_AMOUNT * (GAP - 0x4) - 0x4)
%define MAGIC_SEG 0xFFA

%define SHARE_LOC 0x8101
%define ROWS_GAP 0x2


xchg si,ax
push ss
add si,@copy
pop es

div word [si - 0x2]
add dx,0xFF6

xchg [SHARE_LOC],dx

mov bp,dx
mov cl,0x4
shl bp,cl
sub bp,CALL_DIST

mov cl,(@copy_end - @copy)/0x2
rep movsw

lea ax,[si + JUMP_DIST - @copy_end + ROWS_GAP]
xchg [SHARE_LOC],ax
add ah,ROWS_GAP
mov al,0xA7

push ss
pop ds

inc bh
mov [bx],ax
mov word [bx+0x2],dx

mov word [di],(JUMP_DIST - (@loop_end - @loop) - 0x2 - 0x4)
add word [bx+di],JUMP_DIST - GAP - CALL_DIST
mov word [bx + (@loop - @copy)],GAP

push cs
pop es
push cs
pop ss

mov dx,JUMP_DIST
mov cl,(@loop_end - @loop)/0x2
mov ax,0xA5F3
les di,[bx]
lea sp,[di + bp + 0x2]
dec di
xor si,si

movsw
movsw
movsw
sub di,0x2

call far [bx]

@div_offset:
db 0xF
db 0x0
@copy:
@call_far:
db 0x69
add sp,[bx+si]
call far [bx]
db 0x65

@loop:
add [bx],dx
add di,[si]
add sp,[bx+si]
mov cl,(@loop_end - @loop)/0x2
xor si,si
movsw
movsw
movsw
sub di,0x2
dec bp
db 0x75
call far [bx]
@loop_end:

@copy_end:
