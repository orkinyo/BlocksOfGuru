;; changable
%define oneShieldLen 0x2c
%define jumpDist 0x3000

;; do not change if not necessary
%define oneShieldLoop oneShieldLen/2
%define topShieldGap 0x177
%define bottomShieldGap 0x2C1


;; copy code to StackSeg
mov si,topShieldGap + jumpDist-0x25
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
mov dx,((@copy_end-@copy_start)/2)*0x100+oneShieldLen/2
mov bp,di
mov [bp],si
add [bp],ax ;; [bp] = jmpLoc
mov word [bp+0x2],ss
mov word [bp+0x4],bottomShieldGap
mov word [bp+0x6], oneShieldLen + bottomShieldGap + (@copy_end-@loop_start) + topShieldGap + oneShieldLen
mov word [bp+0x8], bx
mov word [bp+0xA], cs

xor si,si
lds di,[bp+si]
push di
movsw
ret

@copy_loader:
movsw
movsw
mov cl,dh
movsw
rep movsw
@copy_start:
;; write bottom shield
add di,[bp+0x4] ;;bottomShieldGap
mov cl,dl
rep stosw

mov si,di

;; di = top shield start location
sub di,[bp+0x6];;oneShieldLen + bottomShieldGap + (@copy_end-@loop_start) + topShieldGap + oneShieldLen
mov cl,dl
rep stosw

add di,ax; topShieldGap + jumpDist

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
lds di,[bp+si]
movsw
ret
@copy_end:

