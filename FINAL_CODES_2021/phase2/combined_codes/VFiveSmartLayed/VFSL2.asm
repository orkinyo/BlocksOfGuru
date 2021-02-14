; AX = GARBAGE
; BX = ARRAY
; CX = CHANGE XCHG ORDER (0x702) / CALL DI OPCODE
; DX = GARBAGE
; SI = GARBAGE
; DI = LOCATION FOR TAKING ZOMBIES
; BP = LOCATION FOR BOMBING / GARBAGE
; SP = INIT BP
; ES = ZOMBIE JUMP LOCATION
; SS = ARENA
; DS = ARENA
; CS = ARENA

;; GENRAL DEFINES
%define SHARE_LOC 0x9EC4
;;
;; ZOMBIE DEFINES
%define CALL_DI_OPCODE 0x95FF

%define SHL_WRITE_DIST 0x70
%define SHL_CALL_ADDRESS 0xF8E2

%define LOOP_WRITE_DIST 0x72
%define LOOP_CALL_ADDRESS 0x8346

%define INIT_DI 0x7F91
%define INIT_BP 0xC7AF
%define DELTA_BP (0xC100 - INIT_BP)
;;
%define JUMP_DIST 0xF900
%define CALL_AMOUNT 0x55
%define GAP 0x19
%define CALL_DIST (CALL_AMOUNT * (GAP - 0x4) - 0x4)
%define MAGIC_SEG 0xFFA

%define SHARE_LOC 0x8101

;;;;;;;
%define COPY 0x54
%define SURV1_RET_HERE 0x23
%define COPY_END 0x6E
%define ZOMB_START 0x16E
%define CF_LOOP_END 0x6E
%define CF_LOOP 0x5A
%define RET_HERE 0x16
;;;;;;;;;

@start:
mov si,ax
add si,@come_here
xchg [SHARE_LOC],si
lea cx,[si-COPY+SURV1_RET_HERE]
push cx
add ax,@come_here
mov bp, INIT_BP
mov bx,INIT_DI
@come_here:

push ss
pop es

div word [si - 0x2]
add dx,0xFF6

xchg cx,bx
mov [bx-SURV1_RET_HERE+RET_HERE+0x3],dx
xchg cx,bx

mov cx,(COPY_END - COPY)/0x2
rep movsw

lea ax,[si + JUMP_DIST - COPY_END]
mov al,0xA7


add ch,0x1
xchg cx,bp
mov [bp],ax
mov word [bp+0x2],dx

mov word [bp+di-0x100],(JUMP_DIST - (CF_LOOP_END - CF_LOOP) - 0x2 - 0x4)
add word [bp+di],JUMP_DIST - GAP - CALL_DIST
mov word [bp + (CF_LOOP - COPY)],GAP

push bp
;bp/cx -> bp 0x4000 ,0xc000
;bx -> di 0x8100, 0x8200
@init_loop:
mov bp,cx

mov di,bx
mov bx,si
add si,-COPY_END+ZOMB_START
mov es,si

mov cx,ss
push cs
pop ss
mov sp,bp

@zombie_loop:
mov [bp + DELTA_BP + 0x500],ds
mov [bp + DELTA_BP + 0x700],ds
mov [bp + DELTA_BP + 0x400],ds
mov [bp + DELTA_BP + 0x600],ds
mov [bp + DELTA_BP + 0x300],ds
mov [bp + DELTA_BP],ds
mov [bp + DELTA_BP + 0x100],ds
mov [bp + DELTA_BP + 0x200],ds

@xchg1:
xchg dx,[di + 0x26F]
@xchg2:
xchg bp,[di + 0x46F]
@xchg3:
xchg si,[di + 0x66F]
@xchg4:
xchg ax,[di + 0x86F]

xlatb
xchg al,ah
xlatb
xor ah,al
xchg si,ax
mov word [si + SHL_WRITE_DIST],CALL_DI_OPCODE
mov [SHL_CALL_ADDRESS],es


xlatb
xchg al,ah
xlatb
xor ah,al
xchg bp,ax
mov word [bp + LOOP_WRITE_DIST],CALL_DI_OPCODE
mov [LOOP_CALL_ADDRESS],es

xlatb
xchg al,ah
xlatb
xor ah,al
mov si,ax
mov word [si + SHL_WRITE_DIST],CALL_DI_OPCODE
mov [SHL_CALL_ADDRESS],es


xchg ax,dx
xlatb
xchg al,ah
xlatb
xor ah,al
mov si,ax
mov word [si + LOOP_WRITE_DIST],CALL_DI_OPCODE
mov [LOOP_CALL_ADDRESS],es

inc di
mov [SHL_CALL_ADDRESS],di
mov [LOOP_CALL_ADDRESS],di
jp @exit

mov bp,sp

nop
nop
nop
nop
nop
nop
nop
nop
nop

jmp @zombie_loop

@exit:

mov ss,cx

mov sp,0x7FC
xor ax,ax
pop bp
pop si
jmp si
