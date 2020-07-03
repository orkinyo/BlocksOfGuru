;; Anti Callfar K22 - Specific Places + Bytefriendly + Callfar
;; for A5 Callfar : 3,7,b,f
;; for AB Callfar : 5,9,d,1

%define interval 0xf0
;; interval should end with a zero
%define read_callfar 0x100

push ss
pop es

mov si,ax
add si, @loop
mov cl, (@end-@loop)/2
movsb
rep movsw

push cs
pop es
push ds
push ss
pop ds
pop ss

mov cx, ax
add cx, @loop
mov bx,read_callfar
mov [bx],cx
mov word[bx+0x2],0x1000
mov cx, 0x4

mov sp,ax
add sp, @end+0x200
;or sp,0x01

mov dx, interval + 0x2
mov ax, 0xCCCC


@loop:
add sp,dx
pop di
pop bp
shl bp,cl
mov [bp+di-0x2],ax
call far [bx+si]
@end:


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
%define read_callfar 0x100

push ss
pop es

mov si,ax
add si, @loop
mov cl, (@end-@loop)/2
movsb
rep movsw

push cs
pop es
push ds
push ss
pop ds
pop ss

sub ax, 0x500
or al,0x1
mov bx,read_callfar
mov [bx],ax
mov [bx+0x2],cs

mov sp,ax
add sp, (@end-@loop)+0x200-0x11
;or sp,0x01

mov dx, interval + 0x2
mov di, ax
mov ax, 0xCCCC

xor si,si
mov cl, (@end-@loop)/2
movsb
rep movsw
sub di, @end-@loop
xor si,si
mov cl,0x4
call far [bx]


@loop:
add sp,dx
pop di
pop bp
shl bp,cl
mov [bp+di-0x2],ax
call far [bx+si]
@end:

