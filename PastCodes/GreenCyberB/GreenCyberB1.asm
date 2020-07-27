




%define copyallwords (@end_copy_rep - @copy_call)/2

%define switch_counter 0x80

%define copyallwords1 0x18
%define copyallwords2 0x12 ;; 1+2 = copyallwords

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
%define zomb_lives 0x0220

%define start_adr 0x2102
%define crap_val_1 0xADD2
%define crap_val_2 0x9998
%define good_val_1 0x0000
%define good_val_2 0xCE91
%define zombjump 0xDFE7
%define callop 0xE8

jmp @player
@only_zomb:
call @get_adr
@get_adr:
pop ax
sub ax, 0x5
mov bx,ax
add bx,@check_one_for_zomb
@in_loop:
dec byte[bx]
jz @out_of_loop
jmp @in_loop
@out_of_loop:
mov byte [bx],0x1
jmp @player

;;;;;;;;;;;;;;;;;;dec
@delta_for_zomb:
dw 0x0000
@check_one_for_zomb:
db 0x01

;;;;;;;;;;;;;;;;;;

@player:
mov [read_loc], ax
push ss

;;;;;;;;;;;;;; 

push cs
pop es

mov bp, crap_val_2
xchg ax,bp
mov dx, crap_val_1
mov di, start_adr
int 0x86 ;; op 10
;;;;;;;;;;;;;;

mov cx,copyallwords1
lea si,[bp+@copy_call]

mov bx,bp

;;;;
mov dx, good_val_1
mov ax, good_val_2

mov di,start_adr
int 0x86 ;; move 17
;;;;

xor di,di

;;;;;;;;; int 87

mov ax,int87_ax
mov dx,int87_dx
int 0x87

;;;;;;;;; int 87


pop es

mov ax,bp
movsb
rep movsw

;; write to zomb 

sub bp, zombjump+0x1
mov byte [zombjump],callop
mov [zombjump+1], bp

;;

mov cl, copyallwords2
rep movsw

;; End part 1

mov word [bx+@for_zomb+1],zomb_lives

push cs
pop es

push ss
pop ds

mov word [readcallfar+0x2],magicseg

mov bp,switch_counter

push cs
pop ss



mov bx,gofront_rep + 0x4
mov sp,ax 
add sp,bx

xchg ax,bp

add sp, [bp+@delta_for_zomb]
add word[bp+@delta_for_zomb],gofront_rep

xchg ax,bp


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

call far [bx+si]			;; execute call far

call far [bx+si]
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
@for_zomb:
xor bp,bp
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