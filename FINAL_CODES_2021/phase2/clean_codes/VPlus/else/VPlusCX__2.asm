%define INTERVAL 0xF1
%define TRUE_INTERVAL (INTERVAL - 0x4)
%define JUMP_DIST 0x4000
%define TOP_TRAP_DIST 0x12 ;(0x4 * 0x2)
%define BOTTOM_TRAP_DIST 0x34 ;(13 * 0x4 + 0x2)
%define TRAP_VAL TRUE_INTERVAL
%define SHARE_LOC 0xA7FB
%define INIT_SI (0x2 + TOP_TRAP_DIST + (@main_loop_end - @main_loop) + BOTTOM_TRAP_DIST)
%define BOMB_VAL 0xA593
%define DIST_CALC (0xA2 + 0x10 -((@main_loop_end - @copy) + BOTTOM_TRAP_DIST))
%define SAFETY_GAP 0x10


add ax,@copy
mov si,ss
mov bx,si
and bx,0x10
lea si,[bx+si+0x4]

xchg dx,[SHARE_LOC]

xchg ax,si
mov es,ax

mov di,INIT_SI
mov cl,(@copy_end - @copy)/0x2
rep movsw

stosw

mov ds,ax

mov ax,BOMB_VAL

lea dx,[si - @copy_end + JUMP_DIST]
mov dl,((DIST_CALC - SAFETY_GAP)%(0x100))

mov bx,dx
add bx,(@main_loop - @copy - TOP_TRAP_DIST - 0x2)

push cs
pop es

push cs
pop ss

mov si,(INIT_SI + @reset_main_loop - @copy - 0x2)

lea di,[bx + 0x2 + TOP_TRAP_DIST - (@reset_main_loop_end - @reset_main_loop) - 0x2]
lea sp,[bx + INIT_SI + 0x2]

mov bp,di
mov cl,((@main_loop_end - @reset_main_loop)/0x2)

movsw
jmp bp

@copy:
@traps_loader:
movsw
movsw
movsw
mov cx,(@traps_loop_end - @traps_loop)/0x2
rep movsw

@traps_loop:
mov cx,0x504
lea sp,[bx + INIT_SI - 0x3]
mov bx,di

@anti_loop:
pop di
pop bp
shl bp,cl
mov [bp+di-0x2],ax
sub sp,0x3
dec ch
jnz @anti_loop
mov di,bx
rep movsw
@traps_loop_end:

@reset_main_loop_loader:
mov cl,((@main_loop_end - @reset_main_loop)/0x2 - 0x2)
rep movsw

@reset_main_loop:
add di,BOTTOM_TRAP_DIST
movsw
sub di,(INIT_SI + 0x2)
mov bx,di
movsw
mov cx,[si+0x4]
lds si,[si]
add dh,(JUMP_DIST/0x100)
@reset_main_loop_end:

@main_loop:
pop di
pop bp
shl bp,cl
mov word [bp+di-0x2],ax
add sp,[bx]
mov di,[bx]
cmp [bx+si],di
jz @main_loop
mov ds,cx
mov di,dx
movsw
jmp dx
@main_loop_end:
dw TRAP_VAL
dw TRAP_VAL
dw INIT_SI
dw 0x1000
@copy_end:

