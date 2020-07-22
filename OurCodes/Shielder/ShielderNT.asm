;; shielder against callfars
;; does NT on the traps 

;; changable
%define oneShieldLen 0x2c
%define jumpDist 0x3000

;; do not change if not necessary
%define topShieldGap 0x1A6
%define bottomShieldGap 0x2F0
%define trueJumpDist jumpDist - 0x5C

;; copy code to StackSeg
mov si,topShieldGap + trueJumpDist
add ax,@copy_loader
xchg ax,si ;; ax = distShit, si = loc
push ss
pop es
mov cl,(@copy_end-@copy_loader)/2
movsb
rep movsw
push ds
pop es

mov bx,oneShieldLen
mov dx,((@anti_end-@anti_start)/2)*0x100+oneShieldLen/2
mov bp,di
mov [bp],si
add [bp],ax ;; [bp] = jmpLoc
mov word [bp+0x2],ss
mov word [bp+0x4],bottomShieldGap
mov word [bp+0x6], oneShieldLen + bottomShieldGap + (@copy_end-@loop_start) + topShieldGap + oneShieldLen
mov word [bp+0x8], bx
mov word [bp+0xA], cs
mov word [bp+0xC],sp
mov word [bp+0xE], oneShieldLen+ topShieldGap + (@copy_end-@loop_start) + bottomShieldGap

lds di,[bp]
mov si,@anti_end-@copy_loader
push di
movsw
ret

@copy_loader:
movsw
movsw
mov cl,dh
rep movsw
@copy_start:
@anti_start:
xchg di,[bp]
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
pop ss
mov bp,(@copy_end-@copy_loader)+0x1
xchg di,[bp]
mov si,0x6+@anti_end-@anti_start
mov sp,[bp+0xC]
movsw
;;fix bp,sp,si,di,ss ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@anti_end:
movsw
mov cl,(@copy_end-@copy_truely_start)/2
movsw 
rep movsw ;; ????
@copy_truely_start:
;; write bottom shield
add di,[bp+0x4] ;;bottomShieldGap
mov cl,dl
rep stosw

mov si,di

;; di = top shield start location
sub di,[bp+0x6];;oneShieldLen + bottomShieldGap + (@copy_end-@loop_start) + topShieldGap + oneShieldLen
mov cl,dl
rep stosw

add di,ax; topShieldGap + trueJumpDist

mov [bp],di
push word [bp]
push cx

sub di,ax
lds bx,[bp+0x8]
@loop_start:
sub di,bx
sub si,bx
mov cl,dl
repe cmpsw
jz short @loop_start

pop si ;; si = 0
mov ds,[bp+si+0x2]
xchg di,[bp+si]
movsw
retn
@copy_end:

