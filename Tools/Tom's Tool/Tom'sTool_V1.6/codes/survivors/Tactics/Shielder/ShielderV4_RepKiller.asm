;; experimental code!!!

;; shield against V4
;; kills rep(std) on trap


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
movsb ;; fo/e
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
mov cx,(@rep_bomb_end-@rep_bomb_start)/2
mov bp,cx
mov word [bp+si+(@end-@copy_loader)],jmpDist
mov word [si+(@end-@copy_loader)], initialSi 
lea di,[bx+topShieldGap+@end-@loop+jmpDist]
push di
movsw
ret

@copy_loader:
movsw
rep movsw
@rep_bomb_start:
mov ax,0x07FA
push di
mov di,bx
scasw
jz @skip
add di,initialSi
@skip:
sub di,32*2 ;; amountOfTurns
inc ch
std
rep stosw
cld
pop di
movsw
@rep_bomb_end:
movsw
mov cl,(@end-@copy_start)/2
movsw
movsw
rep movsw
@copy_start:
add bx,dx
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
