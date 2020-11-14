
;;anti+ killer(top to buttom) + jump

%define interval 0xf1
%define jumpDist 0x2e00

;; es = StackSeg
push ss
pop es
;; copy reset part
mov si,ax
add si,@jumper
mov cl,(@reset_end-@jumper)/2
rep movsw
;; copy anti+killer part
sub si,@reset_end-@anti_loop
mov cl,(@killer_loop_end-@anti_loop)/2
rep movsw

;; es = Arena, ds = StackSeg, ss = Arena
push cs
pop es
push ss
pop ds
push cs
pop ss

;;prepare for anti
mov cl, 0x4 
mov sp,ax
add sp, @anti_loop_end 

mov dx, interval
mov bx, 0x100+0x2
mov word [bx],0xa5f3
mov word [bx+0x1+0x2+0x4*0x2], jumpDist ;; movsb,movsw,repmovsw(cl=0x4)
mov word [bx+di], @killer_loop_end-@killer_loop
mov di,ax
add di,@killer_loop

@anti_loop:
add sp,dx 
pop si ;; si = ip
pop bp ;; bp = seg
shl bp,cl ;; bp = 0x10*seg
xchg [bp+si-0x1],ax ;; bomb 0x10*seg+ip-2
cmp ax, [bx]
jnz @anti_loop
@anti_loop_end:
lea sp,[bp+si-0x1]
and sp,0xff
@killer_loop:
add sp,bx ;; bx = 0x100-0x2
db 0x73
        ;; jnc short 0x1
db 0xff
        ;; call di
db 0xd7 ;; xlatb: al = ds:(bx+al)
xor si,si
movsb
jmp @killer_loop
@killer_loop_end:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@jumper:
movsw
rep movsw
sub di, [bx+si]
mov cl,(@reset_end-@reset_reg)/2 + (@killer_loop_end-@anti_loop)/2
movsb
dec di
jmp di
@reset_loader:
movsw
db 0xCE ;; doesn't matter
movsw
rep movsw
@reset_reg:
sub di, [bx+si]
mov cl,0x4

@reset_end: