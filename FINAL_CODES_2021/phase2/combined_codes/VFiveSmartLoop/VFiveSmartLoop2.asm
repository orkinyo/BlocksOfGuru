%define JUMP_DIST 0x5200
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

mov [SHARE_LOC],ax
jmp @our_start

@div_offset:
db 0xF
db 0x0
@ax_les_offset:
dw AX_INT_86
dw 0x0010


@our_start:
mov si,ax
push ss
add si,@copy
pop es

push cs
nop

@write_seg:
mov dx,0xCCCC

mov bp,dx
mov cx,(@copy_end - @copy)/0x2
rcr bp,cl
sub bp,CALL_DIST


rep movsw


pop es
push bp
@write_ax:
mov ax,ROWS_GAP*0x100
add byte [si-@copy_end+@write_ax+0x2],ROWS_GAP
mov al,0xA7



mov bp,0x100
push bp
mov [bp],ax
mov word [bp+0x2],dx

mov word [bp+di-0x100],(JUMP_DIST - (@loop_end - @loop) - 0x2 - 0x4)
add word [bp+di],JUMP_DIST - GAP - CALL_DIST
mov word [bp + (@loop - @copy)],GAP



;
@zomb_jump:
lea bx,[si-@copy_end+@zomb_start]
mov [si-@copy_end+@write_ah+0x3],bh
mov [si-@copy_end+@write_al+0x4],bl
add si,@start-@copy_end
mov [si-@start+@add_xchg+0x2],si
mov [si-@start+@reset_xchg+0x2],si
mov bp,di
mov cl,0x4
cwd
cwd
xchg bx,[SHARE_LOC]
@bomb_sec:
mov [0xC801],ds
mov [0xC501],ds
mov [0xC701],ds
mov [0xC401],ds
mov [0xC101],ds
mov [0xC201],ds
mov [0xC301],ds

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@xchg:
xchg sp,[di - 0x1A + 0x8200]
xchg dx,[di - 0x1A + 0x8400]
xchg ax,[di - 0x1A + 0x8600]
xchg si,[di - 0x1A + 0x8800]

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


jp @bomb_sec
xor si,si
mov sp,0x7FC
jmp @skip_zomb_counter
;

@zomb_land:
mov si,ZOMB_COUNTER
@skip_zomb_counter:
pop bx
pop bp
push ss
pop ds
push cs
pop ss

mov dx,JUMP_DIST
mov cl,(@loop_end - @loop)/0x2
mov ax,0xA5F3
les di,[bx]
lea sp,[di + bp + 0x2]
dec di
mov bp,si
xor si,si


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
db 0x75
call far [bx]
@loop_end:

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
