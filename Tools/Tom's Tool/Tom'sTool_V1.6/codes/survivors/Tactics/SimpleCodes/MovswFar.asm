%define interval 0xfe

push ss
pop es

mov si,ax
add si,@start
mov cl,0x6
rep movsw

push cs
push ss
pop ds
pop es

mov bp,interval
lea si,[di-0x2]
mov di,ax
add di,@here+0x2
@here:
movsw
xor si,si

@start:
movsw
movsw
movsw
sub di,bp
push di
movsw
ret
movsw
xor si,si
movsw

;;;;;;;;;;;;;;;;;;;;;;;;;;
