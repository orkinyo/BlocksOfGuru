;; 
;; anti + killer + no jump 

%define interval 0xf1

push cs
pop ss

mov cl, 0x04 

mov sp,ax
add sp, @end 

mov dx, interval
mov bx, 0xa5f3
mov di,ax
add di,@loopy

@loop:
add sp,dx 
pop si ;; si = ip
pop bp ;; bp = seg
shl bp,cl ;; bp = 0x10*seg
xchg [bp+si-0x1],ax ;; bomb 0x10*seg+ip-2
cmp ax, [bx]
jnz @loop
@end:
lea sp,[bp+si-0x1]
and sp,0xff
or sp,0xff00
@loopy:
sub sp,0x100 -0x2
db 0x73
        ;; jnc short 0x1
db 0xff
        ;; call di
db 0xd7 ;; xlatb: al = ds:(bx+al)
jmp @loop


