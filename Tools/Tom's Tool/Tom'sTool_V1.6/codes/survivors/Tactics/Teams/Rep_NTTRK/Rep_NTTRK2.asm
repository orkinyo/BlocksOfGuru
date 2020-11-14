;; pb&j1 = NTTRK
;; # avoides killing rep

%define interval 0xf1
%define jumpDist 0x4000
%define upper_trap_dist 0x12
%define bottom_trap_dist 0x34

%define TRAP 0x47EB
%define initialSi 0x2+upper_trap_dist + (@anti_loop_end-@anti_loop) + bottom_trap_dist
%define trueInterval interval-0x4
%define actualJumpDist jumpDist-0x2D
%define deltaDi @anti_loop-@rk_end-upper_trap_dist-0x2+initialSi-jumpDist-30*2
%define KEY 0xB9B2

xchg dx,[KEY]
mov bx,ss
xchg ax,bx ;; ax = StackSeg, bx = loc

mov di,0x4
stosw ;; write StackSeg in Extra
mov ax,es ;; ax = ExtraSeg

push ss
pop es ;; es = StackSeg
lea si,[bx+@rk_loader]

mov di,initialSi-0x2
stosw ;; write es before StackSeg code

mov cl,(@anti_loop_end-@rk_loader)/2
rep movsw ;; copy code to StackSeg
movsb

mov ax,TRAP ;; option: make es the TRAP value?
stosw
stosw ;; bomb 2 traps in StackSeg

mov byte [bp+di],initialSi ;; for lds si,[si]  
mov word [bp+di+0x2],cs    ;; (after all the copying)

mov ax,ss ;; ax = StackSeg
push cs
push ds
pop es ;; es = Arena 
pop ss ;; ss = Arena

;; prepare sp and cx
lea sp,[bx+jumpDist+(@anti_loop_end-@reset_loader)]
lea cx,[bx+actualJumpDist] ;; cx = jmpLoc
sub dl,0x9F
and dl,0xF0
mov cl,dl
add cl,0x4
cmp cl,0x14
jnz @skip
mov cl,0x4
@skip:
add cx,@reset_loader-@rk_loader
;; prepare bx,si and dx
lea bx,[si-(@anti_loop_end-@anti_loop)-upper_trap_dist-0x2]
mov si, initialSi
mov dx, trueInterval

;; jmp to jmpLoc
mov di,cx
mov bp,cx
xor cx,cx
mov ds,ax
add si,@reset_loader-@rk_loader
movsw
jmp bp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

@rk_loader:
movsw
movsw
mov cx,(@rk_end-@rk_start)/2
movsw
movsw
rep movsw
@rk_start:
add di,deltaDi
lds bx,[si-(@rk_end-@rk_loader)-0x4] ;; ds = ExtraSeg, bx = 0x0
sub [bx],di ;; [bx] = repLoc-di 
cmp word [bx],-0x200 ;; dont rk if: repLoc-di>-0x200 => di-repLoc<0x200
lds bx,[bx+0x2] ;; bx = shit, ds = StackSeg
jae @no_rk
inc ch
std
rep stosw
cld
add di,0x200
@no_rk:
sub di,deltaDi
movsw
@rk_end:

@reset_loader:
movsw
movsw
mov cl,(@anti_loop_end-@reset_start)/2
movsb
rep movsw
@reset_start:

add di,bottom_trap_dist
movsw ;; bomb bottom trap
sub di,initialSi+0x2
mov bx,di ;; prepare bx
movsw ;; bomb top trap
lds si,[si] ;; ds = Arena, si = initialSi
lea cx,[bx+actualJumpDist] ;; cx = jmpLoc
@reset_end:

@anti_loop:
pop di ;; di = ip
pop bp ;; bp = seg
shl bp,cl ;; bp = 0x10*seg
mov [bp+di-0x2],cx ;; bomb 0x10*seg+ip-2
add sp,dx 
mov di,[bx] ;; [bx] = bottom trap
cmp di,[bx+si] ;; [bx+si] = upper trap
jz @anti_loop
mov di,cx ;; cx = nextjumpPlace
mov ds,ax ;; ax = StackSeg
movsw
jmp cx
@anti_loop_end: