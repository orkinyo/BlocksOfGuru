%define JUMP_DIST 0x5100
%define CALL_AMOUNT 0x55
%define GAP 0x19
%define CALL_DIST (CALL_AMOUNT * (GAP - 0x4) - 0x4)

%define SHARE_LOC 0xB879
%define SHARE_LOC_1 0x8701

%define ZOMB_WRITE_DIST 0x6C
%define ROWS_GAP 0x3
%define ZOMB_JUMP_OPCODE (((@zomb_land - @zomb_jump - 0x2) * 0x100) + 0xEB)
%define ZOMB_COUNTER 0x80

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

@add_bp:
dw 0x100

@ff6:
dw 0xFF6

@top_decoy:
nop
xlatb
xchg ah,al
xlatb
nop
xlatb
xchg ah,al
xlatb
nop
xlatb
xchg ah,al
xlatb
nop
xlatb
xchg ah,al
xlatb
nop
xlatb
xchg ah,al
xlatb
nop
xlatb
xchg ah,al
xlatb
nop
xlatb
xchg ah,al
xlatb
nop
xlatb
xchg ah,al
xlatb
nop
xlatb
xchg ah,al
xlatb
nop
xlatb
xchg ah,al
xlatb
nop
xlatb
xchg ah,al
xlatb
nop
xlatb
xchg ah,al
xlatb
nop
xlatb
xchg ah,al
xlatb
nop
xlatb
xchg ah,al
xlatb
mov [0xC801],al
mov [0xC501],al
mov [0xC701],al
mov [0xC401],al
mov [0xC101],al
mov [0xC201],al
mov [0xC301],al
mov [0x4501],al
mov [0x4701],al
mov [0x4401],al
mov [0x4101],al
mov [0x4201],al
mov [0x4301],al

db 0x10
movsw
movsw
movsw
db 0x83
db 0x10
movsw
movsw
movsw
db 0x83

@our_start:
dw 0xF08B ; mov si,ax
push ss
add si,@copy
pop es

mov cx,(@copy_end - @copy)/0x2 - 0x1
push cs

@write_seg:
div word [si - @copy + @div_offset]
add dx,[si - @copy + @ff6]
dw 0xEA8B ; mov bp,dx
push cs
clc
rcr bp,cl

rep movsw
add bp,0x100
movsw

pop es
push bp
@write_ax:
lea ax,[si - @copy_end + 0x7000 + (ROWS_GAP * 0x100)]
add byte [si-@copy_end+@write_ax+0x3],ROWS_GAP
mov al,0xA7

add word [bp + di - 0x2],JUMP_DIST - GAP - CALL_DIST
mov word [bp+0x2],dx
push ss
mov word [bp + (@loop - @copy)],GAP

xchg [bp],ax

;
@zomb_jump:
lea bx,[si-@copy_end+@zomb_start]
mov [si-@copy_end+@write_ah+0x3],bh
mov [si-@copy_end+@write_al+0x4],bl
add si,@start-@copy_end
mov [si-@start+@add_xchg+0x2],si
mov [si-@start+@reset_xchg+0x2],si
dec di
dw 0xEF8B ; mov bp,di
mov cl,0x4
xchg bx,[SHARE_LOC_1]
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
dw 0xE032 ; xor ah,al
xchg di,ax
@write_ah:
mov word [di + ZOMB_WRITE_DIST + 0x2],0xFFCC
@write_al:
mov word [di + ZOMB_WRITE_DIST],0xCCB9
@add_xchg:
add byte [0xCCCC],0x2
loop @start
@reset_xchg:
mov byte [0xCCCC],0x90

inc bp
mov cl,0x4
dw 0xFD8B ; mov di,bp

jnp @bomb_sec

dw 0xF633 ; xor si,si
mov sp,0x7FA

jmp @skip_zomb_counter
;

@zomb_land:
mov si,(0x8000 + ZOMB_COUNTER)
@skip_zomb_counter:
mov di,[0x0000]
int 0x86
mov cl,(@loop_end - @loop)/0x2
pop ds
dw 0xFF33 ; xor di,di
pop bx
int 0x86

mov dx,INT_87_DX

pop ss

mov ax,INT_87_AX
dw 0xEE8B ; mov bp,si

int 0x87

dw 0xF633 ; xor si,si
les di,[bx+si]
mov ax,0xA5F3
lea sp,[di + bx + 0x2 - CALL_DIST - 0x100]
dec di
mov dx,JUMP_DIST

movsw
movsw
movsw
add di,(-0x2)

call far [bx]


@copy:
@call_far:
db 0x69
add sp,[bx+si]
call far [bx]
db 0x65

@loop:
mov cl,(@loop_end - @loop)/0x2
add di,[si]
add sp,[bx+si]
dw 0xF633 ; xor si,si
add [bx+si],dx
movsw
movsw
movsw
add di,(-0x2)
dec bp
db 0x78
call far [bx]
@loop_end:
dw (JUMP_DIST - (@loop_end - @loop) - 0x2 - 0x4)

@copy_end:


@db_1:
db 0x1
@zomb_start:
dw 0xF18B ; mov si,cx

dw 0xD233 ; xor dx,dx
@wait:
xchg dl,[si-@zomb_start+@db_1]
cmp dl,0x1
jnz @wait

xchg [si-@zomb_start+@db_1],dl

lea ax,[si-@zomb_start]
mov word[si-@zomb_start+@zomb_jump],ZOMB_JUMP_OPCODE


jmp @our_start

@bottom_decoy:
nop
xlatb
xchg ah,al
xlatb
nop
xlatb
xchg ah,al
xlatb
nop
xlatb
xchg ah,al
xlatb
nop
xlatb
xchg ah,al
xlatb
nop
xlatb
xchg ah,al
xlatb
nop
xlatb
xchg ah,al
xlatb
nop
xlatb
xchg ah,al
xlatb
nop
xlatb
xchg ah,al
xlatb
nop
xlatb
xchg ah,al
xlatb
nop
xlatb
xchg ah,al
xlatb
nop
xlatb
xchg ah,al
xlatb
xlatb
xchg ah,al
xlatb
xlatb
xchg ah,al
xlatb
xlatb
xchg ah,al
xlatb
mov [0xC801],al
mov [0xC501],al
mov [0xC701],al
mov [0xC401],al
mov [0xC101],al
mov [0xC201],al
mov [0xC301],al
db 0x10
movsw
movsw
movsw
db 0x83
db 0x10
movsw
movsw
movsw
db 0x83

