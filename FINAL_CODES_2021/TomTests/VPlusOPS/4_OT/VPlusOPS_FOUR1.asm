;; GENRAL DEFINES
%define SHARE_LOC 0x9EC4
%define CF_INIT_DI 0x7E90
%define NT_INIT_DI (CF_INIT_DI + 0x100)
%define CF_INIT_BP 0xC7AF
%define NT_INIT_BP (0xC7AF - 0x8000)
%define DELTA_WRITE_LOC_TO_ZOMB 0x109
%define ROWS_GAP 0x0
;;
;; CALL FAR DEFINES
%define CF_JUMP_DIST 0x4B00
%define CALL_AMOUNT 0x84
%define CALL_DIST (0x4 * CALL_AMOUNT)
;;
;; NTT+ DEFINES
%define INTERVAL 0xF1
%define TRUE_INTERVAL (INTERVAL - 0x4)
%define NT_JUMP_DIST 0x4000
%define TOP_TRAP_DIST 0x12
%define BOTTOM_TRAP_DIST 0x3B
%define TRAP_VAL TRUE_INTERVAL
%define INIT_SI (0x2 + TOP_TRAP_DIST + (@main_loop_end - @main_loop) + BOTTOM_TRAP_DIST)
%define BOMB_VAL 0xA593
%define DIST_CALC (0xA2 + 0x4*0x4 -((@main_loop_end - @nt_copy) + BOTTOM_TRAP_DIST))
%define SAFETY_GAP 0x10
%define DX_OFFSET 0x2
%define CL_PART1 0xE
%define CL_PART2 ((@nt_copy_end - @nt_copy)/0x2 - CL_PART1)
%define DI_PART1 (INIT_SI + (@nt_copy_end - @nt_copy) - CL_PART1*0x2)
;;
;; ZOMBIE DEFINES
%define CALL_DI_OPCODE 0x95FF
%define SHL_WRITE_DIST 0x70
%define SHL_CALL_ADDRESS 0xF8E2
%define LOOP_WRITE_DIST 0x72
%define LOOP_CALL_ADDRESS 0x8346
%define DELTA_BP (0xC100 - INIT_BP)
%define ARRAY 0xC7
%define INIT_LOOP 0xA
%define ZOMB_COUNTER 0x480
;;


mov si,ax
add si,@nt_start
mov [SHARE_LOC],si

add si,(@cf_copy - @nt_start)
mov cl,0xF
div cx
add dx,0xFF6

mov bp,dx
mov cl,(@cf_copy_end - @cf_copy)/0x2
rcr bp,cl

push ss
pop es

;mov ax,es
;mov ss,ax
;mov sp,0x3FC

mov [SHARE_LOC],bp

rep movsw

lea di,[si - @cf_copy_end + @zombie_start - NT_INIT_BP - 0x3]

; mov ds,ax
mov [si - @cf_copy_end + @get_es],di

lea cx,[si + CF_JUMP_DIST]
mov cl,0xA2

add bp,(CALL_DIST + 0x1)
mov [bp],cx
mov [bp + 0x2],dx

push cs
push bp
push cs

;lea si,[bp + CALL_DIST + 0x1]

;mov [si],cx
;mov [si+0x2],dx

; xchg [0x3FC],si


@cf_zomb_prep:
@write_si:
mov si,0xCCCC
mov bp,CF_INIT_BP


lea bx,[si + ARRAY - INIT_LOOP]
mov di,CF_INIT_DI

mov [bx - 0x4],ss

call si
@cf_ret:
mov ds,ax

pop es
pop bx
pop ss

mov ax,bx
mov dx,CF_JUMP_DIST
mov cx,(@cf_loop_end - @cf_loop)/0x2
xor si,si
les di,[bx]
dec di

lea sp,[di+bx]

movsw
movsw

mov byte [bx+si],0x2
sub di,[bx+si]

call far [bx]


@cf_copy:
@call_far:
db 0x66
call far [bx]
db 0x68

@cf_loader:
movsb
movsw
rep movsw
@cf_loop:
add [bx],dx
add di,[si]
lea sp,[di+bx]
@change_cl:
mov cl,(@cf_loop_end - @cf_loop)/0x2
xor si,si
movsw
movsw
sub di,[bx+si]
@cf_change:
call far [bx]
@cf_loop_end:
dw (CF_JUMP_DIST - (@cf_loop_end - @cf_loader) - 0x2)
@cf_copy_end:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@get_es:
dw 0xCCCC
@nt_start:
mov [si - @nt_start + @write_si + 0x1],ax
lea ax,[si + (@nt_copy - @nt_start) + DI_PART1 - INIT_SI]
mov si,ss
mov bx,ss
and bx,0x10

lea si,[bx+si+0x4]
xchg ax,si
mov es,ax

xchg bp,[SHARE_LOC]
mov di,DI_PART1

mov cl,CL_PART1
rep movsw

mov es,[si - @nt_copy_end + @get_es]

lea bx,[si - @nt_copy_end + NT_JUMP_DIST]
pop si


@nt_zomb_prep:
push ax
push bx
mov bl,((DIST_CALC - SAFETY_GAP)%(0x100)) + DX_OFFSET - 0x10
add bx,bp

push bx

lea bx,[si + ARRAY - INIT_LOOP]
mov di,NT_INIT_DI
mov bp,NT_INIT_BP
mov [bx - 0x2],ss

call si
@nt_ret:
pop dx
pop si

pop es

push cs
pop ss

add si,(@nt_copy - NT_JUMP_DIST)
mov di,INIT_SI

mov cx,CL_PART2
rep movsw

mov bx,dx
add bx,(@main_loop - @nt_copy - TOP_TRAP_DIST - 0x2)

push es
pop ds

mov si,(INIT_SI + @reset_main_loop - @nt_copy - 0x2)
mov [@main_loop_end - @nt_copy + INIT_SI + 0x8],es

push cs
pop es

mov ax,BOMB_VAL

lea di,[bx + 0x2 + TOP_TRAP_DIST - (@reset_main_loop_end - @reset_main_loop) - 0x2]
lea sp,[bx + INIT_SI + 0x2]

mov bp,di
mov cl,((@main_loop_end - @reset_main_loop)/0x2)

movsw
jmp bp

@nt_copy:
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
add dh,(NT_JUMP_DIST/0x100)
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
@nt_copy_end:
db 0x1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@zombie_start:
mov [SHL_CALL_ADDRESS],di
mov [LOOP_CALL_ADDRESS],di
call @get_ip
@get_ip:
pop si
add si,(@nt_copy_end - @get_ip)
lea ax,[si - @nt_copy_end]
xor dx,dx

@wait:
xchg [si],dl
cmp dl,0x1
jnz @wait

xchg [si],dl
;;

mov cl,0xF
div cx
add dx,0xFF6

mov bp,dx
mov cl,0x4
shl bp,cl

add si,(@cf_copy - @nt_copy_end)

push ss
pop es

mov cl,(@cf_change - @cf_copy)/0x2

@change_zomb_gap:
lea ax,[si + CF_JUMP_DIST + 0x300 + ROWS_GAP*0x100]
add byte [si - @cf_copy + @change_zomb_gap + 0x3],(ROWS_GAP + 0x3)
mov al,0xA2

rep movsw

push ax

mov ax,0x754D
stosw
movsw
movsw

push ss
pop ds

sub word [di-0x2],0x2
inc byte [di - @cf_copy_end - 0x2 + @change_cl + 0x1]

push cs
pop es

lea bx,[bp + CALL_DIST + 0x1]

pop ax

push cs
pop ss

mov [bx],ax
mov [bx+0x2],dx

mov ax,bx
mov dx,CF_JUMP_DIST
mov cl,((@cf_loop_end - @cf_loop)/0x2 + 0x1)
xor si,si
les di,[bx]
dec di
lea sp,[di+bx]
mov bp,ZOMB_COUNTER

movsw
movsw

mov byte [bx+si],0x2
sub di,[bx+si]

call far [bx]
@end: