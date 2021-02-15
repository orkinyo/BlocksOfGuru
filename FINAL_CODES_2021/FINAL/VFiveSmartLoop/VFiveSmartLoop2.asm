%define JUMP_DIST 0xF900
%define CALL_AMOUNT 0x55
%define GAP 0x19
%define CALL_DIST (CALL_AMOUNT * (GAP - 0x4) - 0x4)
%define MAGIC_SEG 0xFFA

%define SHARE_LOC 0x8101

%define ZOMB_WRITE_DIST 0x6C
%define ROWS_GAP 0x3
%define ZOMB_JUMP_OPCODE (((@zomb_land - @zomb_jump - 0x2) * 0x100) + 0xEB)
%define ZOMB_COUNTER 0x200

%define AX_INT_86 0x86D7
%define INT_87_AX 0xCCCC
%define INT_87_DX 0xFFCC



mov [SHARE_LOC],ax
jmp @our_start

@div_offset:
db 0xF
db 0x0
@ax_les_offset:
dw AX_INT_86
dw 0x1000


@our_start:
mov si,ax
push ss
add si,@copy
pop es

push cs
mov cx,(@copy_end - @copy)/0x2 - 0x1

@write_seg:
mov dx,0xCCCC
mov bp,dx
rcr bp,cl
add bp,0x100
push cs

rep movsw
movsw

pop es
push bp
@write_ax:
mov ax,ROWS_GAP*0x100
add byte [si-@copy_end+@write_ax+0x2],ROWS_GAP
mov al,0xA7

xchg [bp],ax
mov word [bp+0x2],dx

add word [bp + di - 0x2],JUMP_DIST - GAP - CALL_DIST
mov word [bp + (@loop - @copy)],GAP

push ss

;
@zomb_jump:
lea bx,[si-@copy_end+@zomb_start]
mov [si-@copy_end+@write_ah+0x3],bh
mov [si-@copy_end+@write_al+0x4],bl
add si,@start-@copy_end
mov [si-@start+@add_xchg+0x2],si
mov [si-@start+@reset_xchg+0x2],si
dec di
mov bp,di
mov cl,0x4
cwd
cwd
xchg bx,[SHARE_LOC]
@bomb_sec:
mov [0xC801],al
mov [0xC501],al
mov [0xC701],al
mov [0xC401],al
mov [0xC101],al
mov [0xC201],al
mov [0xC301],al

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@xchg:
xchg sp,[di - 0x1B + 0x8200]
xchg dx,[di - 0x1B + 0x8400]
xchg ax,[di - 0x1B + 0x8600]
xchg si,[di - 0x1B + 0x8800]

; registers order: ax,dx,sp,si
@start:
nop
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
loop @start
@reset_xchg:
mov byte [0xCCCC],0x90
mov cl,0x4

inc bp
mov di,bp


jnp @bomb_sec

xor si,si
mov sp,0x7FA

jmp @skip_zomb_counter
;

@zomb_land:
mov si,(0x8000 + ZOMB_COUNTER)
@skip_zomb_counter:
mov di,[0x0000]
int 0x86
xor di,di
int 0x86

pop ds
pop bx
pop ss

mov cl,(@loop_end - @loop)/0x2
mov bp,si
xor si,si

mov ax,INT_87_AX
mov dx,INT_87_DX
int 0x87

mov ax,0xA5F3
les di,[bx]
lea sp,[di + bx + 0x2 - CALL_DIST - 0x100]
dec di
mov dx,JUMP_DIST

movsw
movsw
movsw
sub di,0x2

call far [bx]


@copy:
@call_far:
db 0x69
add sp,[bx+si]
call far [bx]
db 0x65

@loop:
add [bx],dx
add di,[si]
add sp,[bx+si]
mov cl,(@loop_end - @loop)/0x2
xor si,si
movsw
movsw
movsw
sub di,0x2
dec bp
db 0x78
call far [bx]
@loop_end:
dw (JUMP_DIST - (@loop_end - @loop) - 0x2 - 0x4)

@copy_end:


@db_1:
db 0x1
@zomb_start:

call @get_ip
@get_ip:
pop si

xor dx,dx
@wait:
xchg dl,[si-@get_ip+@db_1]
cmp dl,0x1
jnz @wait

xchg [si-@get_ip+@db_1],dl

lea ax,[si-@get_ip]
mov word[si-@get_ip+@zomb_jump],ZOMB_JUMP_OPCODE


jmp @our_start
