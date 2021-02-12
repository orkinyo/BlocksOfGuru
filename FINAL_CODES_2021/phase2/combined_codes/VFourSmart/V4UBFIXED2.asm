%define JUMP_DIST 0x5200
%define CALL_AMOUNT 0x84
%define CALL_DIST (CALL_AMOUNT * 0x4)
%define ADD_SP (JUMP_DIST + CALL_DIST)
%define SHARE_LOC 0x8AC6
%define ZOMB_WRITE_DIST 0x6C
%define INT_86_DX 0xD7C4
%define ROWS_GAP 0x3
%define AX_INT_86 0x86D7
%define NT_ZOMBS 0x2
%define ZOMB_JUMP_OPCODE (((@zomb_land - @zomb_jump - 0x2) * 0x100) + 0xEB)
%define ZOMB_COUNTER 0x200


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
add si,@copy

lea bx,[si-@copy+@zomb_start]
mov [si-@copy+@write_ah+0x3],bh
mov [si-@copy+@write_al+0x4],bl
mov [si-@copy+@add_xchg+0x2],bx
mov [si-@copy+@reset_xchg+0x2],bx

mov cl,(@copy_end - @copy)/0x2 - 0x1

push ss
pop es

@write_seg:
mov dx,0xCCCC
mov bp,dx
rcr bp,cl
add bp,CALL_DIST + 0x1
mov [bp + 0x2],dx

rep movsw
movsw

add byte [si - @copy_end + @write_ax + 0x2],ROWS_GAP
@write_ax:
mov ax,0x0000
mov al,0xA2

mov [bp],ax

push bp

;;;;;;;;;;;;
@zomb_jump:
dec di
mov bp,di
mov cl,0x4
xchg [SHARE_LOC],bx

@bomb_again:
mov [0x4501],cs
mov [0x4701],cs
mov [0x4401],ds
mov [0x4101],cs
mov [0x4201],cs
mov [0x4301],ds

@xchg:
xchg sp,[di - 0x1B + 0x8100]
xchg dx,[di - 0x1B + 0x8300]
xchg si,[di - 0x1B + 0x8500]
xchg ax,[di - 0x1B + 0x8700]

@zomb_loop:
xchg ax,ax
xlatb
xchg ah,al
xlatb
xor ah,al
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
mov cl,0x4

inc bp
mov di,bp

mov [0x4801],cs

jp @bomb_again

xor si,si
mov sp,0x7FE

jmp @skip_zomb_counter
;;;;;;;;;;;;

@zomb_land:
mov si,ZOMB_COUNTER

@skip_zomb_counter:
pop bx

push ss
pop ds

push cs
pop ss

mov dx,JUMP_DIST
les di,[bx]
dec di
lea sp,[bx+di]
mov cl,(@loop_end - @loop)/0x2
xor si,si
xor bp,bp
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
add [bx],dx
add di,[si]
lea sp,[di+bx]
mov cl,(@loop_end - @loop)/0x2
xor si,si
movsw
movsw
sub di,[bx+si]
dec bp
db 0x75
db 0xFF
db 0x1F
@loop_end:
dw (JUMP_DIST - (@loop_end - @loader) - 0x2)
@copy_end:
@db_1:
db 0x1
@who_am_i:
db NT_ZOMBS
@zomb_start:
call @get_ip
@get_ip:

pop si
lea ax,[si - @get_ip]
xor dx,dx

@wait:
xchg dl,[si - @get_ip + @db_1]
cmp dl,0x1
jnz @wait

xchg dl,[si - @get_ip + @db_1]

dec byte [si - @get_ip + @who_am_i]
jns @nt

mov word [si-@get_ip+@zomb_jump],ZOMB_JUMP_OPCODE


@nt:
push cs
pop ss

mov sp,ax
mov cl,0xD
mov dx,0xA593
mov ax,0xF1 - 0x4

@anti_loop:
pop si
pop bp
rcr bp,cl
mov [bp + si - 0x2],dx
add sp,ax
jmp @anti_loop




