;; shielder against callfars
;; does NT on the traps 

;; changable
%define oneShieldLen 0x2c
%define jumpDist 0x3000

;; do not change if not necessary
%define topShieldGap 0x1A6
%define bottomShieldGap 0x2F0
%define trueJumpDist jumpDist - 0x56

;; copy code to StackSeg
mov si,topShieldGap + trueJumpDist
add ax,@copy_loader
xchg ax,si ;; ax = distShit, si = loc
push ss
pop es
mov cl,(@copy_end-@copy_loader)/2
rep movsw
push ds
pop es

mov bx,oneShieldLen

mov bp,di
mov [bp],ss
lea dx,[si+topShieldGap + trueJumpDist]
mov word [bp+0x4],bottomShieldGap
mov word [bp+0x6], oneShieldLen + bottomShieldGap + (@copy_end-@loop_start) + topShieldGap + oneShieldLen
mov word [bp+0x8], bx
mov word [bp+0xA], cs
mov word [bp+0xC],sp
mov word [bp+0xE], oneShieldLen+ topShieldGap + (@copy_end-@loop_start) + bottomShieldGap

xchg dx,ax ;; dx = distShit, ax = nextJumpLoc
lds di,[bp-0x2]
mov di,ax
mov si,@anti_end-@copy_loader
push di
movsw
ret

@copy_loader:
movsw
movsw
mov cl,((@anti_end-@anti_start)/2)
rep movsw
@copy_start:
@anti_start:
xchg di,ax
sub di,0x2
scasw
jnz @inUpper
add di,[bp+0xE]
@inUpper:
lea sp,[di-0x5]
mov ss,[bp+0xA]

mov cx,0x0564
@anti_loop:
pop bp ;; ip
pop si ;; seg
shl si,cl
mov [bp+si-0x2], cx
sub sp,0x3
dec ch
jnz @anti_loop
push ds
pop ss ;; mov ss,[bx+si]
mov bp,(@copy_end-@copy_loader)
xchg di,ax
mov si,0x6+@anti_end-@anti_start
mov sp,[bp+0xC]
movsw
;;fix bp,sp,si,di,ss ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@anti_end:
movsw
mov cl,(@copy_end-@copy_truely_start)/2
movsw 
movsw
rep movsw
@copy_truely_start:
;; write bottom shield
add di,[bp+0x4] ;;bottomShieldGap
mov cl,oneShieldLen/2
rep stosw

mov si,di

;; di = top shield start location
sub di,[bp+0x6];;oneShieldLen + bottomShieldGap + (@copy_end-@loop_start) + topShieldGap + oneShieldLen
mov cl,oneShieldLen/2
rep stosw

add di,dx; topShieldGap + trueJumpDist

mov ax,di
push ax
push cx

sub di,dx
lds bx,[bp+0x8]
@loop_start:
sub di,bx
sub si,bx
mov cl,oneShieldLen/2
repe cmpsw
jz short @loop_start

pop si ;; si = 0
mov ds,[bp+si]
xchg di,ax
movsw
retn
@copy_end:

