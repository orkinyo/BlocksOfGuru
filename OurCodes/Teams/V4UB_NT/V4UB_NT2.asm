
;; Anti Callfar K12 - Best So Far
;; freindly for callfars that uses movsb

%define interval 0xf1

push ds ;; ss = Arena
pop ss ;; in order to pop from Arena

mov cx, 0xce04 ;; cl = 0x4, cx = add al,0x0f

mov sp,ax
add sp, @end 
mov ax,0xCEA4
mov dx, interval

@loop:
pop di ;; di = ip
pop bp ;; bp = seg
shl bp,cl ;; bp = 0x10*seg
mov [bp+di-0x2],ax;; bomb 0x10*seg+ip-2
add sp,dx 
jmp @loop
@end:


