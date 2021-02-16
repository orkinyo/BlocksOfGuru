%define JUMP_DIST 0xF900
%define CALL_AMOUNT 0x55
%define GAP 0x19
%define CALL_DIST (CALL_AMOUNT * (GAP - 0x4) - 0x4)
%define MAGIC_SEG 0xFFA

%define SHARE_LOC 0x8101

%define ZOMB_WRITE_DIST 0x6C
%define ROWS_GAP 0x3
%define ZOMB_JUMP_OPCODE (((@zomb_land - @zomb_jump - 0x2) * 0x100) + 0xEB)
%define ZOMB_COUNTER 0x80
%define BEAT3_LOC_1 0x2100
%define BEAT3_LOC_2 0x6100
%define BEAT3_LOC_3 0xA100
%define BEAT3_LOC_4 0xE100

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
pop es
mov cx,0x4

push cs

@write_seg:
mov dx,0xCCCC
dw 0xEA8B ; mov bp,dx
push cs
shl bp,cl

add bp,0x100

add word [bp + (@copy_end - @copy) - 0x2],JUMP_DIST - GAP - CALL_DIST
mov word [bp+0x2],dx
mov dx,INT_87_DX
push ss
mov word [bp + (@loop - @copy)],GAP

lea bx,[si + @zomb_start]
mov [si + @write_ah + 0x3],bh
mov [si + @write_al + 0x4],bl

push si

@write_ax:
mov ax,ROWS_GAP*0x100
add byte [si + @write_ax+0x2],ROWS_GAP
mov al,0xA7
xchg [bp],ax

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@zomb_jump:
@bomb_loop:
mov [di + BEAT3_LOC_1 + 0x100],bp
mov [di + BEAT3_LOC_2 + 0x100],bp
mov [di + BEAT3_LOC_3 + 0x100],bp
mov [di + BEAT3_LOC_4 + 0x100],bp
add di,0x200
loop @bomb_loop

xchg bx,[SHARE_LOC]
mov cl,0x4
cbw
cbw

@zomb_loop:
xchg ax,[di + BEAT3_LOC_1 - 0x700]
cmp ax,[di + BEAT3_LOC_2 - 0x700]
jnz @1_or_2

@3_or_4:
xchg ax,[di + BEAT3_LOC_3 - 0x700]
cmp ax,bp
jnz @found

@4:
xchg ax,[di + BEAT3_LOC_4 - 0x700]
jmp @found

@1_or_2:
cmp ax,bp
jnz @found

@2:
xchg ax,[di + BEAT3_LOC_2 - 0x700]

@found:
xlatb
xchg ah,al
xlatb
dw 0xE032 ; xor ah,al
xchg ax,si
@write_ah:
mov word [si + ZOMB_WRITE_DIST + 0x2],0xFFCC
@write_al:
mov word [si + ZOMB_WRITE_DIST],0xCCB9
add di,0x200
loop @zomb_loop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;
dw 0xDD8B ; mov bx,bp
dw 0xED33 ; xor bp,bp

jmp @skip_zomb_counter
;;;;;;;;;;;;;;;;;;;;;;;;
;

@zomb_land:
dw 0xDD8B ; mov bx,bp
mov bp,(0x8000 + ZOMB_COUNTER)
@skip_zomb_counter:
mov cl,(@copy_end - @copy)/0x2

pop si
add si,@copy
dw 0xFF33 ; xor di,di
rep movsw

pop ds
mov di,[0x0000]
pop es
mov ax,INT_87_AX
pop ss

int 0x86
dw 0xFF33 ; xor di,di
int 0x86

mov cl,(@loop_end - @loop)/0x2

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
cwd
cwd
cwd
cwd
cbw
cwd
cwd
cwd
cwd
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

