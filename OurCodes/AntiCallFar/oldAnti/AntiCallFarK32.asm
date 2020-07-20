%define trap_dist 0x40

push cs
pop ss

mov cx,0x0f04
mov dx, 0x6
mov sp,ax
add sp,@end+trap_dist
or sp,0x1
push cx
push cx
push cx
pop cx
pop cx
pop cx

@loop:
pop bx
pop si;;
pop bp;;
shl bp, cl
mov [bp+si-0x2],cx
shl si,cl
mov [bx+si-0x2],cx
sub sp,dx
jmp @loop

@end: