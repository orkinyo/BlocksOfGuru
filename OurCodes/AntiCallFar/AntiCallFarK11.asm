;; Anti Callfar K3 - Specific Places 
;; for A5 Callfar : 3,7,b,f
;; for AB Callfar : 5,9,d,1

%define interval 0xf0
;; interval should end with a zero

push ds
pop ss

mov cl, 0x4

mov bx,ax
add bx, @end
and bx, 0xF0
inc bx

mov dx, interval + 0x2
mov ax, 0xCCCC

@loop:
les di, [bx]
mov bp, es
shl bp,cl
mov [bp+di-0x2],ax
add bx,dx
jmp @loop
@end:
