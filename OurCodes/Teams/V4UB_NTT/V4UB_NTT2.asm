
;; Anti Callfar K12 - Best So Far
;; plus traps (jumps if about to be run over)
;; uses dx instead of cx as nextjumpPlace (so that it doesn't have to end with 4)

%define interval 0xf1
%define jumpDist 0x4000
%define upper_trap_dist 0x12
%define bottom_trap_dist 0x34

%define initialSi (0x2+upper_trap_dist + (@anti_loop_end-@anti_loop) + bottom_trap_dist)
%define trueInterval (interval-0x4)
%define TRAP trueInterval ;; make sure it isn't a common opcode or part of callfar location
%define KEY 0xA7F3

mov bx,TRAP
xchg ax,bx ;; ax = TRAP, bx = loc

push ss
pop es ;; es = StackSeg
xchg dx,[KEY]
lea si,[bx+@reset_loader]
mov di,initialSi
mov cl,(@anti_loop_end-@reset_loader)/2
rep movsw ;; copy code to StackSeg

stosw
stosw ;; bomb 2 traps in StackSeg

mov byte [bp+di],initialSi ;; for lds si,[si]  
mov word [bp+di+0x2],cs    ;; (after all the copying)

mov ax,ss ;; ax = StackSeg
push cs
push ds
pop es ;; es = Arena 
pop ss ;; ss = Arena

;; prepare dx,cl
mov cl, 0xA4 ;; illegal opcode
shl dx,cl
add dx,0xA0-0x10-(@anti_loop-@reset_loader)+upper_trap_dist+0x2-initialSi
add dh,bh
add dx,jumpDist

;; prepare bx and si
mov bx,dx
add bx,@anti_loop-@reset_loader-upper_trap_dist-0x2
lea sp,[bx+initialSi+0x2]
mov si, initialSi

;; jmp to jmpLoc
mov di,dx
mov ds,ax
movsw
jmp dx

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


@reset_loader:
movsw
movsw
mov cx,(@anti_loop_end-@reset_start)/2
movsw
rep movsw
@reset_start:

add di,bottom_trap_dist
movsw ;; bomb bottom trap
sub di,initialSi+0x2
mov bx,di ;; prepare bx
movsw ;; bomb top trap
lds si,[si] ;; ds = Arena, si = initialSi
lea dx,[bx+jumpDist-0x4] ;; dx = jmpLoc
mov cl,0xA4
@reset_end:

@anti_loop:
pop di ;; di = ip
pop bp ;; bp = seg
shl bp,cl ;; bp = 0x10*seg
mov [bp+di-0x2],cx ;; bomb 0x10*seg+ip-2
add sp,[bx] 
mov di,[bx] ;; [bx] = bottom trap
cmp di,[bx+si] ;; [bx+si] = upper trap
jz @anti_loop
mov di,dx ;; cx = nextjumpPlace
mov ds,ax ;; ax = StackSeg
movsw
jmp dx
@anti_loop_end:

