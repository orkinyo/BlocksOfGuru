%define interval 0x48

push ds
pop ss

mov sp,ax
mov ax,0xd4ff
mov bx,0x5251
mov cx,0x5350
mov dx,0xec29
mov bp,interval

sub sp,bp
push ax
push bx
push cx
push dx
;;jmp sp
call sp