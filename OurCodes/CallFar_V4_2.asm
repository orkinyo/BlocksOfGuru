
;; Code defines
%define gofront 0x2E00
%define calldist 0x200
%define addsp gofront+calldist
%define copystart 0xB ;; 0xB = 11
%define copyloop copystart - 0x2 ;; 0x2 = times of movsw not in rep movsw
%define readcallfar 0x0111 ;; random location in SS
%define magicseg 0xFFE
%define int87_ax 0xA5A5
%define int87_dx 0xA5A5
%define int86_dist 0x200

nop						;; 3 extra command
nop
nop

push cs
pop es					;; es = cs = arena

xchg ax,bp
lea di,[bp+@end+int86_dist]

int 0x86
int 0x86

mov ax,int87_ax
mov dx,int87_dx

xor di,di

int 0x87

lea si,[bp+@copy]		;; si = @copy
mov cl,copystart 		;; cx = wordsstart
push ss 				;; push ss value to stack
pop es					;; es = ss
rep movsw 				;; copy code to ES (where SS is)

xchg ax,bp				;; ax = adr
xor bp,bp				;; bp = 0x0


push ss					;; push ss value to stack
pop ds					;; ds = ss

add ax,gofront
mov al,0xA3				;; ax = closest location ending in 0xA3

mov bx,readcallfar		;; bx = location of where we read call far address
mov [bx],ax 			;; [bx] = address of call far
mov word [bx+0x2],magicseg 	;; [bx+0x2] segment of call far

les di,[bx]				;; di = ax, es = magicseg

push cs				 	;; put value of cs in stack
pop ds					;; ds = cs

mov ax,gofront

mov cl,copyloop 		;; cx = 0x00words

movsw					;; write call far to the address

dec di					;; dx = address + 0x1
xor si,si 				;; si = 0x0000

push ss					;; push ss value to stack
pop ds					;; ds = ss

push cs					;; push cs value to stack
pop ss					;; ss = cs

mov dx,addsp			;; dx = addsp

mov sp,[bx]				;; sp = ax = call far address
add sp,calldist			;; sp = ax + calldist

call far [bx]			;; execute call far

;;;;;;;;;;;;;;;;;;;;;;;;;; END OF REGULAR CODE

@copy:
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
@copy_end:

call far [bx]			;; will be copied to the call far address

@end: