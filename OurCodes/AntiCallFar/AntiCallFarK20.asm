;; smart anti + bombs
;; 4 bytes per 6 opcodes

;; warning kills itself:
;; (value) - (turn that kills itself):
;; 0xf5 - 111000
;; 0xfb - 95580
;; 0xf9 - 64977


%define intreval 0xf5
push ds
pop ss

mov cl, 0x4
xchg ax,si
lea bx, [si+@end]
mov ax, 0xcccc
@loop:
xchg di, [bx]
xchg bp, [bx+0x2]
shl bp, cl
mov [bp+di-0x2],ax
add bx,intreval
jmp @loop
@end:
