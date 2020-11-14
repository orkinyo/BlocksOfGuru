;; working 23/3 14:31 - works for inf jumps
;; Anti Callfar K22 - Specific Places + Bytefriendly + Callfar
;; for A5 Callfar : 3,7,b,f
;; for AB Callfar : 5,9,d,1

;; can do: 
;; decide magic seg by "or al,0xf8"
;; in order to currect the anti
;; change Independent variable in line
;; (change before copying to StackSegment)
;; "mov [bp+di-0x2],ax"

%define interval 0xf0
;; interval should end with a zero
%define read_callfar 0x500

%define currect_sp -read_callfar+(-0x400+1-0xff)

push ss
pop es

mov si,ax
add si, @restart_anti
mov cl, (@end-@restart_anti)/2
rep movsw

push cs
pop es
push ds
push ss
pop ds
pop ss

sub ax, 0x500
;or al,0x1
mov al, 0xA0
mov bx,read_callfar
mov [bx],ax
mov [bx+0x2],cs
mov word [bx+0x20],currect_sp
mov sp,ax
sub sp,0x400-0x1

mov dx, interval + 0x2
mov di, ax
mov ax, 0xf631

mov si, @loop-@restart_anti
mov cl, (@end-@loop)/2
;movsb
rep movsw
sub di, 0x6
xor si,si
mov cx,0x0f04
call far [bx]

@restart_anti:
db 0xcc
db 0xcc
nop
movsw ;; start
movsw
movsw
mov cx,(@end_copy-@start_copy)/2
movsw
rep movsw
@start_copy:
sub word[bx],bx
add sp,[bx+si]
les di,[bx]
mov cl,(@end-@loop)/2
rep movsw
sub di,0x6
xor si,si
mov cx,0x0f04
call far[bx]
@end_copy:


@loop:
add sp,dx
pop si
pop bp
shl bp,cl
mov [bp+si-0x2],cx
@run_over:
call far [bx]
db 0x00
db 0x20
db 0x1f
rep movsw
@end:



