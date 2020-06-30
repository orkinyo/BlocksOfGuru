;; rep (std) + zomb counter (bp) + FSM (anti)

;;todo:
;; make code more efficient
;; make define for amount of jump in fsm part
;; clean comments

%define repAmount 0x100
%define jumpDist 0x2e00
%define antiAmount 1500
%define antiInterval 0xf1

%define repDist 0x2*repAmount
%define trueInterval antiInterval-0x4
%define startSp 0xfbe4
;; es = StackSeg
push ss
pop es

;;copy repmovsw+reser_code to es:0x0
mov si,ax
add si,@copy
mov cl, (@reset_loop_end-@reset_loop)/2 + 0x1
rep movsw
;; write 0xeb0e into es
mov bx,ax
mov ax,0xeb0e
mov dx,ax
int 0x86
int 0x86
;; write nop and anti part
mov di, 0x202 - (@anti_end-@anti) - (0x200-repDist) - (0xe-0x4)
mov cl, (0xe-0x4)/0x2
mov ax, 0x9090
rep stosw
mov si,bx
add si, @anti
mov cl, (@anti_end-@anti)/0x2
rep movsw

std

;; es = Arena, ds = StackSeg
push ds
push es
pop ds
pop es
;; write repmovsw in Arena
add bx, jumpDist ;; bx = repmovsw loc
mov di, bx
xor si,si
movsw
;; prepare for REP
add di,repDist + 0x2;; - 0x1 ;; fo/e
mov cx,repAmount+0x1
mov ax,repDist + 0x2;; - 0x1 ;; fo/e
mov sp,jumpDist
mov dx,repAmount+0x1
mov si, repDist+0x2
jmp bx

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

@copy:
rep movsw
@reset_loop:
add bx, sp ;; sp = jumpDist
mov di,bx
movsw
mov si, repDist+0x2
add di, ax ;; ax = repDist + 0x2 - 0x1
mov cx, dx ;; dx = repAmount + (@reset_loop_end-@reset_loop)/0x2
dec bp
db 0x75
		;; 0x75ff - jnz short 0xff
db 0xff
		;; 0xffe3 - jmp bx
db 0xe3
@reset_loop_end:
;;;; tons of 0xeb0e
;;;; lots of nops
@anti:
;;prepare for anti_loop
push cs
pop ss
push cs
pop ds
mov cx, 0xce04 ;; cl = 0x4, ch = 0xce (illegal opcode)
mov es,cx ;; in order to make sure suicide will work
mov sp,startSp
mov dx, trueInterval
@anti_loop:
pop di ;; di = ip
pop bp ;; bp = seg
shl bp,cl ;; bp = 0x10*seg
mov [bp+di-0x2],cx ;; bomb 0x10*seg+ip-0x2
add sp,dx 
jnz @anti_loop ;; when sp==0 suicide will happen
dw 0xcccc
@anti_end:

@copy_end: