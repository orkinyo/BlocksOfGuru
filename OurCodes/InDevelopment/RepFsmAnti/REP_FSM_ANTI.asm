;; rep + zomb_counter(bp) + FSM (anti)
;; fo/e - for even/odd purposes


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;ABSOLUTE-DEFINES;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; (@anti_end-@anti)/2 < repAmount <= 0x100+(@anti_end-@anti)/2
;; 0x10 <= repAmount <= 0x10e
%define repAmount 0x100
%define jumpDist 0x2e00
%define antiAmount 1500
%define antiInterval 0xf1


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;ACTUAL-DEFINES;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


%define repDist 0x2*repAmount
%define trueInterval antiInterval-0x4
%define startSp (0x10000-(interval*antiAmount))%0x10000


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;CONST-DEFINES;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;0xb0 <= fillbyte <= 0xb7
%define fillbyte1 0xb0
%define fillbyte2 0xb0


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;ACTUAL_CONST_DEFINES;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


%define fillword fillbyte1*0x100+fillbyte2


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;HELPER-FUNCTIONS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


def calc_start_sp(interval, antiAmount):
    sp = 0x10000-interval
    count = 1
    while count != antiAmount:
            if sp<0:
                    sp += 0x10000
            sp-= interval
            count +=1
    return sp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;START-OF-CODE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; es = StackSeg
push ss
pop es

;;copy repmovsw to es:0x0
mov si,ax
add si,@copy
movsw
;; fill es with 0xb0
xchg ax,bx ;; bx = loc
mov ax, fillword
mov dx,ax ;; dx can also be fillbyte3*0x100+fillbyte4
int 0x86
int 0x86
;;copy FSM(anti) + reset loop after the bombing
sub di, @anti_end-@anti + 0x200-repDist + 0x1 ;; fo/e
mov cl, (@anti_end-@anti)/0x2 + (@reset_loop_end-@reset_loop)/2 +0x1 ;; fo/e
rep movsw

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
sub di,repDist + 0x2 - 0x1;; fo/e
mov cx,repAmount + (@reset_loop_end-@reset_loop)/0x2

mov ax,repDist + 0x2 - 0x1 ;; fo/e
mov sp,jumpDist
mov dx,repAmount + (@reset_loop_end-@reset_loop)/0x2
jmp bx


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;END-OF-REGULAR-CODE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


@copy:

rep movsw

@anti:
;; for catching the FSMed survivors
nop
nop
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
@anti_end:

@reset_loop:
rep movsw
add bx, sp ;; sp = jumpDist
mov di,bx
xor si,si
movsw
sub di, ax ;; ax = repDist + 0x2 - 0x1
mov cx, dx ;; dx = repAmount + (@reset_loop_end-@reset_loop)/0x2
dec bp
db 0x75
		;; 0x75ff - jnz short 0xff
db 0xff
		;; 0xffe3 - jmp bx
db 0xe3
@reset_loop_end:

@copy_end:


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;END-OF-CODE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
