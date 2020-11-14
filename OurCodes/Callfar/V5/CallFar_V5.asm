%define jumpDist 0x5200
%define callAmount 51
%define gap 0x6
%define calldist ((callAmount * (gap+0x4)) + 0x4)
;%define calldist 0x202
%define addsp jumpDist+calldist
%define copyloop (@loop_end-@loop)/0x2
%define readcallfar 0x0111 ;; random location in SS
%define magicseg 0x1004

;mov ax,calldist
mov si,ax 				;; si = ax
add si,@copy 			;; si = @copy
push ss 				;; push ss value to stack
pop es					;; es = StackSeg
xor di,di				;; reset di in case of zoms
mov cx,(@copy_end-@copy)/2 		;; cx = wordsstart
;; +-1
rep movsw				;; copy code to ES (where SS is)

push ss					;; push ss value to stack
pop ds					;; ds = StackSeg

add ah,0x2
mov al,0xA1				;; ax = closest location ending in 0xA3

mov bx,readcallfar		;; bx = location of where we read call far address
mov [bx],ax 			;; [bx] = address of call far
mov word [bx+0x2],magicseg 	;; [bx+0x2] segment of call far

les di,[bx]				;; di = ax, es = magicseg

push cs				 	;; put value of cs in stack
pop ds					;; ds = Arena

mov dx,gap

movsw					;; write call far to the address
movsw

mov cl,copyloop 		;; cx = 0x00words
sub di,0x3
xor si,si 				;; si = 0x0000

push ss					;; push ss value to stack
pop ds					;; ds = StackSeg

mov ax,magicseg
push ax
pop ss ;; ss = Magic

mov sp,[bx]
add sp,calldist		
;; - 0x2 because we want to write from start of call far, not add sp,dx
;; - 0x4 because call far is first and last to execute

mov ax,jumpDist

call far [bx]			;; execute call far

;;;;;;;;;;;;;;;;;;;;;;;;;; END OF REGULAR CODE

@copy:
rep movsw				;; write our code
@loop:
sub [bx],ax	;; change call far place (bx -= ax)

mov di,[bx]				;; di = call far address				

sub word sp,jumpDist-calldist
;; - gap because add sp,dx was executed after the call far was overwriten
;; + 0x4 because call far is first and last to act

mov cl,copyloop			;; reset counter for next time we execute "rep movsw" (cx = 0x00words)

dec bp
jz short 0x10

movsw					;; write call far in the next address (address = [bx] = di)

movsw

sub di,0x3					;; dx = [bx] + 0x1 (address of call far + 0x1)

xor si,si				;; reset si (si = 0x0000)

call far [bx]			;; execute call far
@loop_end:
sub sp,dx

call far [bx]

@copy_end:

sub sp,dx
call far [bx]			;; will be copied to the call far address
