;; smart anti

%define intreval 0xff
push ds
pop ss

mov cl, 0x4
xchg ax,si
lea bx, [si+@end]
mov ax, 0xcccc
@loop:
les di,[bx]
mov bp, es
shl bp, cl
mov [bp+di-0x2],ax
add bx,intreval
jmp @loop
@end:
