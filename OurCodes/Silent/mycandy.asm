%define JUMP_DIST 0x600
%define LOOP_AMOUNT 0x10

%define BOMBING_INTERVAL 0x6a6c

%define COPY_LOOP ((@escape - @check_loop)/0x2)
%define COPY_ANTI ((@anti_loop_end - @anti_loop)/0x2)
%define COPY_RESET ((@reset_loop_end - @reset_loop)/0x2)

%define STOSW_OPCODE 0xA552 ; PUSH DX; MOVSW
%define MOVSW_OPCODE_1 0x29A5 ;; MOVSW ; SUB SP,DX
%define MOVSW_OPCODE_2 0xABD4 ;; SUB SP,DX ; STOSW

%define BOTTOM_TRAP_DIST ((11 * 4 + 2) + (LOOP_AMOUNT * 0x5 * 0x4) + (13 * 4))

;;;;;;;;;;;;;;;;

push ss
pop es

mov si,ax
add si,@copy
mov cl,COPY_LOOP
movsb
rep movsw

add di,LOOP_AMOUNT*0x4
mov sp,di
mov bx,MOVSW_OPCODE_1
mov ax,MOVSW_OPCODE_2
mov cl,LOOP_AMOUNT

@copy_loop:
push ax
push bx
loop @copy_loop


mov cl,(@copy_end - @normal_loop_end)/0x2
movsb
rep movsw

mov ax,STOSW_OPCODE
lea bp,[si+JUMP_DIST]
lea bx,[bp+JUMP_DIST]

mov cl,COPY_LOOP
mov dx,BOMBING_INTERVAL

mov sp,0x800

push ss
pop ds

push cs
pop es

push cs
pop ss

lea sp,[bp-0x8]
mov si,(@normal_loop_end-@normal_loop - 0x1)
mov di,bp
mov [bp+BOTTOM_TRAP_DIST],dx
movsb
jmp bp

;;;;;;;;;;;;;;;;;

@copy:
@normal_loop:
mov cl,COPY_LOOP
movsw
movsw
movsw
mov di,bp
movsb
jmp bp
stosw
@normal_loop_end:
movsb
rep movsw
@check_loop:
cmp [bp + BOTTOM_TRAP_DIST],dx
jnz @traps
xor si,si
@traps:
movsw
movsw

@escape:
movsw
mov di,bx
movsw
jmp bx

@check_loop_end:
movsw
movsw
mov cl,COPY_ANTI
rep movsw
@anti_loop:
xchg si,ax
mov cx,0x504
lea sp,[bp + BOTTOM_TRAP_DIST]
@actual_anti_loop:
sub sp,0x3
pop si
pop bp
shl bp,cl
mov [bp+si-0x2],sp
dec ch
jnz @actual_anti_loop
xchg ax,si
movsw
@anti_loop_end:

movsw
movsw
mov cl,COPY_RESET
rep movsw
@reset_loop:
mov ax,STOSW_OPCODE
mov cl,COPY_LOOP
mov bp,bx
lea sp,[bp-0x8]
add bx,[si]
mov si,(@normal_loop_end-@normal_loop - 0x1)
mov [bp+BOTTOM_TRAP_DIST],dx
mov di,bp
movsb
jmp bp
@reset_loop_end:
dw JUMP_DIST
@copy_end: