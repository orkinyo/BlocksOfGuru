%define JUMP_DIST 0x5200
%define CALL_AMOUNT 0x84
%define CALL_DIST (CALL_AMOUNT * 0x4)
%define ADD_SP (JUMP_DIST + CALL_DIST)
%define ZOMB_WRITE_DIST 0x6C
%define INT_86_DX 0xD7C4
%define ROWS_GAP 0x3
%define AX_INT_86 0x86D7
%define NT_ZOMBS 0x2
%define ZOMB_JUMP_OPCODE (((@zomb_land - @zomb_jump - 0x2) * 0x100) + 0xEB)
%define ZOMB_COUNTER 0x200

%define CALL_DI_SHL_BYTE 0xFFE2
%define CALL_DI_SHL_WORD 0xF8E2
%define CALL_DI_LOOP_BYTE 0x46
%define CALL_DI_LOOP_WORD 0x8346

%define INT_87_AX 0x86D7
%define INT_87_DX 0xD7C4

%define SHARE_LOC 0x8AC6
%define SHARE_LOC_1 0x8701

mov [SHARE_LOC],ax
jmp @our_start

@div_offset:
db 0xF
db 0x0

@ax_les_offset:
dw AX_INT_86
dw 0x1000

@top_decoy:
cwd
sub di,[bx+si]
call far [bx]
sub di,[bx+si]
call far [bx]
sub di,[bx+si]
call far [bx]
sub di,[bx+si]
call far [bx]
sub di,[bx+si]
call far [bx]

movsb
movsw
rep movsw
movsb
movsw
rep movsw
movsb
movsw
rep movsw
movsb
movsw
rep movsw
movsb
movsw
rep movsw

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
xlatb
xchg ah,al
xlatb
xlatb
xchg ah,al
xlatb
xlatb
xchg ah,al
xlatb

@our_start:
dw 0xF08B ; mov si,ax
add si,@copy

lea bx,[si-@copy+@zomb_start]
mov [si-@copy+@write_ah+0x3],bh
mov [si-@copy+@write_al+0x4],bl
add bx,@zomb_loop-@zomb_start
mov [si-@copy+@add_xchg+0x2],bx
mov [si-@copy+@reset_xchg+0x2],bx

@zomb_actual_start:
push ss
mov cx,(@copy_end - @copy)/0x2 - 0x1

pop es

@write_seg:
mov dx,0xCCCC
dw 0xEA8B ; mov bp,dx
rcr bp,cl
add bp,CALL_DIST + 0x1
mov [bp + 0x2],dx

rep movsw
movsw

add byte [si - @copy_end + @write_ax + 0x2],(ROWS_GAP+0x3)
@write_ax:
mov ax,0x0000
mov al,0xA2

xchg [bp],ax

push bp

push cs
mov ax,INT_87_AX
pop es
mov dx,INT_87_DX
mov cl,0x4
int 0x87

mov di,[CALL_DI_SHL_WORD]
int 0x86
mov di,[CALL_DI_LOOP_WORD]
int 0x86
;;;;;;;;;;;;
@zomb_jump:
mov di,0x8201
dw 0xEF8B ; mov bp,di

xchg [SHARE_LOC_1],bx

@bomb_again:
mov [0xC501],al
mov [0xC701],al
mov [0xC401],al

mov [0xC101],al
mov [0xC201],al
mov [0xC301],al

@xchg:
xchg sp,[di - 0x1]
xchg dx,[di - 0x1 + 0x200]
xchg si,[di - 0x1 + 0x400]
xchg ax,[di - 0x1 + 0x600]

@zomb_loop:
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
loop @zomb_loop

@reset_xchg:
mov byte [0xCCCC],0x90


inc bp
mov cl,0x4
dw 0xFD8B ; mov di,bp

mov sp,0x7FE

jnp @bomb_again

dw 0xF633 ; xor si,si

jmp @skip_zomb_counter
;;;;;;;;;;;;

@zomb_land:
mov si,0x8000 + ZOMB_COUNTER

@skip_zomb_counter:
pop bx

push ss

mov dx,JUMP_DIST
pop ds

dw 0xC38B ; mov ax,bx

push cs

les di,[bx]
pop ss

dec di
dw 0xEE8B ; mov bp,si
lea sp,[bx+di]

mov cl,(@loop_end - @loop)/0x2

dw 0xF633 ; xor si,si
movsw
movsw

mov byte [bx+si],0x2
sub di,[bx+si]

call far [bx]

@copy:
db 0x69
call far [bx]
db 0x69

@loader:
movsb
movsw
rep movsw

@loop:
mov cl,(@loop_end - @loop)/0x2
add di,[si]
add [bx],dx
lea sp,[di+bx]
dw 0xF633 ; xor si,si
movsw
movsw
sub di,[bx+si]
dec bp
db 0x78
db 0xFF
db 0x1F
@loop_end:
dw (JUMP_DIST - (@loop_end - @loader) - 0x2)
@copy_end:
@db_1:
db 0x1
@who_am_i:
db 0xFF

@zomb_start:
call @get_ip
@get_ip:

pop si
lea ax,[si - @get_ip]
dw 0xD233 ; xor dx,dx

@wait:
xchg dl,[si - @get_ip + @db_1]
cmp dl,0x1
jnz @wait

xchg dl,[si - @get_ip + @db_1]

inc byte [si - @get_ip + @who_am_i]
jz @nt
cmp byte [si - @get_ip + @who_am_i],0x2
jz @nt

mov word [si-@get_ip+@zomb_jump],ZOMB_JUMP_OPCODE
add si,(@copy - @get_ip)

jmp @zomb_actual_start

@nt:
push cs
pop ss
dw 0xE08B ; mov sp,ax

mov cl,0xD

mov dx,0xA593
mov ax,0xF1 - 0x4

@anti_loop:
pop si
pop bp
rcr bp,cl
mov [bp + si - 0x2],dx
dw 0xE003 ; add sp,ax
jmp @anti_loop

@bottom_decoy:
sub di,[bx+si]
call far [bx]
sub di,[bx+si]
call far [bx]
sub di,[bx+si]
call far [bx]
sub di,[bx+si]
call far [bx]
sub di,[bx+si]
call far [bx]

movsb
movsw
rep movsw
movsb
movsw
rep movsw
movsb
movsw
rep movsw
movsb
movsw
rep movsw
movsb
movsw
rep movsw

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
xlatb
xchg ah,al
xlatb
xlatb
xchg ah,al
xlatb
xlatb
xchg ah,al
xlatb
