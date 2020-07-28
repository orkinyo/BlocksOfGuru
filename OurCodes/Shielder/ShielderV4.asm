;; shield against V4
;; changable
%define jmpDist 0x3000-0x1c

;; do not change if not necessary
%define topShieldGap 0x8
%define bottomShieldGap 0x1A
%define initialSi topShieldGap + bottomShieldGap +bottomShieldGap+@end-@loop

push ss
pop es
mov si,ax
add si,@copy_loader
mov di, initialSi
mov cl,(@end-@copy_loader)/2
movsb
rep movsw

push cs
push ss
push cs
pop es
pop ds

mov bx,ax
add bx,@loop-topShieldGap
mov si,initialSi
mov dx,jmpDist+(@end-@copy_loader)
mov cx,(@end-@copy_start)/2
mov bp,cx
mov word [bp+si+(@end-@copy_loader)],jmpDist
mov word [si+(@end-@copy_loader)], si
lea di,[bx+topShieldGap+@end-@loop+jmpDist]
push di
movsw
ret

@copy_loader:
movsw
rep movsw
@copy_start:

add bx,dx
;lea bx,[di-(@end-@loop)-bottomShieldGap]
add di,[bp+si];jmpDist
mov si,[si];;initialSi
pop ds

push cs
push di
push ss
mov cx,bp

mov [bx],sp
mov [bx+si],sp
@loop:
mov ax,[bx]
cmp ax,[bx+si]
jz @loop
;; lds di,[bp+si]
pop ds
movsw
ret
@end:
