
;; Anti Callfar K12 - Best So Far
;; A4 friendly
;; plus traps (jumps if about to be run over)

%define interval 0xf1
%define jumpDist 0x2e00
%define upper_trap_dist 0x12
%define bottom_trap_dist 0x34

%define TRAP 0x47EB


mov bx,ax


push ss
pop es ;; es = StackSeg

lea si,[bx+@copy_loader]
mov di,0x2+upper_trap_dist + (@end-@loop) + bottom_trap_dist
mov cl,(@copy_end-@copy_loader)/2
rep movsw

sub si,@copy_end-@loop
mov cl,(@end-@loop)/2
rep movsw
mov ax,TRAP
stosw
stosw

;; is [bp+di] in the right place ??
mov word[bp+di],0x2+upper_trap_dist + (@end-@loop) + bottom_trap_dist
mov word[bp+di+0x2],cs

mov ax,ss
push cs
push ds
pop es ;; es = Arena 
pop ss ;; ss = Arena

lea cx,[bx+jumpDist]
mov cl, 0xA4
;; shl __,cl -> shl __,0x4 |||| cl = movsb ||| cx = nextjumpPlace

lea sp,[bx+@loop-0x4]
mov dx, interval-0x4
add bx, @loop-upper_trap_dist-0x2
mov si, 0x2+upper_trap_dist + (@end-@loop) + bottom_trap_dist
mov word [bx],TRAP
mov word [bx+si],TRAP

@loop:
pop di ;; di = ip
pop bp ;; bp = seg
shl bp,cl ;; bp = 0x10*seg
mov [bp+di-0x2],cx ;; bomb 0x10*seg+ip-2
add sp,dx 
mov bp,[bx] ;; [bx] = bottom trap
cmp bp,[bx+si] ;; [bx+si] = upper trap
jz @loop
mov di,cx ;; cx = nextjumpPlace
mov ds,ax ;; ax = StackSeg
movsw
jmp cx
@end:

;;;;;;;;;;;;;;;
@copy_loader:
movsw
movsw
mov cx,(@copy_end-@copy + @end-@loop)/2
movsw
rep movsw
@copy:

add di,bottom_trap_dist
movsw
sub di,0x2+bottom_trap_dist + @end-@loop + upper_trap_dist+0x2
mov bx,di
movsw
lds si,[si]
lea cx,[bx+jumpDist-0x4]

@copy_end:
;;anti