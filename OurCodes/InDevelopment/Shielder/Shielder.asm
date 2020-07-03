;; changable
%define oneShieldLen 40
%define shieldCode 0x88A1
%define jumpDist 0x3000

;; do not change if not necessary
%define oneShieldLoop oneShieldLen/2
%define bottomShieldGap 0x40
%define topShieldGap 0x40
%define codeLength (@copy_end - @loop_start)
%define distToCmp (@loop_start - @copy_start)
%define copyLoop (@copy_end - @copy_start)/2

mov si,shieldCode
xchg si,ax
add si,@copy_start

push ss
pop es

mov cl,copyLoop
rep movsw

;;;;

push ds
pop es

push ss
pop ds

xor si,si
lea di,[si - @copy_end + jumpDist]
mov cl,copyLoop
movsw

sub di,0x2

jmp di
;;;;

@copy_start:
rep movsw
rep movsw

;; write bottom shield
add di,bottomShieldGap


mov cl,oneShieldLoop
rep stosw

mov si,di

;; di = top shield start location
sub di,oneShieldLen + bottomShieldGap + codeLength + topShieldGap + oneShieldLen
mov cl,oneShieldLoop
rep stosw

;; bx = next jump location
lea bx,[di + topShieldGap + distToCmp + jumpDist]

;; put values in StackSeg
push ss
push bx

push es
pop ds

@loop_start:
sub di,oneShieldLen
sub si,oneShieldLen

mov cl,oneShieldLoop
repe cmpsw
jz short @loop_start
pop di
pop ds
xor si,si
mov cl,copyLoop
movsw
sub di,0x2
jmp di
nop

@copy_end: