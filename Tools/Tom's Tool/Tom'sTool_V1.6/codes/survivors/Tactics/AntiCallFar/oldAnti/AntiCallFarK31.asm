;;Anti 31 - only close by (teamed up with 23 or 12)

%define dist 0x40

;;copy
push ss
pop es

mov si,ax
add si, @loop
mov cl, (@end-@loop)/2
;movsb
rep movsw

;;paste
;;preloop
push cs
push ss
push cs
pop es
pop ds
pop ss


mov dx,-0x2

mov di,ax
mov ax,-0x6
add di,0x500
or di,0x1
mov bp,di
lea sp,[di+dist]
push cx
push cx
push cx
pop cx
pop cx
pop cx
xor si,si
mov cl, (@end-@loop)/2
;movsb
rep movsw
mov cx, 0x0f04
jmp bp





@loop:
pop si
pop bp
shl bp,cl
mov [bp+si-0x2],cx
add sp,dx
xchg ax,dx
jmp @loop
@end: