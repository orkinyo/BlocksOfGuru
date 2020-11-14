%define gofor 0x800
%define calldist 0xB7 * (gap-0x4)
%define gap 0x1D
%define addsp gofor+calldist
%define copystart 0xD ;; 0xD = 13
%define copyloop copystart - 0x3 ;; 0x3 = times of movsw not in rep movsw
%define readcallfar 0x0111 ;; random location in SS
%define magicseg 0x1004


mov si,ax 				;; si = ax
add si,@copy 			;; si = @copy
push ss 				;; push ss value to stack
pop es					;; es = ss
xor di,di				;; reset di in case of zoms
mov cx,copystart 		;; cx = wordsstart
rep movsw				;; copy code to ES (where SS is)

push ss					;; push ss value to stack
pop ds					;; ds = ss

mov al,0xA1				;; ax = closest location ending in 0xA3

mov bx,readcallfar		;; bx = location of where we read call far address
mov [bx],ax 			;; [bx] = address of call far
mov word [bx+0x2],magicseg 	;; [bx+0x2] segment of call far

les di,[bx]				;; di = ax, es = magicseg

push cs				 	;; put value of cs in stack
pop ds					;; ds = cs

mov dx,gap

movsw					;; write call far to the address
movsw

mov cl,copyloop 		;; cx = 0x00words
dec di					;; dx = addrees + 0x1
xor si,si 				;; si = 0x0000

push ss					;; push ss value to stack
pop ds					;; ds = ss

mov ax,magicseg
push ax
pop ss

mov sp,[bx]
sub sp,calldist - 0x6		
;; - 0x2 because we want to write from start of call far, not add sp,dx
;; - 0x4 because call far is first and last to execute

mov ax,gofor

call far [bx]			;; execute call far

;;;;;;;;;;;;;;;;;;;;;;;;;; END OF REGULAR CODE

@copy:
rep movsw				;; write our code

sub [bx],ax	;; change call far place (bx -= ax)

mov di,[bx]				;; di = call far address				

sub word sp,addsp - gap + 0x4
;; - gap because add sp,dx was executed after the call far was overwriten
;; + 0x4 because call far is first and last to act

mov cl,copyloop			;; reset counter for next time we execute "rep movsw" (cx = 0x00words)

dec bp
jz short 0x10

movsw					;; write call far in the next address (address = [bx] = di)

movsw

dec di					;; dx = [bx] + 0x1 (address of call far + 0x1)

xor si,si				;; reset si (si = 0x0000)

call far [bx]			;; execute call far

add sp,dx

call far [bx]

@copy_end:

add sp,dx
call far [bx]			;; will be copied to the call far address
