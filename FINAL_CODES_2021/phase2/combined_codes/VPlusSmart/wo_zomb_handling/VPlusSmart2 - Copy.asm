;; NTT+ DEFINES
%define INTERVAL 0xF1
%define TRUE_INTERVAL (INTERVAL - 0x4)
%define JUMP_DIST (-0x4000)
%define TOP_TRAP_DIST 0x12
%define BOTTOM_TRAP_DIST 0x3B
%define TRAP_VAL TRUE_INTERVAL
%define SHARE_LOC 0xA7FB
%define INIT_SI (0x2 + TOP_TRAP_DIST + (@main_loop_end - @main_loop) + BOTTOM_TRAP_DIST)
%define BOMB_VAL 0xA593
%define DIST_CALC (0xA2 + 0x4*0x4 -((@main_loop_end - @copy) + BOTTOM_TRAP_DIST))
%define SAFETY_GAP 0x10
%define DX_OFFSET 0x2
%define CL_PART1 0x18
%define CL_PART2 ((@copy_end - @copy)/0x2 - CL_PART1)
%define SI_PART1 (CL_PART1*0x2)
;;
;; ZOMBIE DEFINES
%define ZOMB_CALL_ADDRESS 0xFF83
%define ZOMB_WRITE_DIST 0x6C
%define CALL_DI_OPCODE 0x55FF
;;
;; GENRAL DEFINES
%define CF_COPY_LABEL 0xCC
%define ZOMB_CL_COPY 0xB
%define ZOMB_CL_LOOP 0x9
%define ZOMB_CL_CHANGE 0xC
%define CALL_AMOUNT 0x84
%define CALL_DIST (0x4 * CALL_AMOUNT)
%define CF_JUMP_DIST 0x5200
%define ROWS_GAP 0x0
%define DEC_BP_JZ_OPODE 0x754D
%define ZOMBIE_COUNTER 0x80
;;


mov [SHARE_LOC],ax
jmp @our_start

@zombie_start:
mov ax,0xCCCC
mov si,ax
add si,CF_COPY_LABEL

xor dx,dx
@zomb_wait:
xchg dl,[si-0x1]

cmp dl,0x1
jnz @zomb_wait

xchg dl,[si-0x1]

push ax

mov cx,0xF
div cx
add dx,0xFF6

mov bp,dx
mov cl,0x4
shl bp,cl

mov cl,ZOMB_CL_COPY
push ss
pop es

rep movsw

mov ax,DEC_BP_JZ_OPODE
stosw
movsw
movsw

pop ax

lea bx,[bp + CALL_DIST + 0x1]
add byte [si],(ROWS_GAP + 0x3)
add ah,[si]
mov al,0xA2

push ss
pop ds

inc byte [di - ZOMB_CL_CHANGE + 0x1 - 0x2]
sub word [di-0x2],0x2

mov [bx],ax
mov [bx+0x2],dx

push cs
pop es
push cs
pop ss

mov ax,bx
mov dx,CF_JUMP_DIST
mov cl,ZOMB_CL_LOOP
xor si,si
les di,[bx]
dec di
mov bp,ZOMBIE_COUNTER

lea sp,[di+bx]

movsw
movsw

mov word [bx+si],0x2
sub di,[bx+si]

call far [bx]

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
mov bp,0x8201
mov cl,0x4
mov di,bp
lea bx,[si - @copy_end + @zombie_start]
mov [si - @copy_end + @write_ah + 0x3],bh
mov [si - @copy_end + @write_al + 0x4],bl
xor si,si
xchg bx,[SHARE_LOC]


@bomb_again:
mov [0xC801],bp
mov [0xC501],bp
mov [0xC701],bp
mov [0xC401],bp
mov [0xC101],bp
mov [0xC201],bp
mov [0xC301],bp

@xchg:
xchg sp,[di - 0x1]
xchg dx,[di + 0x200 - 0x1]
xchg si,[di + 0x400 - 0x1]
xchg ax,[di + 0x600 - 0x1]

@zombie_loop:
xchg ax,ax
xlatb
xchg ah,al
xlatb
xor ah,al
mov di,ax
@write_ah:
mov word [di + ZOMB_WRITE_DIST + 0x2],0xFFCC
@write_al:
mov word [di + ZOMB_WRITE_DIST],0xCCB9
@add_xchg:
add byte [0xCCCC],0x2
loop @zombie_loop

@reset_xchg:
mov byte [0xCCCC],0x90
mov cl,0x4

inc bp
mov di,bp

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

mov si,(INIT_SI + @reset_main_loop - @copy - 0x2)

mov [@main_loop_end - @copy + INIT_SI + 0x8],es

push cs
pop es

push cs
pop ss

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

