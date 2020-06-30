;; bestest K2
;; smart anti + bombs
;; 4/6 bytes per 7 opcodes

%define intreval 0xe2
%define first_stop 0x38a3

push ds
push ds
pop es
pop ss


mov di,ax
sub di,0x500
or di,0x1

lea bx, [di-0x4]
mov dx,intreval

mov si,ax
add si, @loop
mov cl,(@end-@loop)/2

mov ax, 0xcccc

rep movsw
movsb

mov cl, 0x4
sub di,(@end-@loop)
mov si, first_stop
jmp di

@loop:
xchg di, [bx]
xchg bp, [bx+0x2]
shl bp, cl
mov [bp+di-0x2],ax
sub bx,dx
dec si
jnz @loop
sub bx,(@end-@loop)+0x4+0x1
mov si,first_stop
@end:
