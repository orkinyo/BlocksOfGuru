;; NTT+ DEFINES
%define INTERVAL 0xF1
%define TRUE_INTERVAL (INTERVAL - 0x4)
%define JUMP_DIST 0x4000
%define TOP_TRAP_DIST 0x12
%define BOTTOM_TRAP_DIST 0x3B
%define TRAP_VAL TRUE_INTERVAL
%define SHARE_LOC 0xA7FB
%define INIT_SI (0x2 + TOP_TRAP_DIST + (@main_loop_end - @main_loop) + BOTTOM_TRAP_DIST)
%define BOMB_VAL 0xA593
%define DIST_CALC (0xA2 + 0x4*0x4 -((@main_loop_end - @copy) + BOTTOM_TRAP_DIST))
%define SAFETY_GAP 0x10
%define DX_OFFSET 0x6
%define CL_PART1 ((@copy_end - @copy)/0x2 - 0x15)
%define CL_PART2 0x15
%define SI_PART1 (CL_PART1*0x2)
;;
;; ZOMBIE DEFINES
%define ZOMB_CALL_ADDRESS 0xFF83
%define ZOMB_WRITE_DIST 0x6C
%define CALL_DI_OPCODE 0x55FF
;;



jmp @our_start

@zombie_start:


@our_start:
add ax,@copy_end - SI_PART1
mov si,ss
mov bx,ss
and bx,0x10
lea si,[bx+si+0x4]
xchg ax,si

push si ; for end

mov es,ax

mov di,INIT_SI + @copy_end - @copy - SI_PART1

xchg bp,[SHARE_LOC]

lea dx,[si - @copy_end + JUMP_DIST]
mov dl,((DIST_CALC - SAFETY_GAP)%(0x100)) + DX_OFFSET - 0x10
add dx,bp

push dx ; for end

mov cl,CL_PART1
rep movsw

;; zombie section
mov dx,0x8200
mov cl,0x4
mov di,dx
lea bx,[si - @copy_end + @zombie_start]
mov [si - @copy_end + @write_ah + 0x3],bh
mov [si - @copy_end + @write_al + 0x4],bl
add bx,@zombie_loop - @zombie_start
mov [si - @copy_end + @dec_xchg + 0x2],bx
mov [si - @copy_end + @reset_xchg + 0x2],bx
xor si,si
xchg bx,[SHARE_LOC]


mov [0xC801],bp
mov [0xC501],bp
@bomb_again:
mov [0xC701],bp
mov [0xC401],bp
mov [0xC101],bp
mov [0xC201],bp
mov [0xC301],bp

@xchg:
xchg bp,[di]
xchg si,[di + 0x200]
xchg sp,[di + 0x400]
xchg di,[di + 0x600]

@zombie_loop:
xchg ax,di
xlatb
xchg ah,al
xlatb
xor ah,al
mov di,ax
@write_ah:
mov word [di + ZOMB_WRITE_DIST + 0x2],0xFFCC
@write_al:
mov word [di + ZOMB_WRITE_DIST],0xCCB9
@dec_xchg:
dec byte [0xCCCC]
loop @zombie_loop

@reset_xchg:
mov byte [0xCCCC],0x97
mov cl,0x4

inc dl
mov di,dx

jnp @bomb_again


;; zombie section end


mov sp,0x7FC ; for end
pop dx ; for end
pop si ; for end

mov cl,CL_PART2
mov di,INIT_SI
add si,SI_PART1 - @copy_end + @copy
rep movsw

push es
pop ds

mov bx,dx
add bx,(@main_loop - @copy - TOP_TRAP_DIST - 0x2)

push cs
pop ss

mov si,(INIT_SI + @reset_main_loop - @copy - 0x2)

mov [@main_loop_end - @copy + INIT_SI + 0x8],es

push cs
pop es

mov ax,BOMB_VAL

lea di,[bx + 0x2 + TOP_TRAP_DIST - (@reset_main_loop_end - @reset_main_loop) - 0x2]
lea sp,[bx + INIT_SI + 0x2]

mov bp,di
mov cl,((@main_loop_end - @reset_main_loop)/0x2)

movsw
jmp bp

@copy:
@traps_loader:
movsw
movsw
movsw
mov cx,(@traps_loop_end - @traps_loop)/0x2
rep movsw

@traps_loop:
mov cx,0x504
lea sp,[bx + INIT_SI - 0x3]
mov bx,di

@anti_loop:
pop di
pop bp
shl bp,cl
mov word [bp+di-0x2],ax
sub sp,0x3
dec ch
jnz @anti_loop
mov di,bx
rep movsw
@traps_loop_end:

@reset_main_loop_loader:
mov cl,((@main_loop_end - @reset_main_loop)/0x2 - 0x2)
rep movsw

@reset_main_loop:
add di,BOTTOM_TRAP_DIST
movsw
sub di,(INIT_SI + 0x2)
mov bx,di
movsw
mov cx,[si+0x4]
lds si,[si]
add dh,(JUMP_DIST/0x100)
@reset_main_loop_end:

@main_loop:
pop di
pop bp
shl bp,cl
mov word [bp+di-0x2],ax
add sp,[bx]
mov di,[bx]
cmp [bx+si],di
jz @main_loop
mov ds,cx
mov di,dx
movsw
jmp dx
@main_loop_end:
dw TRAP_VAL
dw TRAP_VAL
dw INIT_SI
dw 0x1000
@copy_end:

