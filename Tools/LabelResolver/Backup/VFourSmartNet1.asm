%define JUMP_DIST 0x5200
%define CALL_AMOUNT 0x84
%define CALL_DIST (CALL_AMOUNT * 0x4)
%define ADD_SP (JUMP_DIST + CALL_DIST)
%define ZOMB_WRITE_DIST 0x6C
%define INT_86_DX 0xD7C4
%define ROWS_GAP (-0x1)
%define AX_INT_86 0x86D7
%define NT_ZOMBS 0x2
%define ZOMB_JUMP_OPCODE (((@zomb_land - @zomb_jump - 0x2) * 0x100) + 0xEB)
%define ZOMB_COUNTER 0x200

%define CALL_DI_SHL_BYTE 0xFFE2
%define CALL_DI_SHL_WORD 0xF8E2
%define CALL_DI_LOOP_BYTE 0x46
%define CALL_DI_LOOP_WORD 0x8346
%define BEAT3_LOC_1 0x2100
%define BEAT3_LOC_2 0x6100
%define BEAT3_LOC_3 0xA100
%define BEAT3_LOC_4 0xE100

%define INT_87_AX 0x86D7
%define INT_87_DX 0xD7C4

%define SHARE_LOC 0x8AC6
%define SHARE_LOC_1 0x8701

mov [SHARE_LOC],ax
jmp @our_start

@div_offset:
db 0xE
db 0x0

@ax_les_offset:
dw AX_INT_86
dw 0x1000

@top_decoy:
cwd
cbw
cwd
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

add di,[si]
add [bx],dx
add di,[si]
add [bx],dx
add di,[si]
add [bx],dx

@our_start:
dw 0xF08B ; mov si,ax

lea bx,[si+@zomb_start]
mov [si+@write_ah+0x3],bh
mov [si+@write_al+0x4],bl

@zomb_actual_start:
push ss
mov cl,0x4


@write_seg:
;add word dx,0x0001
dd 0x0001C281
dw 0xEA03 ; add bp,dx
shl bp,cl
add bp,CALL_DIST + 0x1
mov [bp + 0x2],dx

push cs
mov ax,INT_87_AX
pop es
mov dx,INT_87_DX
int 0x87

mov di,[CALL_DI_SHL_WORD]
int 0x86
mov di,[CALL_DI_LOOP_WORD]
int 0x86

add byte [si + @write_ax + 0x2],(ROWS_GAP+0x3)
@write_ax:
mov ax,0x00A2

xchg [bp],ax

@zomb_jump:
xor di,di

@bomb_loop:
mov [di + BEAT3_LOC_1 + 0x100],bp
mov [di + BEAT3_LOC_2 + 0x100],bp
mov [di + BEAT3_LOC_3 + 0x100],bp
mov [di + BEAT3_LOC_4 + 0x100],bp
add di,0x200
loop @bomb_loop

xchg [SHARE_LOC_1],bx
mov cl,0x4
push si

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
xor ah,al
xchg ax,si
@write_ah:
mov word [si + ZOMB_WRITE_DIST + 0x2],0xFFCC
@write_al:
mov word [si + ZOMB_WRITE_DIST],0xCCB9
add di,0x200
loop @zomb_loop

mov bx,bp
xor bp,bp
pop si
jmp @skip_zomb_counter
;;;;;;;;;;;;

@zomb_land:
mov bx,bp
mov bp,0x8000 + ZOMB_COUNTER
@skip_zomb_counter:
add si,@copy
pop es

xor di,di
mov cl,(@copy_end - @copy)/0x2
rep movsw

push ss

mov dx,JUMP_DIST
pop ds

dw 0xC38B ; mov ax,bx

push cs

les di,[bx]
pop ss

dec di
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
@seg_diff:
db 0x1
@zomb_start:
xchg si,cx

lea ax,[si - @zomb_start]
dw 0xD233 ; xor dx,dx

@wait:
xchg dl,[si - @zomb_start + @db_1]
cmp dl,0x1
jnz @wait

xchg dl,[si - @zomb_start + @db_1]

mov dl,[si - @zomb_start + @seg_diff]
inc byte [si - @zomb_start + @seg_diff]
add dx,[si - @zomb_start + @write_seg + 0x2]

cmp dx,0x1005
jb @skip_seg_change

sub dx,0xF

@skip_seg_change:
sub dx,[si - @zomb_start + @write_seg + 0x2]

mov word [si - @zomb_start + @zomb_jump],ZOMB_JUMP_OPCODE
add si,(-@zomb_start)


jmp @zomb_actual_start

@bottom_decoy:
add di,[si]
add [bx],dx
add di,[si]
add [bx],dx

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