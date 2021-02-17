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
db 0xF
db 0x0

@ax_les_offset:
dw AX_INT_86
dw 0x1000

@jds:
db 0x27
db 0x4B
db 0x52
db 0x5E
db 0x64
db 0xD3
db 0xEE
db 0x52

@ff6:
dw 0xFF6

@top_decoy:
cwd
sub di,[bx+si]
call far [bx]
sub di,[bx+si]
call far [bx]
sub di,[bx+si]
call far [bx]

movsw
rep movsw
movsw
rep movsw
movsw
rep movsw
movsw
rep movsw
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
inc ax

lea bx,[si+@zomb_start]
mov [si+@write_ah+0x3],bh
mov [si+@write_al+0x4],bl

@zomb_actual_start:
push ss
mov cl,0x4

dw 0xDE8B ; mov bx,si
and bx,0x7
mov bl,[si + bx + @jds]
mov [si + @write_jd + 0x2],bl

div word [si + @div_offset]
@write_seg:
add dx,[si + @ff6]

dw 0xEA03 ; add bp,dx
shl bp,cl
add bp,CALL_DIST + 0x1
mov [bp + 0x2],dx

push cs
pop es

add byte [si + @write_ax + 0x3],(ROWS_GAP+0x3)
@write_ax:
lea ax,[si + 0x7000]
mov al,0xA2

xchg [bp],ax

@zomb_jump:
dw 0xFF33 ; xor di,di

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
dw 0xE032 ; xor ah,al
xchg ax,si
@write_ah:
mov word [si + ZOMB_WRITE_DIST + 0x2],0xFFCC
@write_al:
mov word [si + ZOMB_WRITE_DIST],0xCCB9
add di,0x200
loop @zomb_loop

dw 0xDD8B ; mov bx,bp
dw 0xED33 ; xor bp,bp
pop si
jmp @skip_zomb_counter
;;;;;;;;;;;;

@zomb_land:
dw 0xDD8B ; mov bx,bp
mov bp,0x8000 + ZOMB_COUNTER
@skip_zomb_counter:
mov ax,INT_87_AX
add si,@copy
mov dx,INT_87_DX
int 0x87

mov di,[CALL_DI_SHL_WORD]
int 0x86
mov di,[CALL_DI_LOOP_WORD]
int 0x86

pop es

dw 0xFF33 ; xor di,di
mov cl,(@copy_end - @copy)/0x2
push ss
rep movsw
movsb

@write_jd:
mov dx,JUMP_DIST
pop ds

mov ax,0xA4A5

push cs

add [di - 0x3],dh
add [di - 0x1],dh

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
db 0x63
call far [bx]
db 0x65

@loader:
movsw
rep movsw

@loop:
mov cl,(@loop_end - @loop)/0x2
add di,[si]
lea sp,[di+bx]
dw 0xF633 ; xor si,si
add [bx+si],dx
movsw
movsw
sub di,[bx+si]
dec bp
db 0x78
call far [bx]
@loop_end:
dw (-(@loop_end - @loader) - 0x2)
dw (-(@loop_end - @loader) - 0x2 - 0x4)
@copy_end:
@db_1:
db 0x1
@seg_diff:
dw 0x0002
@zomb_start:
xchg si,cx

lea ax,[si - @zomb_start]
dw 0xD233 ; xor dx,dx

@wait:
xchg dl,[si - @zomb_start + @db_1]
cmp dl,0x1
jnz @wait

xchg dl,[si - @zomb_start + @db_1]

add ax,[si - @zomb_start + @seg_diff]
inc byte [si - @zomb_start + @seg_diff]

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

movsw
rep movsw
movsw
rep movsw
movsw
rep movsw
movsw
rep movsw
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