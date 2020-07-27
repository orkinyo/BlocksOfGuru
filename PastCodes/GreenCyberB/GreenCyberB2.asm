%define copyallwords (@end_copy_rep - @copy_call)/2
%define switch_counter 0x80

;; Call Far defines
%define gofront_call 0x2E00
%define calldist 0x200
%define addsp gofront_call+calldist
%define copystart 0xB ;; 0xB = 11
%define copyloop copystart - 0x2 ;; 0x2 = times of movsw not in rep movsw
%define readcallfar 0x221 ;; random location in SS
%define magicseg 0xFFE
%define int87_ax 0xA5A5
%define int87_dx 0xA5A5
%define int86_dist 0x200
%define callfar_start 0x0
%define copy_len 0x0

;; Rep defines
%define gofront_rep 0x4E00
%define bomb_count 0x100
%define copy_code (@end_copy_rep - @copy_rep)/2
%define rep_movsw_op 0xA5F3

%define read_loc 0x9211

jmp @here

@here:
push word [read_loc]
push ss
pop es

xchg ax,bp
mov cl,copyallwords
lea si,[bp+@copy_call]
movsb
rep movsw

;; End part 1

xchg ax,bp
xor bp,bp

push cs
pop es

push ss
pop ds

mov word [readcallfar+0x2],magicseg

mov bp,switch_counter

push cs
pop ss

mov bx,gofront_rep + 0x4

pop ax
mov sp,ax 
add sp,bx

mov ax,bomb_count*2 - 0x2
mov si,@copy_rep - @copy_call - 0x2 + 0x100*2
mov di,sp

add di,ax
sub di,0x2

inc ch
std

mov dx, rep_movsw_op 

push ax
push dx
push dx
pop dx
jmp sp

@copy_call:
movsw
rep movsw				;; write our code

add word [bx],ax	;; change call far place (bx -= ax)

mov di,[bx]				;; di = call far address				

add word sp,dx		;; change sp adress relative to next call far address (sp -= dx)

mov cx,copyloop			;; reset counter for next time we execute "rep movsw" (cx = 0x00words)

dec bp
jz short 0x10

movsw					;; write call far in the next address (address = [bx] = di)

dec di					;; dx = [bx] + 0x1 (address of call far + 0x1)

xor si,si				;; reset si (si = 0x0000)

call far [bx]			;; execute call far

call far [bx]
@copy_call_end:

@chg_reg:
mov bx, readcallfar
mov ax,sp
mov al,0xA2
mov [bx],ax
les ax,[bx]
mov sp,ax
sub sp, ((0x1000-magicseg)*0x10)
mov dx,addsp
mov ax, gofront_call

cld
mov si,0x1
mov cl, copyloop
add di,@end_chg_reg-@chg_reg+0x2 + ((0x1000-magicseg)*0x10)
movsw

@end_chg_reg:

@copy_rep:
dec bp
jnz @rep
add di,@end_chg_reg-@chg_reg+@rep-@copy_rep
mov cl, (@end_chg_reg-@chg_reg)/2
rep movsw
@rep:
add sp,bx 
add di, gofront_rep + bomb_count*2
inc ch
add si,bomb_count*2
push ax
push dx
push dx
pop dx
jmp sp
@end_copy_rep:
@suicide: