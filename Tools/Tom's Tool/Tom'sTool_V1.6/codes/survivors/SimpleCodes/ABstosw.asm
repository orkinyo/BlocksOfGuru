;; ab53
;; no suicide

push ds
pop es
push ds
pop ss

mov sp,ax
add ax, @tail
xchg di,ax
mov ax, 0xab53
mov bx, 0xcccc
push bx
stosw
@tail:
push bx
stosw